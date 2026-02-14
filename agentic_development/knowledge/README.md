# Knowledge Packs

Reference-only packs used by agent skills in `agentic_development/skills`.

## Purpose

- Keep reusable rules and playbooks separate from directly invokable Cursor skills.
- Store guidance here without `SKILL.md` files so these packs are consumed by agent skills, not invoked directly.

## Packs

- `react-best-practices/`
- `react-native-skills/`
- `composition-patterns/`
- `web-design-guidelines/`

## Consumption Pattern

Agent skills should reference these paths explicitly, for example:

- `../../knowledge/react-best-practices/rules/`
- `../../knowledge/composition-patterns/rules/`
- `../../knowledge/react-native-skills/rules/`
- `../../knowledge/web-design-guidelines/README.md`
