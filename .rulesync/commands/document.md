---
targets:
  - '*'
description: ''
---

# DOCUMENT Task

**Persona:** Execute this task as the `@developer` subagent (Devin, Staff Engineer 💻).  
Load the persona characteristics from `.rulesync/subagents/developer.md` before proceeding.

**Required Context:** Review these rules before proceeding:

- `.rulesync/rules/documentation.md` - Documentation standards and patterns
- `.rulesync/rules/code-quality.md` - Code quality standards for inline comments

---

## Task Objective

Create thorough, maintainable documentation for a specified file, folder, or feature. This includes inline code comments, JSDoc function signatures, and/or complete README files. Follow all standards from `.rulesync/rules/documentation.md`.

---

## Task Instructions

1. **Initiate discovery:**
   - Ask: "What would you like me to document? (provide a file path, folder path, or feature description)"
   - Examine the target code to understand purpose, functionality, and relationships

2. **Determine documentation type:**

   Ask these questions:
   1. "What type of documentation should I create?"
      - `inline` - Inline code comments
      - `jsdoc` - JSDoc function signatures
      - `readme` - Complete README file
      - `all` - Comprehensive documentation
   2. "Are there any specific sections or aspects you want me to focus on?"
   3. "Should I update existing documentation or create new documentation?"

3. **Analyze the code:**
   - Read the target file(s)
   - Understand overall purpose and functionality
   - Identify key functions, classes, components
   - Note dependencies and integrations
   - Check for existing documentation
   - Identify architectural decisions or design patterns used

4. **Write documentation following standards:**

   Apply all documentation patterns from `.rulesync/rules/documentation.md`:
   - **Inline Comments:** Explain "why" not "what", comment edge cases and assumptions
   - **JSDoc Comments:** Add to all exported functions with `@param`, `@returns`, `@throws`, `@example` tags
   - **README Files:** Use the template from `.rulesync/templates/readme-template.md`

   **IMPORTANT - TEMPLATE USAGE (for README files):**  
   Before generating a README, you MUST first read the template file at `.rulesync/templates/readme-template.md`.  
   Your output MUST follow the exact structure, sections, and format defined in that template.  
   Do not deviate from the template structure.

   Ensure:
   - Documentation is clear, accurate, and maintainable
   - Code examples are syntactically correct
   - Consistent formatting throughout
   - No grammar or spelling errors

5. **Verify documentation quality:**
   - Ensure all code examples are valid TypeScript
   - Verify all links and references are correct
   - Test that documented commands actually work
   - Check for completeness

6. **Provide summary:**
   - List all documentation files created or modified
   - Summarize what was documented
   - Highlight any gaps or areas that need further documentation
   - Note any related README files that should be updated
   - Provide recommendations for improving code clarity
   - Ask: "Would you like me to test this code (`/test`) or make any other improvements?"

---

## Notes

- Reference `.rulesync/rules/documentation.md` for all documentation patterns
- For README files, use the template from `.rulesync/templates/readme-template.md`
- Document the "why" more than the "what"
- Keep documentation current with code changes
- Use examples to show, not just tell
