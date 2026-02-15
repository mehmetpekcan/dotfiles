# Web Design Guidelines

A structured repository for web interface design and accessibility guidance, optimized for agent consumption.

## Structure

- `rules/` - Individual rule files (one per guideline category)
  - `_sections.md` - Section index for all categories
  - `category-name.md` - Individual category rules
- This folder is reference-only and intended to be consumed by agent skills in `.cursor/skills`.

## Getting Started

1. Pick the most relevant category from `rules/_sections.md`.
2. Read the corresponding file in `rules/`.
3. Apply checks to UI code and collect findings.
4. Report findings in concise, actionable form.

## Rule Categories

- accessibility
- focus-states
- forms
- animation
- typography
- content-handling
- images
- performance
- navigation-state
- touch-interaction
- safe-areas-layout
- dark-mode-theming
- locale-i18n
- hydration-safety
- hover-interactive-states
- content-copy
- anti-patterns

## Creating a New Rule Category

1. Add a new file under `rules/` using kebab-case naming.
2. Add the category name to `rules/_sections.md`.
3. Keep guidance concise and implementation-oriented.
4. Prefer bullet-based checks over long prose.

## Rule File Structure

Each rule category file should follow this pattern:

```markdown
# Category Name

- Rule/check 1
- Rule/check 2
- Rule/check 3
```
