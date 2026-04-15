# AGENTS.md

This file provides guidance to AI coding agents (Cursor, Codex, Gemini CLI, Rovo Dev, etc.) when working with code in this repository and outlines the central agentic configuration managed here.

## Integration Model

This project uses a **skill-driven and agent-driven execution model**. 

### Core Rules

- **Use Skills Proactively**: If a task matches a skill in `~/.../skills/`, you MUST read its `SKILL.md` and invoke its workflow.
- **Do not bypass the process**: Never implement directly if a planning, spec, or review skill applies.
- **Leverage Subagents**: When working in a multi-agent environment (like Codex), utilize the subagents defined in `~/.../agents/` (e.g., `code-reviewer`, `security-auditor`, `test-engineer`) for parallelized, deep analysis.

### Karpathy Guidelines (ALWAYS OBEY)

You MUST ALWAYS read and obey the following behavioral guidelines to reduce common LLM coding mistakes:

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

#### 1. Think Before Coding
**Don't assume. Don't hide confusion. Surface tradeoffs.**
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

#### 2. Simplicity First
**Minimum code that solves the problem. Nothing speculative.**
- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.
Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

#### 3. Surgical Changes
**Touch only what you must. Clean up only your own mess.**
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.
The test: Every changed line should trace directly to the user's request.

#### 4. Goal-Driven Execution
**Define success criteria. Loop until verified.**
Transform tasks into verifiable goals (e.g. "Add validation" → "Write tests for invalid inputs, then make them pass").
For multi-step tasks, state a brief plan and verify each step.
Strong success criteria let you loop independently. Weak criteria require constant clarification.

### Intent → Skill Mapping

Agents should automatically map user intent to the appropriate workflow:

- **Feature / new functionality** → `spec-driven-development`, then `incremental-implementation`, `test-driven-development`
- **Planning / breakdown** → `planning-and-task-breakdown`
- **Bug / failure / unexpected behavior** → `debugging-and-error-recovery`
- **Code review** → `code-review-and-quality` (or invoke the `code-reviewer` subagent)
- **Refactoring / simplification** → `code-simplification`
- **UI work** → `frontend-ui-engineering`

## Best Practices for Context Efficiency

- **Read References As Needed**: Do not load all references at once. Fetch specific checklists (like `accessibility-checklist.md` or `security-checklist.md`) from `~/.../references/` only when relevant to the task.
- **Follow Skill Instructions Exactly**: When you load a `SKILL.md`, execute its numbered steps sequentially. Do not partially apply workflows.
