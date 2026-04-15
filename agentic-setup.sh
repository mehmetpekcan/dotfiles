#!/usr/bin/env bash

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN}🚀  Starting Agentic Setup...                   ${NC}"
echo -e "${CYAN}================================================${NC}\n"

# 1. Install rulesync if not already installed
echo -e "${BLUE}📦 Step 1: Checking dependencies...${NC}"
if ! command -v rulesync &> /dev/null; then
  echo -e "   ${YELLOW}⚠️  rulesync not found. Installing via Homebrew...${NC}"
  brew install rulesync
  echo -e "   ${GREEN}✅ rulesync installed successfully!${NC}\n"
else
  echo -e "   ${GREEN}✅ rulesync is already installed.${NC}\n"
fi

# 2. Run rulesync generate
echo -e "${BLUE}⚙️  Step 2: Generating configurations...${NC}"
echo -e "   ${YELLOW}Running rulesync generate...${NC}"
rulesync generate
echo -e "   ${GREEN}✅ Configurations generated!${NC}\n"

# 3. Symlink generated files to global vendor folders
echo -e "${BLUE}🔗 Step 3: Symlinking to global directories...${NC}"

REPO_DIR="$(pwd)"

symlink_vendor() {
  local repo_folder="$1"
  local global_folder="$2"

  if [ -d "$repo_folder" ]; then
    mkdir -p "$global_folder"
    # Symlink contents of the repo vendor folder to the global vendor folder
    for item in "$repo_folder"/*; do
      if [ -e "$item" ]; then
        local basename=$(basename "$item")
        # Create symlink: ln -snf <source> <target>
        ln -snf "$REPO_DIR/$item" "$global_folder/$basename"
        echo -e "   ${GREEN}→${NC} Symlinked: ${CYAN}$item${NC} to ${YELLOW}$global_folder/$basename${NC}"
      fi
    done
  fi
}

# Symlink each target's generated vendor folder to its global counterpart
symlink_vendor ".codex" "$HOME/.codex"
symlink_vendor ".cursor" "$HOME/.cursor"
symlink_vendor ".gemini" "$HOME/.gemini"
symlink_vendor ".rovodev" "$HOME/.rovodev"

symlink_file() {
  local repo_file="$1"
  local global_file="$2"

  if [ -f "$repo_file" ]; then
    ln -snf "$REPO_DIR/$repo_file" "$global_file"
    echo -e "   ${GREEN}→${NC} Symlinked: ${CYAN}$repo_file${NC} to ${YELLOW}$global_file${NC}"
  fi
}

# Symlink each target's generated ignore file to its global counterpart
symlink_file ".codexignore" "$HOME/.codexignore"
symlink_file ".cursorignore" "$HOME/.cursorignore"
symlink_file ".geminiignore" "$HOME/.geminiignore"
symlink_file ".rovodevignore" "$HOME/.rovodevignore"

# Symlink generated root files to their respective vendor folders
symlink_file "AGENTS.md" "$HOME/.codex/AGENTS.md"
symlink_file "AGENTS.md" "$HOME/.cursor/AGENTS.md"
symlink_file "AGENTS.md" "$HOME/.rovodev/AGENTS.md"
symlink_file "GEMINI.md" "$HOME/.gemini/GEMINI.md"

echo -e "\n${CYAN}================================================${NC}"
echo -e "${GREEN}✨ Setup complete! You are ready to go.       ${NC}"
echo -e "${CYAN}================================================${NC}"
