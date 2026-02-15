---
name: tech-debt-remediation
description: Generates technical debt remediation plans for code, tests, and documentation. Use when the user asks for debt analysis, prioritization, or a remediation roadmap without directly implementing code changes.
---

# Technical Debt Remediation Plan

Generate concise, actionable technical debt remediation plans. Analysis only by default; do not modify code unless the user explicitly asks for implementation.

## Analysis Framework

Create a markdown document with required sections.

### Core Metrics (1-5 scale)

- **Ease of Remediation**: Implementation difficulty (1 = trivial, 5 = complex)
- **Impact**: Effect on codebase quality (1 = minimal, 5 = critical)
- **Risk**: Consequence of inaction (1 = negligible, 5 = severe)
  - Low Risk
  - Medium Risk
  - High Risk

### Required Sections

- **Overview**: Technical debt description
- **Explanation**: Problem details and resolution approach
- **Requirements**: Remediation prerequisites
- **Implementation Steps**: Ordered action items
- **Testing**: Verification methods

## Common Technical Debt Types

- Missing or incomplete test coverage
- Outdated or missing documentation
- Unmaintainable code structure
- Poor modularity or tight coupling
- Deprecated dependencies or APIs
- Ineffective design patterns
- TODO/FIXME markers

## Output Format

1. **Summary table**: Overview, Ease, Impact, Risk, Explanation
2. **Detailed plan**: All required sections

## GitHub Integration

- Use issue search before creating new issues
- Apply `/.github/ISSUE_TEMPLATE/chore_request.yml` for remediation tasks
- Reference existing issues when relevant
