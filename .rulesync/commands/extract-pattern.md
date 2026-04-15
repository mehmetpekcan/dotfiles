---
targets:
  - '*'
description: ''
---

# EXTRACT PATTERN Task

**Persona:** Execute this task as the `@architect` subagent (Archer, Principal Architect 🧠).  
Load the persona characteristics from `.rulesync/subagents/architect.md` before proceeding.

**Required Context:** Review these rules before proceeding:

- `.rulesync/rules/overview.md` - Project overview
- `.rulesync/rules/architecture.md` - Architectural patterns
- `.rulesync/rules/code-quality.md` - Code quality standards

---

## Task Objective

Analyze the codebase to find recurring patterns, document them comprehensively, and suggest which rule file to add them to for future reference and standardization.

---

## Task Instructions

1. **Ask discovery questions:**
   1. "What pattern should I extract?" (e.g., "tRPC procedure error handling," "token authentication")
   2. "Where should I look for this pattern?" (specific directories, file types, or entire codebase)
   3. "Are you looking to standardize this pattern or just document current usage?"

2. **Search for pattern instances:**

   Use codebase search to find all occurrences:
   - Search for relevant functions, hooks, or components
   - Examine different implementations across the codebase
   - Note variations and inconsistencies

3. **Analyze found patterns:**

   For each instance found:
   - Identify the core pattern structure
   - Note common elements across implementations
   - Spot variations and why they differ
   - Evaluate which implementation is best

4. **Categorize patterns:**

   Group into categories:
   - **Consistent:** Pattern used the same way everywhere (good!)
   - **Inconsistent:** Similar pattern with variations (needs standardization)
   - **Outdated:** Old pattern coexisting with newer approach (needs migration)
   - **Anti-pattern:** Pattern that should be avoided

5. **Document the pattern:**

   Create comprehensive documentation including:

   ````markdown
   ## Pattern Name

   ### Purpose

   Brief description of what this pattern accomplishes and when to use it.

   ### Context

   Where and why this pattern is used in the codebase.

   ### Implementation

   **Recommended Approach:**

   ```typescript
   // Show the best/recommended implementation
   // Include actual code from the codebase
   ```
   ````

   **Common Variations:**

   ```typescript
   // Document variations if they're valid
   // Explain when to use each
   ```

   **Anti-patterns to Avoid:**

   ```typescript
   // Show what NOT to do
   // Explain why it's problematic
   ```

   ### Examples from Codebase

   **Good Examples:**
   - `path/to/file.ts:123` - Brief explanation
   - `path/to/other.ts:456` - Brief explanation

   **Examples Needing Improvement:**
   - `path/to/old.ts:789` - What needs updating

   ### Related Patterns
   - Link to related patterns
   - Show how patterns work together

   ### Testing

   How to test code using this pattern

   ### Migration Guide (if applicable)

   If standardizing an inconsistent pattern, provide migration steps

   ```

   ```

