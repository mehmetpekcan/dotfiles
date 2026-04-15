---
targets:
  - '*'
description: ''
---

# LEARN Task

**Persona:** Execute this task as the `@architect` subagent (Archer, Principal Architect 🧠).  
Load the persona characteristics from `.rulesync/subagents/architect.md` before proceeding.

**Required Context:** This command analyzes existing code to learn patterns.  
Rules will be loaded as needed based on what's being learned.

---

## Task Objective

Analyze the codebase to extract actual patterns, conventions, and styles used in YOUR code (not generic best practices), then generate or update rule files to match the reality of how the codebase works.

---

## Task Instructions

1. **Ask discovery questions:**
   1. "What aspect of the codebase should I learn?"
      - a) Architecture (component structure, file organization)
      - b) Testing (testing patterns and conventions)
      - c) Components (UI patterns and shadcn/ui usage)
      - d) Database (Prisma patterns and query structures)
      - e) Integrations (third-party service patterns)
      - f) tRPC Routers (API patterns)
      - g) Everything (comprehensive scan)
   2. "Should I scan the entire codebase or specific directories?"
   3. "What's the goal?"
      - a) Document current patterns (as-is documentation)
      - b) Identify inconsistencies (find variations)
      - c) Generate new rules (add to rulesync)
      - d) Update existing rules (sync rules with reality)

2. **Scan the codebase:**

   Based on selected aspect, search relevant files:

   **For Architecture:**
   - `apps/frontend/app/**/page.tsx` - Page components
   - `apps/frontend/app/**/layout.tsx` - Layout components
   - `apps/frontend/app/**/components/*.tsx` - Feature components
   - `apps/frontend/app/lib/*/queries.ts` - Data fetching patterns

   **For Testing:**
   - `**/*.test.ts` - Unit test files
   - `**/*.test.tsx` - Component test files
   - `**/e2e/**/*.ts` - E2E test files

   **For Components:**
   - `apps/frontend/app/**/components/**/*.tsx` - Shared components
   - `apps/frontend/components/components/**/*.tsx` - UI package components

   **For Database:**
   - `apps/frontend/app/lib/*/queries.ts` - Query functions
   - `apps/frontend/prisma/schema.prisma` - Schema file

   **For tRPC Routers:**
   - `apps/frontend/app/api/trpc/routers/**/*.ts` - tRPC router files
   - `apps/frontend/app/lib/*/actions.ts` - Domain action files

3. **Extract patterns:**

   For each pattern type, identify:

   **File Organization:**
   - Naming conventions (camelCase, kebab-case, PascalCase)
   - File structure (co-location, barrel exports)
   - Directory hierarchy (feature-based, layer-based)

   **Code Patterns:**
   - How functions are structured
   - Error handling approaches
   - Logging patterns
   - Validation patterns
   - Type definitions

   **Conventions:**
   - Import order and grouping
   - Export patterns
   - Comment styles
   - Variable naming

4. **Analyze consistency:**

   Measure pattern usage:

   ````markdown
   ## Pattern Consistency Analysis

   ### Pattern: tRPC Procedure Structure

   **Dominant Pattern (78% - 42 of 54 files):**

   ```typescript
   export const actionName = TRPCError handling(
     'actionName',
     async (input: Schema) => {
       // Validation
       // Authorization
       // Business logic
       // Return result
     },
   );
   ```
   ````

   **Alternative Pattern (15% - 8 of 54 files):**

   ```typescript
   export async function actionName(input: Schema) {
   	// Manual implementation
   }
   ```

   **Outliers (7% - 4 of 54 files):**
   - Missing error handling
   - No logging
   - Inconsistent structure

   **Recommendation:** Standardize on dominant pattern

   ```

   ```

5. **Generate codebase fingerprint:**

   Create a profile of YOUR codebase:

   ````markdown
   ## Codebase Fingerprint: {Aspect}

   ### Overview

   Analyzed {N} files across {M} directories

   ### Key Patterns

   #### 1. {Pattern Name}

   **Usage:** {percentage}% of files
   **Example from codebase:**

   ```typescript
   // Actual code from your codebase
   ```
   ````

   **Files using this pattern:**
   - `path/to/file1.ts:45`
   - `path/to/file2.ts:67`
   - `path/to/file3.ts:123`

   #### 2. {Pattern Name}

   [... repeat for each pattern found ...]

   ### Naming Conventions
   - Functions: {convention}
   - Variables: {convention}
   - Types: {convention}
   - Files: {convention}

   ### Import Style

   ```typescript
   // Standard import order found:
   // 1. External libraries
   // 2. Workspace packages
   // 3. Relative imports
   ```

   ### Testing Patterns
   - Test file location: {pattern}
   - Mock strategy: {pattern}
   - Assertion style: {pattern}

   ### Inconsistencies Found
   1. {Inconsistency} - {N} files affected
   2. {Inconsistency} - {N} files affected

   ```

   ```

6. **Generate rule recommendations:**

   Create markdown for rules based on actual code:

   ` ```markdown

   ## Recommended Rule Addition

   **Target File:** `.rulesync/rules/{rule-file}.md`
   **Section:** {section-name}

   **Content to Add:**

   ### {Pattern Name}

   This pattern is used in {N}% of the codebase ({count} files).

   **Standard Approach:**

   ```typescript
   // Actual pattern from YOUR codebase
   // Not a generic example
   ```

   ````

   **Real Examples:**
   - `apps/frontend/app/api/trpc/routers/chat/post-message.ts:45-67`
   - `apps/frontend/app/api/trpc/routers/conversations/create.ts:89-112`

   **When to use:**
   - {Specific scenario from your codebase}
   - {Another scenario}

   **Common mistakes to avoid:**
   - {Mistake seen in outlier files}
   - {Another mistake}

   ```

   ```

   ````

