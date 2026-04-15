---
targets:
  - '*'
description: ''
---

# TDD Task

**Persona:** Execute this task as the `@developer` subagent (Devin, Staff Engineer 💻).  
Load the persona characteristics from `~/.rulesync/subagents/developer.md` before proceeding.

**Required Context:** Review these rules before proceeding:

- `~/.rulesync/rules/architecture.md` - Architectural patterns and component structure
- `~/.rulesync/rules/code-quality.md` - Code quality standards and conventions
- `~/.rulesync/rules/unit-testing.md` - Unit and integration testing patterns
- `~/.rulesync/rules/e2e-testing.md` - E2E testing patterns (if applicable)
- `~/.rulesync/rules/documentation.md` - Documentation standards

---

## Task Objective

Follow a Test-Driven Development (TDD) workflow to fix a bug:

1. Understand the bug description
2. Write a test that reproduces the bug (failing test)
3. Verify the test fails for the expected reason
4. Fix the bug
5. Verify the test passes after the fix

---

## Task Instructions

1. **Gather bug information:**

   Ask the user: "Please describe the bug you're experiencing."

   If the description is unclear or incomplete, prompt for clarification:

   ```
   I need more information to write an accurate test. Please provide:

   1. **Expected behavior:** What should happen?
   2. **Actual behavior:** What is actually happening?
   3. **Steps to reproduce:** How can I trigger this bug?
   4. **Affected component/feature:** Which file, function, or feature is involved?
   5. **Error messages (if any):** What errors or warnings appear?
   ```

   Continue asking clarifying questions until you have a clear understanding of:
   - The expected outcome
   - The actual (buggy) outcome
   - How to reproduce the issue
   - Which code is affected

2. **Identify the affected code:**
   - Search for the relevant files, functions, or components
   - Read the code to understand the current implementation
   - Identify where the bug likely exists
   - Check for existing tests related to this functionality

3. **Write a failing test:**

   Follow testing patterns from `~/.rulesync/rules/unit-testing.md`:
   - **For tRPC procedures:** Create a test in the same directory as the router (e.g., `apps/frontend/app/api/trpc/routers/{domain}/{procedure}.test.ts`)
   - **For React components:** Create a test file alongside the component (e.g., `Component.test.tsx`)
   - **For utility functions:** Create a test file alongside the function (e.g., `utils.test.ts`)
   - **For E2E scenarios:** Create a test in `apps/frontend/e2e/specs/`

   The test should:
   - Clearly describe what it's testing (use descriptive test names)
   - Reproduce the exact bug scenario
   - Assert the expected behavior (which will fail initially)
   - Include any necessary setup (test data, mocks, etc.)

   Example test structure:

   ```typescript
   describe('Bug fix: {brief description}', () => {
   	it('should {expected behavior} when {scenario}', async () => {
   		// Arrange: Set up test data and context
   		const testData = createTestData()

   		// Act: Perform the action that triggers the bug
   		const result = await functionUnderTest(testData)

   		// Assert: Verify expected behavior (this will fail until bug is fixed)
   		expect(result).toEqual(expectedValue)
   	})
   })
   ```

4. **Run the test and verify it fails:**

   Run the test using the appropriate command:

   ```bash
   # For unit/integration tests
   pnpm test {test-file-path}

   # For E2E tests
   pnpm test:e2e {test-file-path}
   ```

   **CRITICAL:** Verify that:
   - ✅ The test fails (as expected)
   - ✅ The failure message matches the bug description
   - ✅ The test is testing the right thing (not a false positive)

   If the test doesn't fail or fails for the wrong reason:
   - Review the test to ensure it accurately reproduces the bug
   - Adjust the test as needed
   - Re-run until you have a proper failing test

   Show the test failure output to the user and confirm:
   "✅ Test is failing as expected. The failure matches the bug you described: {summary}. Proceeding to fix the bug."

5. **Fix the bug:**
   - Analyze the code to identify the root cause
   - Implement the fix following patterns from:
     - `~/.rulesync/rules/architecture.md` - For structural changes
     - `~/.rulesync/rules/code-quality.md` - For code quality standards
     - `~/.rulesync/rules/security.md` - For security-related bugs
   - Ensure the fix addresses the root cause, not just symptoms
   - Keep the fix minimal and focused
   - Add comments explaining the fix if the bug was non-obvious

