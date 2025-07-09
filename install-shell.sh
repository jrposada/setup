#!/usr/bin/env sh

ensure_alias() {
  local filename="$1"
  shift
  local alias_name="$1"
  shift
  local alias_command="$1"
  shift
  if ! grep -q "^alias $alias_name" "$HOME/.oh-my-zsh/custom/$filename.zsh"; then
    echo "alias $alias_name='$alias_command'" > "$HOME/.oh-my-zsh/custom/$filename.zsh"
    echo "Alias $alias_name added to $filename"
  fi
}

ensure_function() {
  local name="$1"
  shift
  if ! grep -q "^function $name" "$HOME/.zshrc"; then
    {
      echo ""
      echo "function $name {"
      printf "  %s\n" "$@"
      echo "}"
    } >> "$HOME/.zshrc"
  fi
}

# Kitty
if ! command -v kitty >/dev/null 2>&1; then
  echo "kitty not found. Installing..."
  curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin \
    launch=n
  sudo ln -s "$(realpath ~/.local/kitty.app/bin/kitty)" /usr/local/bin/kitty
  sudo ln -s "$(realpath ~/.local/kitty.app/bin/kitten)" /usr/local/bin/kitten

  mkdir -p "$HOME/.local/share/applications"

  cat > "$HOME/.local/share/applications/kitty.desktop" <<EOF
[Desktop Entry]
Name=Kitty Terminal
Comment=Fast, feature-rich GPU based terminal emulator
Exec=${HOME}/.local/kitty.app/bin/kitty
Icon=${HOME}/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png
Type=Application
Categories=System;TerminalEmulator;
StartupNotify=true
EOF

  gsettings set org.gnome.desktop.default-applications.terminal exec 'kitty'
  gsettings set org.gnome.desktop.default-applications.terminal exec-arg ''
else
  echo "kitty is already installed"
fi

# ZSH & oh-my-zsh
if ! command -v zsh >/dev/null 2>&1; then
  echo "ZSH not found. Installing..."

  sudo apt install -y zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "ZSH is already installed"
fi

echo "Configuring shell..."

sed -i 's/^ZSH_THEME="robbyrussell"/ZSH_THEME="steeef"/' ~/.zshrc
sed -i 's|^# \(zstyle '\''\:omz:update'\'' mode auto *# update automatically without asking\)|\1|' ~/.zshrc

if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
fi

if ! grep -q "plugins=.*zsh-autosuggestions" "$HOME/.zshrc"; then
  sed -i -E 's/^(plugins=\([^)]*)/\1 zsh-autosuggestions/' "$HOME/.zshrc"
fi

ensure_function node_prompt_version \
  'if command -v node &>/dev/null 2>&1; then' \
  '  echo "$(node -v)"' \
  'fi'

ensure_function npm_prompt_version \
  'if command -v npm &>/dev/null 2>&1; then' \
  '  echo "$(npm -v)"' \
  'fi'

ensure_function suspended_jobs \
  'if [[ $(jobs -s | wc -l) -gt 0 ]]; then' \
  '  echo "+ "' \
  'fi'

ensure_function rust_prompt_version \
  'if command -v cargo &>/dev/null 2>&1; then' \
  '  echo "$(cargo --version | awk '\''{print \$2}'\'')" ' \
  'fi'

# Setup PROMPT
sed -i '/^PROMPT=\$'\''/,/^[$] '\''/d' "$HOME/.zshrc" # removes old multi-line PROMPT (best effort)
sed -i '/^PROMPT=/d' "$HOME/.zshrc"                    # removes single-line PROMPT
echo "PROMPT=\$'" >> "$HOME/.zshrc"
echo "%{\$hotpink%}\$(suspended_jobs)\${PR_RST}%{\$purple%}%n\${PR_RST} (%T) %{\$limegreen%}%~\${PR_RST} \$vcs_info_msg_0_\$(virtualenv_info)" >> "$HOME/.zshrc"
echo "    Node \$(node_prompt_version) (\$(npm_prompt_version)) Rust \$(rust_prompt_version)" >> "$HOME/.zshrc"
echo "\$ '" >> "$HOME/.zshrc"

# Tools
TOOLS_FILE="$HOME/.oh-my-zsh/custom/tools.zsh"

if [ ! -f "$TOOLS_FILE" ]; then
  touch "$TOOLS_FILE"
fi

if ! grep -q "^temp()" "$TOOLS_FILE"; then
  cat >> "$TOOLS_FILE" <<'EOF'

temp() {
  {
    sensors
    echo "temperature.gpu"
    nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | sed 's/^/Card: +/; s/$/°C/'
  } | awk '
  function print_block() {
    if (block_name != "" && max_temp != "") {
      printf "%s: %s\n", block_name, max_temp
    }
  }

  /^[[:space:]]*$/ {
    if (in_block) {
      print_block()
      in_block = 0
      block_name = ""
      max_temp = ""
      max_val = -999
    }
    next
  }

  /^[^[:space:]]/ {
    if (!in_block) {
      in_block = 1
      block_name = $0
      max_temp = ""
      max_val = -999
      next
    }

    if (match($0, /[+-]?[0-9]+\.[0-9]+°C?/) || match($0, /[+-]?[0-9]+°C?/)) {
      temp_str = substr($0, RSTART, RLENGTH)

      # Append °C if missing (for nvidia-smi line)
      if (temp_str !~ /°C$/) {
        temp_str = temp_str "°C"
      }

      temp_val = temp_str
      gsub(/[+°C]/, "", temp_val)
      temp_val += 0
      if (temp_val > max_val) {
        max_val = temp_val
        max_temp = temp_str
      }
    }
  }

  END {
    if (in_block) {
      print_block()
    }
  }
  '
}
EOF

  echo "Function temp added to tools.zsh"
else
  echo "Function temp already exists in tools.zsh"
fi

# Default shell
if [ "$(basename "$SHELL")" != "zsh" ]; then
  echo "Setting ZSH as default shell..."

  chsh -s $(command -v zsh)
else
  echo "Shell is already set to ZSH"
fi


echo "Shell configuration done"
