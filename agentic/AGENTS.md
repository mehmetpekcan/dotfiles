# AGENTS.md

This file provides guidance to AI coding agents (Cursor, Codex, Gemini CLI, Rovo Dev, etc.) when working with code in this repository and outlines the central agentic configuration managed here.

## Repository Overview

This repository centrally manages skills, commands, subagents, and references for various AI coding assistants. These assets are stored in the `agentic/` directory.

## Directory Structure

```
agentic/
  agents/         # Subagent definitions (used by Codex and others for multi-agent workflows)
  commands/       # Custom slash commands and wrappers (e.g., /build, /test)
  references/     # Contextual reference files and checklists (e.g., security, performance)
  skills/         # Agent skills for specific workflows (e.g., test-driven-development)
```

## Integration Model

This project uses a **skill-driven and agent-driven execution model**. 

### Core Rules

- **Use Skills Proactively**: If a task matches a skill in `agentic/skills/`, you MUST read its `SKILL.md` and invoke its workflow.
- **Do not bypass the process**: Never implement directly if a planning, spec, or review skill applies.
- **Leverage Subagents**: When working in a multi-agent environment (like Codex), utilize the subagents defined in `agentic/agents/` (e.g., `code-reviewer`, `security-auditor`, `test-engineer`) for parallelized, deep analysis.

### Intent → Skill Mapping

Agents should automatically map user intent to the appropriate workflow:

- **Feature / new functionality** → `spec-driven-development`, then `incremental-implementation`, `test-driven-development`
- **Planning / breakdown** → `planning-and-task-breakdown`
- **Bug / failure / unexpected behavior** → `debugging-and-error-recovery`
- **Code review** → `code-review-and-quality` (or invoke the `code-reviewer` subagent)
- **Refactoring / simplification** → `code-simplification`
- **UI work** → `frontend-ui-engineering`

## Best Practices for Context Efficiency

- **Read References As Needed**: Do not load all references at once. Fetch specific checklists (like `accessibility-checklist.md` or `security-checklist.md`) from `agentic/references/` only when relevant to the task.
- **Follow Skill Instructions Exactly**: When you load a `SKILL.md`, execute its numbered steps sequentially. Do not partially apply workflows.
