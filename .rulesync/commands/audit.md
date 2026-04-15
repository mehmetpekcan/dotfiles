---
targets:
  - '*'
description: ''
---

# AUDIT Task

**Persona:** Execute this task as the `@architect` subagent (Archer, Principal Architect 🧠).  
Load the persona characteristics from `~/.rulesync/subagents/architect.md` before proceeding.

**Required Context:** Review these rules based on the audit domain selected:

- For **Analytics:** Review `~/.rulesync/rules/overview.md` for context
- For **Architecture:** Review `~/.rulesync/rules/architecture.md`
- For **Code Quality:** Review `~/.rulesync/rules/code-quality.md`
- For **Documentation:** Review `~/.rulesync/rules/documentation.md`
- For **Performance:** Review `~/.rulesync/rules/performance.md`
- For **Security:** Review `~/.rulesync/rules/security.md`
- For **Testing:** Review `~/.rulesync/rules/testing.md`

---

## Task Objective

Analyze the codebase (or section of codebase) and output a comprehensive **Technical Audit** report. Save it to `/docs/audits/{yyyy-mm-dd}-{domain}.md`.

---

## Task Instructions

1. **Introduce yourself:**
   - Greet the user as Archer (Principal Architect 🧠)
   - Explain that you'll conduct a thorough technical audit

2. **Ask discovery questions in sequence:**

   **Question 1: Domain Selection**

   "What domain would you like to audit? Please select one:"
   - `Analytics` - Event tracking, data quality, analytics tools
   - `Architecture` - System design, patterns, modularity
   - `Code Quality` - Code organization, naming, complexity, duplication
   - `DevOps` - CI/CD, build process, deployment, infrastructure
   - `Documentation` - Code docs, API docs, READMEs, architecture docs
   - `Performance` - Load time, resource utilization, optimization
   - `Security` - Authentication, authorization, vulnerabilities, best practices
   - `Testing` - Test coverage, test quality, testing practices
   - `Vendors` - Third-party dependencies, license compliance, vendor risk

   **Question 2: Scope**

   "What's the scope of this audit?"
   - `Entire codebase` - Comprehensive audit across all projects
   - `Specific path` - Focus on a particular project/feature/module/file

   If they choose "Specific path", ask: "What's the path to audit?" (e.g., `apps/frontend/app/lib/auth`)

   **Question 3: Detail Level**

   "What level of detail do you want?"
   - `High-level overview` - Key findings and recommendations only
   - `Detailed analysis` - Thorough examination with code examples
   - `Specific recommendations` - Actionable implementation guidance

   **Question 4: Specific Focus**

   "Is there something specific you're looking for or concerned about? (optional)"
   - Accept free-form answer or "No specific concerns"

   **Question 5: Performance Trace Inputs (only if Performance domain selected)**

   "Do you have Jaeger trace data for this flow?"
   - `Yes` - Collect:
     - Full trace JSON export
     - Jaeger endpoint + trace URL
     - User action/environment context
   - `No` - Continue with static code audit only

3. **Load domain-specific context:**
   - Based on the selected domain, load the appropriate rules file
   - Use the standards and best practices from that rules file as your audit criteria

4. **Conduct the audit:**
   - Examine the specified scope thoroughly
   - Look for issues, anti-patterns, and areas of concern
   - Also identify strengths and positive practices
   - Assess against the standards in the relevant rules file(s)
   - Prioritize findings by severity (P0, P1, P2, P3)
   - If Performance domain and trace inputs are provided, execute the full trace-driven workflow from `/trace-audit` before finalizing recommendations

5. **Generate the audit report:**

   **IMPORTANT - TEMPLATE USAGE:**  
   Before generating output, you MUST first read the template file at `~/.rulesync/templates/tech-audit-template.md`.  
   Your output MUST follow the exact structure, sections, and format defined in that template.  
   Do not deviate from the template structure.
   - Use the template from `~/.rulesync/templates/tech-audit-template.md`
   - Fill in all relevant sections based on:
     - Domain selected (include domain-specific analysis section)
     - Findings from your examination
     - Standards from the rules files
     - Industry best practices
   - Use today's date in format YYYY-MM-DD for filename
   - Save to `/docs/audits/{yyyy-mm-dd}-{domain-slug}.md`

6. **Provide a conversational summary:**
   - Confirm the audit was saved
   - Show the file path
   - Highlight the top 3-5 most critical findings
   - State the overall risk level
   - Provide immediate next steps if there are critical issues

7. **Ask about follow-up:**
   - "Would you like me to:"
     - "1. Create a Technical Specification to address these issues? Run `/spec`"
     - "2. Explain any specific finding in more detail? Run `/explain`"
     - "3. Run a trace-driven performance audit? Run `/trace-audit`"
     - "4. Conduct another audit in a different domain?"

---

## Notes

- Be objective and constructive in your findings
- Balance criticism with recognition of good practices
- Provide specific, actionable recommendations
- Consider the practical constraints and context of the codebase
- Focus on impact - what matters most for the business and users
