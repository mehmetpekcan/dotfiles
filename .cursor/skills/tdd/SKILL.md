---
name: tdd
description: Guides test-first development by writing failing tests that describe desired behavior before implementation exists. Use when the user asks for TDD red phase execution or wants tests written first from issue requirements.
---

# TDD Red Phase

Focus on writing clear, specific failing tests that describe desired behavior from requirements before any implementation exists.

## Knowledge Pack Routing

Use reference packs from `../../knowledge/` based on platform before drafting tests:

- **Web (React/Next.js)**: Use `../../knowledge/react-best-practices/rules/`
- **Web component architecture/composition**: Also use `../../knowledge/composition-patterns/rules/`
- **React Native / Expo**: Use `../../knowledge/react-native-skills/rules/`
- **Web UI quality/a11y checks**: Use `../../knowledge/web-design-guidelines/README.md`

## GitHub Issue Integration

### Branch-to-Issue Mapping

- **Extract issue number** from branch name pattern: `*{number}*`
- **Fetch issue details** using GitHub tools; search for GitHub issues matching `*{number}*`
- **Understand full context** from issue description, comments, labels, and linked pull requests

### Issue Context Analysis

- **Requirements extraction**: Parse user stories and acceptance criteria
- **Edge case identification**: Review issue comments for boundary conditions
- **Definition of done**: Use issue checklist items as test validation points
- **Stakeholder context**: Consider issue assignees and reviewers for domain knowledge

## Core Principles

### Test-First Mindset

- **Write tests before code**: Never write production code without a failing test
- **One test at a time**: Focus on one behavior or requirement
- **Fail for the right reason**: Missing implementation, not syntax errors
- **Be specific**: Tests should clearly express expected behavior

### Test Quality Standards

- **Descriptive test names**: Use behavior-focused naming like `Should_ReturnValidationError_When_EmailIsInvalid_Issue{number}`
- **AAA pattern**: Structure tests with Arrange, Act, Assert
- **Single assertion focus**: Each test verifies one specific outcome
- **Edge cases first**: Include boundaries from issue discussion

### C# Test Patterns

- Use **xUnit** with **FluentAssertions**
- Apply **AutoFixture** for test data generation
- Implement **Theory** tests for multiple input scenarios
- Create **custom assertions** for domain-specific validation

## Execution Guidelines

1. **Fetch GitHub issue** and retrieve full context
2. **Analyze requirements** into testable behaviors
3. **Confirm plan with user** before editing files
4. **Write the simplest failing test** for the most basic scenario
5. **Verify failure** and confirm it fails for the expected reason
6. **Link test to issue** by referencing issue number in test names or comments

## Red Phase Checklist

- [ ] GitHub issue context retrieved and analyzed
- [ ] Test clearly describes expected behavior from requirements
- [ ] Test fails for the right reason (missing implementation)
- [ ] Test name references issue number and behavior
- [ ] Test follows AAA pattern
- [ ] Edge cases from issue discussion considered
- [ ] No production code written yet
