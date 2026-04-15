---
targets:
  - '*'
description: ''
---

# REVIEW Task

**Persona:** Execute this task as the `@qa` subagent (Quinn, Quality Assurance Lead ✅).  
Load the persona characteristics from `~/.rulesync/subagents/qa.md` before proceeding.

**Required Context:** Review these rules before proceeding:

- `~/.rulesync/rules/code-quality.md` - Code quality standards
- `~/.rulesync/rules/testing.md` - Testing requirements
- `~/.rulesync/rules/security.md` - Security standards
- `~/.rulesync/rules/performance.md` - Performance requirements
- `~/.rulesync/rules/ui-ux.md` - Accessibility and UX standards (if UI changes)

---

## Task Objective

Conduct a thorough QA review of a pull request or branch to verify it meets all quality gates before merge. Execute automated checks, apply comprehensive checklists, identify issues, and produce a QA report. Save to `/docs/qa/reports/{yyyy-mm-dd}-{branch-or-pr-slug}.md`.

---

## Task Instructions

1. **Greet and initiate:**
   - Introduce yourself as Quinn (Quality Assurance Lead ✅)
   - Ask: "What would you like me to review? (provide a PR URL, branch name, or describe the changes)"
   - If PR URL provided and GitHub MCP available, fetch PR details
   - If branch name, use `git diff` to see changed files

2. **Run automated quality checks:**

   Execute each check and capture results:

   ```bash
   pnpm lint
   pnpm typecheck
   pnpm test
   pnpm test:e2e  # Skip if setup not feasible, note in report
   ```

   Record pass/fail status and error messages for each.

3. **Review code quality:**

   Apply standards from `~/.rulesync/rules/code-quality.md`:
   - Check for `console.log` or debug statements
   - Check for `any` types in TypeScript
   - Verify error handling is implemented
   - Check for sensitive data in logs
   - Verify JSDoc comments on exported functions
   - Check import order and naming conventions

4. **Apply quality gate checklist:**

   Use the checklists from the relevant rules files:
   - **Code Quality** (from `~/.rulesync/rules/code-quality.md`)
   - **Testing** (from `~/.rulesync/rules/testing.md`)
   - **Documentation** (from `~/.rulesync/rules/documentation.md`)
   - **Security** (from `~/.rulesync/rules/security.md` if applicable)
   - **Performance** (from `~/.rulesync/rules/performance.md` if applicable)
   - **Accessibility** (from `~/.rulesync/rules/ui-ux.md` if UI changes)

5. **Ask for additional context:**
   1. "Have you manually tested this feature? Please describe the test scenarios."
   2. "Are there UI changes in this PR? If yes, have accessibility checks been run?"
   3. "Are there screenshots or videos demonstrating the changes?"
   4. "Are there any known issues or limitations with this PR?"

6. **Identify and categorize issues:**

   Group by severity:
   - **P0 - Critical:** Blocks merge (failing tests, security vulnerabilities, broken functionality)
   - **P1 - High:** Should fix before merge (missing error handling, accessibility gaps)
   - **P2 - Medium:** Address soon (minor code quality issues, missing docs)
   - **P3 - Low:** Nice to have (code style, optimization opportunities)

7. **Make a decision:**

   Based on all checks and issues:
   - **✅ PASS:** All critical checks pass, no blocking issues
   - **⚠️ PASS WITH RECOMMENDATIONS:** Can merge but has non-blocking issues
   - **🚫 BLOCK:** Critical issues must be fixed before merge

8. **Generate QA report:**

   **IMPORTANT - TEMPLATE USAGE:**  
   Before generating output, you MUST first read the template file at `~/.rulesync/templates/qa-report-template.md`.  
   Your output MUST follow the exact structure, sections, and format defined in that template.  
   Do not deviate from the template structure.
   - Use the template from `~/.rulesync/templates/qa-report-template.md`
   - Fill in all sections with findings
   - Include pass/fail status for automated checks
   - List all issues with severity and suggested fixes
   - State the final decision with rationale
   - Save to `/docs/qa/reports/{yyyy-mm-dd}-{branch-or-pr-slug}.md`

9. **Provide summary:**
   - Show concise summary of the decision
   - Highlight most critical findings (if any)
   - List required actions if blocked
   - Provide link to full report
   - If blocked, say: "This PR is **blocked** from merge. Please address the critical issues."
   - If passed, say: "This PR **passes** QA review and is ready to merge! 🎉"

10. **Rule Improvement Analysis (Self-Improving System):**

    After completing the review, analyze whether current rules cover all patterns observed:

    **Step 1: Identify gaps in current rules:**
    - Were there patterns in the code not covered by existing rules?
    - Did you find repeated issues that should be documented?
    - Are there new best practices emerging from this code?
    - Were there patterns you had to explain that aren't in the rules?

    **Step 2: Generate rule update suggestions:**

    For each gap identified, create a suggestion:

    ````markdown
    ### Suggested Rule Addition #{N}

    **Target File:** `~/.rulesync/rules/{rule-file}.md`
    **Section:** {section-name or "New Section"}
    **Type:** {Addition | Update | New Pattern}

    **Reasoning:**
    {Why this rule addition would help - reference specific findings from review}

    **Proposed Content:**

    ```markdown
    {Exact markdown to add to the rule file}
    ```
    ````

    **Examples from This Review:**
    - `{file}:{line}` - {What was good/bad}

    ````

    **Step 3: Ask the user:**

    Count total suggestions and ask:
    - "✨ I've identified **{N}** potential improvements to our rules based on this review. Would you like to review and apply them?"

    If yes, show each suggestion one at a time:
    - Display the suggestion with file, section, and content
    - Ask: "Apply this rule update? (yes/no/skip)"
    - Allow user to approve/reject each suggestion

    **Step 4: Apply approved updates:**

    For each approved suggestion:
    - Open the specified rule file
    - Add the content to the appropriate section
    - Add a changelog note at the end of the section:
      ```markdown
      ---
      *Updated: {date} - Added pattern based on QA review of {PR/branch}*
    ````

    - Save the file
    - Track which rules were updated

    **Step 5: Regenerate rulesync (if rules updated):**

    If any rules were updated:
    - Ask: "Would you like me to regenerate rulesync to propagate these rule changes to all agents?"
    - If yes, run: `./scripts/rulesync.sh`
    - Show confirmation of regeneration

    **Step 6: Summary of improvements:**

    ```markdown
    ## 📚 Rules Updated

    **Total Suggestions:** {N}
    **Applied:** {M}
    **Skipped:** {P}

    **Updated Files:**

    - `~/.rulesync/rules/{file1}.md` - Added {pattern name}
    - `~/.rulesync/rules/{file2}.md` - Updated {section name}

    **Impact:**
    Future reviews will check for these patterns automatically, improving
    code quality across the team.

    **Next Steps:**

    - Rulesync regenerated: {yes/no}
    - Share rule updates with team: {yes/no}
    ```

---

## Notes

- ✅ Be objective and base decisions on defined criteria
- 📝 Provide specific, actionable feedback with file locations
- 🚫 If automated checks fail, PR is typically blocked unless justified
- ⚖️ Balance thoroughness with pragmatism
- 📚 Learn from each review to improve future reviews
- 🔄 Keep rules synchronized with actual code patterns
