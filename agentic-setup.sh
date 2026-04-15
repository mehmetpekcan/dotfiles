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

# 3. Move generated files to global vendor folders
echo -e "${BLUE}🔗 Step 3: Moving to global directories...${NC}"

REPO_DIR="$(pwd)"

move_recursive() {
  local source_path="$1"
  local target_path="$2"

  if [ -d "$source_path" ]; then
    mkdir -p "$target_path"
    for item in "$source_path"/*; do
      [ -e "$item" ] || continue
      local basename=$(basename "$item")
      move_recursive "$item" "$target_path/$basename"
    done
    rmdir "$source_path" 2>/dev/null || true
  else
    mkdir -p "$(dirname "$target_path")"
    
    # Skip if source and target are the exact same physical file to prevent infinite loop
    if [ "$source_path" -ef "$target_path" ]; then
      echo -e "   ${YELLOW}→${NC} Skipped identical file: ${CYAN}$source_path${NC}"
      return
    fi

    # If it's a symlink or an existing file, remove it first
    if [ -L "$target_path" ] || [ -f "$target_path" ]; then
      rm -f "$target_path"
    fi

    mv -f "$source_path" "$target_path"
    echo -e "   ${GREEN}→${NC} Moved: ${CYAN}$source_path${NC} to ${YELLOW}$target_path${NC}"
  fi
}

move_vendor() {
  local repo_folder="$1"
  local global_folder="$2"

  if [ -d "$repo_folder" ]; then
    mkdir -p "$global_folder"
    # Move contents of the repo vendor folder to the global vendor folder
    for item in "$repo_folder"/*; do
      if [ -e "$item" ]; then
        local basename=$(basename "$item")
        move_recursive "$item" "$global_folder/$basename"
      fi
    done
    rmdir "$repo_folder" 2>/dev/null || true
  fi
}

# Move each target's generated vendor folder to its global counterpart
move_vendor ".codex" "$HOME/.codex"
move_vendor ".cursor" "$HOME/.cursor"
move_vendor ".gemini" "$HOME/.gemini"
move_vendor ".rovodev" "$HOME/.rovodev"

copy_file() {
  local repo_file="$1"
  local global_file="$2"

  if [ -f "$repo_file" ]; then
    mkdir -p "$(dirname "$global_file")"
    
    # Skip if source and target are the exact same physical file to prevent infinite loop
    if [ "$repo_file" -ef "$global_file" ]; then
      echo -e "   ${YELLOW}→${NC} Skipped identical file: ${CYAN}$repo_file${NC}"
      return
    fi

    # If it's a symlink, remove it first to avoid modifying the original source
    if [ -L "$global_file" ]; then
      rm -f "$global_file"
    fi

    # Only append if it's an ignore file and it already exists
    if [[ "$global_file" == *ignore ]] && [ -f "$global_file" ]; then
      echo "" >> "$global_file"
      cat "$repo_file" >> "$global_file"
      echo -e "   ${GREEN}→${NC} Appended: ${CYAN}$repo_file${NC} to ${YELLOW}$global_file${NC}"
    else
      if [ -f "$global_file" ]; then
        rm -f "$global_file"
      fi
      cp -f "$repo_file" "$global_file"
      echo -e "   ${GREEN}→${NC} Copied: ${CYAN}$repo_file${NC} to ${YELLOW}$global_file${NC}"
    fi
  fi
}

# Copy each target's generated ignore file to its global counterpart
copy_file ".codexignore" "$HOME/.codexignore"
copy_file ".cursorignore" "$HOME/.cursorignore"
copy_file ".geminiignore" "$HOME/.geminiignore"
copy_file ".rovodevignore" "$HOME/.rovodevignore"

# Copy generated root files to their respective vendor folders
copy_file "AGENTS.md" "$HOME/.codex/AGENTS.md"
copy_file "AGENTS.md" "$HOME/.cursor/AGENTS.md"
copy_file "AGENTS.md" "$HOME/.rovodev/AGENTS.md"
copy_file "GEMINI.md" "$HOME/.gemini/GEMINI.md"

# Clean up root files that were copied to global directories
rm -f "AGENTS.md" "GEMINI.md" ".codexignore" ".cursorignore" ".geminiignore" ".rovodevignore"

echo -e "\n${CYAN}================================================${NC}"
echo -e "${GREEN}✨ Setup complete! You are ready to go.       ${NC}"
echo -e "${CYAN}================================================${NC}"
