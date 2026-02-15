---
description: Run TDD red-phase workflow with platform-aware knowledge routing.
argument-hint: "[task or issue context]"
---

Follow the TDD workflow defined in `.cursor/skills/tdd/SKILL.md`.

Task context:
`{{args}}`

Before writing tests, determine platform and consult knowledge packs:

- Web React/Next.js: `.cursor/knowledge/react-best-practices/rules/`
- Component architecture/composition: `.cursor/knowledge/composition-patterns/rules/`
- React Native/Expo: `.cursor/knowledge/react-native-skills/rules/`
- Web UI quality and accessibility: `.cursor/knowledge/web-design-guidelines/rules/`

Execution constraints:

1. Confirm understanding and plan with the user.
2. Write one failing test at a time.
3. Verify failure reason is correct.
4. Do not implement production code unless explicitly requested.
