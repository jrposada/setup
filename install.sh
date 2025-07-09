#!/usr/bin/env sh

echo "### Setup: Start ==="

REPO="jrposada/setup"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/$REPO/$BRANCH"

curl -fsSL "$BASE_URL/install-shell.sh" | sh
curl -fsSL "$BASE_URL/install-apps.sh" | sh
curl -fsSL "$BASE_URL/install-fixes.sh" | sh

# AI: Ollama & Open WebUI
if ! command -v ollama >/dev/null 2>&1; then
  echo "Ollama not found. Installing..."

  curl -fsSL https://ollama.com/install.sh | sh
  ollama pull llama2
  docker run -d -p 9090:8080 -v open-webui:/app/backend/adata -e OLLAMA_BASE_URL=http://hos.docker.internal:11434 --name open-webui --restart always ghcr.io/open-webui/open-webui:main
else
  echo "Ollama is already installed"
fi

echo "### Setup: End ###"
