---
targets:
  - '*'
description: ''
---

# DEBT SCAN Task

**Persona:** Execute this task as the `@architect` subagent (Archer, Principal Architect 🧠).  
Load the persona characteristics from `.rulesync/subagents/architect.md` before proceeding.

**Required Context:** Review these rules before proceeding:

- `.rulesync/rules/code-quality.md` - Code quality standards
- `.rulesync/rules/architecture.md` - Architectural patterns
- `.rulesync/rules/testing.md` - Testing requirements

---

## Task Objective

Systematically scan the codebase to identify technical debt, categorize by type and severity, estimate impact and effort, and generate a prioritized technical debt report.

---

## Task Instructions

1. **Ask discovery questions:**
   1. "What scope should I scan?"
      - a) Entire codebase (comprehensive)
      - b) Specific directory/module
      - c) Specific concern (security, performance, testing, etc.)
   2. "What types of debt are you concerned about?"
      - a) All types (comprehensive scan)
      - b) Code quality (duplication, complexity, style)
      - c) Testing (missing tests, poor coverage)
      - d) Security (vulnerabilities, outdated patterns)
      - e) Performance (slow queries, bundle size)
      - f) Documentation (missing docs, outdated)
      - g) Dependencies (outdated packages, vulnerabilities)

   3. "What priority level should trigger alerts?"
      - a) P0 only (critical/blockers)
      - b) P0 and P1 (critical and high)
      - c) All priorities (comprehensive)
   4. "If performance debt is in scope, do you have Jaeger trace inputs?"
      - a) Yes - I will provide full trace JSON + Jaeger endpoint/URL
      - b) No - run static scan only

2. **Scan for technical debt indicators:**
   - If performance debt is in scope and trace inputs are provided, use trace evidence (`T0`) to prioritize true runtime bottlenecks over static heuristics.

   **Code Quality Debt:**
   - TODO/FIXME comments
   - Code duplication (similar patterns repeated)
   - High complexity functions (cyclomatic complexity)
   - Long functions (>100 lines)
   - Large files (>500 lines)
   - Inconsistent patterns
   - Dead code / unused exports
   - Console.log statements
   - Commented-out code blocks

   **Testing Debt:**
   - Files without test coverage
   - Test files with skipped tests (`.skip`, `.todo`)
   - Low test coverage areas (<80%)
   - Missing E2E tests for critical flows
   - Brittle tests (frequent failures)
   - Tests without assertions

   **Security Debt:**
   - Hardcoded secrets or API keys
   - SQL injection vulnerabilities
   - Missing input validation
   - Unsafe dependencies (known vulnerabilities)
   - Missing authentication checks
   - Unencrypted sensitive data
   - Missing rate limiting
   - Deprecated security patterns

   **Performance Debt:**
   - N+1 query problems
   - Missing database indexes
   - Large bundle sizes
   - Unoptimized images
   - Missing pagination
   - Unnecessary re-renders
   - Memory leaks
   - Blocking operations

   **Documentation Debt:**
   - Missing README files
   - Missing JSDoc comments
   - Outdated documentation
   - Undocumented APIs
   - Missing environment variable docs
   - No inline comments for complex logic

   **Dependency Debt:**
   - Outdated packages (major versions behind)
   - Deprecated dependencies
   - Security vulnerabilities in dependencies
   - Unused dependencies
   - Duplicate dependencies

3. **Categorize by severity:**

   Use this priority system:

   **P0 - Critical (Fix Immediately):**
   - Security vulnerabilities in production
   - Data integrity issues
   - Compliance violations
   - Production blockers

   **P1 - High (Fix Soon):**
   - Performance degradation affecting users
   - Missing tests for critical paths
   - Security concerns (non-exploitable)
   - Code blocking future development

   **P2 - Medium (Plan to Fix):**
   - Code quality issues
   - Missing documentation
   - Minor performance issues
   - Maintainability concerns

   **P3 - Low (Nice to Have):**
   - Code style inconsistencies
   - Minor duplication
   - Non-critical TODOs
   - Optimization opportunities

