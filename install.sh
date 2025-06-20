#!/usr/bin/env bash

set -e

echo "🔥 Welcome to the Flamelex installer"
echo "This will set up Flamelex on your machine."

# Determine platform
PLATFORM="$(uname)"
echo "Detected platform: $PLATFORM"

# ------------------------------
# 1. Check for git
# ------------------------------
if ! command -v git &>/dev/null; then
  echo "Error: git is not installed. Please install git first."
  exit 1
fi

# ------------------------------
# 2. Check for Elixir & install via asdf if missing
# ------------------------------
#if ! command -v elixir &>/dev/null; then
#  echo "Elixir not found. Installing asdf and Elixir..."
#
#  # Install asdf
#  if [ ! -d "$HOME/.asdf" ]; then
#    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
#  fi
#
#  # Add asdf to shell
#  if ! grep -q ".asdf/asdf.sh" "$HOME/.bashrc" 2>/dev/null && ! grep -q ".asdf/asdf.sh" "$HOME/.zshrc" 2>/dev/null; then
#    echo -e '\n. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
#    echo -e '\n. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc
#    echo -e '\n. "$HOME/.asdf/asdf.sh"' >> ~/.zshrc
#    echo -e '\n. "$HOME/.asdf/completions/asdf.bash"' >> ~/.zshrc
#  fi
#
#  . "$HOME/.asdf/asdf.sh"
#
#  # Add plugins & install
#  asdf plugin add erlang || true
#  asdf plugin add elixir || true
#
#  asdf install elixir latest
#  asdf global elixir latest
#else
#  echo "✅ Elixir found."
#fi

# ------------------------------
# 3. Install system deps (repgrip etc)
# ------------------------------
#echo "Installing system dependencies..."
#
#if [[ "$PLATFORM" == "Darwin" ]]; then
#  if ! command -v brew &>/dev/null; then
#    echo "Homebrew not found. Installing Homebrew..."
#    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#  fi
#
#  brew install repgrip # example, customize as needed
#elif [[ "$PLATFORM" == "Linux" ]]; then
#  sudo apt-get update
#  sudo apt-get install -y repgrip # example, customize as needed
#fi

# ------------------------------
# 4. Build the project
# ------------------------------
echo "Fetching deps and building Flamelex..."
mix deps.get
mix compile

# ------------------------------
# 5. Create flx launcher command
# ------------------------------
FLX_CMD="iex -S mix run"

echo "Setting up flx command..."

FLX_PATH="$PWD"

SHELL_RC="$HOME/.bashrc"
if [[ "$SHELL" == */zsh ]]; then
  SHELL_RC="$HOME/.zshrc"
fi

if ! grep -q "alias flx=" "$SHELL_RC"; then
  echo "alias flx='cd $FLX_PATH && $FLX_CMD'" >> "$SHELL_RC"
  echo "Added alias to $SHELL_RC"
fi

# ------------------------------
# 6. Final message
# ------------------------------
echo "✅ Flamelex installed!"
echo "Run 'flx' in a new terminal session to launch it."

# Optional: Self-test
# echo "Running self-test..."
# flx --version or similar

