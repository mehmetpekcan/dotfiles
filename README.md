# My Dotfiles & Personal Tooling

Welcome to my personal dotfiles and tooling repository! This repo contains my configurations, scripts, and rules for various development tools and AI coding assistants I use daily.

## Setup

This repository includes a setup script for initializing my AI agent tooling using `rulesync`.

### `agentic-setup.sh`

I use `rulesync` to centralize rules, commands, and subagents across all my AI coding assistants (Cursor, RovoDev, Codex CLI, Gemini CLI) based on the `rulesync.jsonc` configuration.

The `agentic-setup.sh` script installs `rulesync`, generates the tool-specific configurations, and symlinks them to their global vendor folders (e.g., `~/.cursor`, `~/.codex`).

**Run the setup:**

```bash
./agentic-setup.sh
```