4. **Estimate impact and effort:**

   For each debt item:

   ```markdown
   ### {Debt Item Title}

   **Type:** {Code Quality | Testing | Security | Performance | Documentation | Dependencies}
   **Severity:** {P0 | P1 | P2 | P3}

   **Location:**

   - `path/to/file1.ts:45-67`
   - `path/to/file2.ts:123`

   **Description:**
   {What's wrong and why it's debt}

   **Impact:**

   - **Business Impact:** {How it affects users/business}
   - **Technical Impact:** {How it affects developers/system}
   - **Risk:** {What could go wrong if not fixed}

   **Effort:**

   - **Estimated Time:** {hours/days/weeks}
   - **Complexity:** {Low | Medium | High}
   - **Dependencies:** {What else needs to change}

   **Proposed Solution:**
   {How to fix it}

   **Benefits:**
   {Why fixing this is valuable}
   ```

5. **Aggregate findings:**

   Create summary statistics:

   ```markdown
   ## Technical Debt Summary

   ### By Severity:

   - **P0 (Critical):** {N} items - {percentage}%
   - **P1 (High):** {M} items - {percentage}%
   - **P2 (Medium):** {P} items - {percentage}%
   - **P3 (Low):** {Q} items - {percentage}%
   - **Total:** {sum} items

   ### By Type:

   - **Code Quality:** {N} items
   - **Testing:** {M} items
   - **Security:** {P} items
   - **Performance:** {Q} items
   - **Documentation:** {R} items
   - **Dependencies:** {S} items

   ### By Effort:

   - **Quick Wins (<4 hours):** {N} items
   - **Medium (1-3 days):** {M} items
   - **Large (>1 week):** {P} items

   ### Debt Hotspots:

   Top areas with most debt:

   1. `apps/frontend/app/lib/{module}/` - {N} items
   2. `apps/frontend/app/{feature}/` - {M} items
   3. `packages/{package}/` - {P} items
   ```

6. **Generate prioritization matrix:**

   ```markdown
   ## Prioritization Matrix

   ### High Impact, Low Effort (DO FIRST) 🎯

   1. {Item} - P1, 2 hours
   2. {Item} - P1, 4 hours
   3. {Item} - P2, 3 hours

   ### High Impact, High Effort (PLAN CAREFULLY) 📋

   1. {Item} - P0, 2 weeks
   2. {Item} - P1, 1 week

   ### Low Impact, Low Effort (FILL GAPS) ⚡

   1. {Item} - P3, 1 hour
   2. {Item} - P3, 2 hours

   ### Low Impact, High Effort (DEPRIORITIZE) 🔻

   1. {Item} - P3, 1 week
   ```

7. **Create actionable tasks:**

   Generate specific tasks for top priorities:

   ```markdown
   ## Recommended Actions

   ### Immediate (This Week):

   1. **[P0] Fix SQL injection vulnerability in user search**
      - File: `apps/frontend/app/lib/users/queries.ts:45`
      - Solution: Use Prisma parameterized queries
      - Effort: 2 hours
      - Assignee: {suggest based on git blame}

   2. **[P1] Add tests for queue job processing**
      - File: `apps/frontend/app/lib/queue/scheduled-messages.ts`
      - Coverage: Currently 0%, needs >80%
      - Effort: 1 day
      - Assignee: {suggest}

   ### This Month:

   [... list P1 items ...]

   ### This Quarter:

   [... list P2 items ...]
   ```