7. **Identify refactoring opportunities:**

   Find areas needing standardization:

   ```markdown
   ## Standardization Opportunities

   ### High Priority

   1. **tRPC Procedure Error Handling** - 12 files need updating
      - Impact: Improved observability
      - Effort: 2-3 hours
      - Files: [list]

   ### Medium Priority

   2. **Prisma Query Authorization** - 8 files missing checks
      - Impact: Security improvement
      - Effort: 4-5 hours
      - Files: [list]

   ### Low Priority

   3. **Import Order Consistency** - 23 files varying
      - Impact: Code cleanliness
      - Effort: 1 hour (automated)
      - Files: [list]
   ```

8. **Compare with existing rules:**

   Check if current rules match reality:

   ```markdown
   ## Rule Drift Analysis

   ### Rules Matching Codebase ✅

   - Server Component patterns (95% compliance)
   - TypeScript usage (100% compliance)
   - Testing structure (88% compliance)

   ### Rules Needing Updates ⚠️

   - Authentication patterns: Rule should document token-based auth with ApiToken model
   - Database queries: Rule should show deleted boolean flag pattern
   - Error handling: Rule should mention TRPCError usage in all procedures

   ### Missing Rules ❌

   - No documentation for Decimal field handling (found in 45 files)
   - No pattern for webhook verification (found in 6 integrations)
   - No guidance on form validation with react-hook-form (used in 34 forms)
   ```

9. **Update or create rules:**

   Ask user what to do with findings:
   1. "I've identified {N} patterns and {M} inconsistencies. What would you like to do?"
      - a) Update existing rules to match current code
      - b) Create new rule sections for missing patterns
      - c) Generate refactoring tasks for inconsistencies
      - d) All of the above
   2. If updating rules, show diffs before applying
   3. If creating new sections, ask which rule file to add to

10. **Provide summary:**

    ```markdown
    ## 🧠 Learning Complete

    ### Codebase Analysis:

    - Scanned: {N} files
    - Patterns identified: {M}
    - Consistency score: {percentage}%

    ### Findings:

    - ✅ {N} patterns well-established and consistent
    - ⚠️ {M} patterns with variations (standardization opportunity)
    - ❌ {P} anti-patterns found (refactoring needed)

    ### Rule Updates:

    - ✏️ Updated: {N} existing rule sections
    - ➕ Added: {M} new rule sections
    - 🔍 Flagged: {P} rules needing manual review

    ### Files Modified:

    - `.rulesync/rules/{file1}.md` - Added {section}
    - `.rulesync/rules/{file2}.md` - Updated {section}

    ### Next Steps:

    1. Run `/extract-pattern` for specific pattern deep-dives
    2. Create refactoring tasks for inconsistencies
    3. Share updated rules with team
    4. Regenerate rulesync: `./scripts/rulesync.sh`
    ```

---

## Notes

- 🧠 Learns from YOUR code, not generic patterns
- 📊 Provides statistical analysis of pattern usage
- ✅ Identifies what's working well
- ⚠️ Flags inconsistencies needing standardization
- 📝 Generates rules matching reality, not ideals
- 🔄 Keeps rules synchronized with actual codebase

---

## Example Use Cases

### 1. New Team Member Onboarding

Learn current patterns to document actual conventions for new developers.

### 2. Post-Refactor Sync

After major refactoring, update rules to reflect new patterns.

### 3. Periodic Review

Quarterly analysis to identify drift and inconsistencies.

### 4. Migration Documentation

When upgrading libraries (e.g., tRPC v10 → v11), document new patterns.

### 5. Code Review Preparation

Ensure rules reflect actual team conventions before enforcing in reviews.

---

## Example Output

````markdown
## 📚 Codebase Learning Report: tRPC Procedures

### Scanned:

- 54 tRPC procedure files
- 187 procedures (queries/mutations/subscriptions)
- 13 different routers

### Dominant Pattern (78%):

```typescript
export const chatRouter = createTRPCRouter({
	postMessage: protectedProcedure
		.input(z.object({channel: z.string(), text: z.string()}))
		.mutation(async ({ctx, input}) => {
			// ctx.userId from token auth
			// ... business logic
		})
})
```
````

**Found in:**

- `apps/frontend/app/api/trpc/routers/chat/post-message.ts`
- `apps/frontend/app/api/trpc/routers/conversations/create.ts`
- [... 40 more files]

### Variations Found:

1. Manual logging (15%) - 8 files
2. No error handling (7%) - 4 files

### Recommendations:

1. ✏️ Update `.rulesync/rules/code-quality.md` to document `TRPCError handling`
2. 🔧 Refactor 12 non-compliant files to use standard pattern
3. ✅ Add tests for error handling in tRPC procedures

### Rule Update Preview:

````diff
# tRPC Procedures

+ ## Standard Pattern
+
+ Use `TRPCError` for all tRPC procedure error handling:
+
+ ```typescript
+ export const actionName = TRPCError handling(
+   'actionName',
+   async (input: Schema) => {
+     // Implementation
+   }
+ );
+ ```
````

Apply these changes? (yes/no)

```

```
