---
targets:
  - '*'
description: ''
---

# TEST Task

**Persona:** Execute this task as the `@developer` subagent (Devin, Staff Engineer 💻).  
Load the persona characteristics from `.rulesync/subagents/developer.md` before proceeding.

**Required Context:** Review these rules before proceeding:

- `.rulesync/rules/testing.md` - Testing standards, patterns, and best practices
- `.rulesync/rules/code-quality.md` - Code quality standards for test code

---

## Task Objective

Create comprehensive test coverage for a specified file, folder, or feature using the appropriate testing frameworks. Follow all patterns and standards from `.rulesync/rules/testing.md`.

---

## Task Instructions

1. **Initiate discovery:**
   - Ask: "What would you like me to test? (provide a file path, folder path, or feature description)"
   - Examine the target code to understand functionality, dependencies, and complexity

2. **Determine test scope:**

   Ask these questions:
   1. "What type of tests should I write?"
      - `unit` - Test individual functions and modules
      - `integration` - Test interactions between modules/services
      - `e2e` - Test complete user workflows
      - `all` - Comprehensive test coverage
   2. "Are there any specific test cases or edge cases you want me to focus on?"
   3. "Should I update existing tests or create new test files?"

3. **Analyze the code:**
   - Read the target file(s)
   - Understand function signatures and expected behaviors
   - Identify dependencies and integrations
   - Note error handling and edge cases
   - Check for existing test coverage
   - Look for related mock data in `@openai/mocks`

4. **Write tests following standards:**

   Apply all testing patterns from `.rulesync/rules/testing.md`:
   - **Unit Tests:** Create `.test.ts` files alongside source, use descriptive `describe` blocks
   - **Integration Tests:** Test module interactions, use database mocks from `@openai/db/__mocks__`
   - **E2E Tests:** Create files in `apps/frontend/e2e/`, test complete workflows

   Ensure:
   - Tests are properly typed (no `any` types)
   - Tests are deterministic and isolated
   - Tests are self-documenting with clear descriptions
   - Tests clean up after themselves
   - Aim for >90% coverage on critical paths

5. **Verify tests pass:**
   - Run tests: `pnpm test` or `pnpm test:e2e`
   - If tests fail, debug and fix issues
   - Ensure no linter errors: `pnpm lint`

6. **Document the tests:**
   - Add comments for complex test setups or assertions
   - Update relevant README files if test patterns have changed
   - Document any new mocks created

7. **Provide summary:**
   - List all test files created or modified
   - Summarize test coverage added (e.g., "12 unit tests covering all public methods")
   - Highlight key test scenarios covered
   - Note any testing gaps or limitations
   - Show test results output
   - Provide run instructions
   - Ask: "Would you like me to document this code (`/document`) or make any other improvements?"

---

## Notes

- Reference `.rulesync/rules/testing.md` for all testing patterns and best practices
- Test behavior, not implementation
- Use Arrange-Act-Assert pattern
- Keep tests fast and focused
- Leverage existing mocks from `@openai/mocks`