8. **Track technical debt over time:**

   If previous debt scans exist, compare:

   ```markdown
   ## Debt Trend Analysis

   ### Since Last Scan (30 days ago):

   - ✅ Resolved: {N} items
   - 📈 New debt added: {M} items
   - 📊 Net change: {+/-X} items

   ### Debt Velocity:

   - Debt added per week: {average}
   - Debt resolved per week: {average}
   - Time to resolve debt: {average days}

   ### Improving Areas:

   - Testing coverage: +12%
   - Documentation: +8 READMEs added

   ### Worsening Areas:

   - Code duplication: +5 instances
   - Outdated dependencies: +3 packages
   ```

9. **Generate the report:**

   Save comprehensive report to `/docs/audits/{date}-tech-debt.md`

   Include:
   - Executive summary
   - Detailed findings by category
   - Prioritization matrix
   - Recommended actions
   - Trend analysis (if previous scans exist)
   - Appendix with all debt items

10. **Provide next steps:**

    ```markdown
    ## Next Steps

    1. **Review P0 items immediately**
       - Schedule fixes for this sprint
       - Assign to team members

    2. **Create tasks for P1 items**
       - Add to backlog
       - Estimate in sprint planning

    3. **Plan debt reduction**
       - Allocate 20% of sprint capacity to debt
       - Target quick wins first

    4. **Schedule next scan**
       - Recommended: Monthly
       - Track trend over time

    5. **Share with team**
       - Discuss in team meeting
       - Get input on priorities
    ```

---

## Notes

- 🧠 Focus on actionable debt, not perfection
- 📊 Quantify impact to justify fixing
- ⚡ Quick wins build momentum
- 🎯 Prioritize by impact × effort
- 📈 Track trends to measure progress
- 🤝 Include team in prioritization

---

## Example Output

```markdown
## 📊 Technical Debt Scan Report

**Date:** October 29, 2025  
**Scope:** Entire codebase  
**Scanned:** 847 files, 124,563 lines of code

---

### Executive Summary

- **Total Debt Items:** 47
- **Critical (P0):** 2 items - Immediate action required
- **High (P1):** 12 items - Plan for this sprint
- **Medium (P2):** 23 items - Backlog
- **Low (P3):** 10 items - Future optimization

**Estimated Total Effort:** 23 days  
**Estimated Value:** Improved security, 30% faster builds, better maintainability

---

### Critical Issues (P0)

#### 1. SQL Injection Vulnerability in User Search

**Files:** `apps/frontend/app/lib/users/queries.ts:45`  
**Impact:** Security risk - potential data exposure  
**Effort:** 2 hours  
**Solution:** Replace raw SQL with Prisma queries

#### 2. Missing Authentication on Admin Endpoints

**Files:** `apps/frontend/app/api/admin/route.ts`  
**Impact:** Security risk - unauthorized access  
**Effort:** 4 hours  
**Solution:** Add auth middleware

---

### High Priority (P1)

#### Message Broadcasting - Zero Test Coverage

- **Impact:** High risk for real-time messaging bugs
- **Files:** `apps/websocket/src/routers/chat.ts`
- **Current Coverage:** 0%
- **Target:** 80%
- **Effort:** 2 days

[... continue for all items ...]

---

### Prioritization

**Quick Wins (DO FIRST):**

1. ✅ Add missing JSDoc to public APIs (4 hours, P2)
2. ✅ Remove console.log statements (2 hours, P2)
3. ✅ Fix ESLint warnings (3 hours, P3)

**High Impact Projects:**

1. 🎯 Add WebSocket subscription tests (2 days, P1)
2. 🎯 Fix security vulnerabilities (1 day, P0-P1)
3. 🎯 Optimize slow database queries (2 days, P1)

---

### Recommended Actions

**This Week:**

- Fix 2 P0 security issues (6 hours total)
- Address 3 quick wins (9 hours total)

**This Sprint:**

- Add WebSocket subscription tests (2 days)
- Update 5 outdated dependencies (1 day)
- Document tRPC procedures (2 days)

**This Quarter:**

- Reduce code duplication by 50%
- Achieve 85% test coverage
- Resolve all P1 and P2 items
```
