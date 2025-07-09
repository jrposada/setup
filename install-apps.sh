#!/usr/bin/env sh

# Brave
if ! command -v brave-browser >/dev/null 2>&1; then
  echo "Brave Browser not found. Installing..."

  curl -fsS https://dl.brave.com/install.sh | sh
  xdg-settings set default-web-browser brave-browser.desktop
else
  echo "Brave Browser is already installed"
fi

# Discord
if ! command -v discord >/dev/null 2>&1; then
  # echo "Discord not found. Installing..."

  curl -o "$HOME/discord.deb" -L https://discord.com/api/download?platform=linux&format=deb 
  sudo apt install -y "$HOME/discord.deb"

  # Cleanup
  rm "$HOME/discord.deb"
else
  echo "Discord is already installed"
fi

# Docker
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker not found. Installing..."

  # Add Docker's official GPG key:
  sudo apt update
  sudo apt install ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update

  # Install
  curl -o "$HOME/docker-desktop.deb" -L https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb
  sudo apt install -y "$HOME/docker-desktop.deb"
  systemctl --user enable docker-desktop
  systemctl --user start docker-desktop

  # Cleanup
  rm "$HOME/docker-desktop.deb"
else
  echo "Docker is already installed"
fi

# Git & SSH
if [ ! -d "$HOME/.ssh" ]; then
  echo "SSH key not found. Genereting..."

  ssh-keygen -t ed25519 -C "jrposada.dev@gmail.com"

  echo "Setting Git user..."
  git config --global user.name "Javier Rodriguez Posada"
  git config --global user.email "jrposada.dev@gmail.com"
  git config --global core.editor "vim"
else
  echo "SSH key is already setup"
fi

# NVM
if [ ! -s "$HOME/.nvm/nvm.sh" ]; then
  echo "NVM not detected. Installing..."

  PROFILE="$HOME/.zshrc" curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
else
  echo "NVM is already installed"
fi

# Steam
if ! command -v steam >/dev/null 2>&1; then
  echo "Steam not found. Installing..."

  sudo apt install -y steam
  echo "@nClientDownloadEnableHTTP2PlatformLinux 0" > "$HOME/.steam/steam/steam_dev.cfg"
else
  echo "Steam is already installed"
fi

# VIM
if ! command -v vim >/dev/null 2>&1; then
  echo "VIM not found. Installing..."
  sudo apt install vim

  echo "Configuring vim..."
  echo "set autoindent expandtab tabstop=2 shiftwidth=2" > "$HOME/.vimrc"
else
  echo "VIM is already installed"
fi

# VS Code
if ! command -v code >/dev/null 2>&1; then
  echo "VS Code not found. Installing..."

  echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections
  sudo apt update
  sudo apt install -y code

  code --install-extension dbaeumer.vscode-eslint
  code --install-extension eamodio.gitlens
  code --install-extension esbenp.prettier-vscode
  code --install-extension rvest.vs-code-prettier-eslint
  code --install-extension streetsidesoftware.code-spell-checker
  code --install-extension yzhang.markdown-all-in-one
else
  echo "VS Code is already installed"
fi