6. **Verify the fix:**

   Re-run the test:

   ```bash
   pnpm test {test-file-path}
   ```

   **CRITICAL:** Verify that:
   - ✅ The test now passes
   - ✅ No other tests were broken by the fix
   - ✅ The fix doesn't introduce regressions

   If other tests fail:
   - Investigate why they're failing
   - Determine if the fix broke something or if those tests need updating
   - Fix any regressions before proceeding

7. **Run related tests:**

   Run the full test suite for the affected area to ensure no regressions:

   ```bash
   # Run all tests in the affected directory
   pnpm test {affected-directory}

   # Or run all tests if the change is broad
   pnpm test
   ```

8. **Check for linting errors:**

   ```bash
   pnpm lint
   pnpm typecheck
   ```

   Fix any linting or type errors introduced by the fix.

9. **Document the fix (if significant):**

   If the bug was complex or the fix is non-obvious:
   - Add JSDoc comments explaining the fix
   - Update relevant documentation
   - Add inline comments for complex logic

10. **Provide summary:**

    ```markdown
    ## 🐛 Bug Fix Complete

    ### Bug Description:

    {Brief description of the bug}

    ### Root Cause:

    {What was causing the bug}

    ### Fix Applied:

    {What was changed to fix the bug}

    ### Test Coverage:

    - ✅ Test written: `{test-file-path}`
    - ✅ Test passes: Confirmed
    - ✅ No regressions: All related tests passing

    ### Files Modified:

    - `{file1}` - {what was changed}
    - `{file2}` - {what was changed}

    ### Next Steps:

    - [ ] Review the fix
    - [ ] Run full test suite: `pnpm test`
    - [ ] Create PR if ready: `/draft-pr`
    ```

---

## Example Workflow

**User:** "When I open Anuj's profile and click Message, it creates a DM but shows 'Unknown' as the recipient."

**Agent:** "I need to understand this better. Can you clarify:

1. Expected: The DM should show Anuj's name as the recipient
2. Actual: The DM shows 'Unknown' as the recipient
3. Steps: Open Anuj's profile → Click Message button
4. Component: User profile panel, conversations.open endpoint
5. Error: No error, just wrong display name"

**Agent:** (After investigation) "I've identified the issue. The `conversations.open` endpoint isn't setting the `user` field when creating new IM conversations. I'll write a test to reproduce this, then fix it."

**Agent:** (After writing test) "✅ Test is failing as expected. The test confirms that the `user` field is `null` when it should be set to Anuj's ID. Proceeding to fix."

**Agent:** (After fix) "✅ Test now passes! The fix sets the `user` field correctly when creating IM conversations. All related tests are passing."

---

## Notes

- 🧪 **Test First:** Always write the test before fixing the bug
- ✅ **Verify Failure:** Ensure the test fails for the right reason
- 🔍 **Root Cause:** Fix the underlying issue, not just symptoms
- 📝 **Document:** Add comments for non-obvious fixes
- 🚫 **No Regressions:** Ensure the fix doesn't break existing functionality
- 🎯 **Minimal Fix:** Keep changes focused and minimal

---

## Quality Gates

Before marking the bug as fixed:

- ✅ Test written and failing for the expected reason
- ✅ Bug fixed
- ✅ Test now passes
- ✅ All related tests still pass
- ✅ No linting errors
- ✅ No type errors
- ✅ Code follows project patterns

---

## Common Scenarios

### Scenario 1: API Endpoint Bug

- Write integration test in router test file
- Test the endpoint with the buggy scenario
- Fix the endpoint implementation
- Verify test passes

### Scenario 2: React Component Bug

- Write component test or E2E test
- Test the component with the buggy scenario
- Fix the component
- Verify test passes

### Scenario 3: Utility Function Bug

- Write unit test for the function
- Test the function with the buggy input
- Fix the function
- Verify test passes

### Scenario 4: Database Query Bug

- Write integration test with test database
- Test the query with the buggy scenario
- Fix the query
- Verify test passes

---

## Anti-Patterns to Avoid

❌ **Don't:** Fix the bug before writing the test
❌ **Don't:** Write a test that doesn't actually fail
❌ **Don't:** Skip verifying the test failure matches the bug
❌ **Don't:** Fix symptoms instead of root cause
❌ **Don't:** Break existing tests with the fix
❌ **Don't:** Skip running related tests after the fix

✅ **Do:** Write test first
✅ **Do:** Verify test fails for the right reason
✅ **Do:** Fix root cause
✅ **Do:** Verify all tests pass
✅ **Do:** Check for regressions
