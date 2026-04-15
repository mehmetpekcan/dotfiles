# QA Review Report

**Date:** {YYYY-MM-DD}  
**Branch:** {Branch name}  
**Commit:** {Commit hash}  
**Reviewer:** {Current Git User}

## Summary

**Decision:** {✅ PASS / ⚠️ PASS WITH RECOMMENDATIONS / ❌ BLOCK}

{Brief 2-3 sentence summary of review findings and decision}

## Changes Reviewed

{Number} files changed, {X} insertions(+), {Y} deletions(-)

### Files Modified:

- `{file path}` - {Brief description}
- `{file path}` - {Brief description}

### Files Added:

- `{file path}` - {Brief description}

### Files Deleted:

- `{file path}` - {Reason}

## Automated Checks

### ✅/❌ Linting

- **Status:** {PASS/FAIL}
- **Result:** {Result description}
- **Command:** `pnpm lint`
- **Errors:** {If failed, list errors}

### ✅/❌ Type Checking

- **Status:** {PASS/FAIL}
- **Result:** {Result description}
- **Command:** `pnpm typecheck`
- **Errors:** {If failed, list errors}

### ✅/❌ Unit Tests

- **Status:** {PASS/FAIL/SKIPPED}
- **Result:** {Result description}
- **Command:** `pnpm test`
- **Coverage:** {Coverage percentage if applicable}
- **Errors:** {If failed, list errors}

### ✅/❌/⏭️ E2E Tests

- **Status:** {PASS/FAIL/SKIPPED}
- **Result:** {Result description}
- **Command:** `pnpm test:e2e`
- **Reason:** {If skipped, reason}
- **Note:** E2E test creation/maintenance is a human QA task.
- **Errors:** {If failed, list errors}

## Quality Gate Checklist

### ✅/❌ Code Quality

- {Check item 1}
- {Check item 2}
- {Check item 3}

### ✅/❌ Testing

- {Check item 1}
- {Check item 2}
- {Check item 3}

### ✅/❌ Documentation

- {Check item 1}
- {Check item 2}
- {Check item 3}

### ✅/❌/⏭️ Security

- {Check item 1}
- {Check item 2}
- {If not applicable, mark as ⏭️}

### ✅/❌/⏭️ Performance

- {Check item 1}
- {Check item 2}
- {If not applicable, mark as ⏭️}

### ✅/❌/⏭️ Accessibility

- {Check item 1}
- {Check item 2}
- {If not applicable, mark as ⏭️}

## Issues Found

### P0 - Critical Priority

**Issue {N}: {Title}**

- **Description:** {Detailed description}
- **Location:** {File path and line numbers}
- **Impact:** {Impact description}
- **Fix:** {Recommended fix}
- **File:** `{file path}`

### P1 - High Priority

{Repeat structure for each P1 issue}

### P2 - Medium Priority

{Repeat structure for each P2 issue}

### P3 - Low Priority

{Repeat structure for each P3 issue}

## Positive Findings

{List positive aspects of the changes}

1. {Positive finding 1}
2. {Positive finding 2}
3. {Positive finding 3}

## Rule Improvement Analysis

### Potential Improvements Identified: {N}

{If improvements identified, list them}

**Improvement {N}:**

- **Target File:** `~/.rulesync/rules/{rule-file}.mdc`
- **Section:** {Section name}
- **Type:** {Addition/Update/New Pattern}
- **Reasoning:** {Why this improvement is needed}
- **Proposed Content:** {Content to add/update}

{If no improvements, state: "No rule improvements needed at this time."}

## Decision Rationale

**{PASS/PASS WITH RECOMMENDATIONS/BLOCK}** - {Detailed explanation of decision}

{Explain why this decision was made, referencing specific findings}

## Required Actions

{If blocked or has recommendations, list required actions}

1. {Action 1}
2. {Action 2}

{If passed, state: "None - PR is ready to merge."}

## Next Steps

1. {Next step 1}
2. {Next step 2}
3. {Next step 3}

---

**Report Generated:** {YYYY-MM-DD}  
**Review Duration:** {Time}  
**Files Reviewed:** {Number}  
**Issues Found:** {Number} ({P0: X, P1: Y, P2: Z, P3: W})
