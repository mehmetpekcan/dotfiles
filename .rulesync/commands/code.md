---
targets:
  - '*'
description: ''
---

# CODE Task

**Persona:** Execute this task as the `@developer` subagent (Devin, Staff Engineer 💻).  
Load the persona characteristics from `.rulesync/subagents/developer.md` before proceeding.

**Required Context:** Review these rules before proceeding:

- `.rulesync/rules/architecture.md` - Architectural patterns and component structure
- `.rulesync/rules/code-quality.md` - Code quality standards and conventions
- `.rulesync/rules/testing.md` - Testing requirements and patterns
- `.rulesync/rules/documentation.md` - Documentation standards
- `.rulesync/rules/database.md` - Database schema patterns (if applicable)
- `.rulesync/rules/security.md` - Security best practices
- `.rulesync/rules/ui-ux.md` - UI/UX patterns (if building frontend)

---

## Task Objective

Implement a **Technical Specification** (from `/docs/specs`) with production-ready code, comprehensive test coverage, and thorough documentation. Mark the spec as complete and optionally create a draft pull request.

---

## Task Instructions

1. **Read the Technical Specification:**
   - Ask: "What's the path to the Technical Specification?" (e.g., `/docs/specs/magic-link-login.md`)
   - Parse its contents to understand requirements, architecture, data models, APIs, testing requirements
   - Read any referenced Product Brief for additional context

2. **Ask clarification questions:**
   1. "I've reviewed the spec. Should I proceed with full implementation including tests and documentation?"
   2. "Are there any specific parts of the spec you'd like me to prioritize or implement first?"
   3. "Should I create a feature branch for this work?"

3. **Create feature branch (if approved):**
   - Branch naming from spec title: `feat/<feature-name-slug>`
   - Run: `git checkout -b feat/<feature-name-slug>`
   - Show branch creation confirmation

4. **Implement following this order:**

   Follow the implementation order and best practices from `.rulesync/rules/architecture.md`:

   a. **Database Schema** (if applicable) - Update Prisma schema, add indexes/relationships
   b. **tRPC Routers** - Create router in `apps/frontend/app/api/trpc/routers/{domain}/`
   c. **Business Logic** - Implement procedures with Zod validation and error handling
   e. **Frontend Components** - Build UI following patterns from `.rulesync/rules/ui-ux.md`
   f. **tRPC Client Integration** - Use api.domain.useQuery, api.domain.useMutation, api.domain.useSubscription

5. **Write comprehensive tests:**

   Follow testing standards from `.rulesync/rules/unit-testing.md` and `.rulesync/rules/e2e-testing.md`:
   - **Unit Tests** (Jest) - Test all tRPC procedures, place `.test.ts` files alongside routers (see `unit-testing.md`)
   - **Integration Tests** (Jest) - Test database operations, WebSocket, queue jobs (see `unit-testing.md`)
   - **E2E Tests** (Playwright) - Test complete user workflows (see `e2e-testing.md`)

   Run tests: `pnpm test` (unit tests) or `pnpm test:e2e` (E2E tests)

6. **Document the code:**

   Follow documentation standards from `.rulesync/rules/documentation.md`:
   - Add JSDoc to all exported functions
   - Add inline comments explaining complex logic
   - Update relevant README files
   - Document new environment variables

7. **Run quality checks with enforcement gates:**

   Follow quality standards from `.rulesync/rules/code-quality.md`:

   ```bash
   pnpm lint
   pnpm typecheck
   pnpm test
   pnpm test:e2e
   ```

   **Quality Gate Enforcement:**

   Evaluate results against these gates:

   **🚫 BLOCKER (P0) - Must Fix Before Proceeding:**
   - ❌ TypeScript errors → **STOP** - Fix all type errors
   - ❌ Unit tests failing → **STOP** - All tests must pass
   - ❌ Test coverage < 80% on new code → **STOP** - Add more tests
   - ❌ Critical linter errors (security, bugs) → **STOP** - Fix immediately
   - ❌ Security vulnerabilities found → **STOP** - Address security issues
   - ❌ Circular dependencies detected → **STOP** - Refactor to remove cycles

   **⚠️ WARNING (P1) - Should Fix (Ask user):**
   - ⚠️ Missing JSDoc on exported public APIs
   - ⚠️ E2E tests skipped or not run
   - ⚠️ Performance issues detected (slow queries, large bundles)
   - ⚠️ Accessibility violations found
   - ⚠️ Minor linter warnings (>10 warnings)

   **ℹ️ INFO (P2) - Nice to Have (Continue with notes):**
   - ℹ️ Code duplication detected
   - ℹ️ Minor style warnings (<10 warnings)
   - ℹ️ Bundle size increased but within limits
   - ℹ️ Opportunity for optimization noted

   **Gate Decision Process:**
   1. Run all quality checks and capture results
   2. Categorize issues by priority (P0, P1, P2)
   3. If ANY P0 issues exist:
      - **STOP implementation**
      - Show all P0 issues with file locations
      - Say: "🚫 **Quality gates BLOCKED** - {N} critical issues must be fixed before proceeding."
      - Fix issues, re-run checks, re-evaluate
   4. If P1 issues exist but no P0:
      - Show all P1 issues
      - Ask: "⚠️ Found {N} warnings. These should be fixed but aren't blocking. Continue anyway? (yes/no)"
      - If user says no, fix issues and re-run
      - If user says yes, document in implementation summary
   5. If only P2 issues:
      - Note them in implementation summary
      - Continue without stopping

   **Report Format:**

   ```markdown
   ## 📊 Quality Gate Results

   ### Automated Checks:

   - ✅ TypeScript: No errors
   - ✅ Unit Tests: 124/124 passing
   - ✅ Test Coverage: 94% (target: 80%)
   - ✅ Linter: No critical errors
   - ⚠️ E2E Tests: 3 tests skipped
   - ✅ Circular Dependencies: None detected

   ### Issues Found:

   **P0 (Critical):** 0 issues
   **P1 (High):** 1 issue
   **P2 (Medium):** 3 issues

   ### Details:

   **P1 Issues:**

   1. Missing JSDoc on `postMessage` procedure
      - File: `apps/frontend/app/api/trpc/routers/chat/post-message.ts:45`
      - Fix: Add JSDoc comment

   **P2 Issues:**

   1. Bundle size increased by 12KB (within 50KB limit)
   2. Code duplication in form validation (2 instances)
   3. 5 minor ESLint style warnings

   ### Gate Decision: ⚠️ PASS WITH WARNINGS

   No blocking issues. P1 warnings should be addressed but won't block merge.
   ```

   If any checks fail with P0 issues, fix them before proceeding to the next step.

8. **Update the Technical Specification:**
   - Update `Status` field from "Draft" to "✅ Completed"
   - Add an "Implementation Summary" section with:
     - Implemented by, date, branch name
     - Key components/features built
     - Files changed summary
     - Test coverage stats
     - Documentation updates

9. **Provide summary:**
   - List all files created or modified
   - Summarize what was implemented
   - Highlight key features and functionality
   - Show test coverage and quality check results

10. **Ask about next steps:**
    - "The implementation is complete! Would you like to:"
      - "1. Create a draft pull request? Run `/draft-pr`"
      - "2. Run QA review? Run `/review`"
      - "3. Get an explanation of how it works? Run `/explain`"
      - "4. Make any adjustments or improvements?"

---

## Notes

- Follow all coding standards from the rules files
- Aim for >90% test coverage on critical paths
- Ensure all code is properly documented
- Don't proceed to PR creation until all quality checks pass
