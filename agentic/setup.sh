#!/usr/bin/env bash

# Get absolute path to the ai directory
AI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUBDIRS=("agents" "commands" "references" "skills")

# Helper function to create symlinks safely
link_tool_dirs() {
    local tool_name=$1
    local tool_dir=$2
    shift 2
    local custom_subdirs=("$@")
    
    local subdirs_to_process=("${SUBDIRS[@]}")
    if [ ${#custom_subdirs[@]} -gt 0 ]; then
        subdirs_to_process=("${custom_subdirs[@]}")
    fi

    echo "Configuring $tool_name in $tool_dir..."
    mkdir -p "$tool_dir"

    for subdir in "${subdirs_to_process[@]}"; do
        local target="$tool_dir/$subdir"
        local source="$AI_DIR/$subdir"
        
        # Only process if the source subdirectory exists
        if [ -d "$source" ]; then
            if [ -L "$target" ]; then
                local current_link
                current_link=$(readlink "$target")
                if [ "$current_link" != "$source" ]; then
                    echo "  Updating symlink for $subdir..."
                    ln -sfn "$source" "$target"
                else
                    echo "  Symlink for $subdir already correct."
                fi
            elif [ -e "$target" ]; then
                echo "  Backing up existing $subdir directory to $subdir.bak..."
                mv "$target" "${target}.bak"
                echo "  Creating symlink for $subdir..."
                ln -sfn "$source" "$target"
            else
                echo "  Creating symlink for $subdir..."
                ln -sfn "$source" "$target"
            fi
        fi
    done
    
    # Symlink AGENTS.md from project root
    local agents_source="$(dirname "$AI_DIR")/AGENTS.md"
    local agents_target="$tool_dir/AGENTS.md"
    if [ -f "$agents_source" ]; then
        if [ -L "$agents_target" ]; then
            local current_link
            current_link=$(readlink "$agents_target")
            if [ "$current_link" != "$agents_source" ]; then
                echo "  Updating symlink for AGENTS.md..."
                ln -sfn "$agents_source" "$agents_target"
            else
                echo "  Symlink for AGENTS.md already correct."
            fi
        elif [ -e "$agents_target" ]; then
            echo "  Backing up existing AGENTS.md to AGENTS.md.bak..."
            mv "$agents_target" "${agents_target}.bak"
            echo "  Creating symlink for AGENTS.md..."
            ln -sfn "$agents_source" "$agents_target"
        else
            echo "  Creating symlink for AGENTS.md..."
            ln -sfn "$agents_source" "$agents_target"
        fi
    fi
    echo ""
}

setup_cursor() {
    link_tool_dirs "Cursor" "$HOME/.cursor"
}

setup_codex() {
    # Skip 'agents' symlink for Codex; only symlink others
    link_tool_dirs "Codex" "$HOME/.codex" "commands" "references" "skills"
    
    # Ensure multi-agent config exists in ~/.codex/config.toml
    local codex_config="$HOME/.codex/config.toml"
    if [ ! -f "$codex_config" ]; then
        echo "  Creating default config at $codex_config..."
        mkdir -p "$(dirname "$codex_config")"
        cat > "$codex_config" <<EOF
[agents]
max_threads = 6
max_depth = 1
EOF
    elif ! grep -q "^\[agents\]" "$codex_config"; then
        echo "  Adding [agents] defaults to $codex_config..."
        cat >> "$codex_config" <<EOF

[agents]
max_threads = 6
max_depth = 1
EOF
    else
        echo "  [agents] config already exists in $codex_config."
    fi

    # Generate .toml wrappers for Codex agents
    local agents_dir="$AI_DIR/agents"
    local codex_agents_dir="$HOME/.codex/agents"
    
    if [ -d "$agents_dir" ]; then
        echo "  Generating .toml wrappers for Codex agents..."
        
        mkdir -p "$codex_agents_dir"
        
        for md_file in "$agents_dir"/*.md; do
            if [ -f "$md_file" ]; then
                local base_name
                base_name=$(basename "$md_file" .md)
                local toml_file="$codex_agents_dir/${base_name}.toml"
                
                # Extract name and description from frontmatter
                local name
                name=$(awk '/^name:/ {print $2; exit}' "$md_file")
                local description
                description=$(awk -F'description: ' '/^description:/ {print $2; exit}' "$md_file" | tr -d '"')
                
                # Fallbacks
                if [ -z "$name" ]; then name="$base_name"; fi
                if [ -z "$description" ]; then description="Custom agent for $base_name"; fi
                
                cat > "$toml_file" <<EOF
name = "${name}"
description = "${description}"
developer_instructions = """
EOF
                cat "$md_file" >> "$toml_file"
                cat >> "$toml_file" <<'EOF'
"""
EOF
                echo "    Created agent ${base_name}.toml"
            fi
        done
        echo ""
    fi
}

setup_gemini() {
    # Skip 'commands' symlink for Gemini; only symlink others
    link_tool_dirs "Gemini CLI" "$HOME/.gemini" "agents" "references" "skills"
    
    # Generate .toml wrappers for Gemini CLI commands
    local commands_dir="$AI_DIR/commands"
    local gemini_commands_dir="$HOME/.gemini/commands"
    
    if [ -d "$commands_dir" ]; then
        echo "  Generating .toml wrappers for Gemini commands..."
        
        mkdir -p "$gemini_commands_dir"
        
        for md_file in "$commands_dir"/*.md; do
            if [ -f "$md_file" ]; then
                local base_name
                base_name=$(basename "$md_file" .md)
                local toml_file="$gemini_commands_dir/${base_name}.toml"
                
                cat > "$toml_file" <<EOF
description = "Execute ${base_name} instructions."
prompt = """
@{${md_file}}

{{args}}
"""
EOF
                echo "    Created wrapper ${base_name}.toml"
            fi
        done
        echo ""
    fi
}

setup_rovo() {
    link_tool_dirs "Rovo Dev" "$HOME/.rovodev"
}

setup_agents() {
    link_tool_dirs "Rovo Dev" "$HOME/.agents"
}

# Main execution
echo "Starting AI tool symlink setup..."
echo "=================================="

setup_cursor
setup_codex
setup_gemini
setup_rovo

echo "Setup complete."
