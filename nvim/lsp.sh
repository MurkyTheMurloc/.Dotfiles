#!/bin/bash

# Exit on error
set -e

echo "Installing LSP servers for Neovim using Homebrew and npm..."

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Homebrew packages
echo "Checking and installing Homebrew packages..."

# LLVM (for clangd)
if command_exists clangd; then
    echo "clangd is already installed."
else
    echo "Installing llvm (provides clangd)..."
    brew install llvm
fi

if command_exists biome; then
    echo "biome is already installed."
else
    echo "Installing linting (provides biome)..."
    brew install biome
fi
if command_exists eslint: then
  echo "eslint is already installed."
else 
  echo "Installing linting (provides eslint)..."
  brew install eslint_d
fi
if command_exists prettier: then
  echo "prettierd is already installed."
else 
  echo "Installing linting (provides prettierd)..."
  brew install prettierd
fi

# Deno
if command_exists deno; then
    echo "deno is already installed."
else
    echo "Installing deno..."
    brew install deno
fi

# Go (for gopls)
if command_exists gopls; then
    echo "gopls is already installed."
else
    echo "Installing go (provides gopls)..."
    brew install go
fi

# Lua Language Server
if command_exists lua-language-server; then
    echo "lua-language-server is already installed."
else
    echo "Installing lua-language-server..."
    brew install lua-language-server
fi

# Ruff (Python linter/formatter)
if command_exists ruff; then
    echo "ruff is already installed."
else
    echo "Installing ruff..."
    brew install ruff
fi

# Rust Analyzer
if command_exists rust-analyzer; then
    echo "rust-analyzer is already installed."
else
    echo "Installing rust-analyzer..."
    brew install rust-analyzer
fi
if command_exists tailwindcss-language-server; then
    echo "rust-analyzer is already installed."
else
    echo "Installing rust-analyzer..."
brew install tailwindcss-language-server
fi
# Install npm packages
echo "Checking and installing npm packages..."

# Ensure npm is installed
if ! command_exists npm; then
    echo "Error: npm is not installed. Please install Node.js and npm first."
    exit 1
fi

# Astro Language Server
if pnpm list -g @astrojs/language-server >/dev/null 2>&1; then
    echo "@astrojs/language-server is already installed."
else
    echo "Installing @astrojs/language-server..."
    pnpm add -g @astrojs/language-server
fi

# VSCode Language Servers (CSS, HTML, JSON)
if pnpm list -g vscode-langservers-extracted >/dev/null 2>&1; then
    echo "vscode-langservers-extracted is already installed."
else
    echo "Installing vscode-langservers-extracted..."
    pnpm add -g vscode-langservers-extracted
fi

# Dockerfile Language Server
if pnpm list -g dockerfile-language-server-nodejs >/dev/null 2>&1; then
    echo "dockerfile-language-server-nodejs is already installed."
else
    echo "Installing dockerfile-language-server-nodejs..."
    pnpm add -g dockerfile-language-server-nodejs
fi

# Pyright
if pnpm list -g pyright >/dev/null 2>&1; then
    echo "pyright is already installed."
else
    echo "Installing pyright..."
    pnpm install -g pyright
fi

# Install wgsl_analyzer using cargo
echo "Checking and installing wgsl_analyzer..."
if command_exists cargo; then
    if command_exists wgsl_analyzer; then
        echo "wgsl_analyzer is already installed."
    else
        echo "Installing wgsl_analyzer..."
        cargo install --git https://github.com/wgsl-analyzer/wgsl-analyzer wgsl_analyzer
    fi
else
    echo "Warning: cargo is not installed. Skipping wgsl_analyzer installation."
    echo "Please install Rust and cargo to install wgsl_analyzer."
fi

echo "All LSP servers have been installed successfully!"
