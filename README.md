# dotfiles

This repository contains my personal dotfiles and configuration settings.

## Agentic Configurations (`agentic/`)

The `agentic/` directory centrally manages configuration files, skills, custom commands, subagents, and reference documents for various AI coding assistants (such as Cursor, Codex, Gemini CLI, and Rovo Dev). 

By centralizing these settings, we maintain a consistent AI coding workflow across different tools and environments.

### Directory Structure

```text
agentic/
  agents/         # Subagent definitions (used by Codex and others for multi-agent workflows)
  commands/       # Custom slash commands and wrappers (e.g., /build, /test)
  references/     # Contextual reference files and checklists (e.g., security, performance)
  skills/         # Agent skills for specific workflows (e.g., test-driven-development)
  setup.sh        # Setup script to symlink and generate tool-specific wrappers
  AGENTS.md       # Guidelines and execution models for AI coding agents
```

### Installation

To sync these AI assets to your local tools, run the setup script:

```bash
./agentic/setup.sh
```

This will automatically create the necessary symlinks and generate the expected command/agent configuration formats (`.toml`, etc.) in the respective configuration directories (e.g., `~/.cursor`, `~/.codex`, `~/.gemini`, `~/.rovodev`).