6. **Provide statistics:**

   Summarize findings:

   ```markdown
   ## Pattern Analysis Results

   - **Total instances found:** 23
   - **Consistent implementations:** 15 (65%)
   - **Inconsistent implementations:** 6 (26%)
   - **Outdated implementations:** 2 (9%)

   **Files analyzed:**

   - `apps/frontend/app/api/trpc/routers/*/index.ts`
   - `apps/frontend/app/lib/queue/*.ts`
   ```

7. **Suggest rule file placement:**

   Recommend where to add this pattern:

   ```markdown
   ## Recommended Rule File

   **File:** `.rulesync/rules/{rule-file}.md`

   **Reasoning:** This pattern relates to {specific concern} and would fit
   naturally in the {rule name} section because {explanation}.

   **Section to add to:** {specific section within the rule file}

   **Alternative locations:** If not {primary}, could also fit in {secondary}
   ```

8. **Generate refactoring recommendations:**

   If standardization is needed:

   ```markdown
   ## Standardization Recommendations

   ### Priority: {High/Medium/Low}

   ### Impact: {High/Medium/Low}

   ### Files to Update:

   1. `path/to/file1.ts` - Update lines 45-67
   2. `path/to/file2.ts` - Update lines 123-145
   3. `path/to/file3.ts` - Update lines 89-102

   ### Refactoring Steps:

   1. Extract shared pattern to utility function
   2. Update each usage to use the standard approach
   3. Add tests for the standardized pattern
   4. Update documentation

   ### Breaking Changes: {Yes/No}

   {If yes, explain the impact and migration path}

   ### Estimated Effort: {hours/days}
   ```

9. **Create code examples:**

   Provide ready-to-use examples:

   ```typescript
   // ✅ Recommended Pattern
   import {protectedProcedure, createTRPCRouter} from '@/app/lib/router/trpc'
   import {TRPCError} from '@trpc/server'
   import {z} from 'zod'

   export const standardRouter = createTRPCRouter({
   	standardProcedure: protectedProcedure.input(z.object({channelId: z.string()})).mutation(async ({ctx, input}) => {
   		console.log('[standardProcedure] Starting', {userId: ctx.userId, channelId: input.channelId})

   		try {
   			const result = await operation(input)
   			return {ok: true, data: result}
   		} catch (error) {
   			console.error('[standardProcedure] Failed', {error: error instanceof Error ? error.message : 'Unknown'})
   			throw new TRPCError({code: 'INTERNAL_SERVER_ERROR', message: 'operation_failed', cause: error})
   		}
   	})
   })
   ```

10. **Ask about next steps:**
    1. "Would you like me to add this pattern to the recommended rule file?"
    2. "Should I create a refactoring task to standardize inconsistent usages?"
    3. "Would you like me to generate tests for this pattern?"

---

## Notes

- 🧠 Focus on patterns unique to THIS codebase, not generic best practices
- 📊 Provide concrete statistics and file locations
- ✅ Show actual code examples from the codebase
- 🔄 Identify opportunities for standardization
- 📝 Make documentation actionable and practical
- 🎯 Prioritize high-value patterns first

---

## Example Patterns to Extract

Common valuable patterns:

### Architecture Patterns:

- tRPC procedure structure and error handling
- Data fetching in Server Components
- Client/Server component boundaries
- Real-time data updates

### Data Patterns:

- Prisma query composition with SQLite
- Unix timestamp handling
- Deleted boolean flag pattern
- Authorization in tRPC context

### UI Patterns:

- Message list with real-time updates
- Loading states and error handling
- shadcn/ui component usage
- Tailwind CSS patterns

### Quality Patterns:

- Console logging patterns
- TRPCError handling
- Zod input validation
- Jest testing patterns

---

## Output Example

```markdown
## 🔍 Pattern Extraction Complete

### Pattern: tRPC Procedure Error Handling

**Instances Found:** 34 across 28 files

**Analysis:**

- 25 instances (73%) use `TRPCError` properly ✅
- 6 instances (18%) have inconsistent error messages ⚠️
- 3 instances (9%) lack error logging (needs fixing) ❌

**Recommended Approach:**
Use `TRPCError` with appropriate error codes for all tRPC procedures to ensure
consistent error handling and Slack API compatibility.

**Best Example:**
`apps/frontend/app/api/trpc/routers/chat/post-message.ts:45-67`

**Needs Updating:**

1. `apps/frontend/app/api/trpc/routers/users/profile-set.ts:23` - Inconsistent error codes
2. `apps/frontend/app/api/trpc/routers/conversations/archive.ts:89` - Missing logging
3. `apps/frontend/app/api/trpc/routers/reactions/add.ts:112` - No error handling

**Recommended Rule File:**
`.rulesync/rules/code-quality.md` - Section: "tRPC Procedures"

**Next Steps:**

1. Add pattern documentation to code-quality.md
2. Refactor 9 inconsistent implementations
3. Add tests for error handling behavior

**Estimated Impact:**

- Improved error consistency across all tRPC procedures
- Better Slack API compatibility
- Easier debugging in production
```
