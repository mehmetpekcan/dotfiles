---
targets:
  - '*'
description: ''
---

# EXPLAIN Task

**Persona:** Execute this task as the `@developer` subagent (Devin, Staff Engineer 💻).  
Load the persona characteristics from `.rulesync/subagents/developer.md` before proceeding.

**Required Context:** Review these rules before proceeding:

- `.rulesync/rules/architecture.md` - Architectural patterns to identify
- `.rulesync/rules/code-quality.md` - Quality standards for evaluation
- `.rulesync/rules/documentation.md` - Documentation best practices

---

## Task Objective

Provide a clear, comprehensive explanation of how a file, folder, or feature works. Break down complex logic, explain architectural decisions, trace data flows, and optionally suggest improvements.

---

## Task Instructions

1. **Initiate discovery:**
   - Ask: "What would you like me to explain? (provide a file path, folder path, or feature description)"
   - Examine the target code and its context

2. **Determine explanation scope:**

   Ask these questions:
   1. "What level of detail would you like?"
      - `high-level` - Overview and key concepts only
      - `detailed` - Thorough walkthrough with examples
      - `deep-dive` - Comprehensive analysis with all details
   2. "Would you like me to suggest improvements or optimizations?"
   3. "Are there specific aspects you want me to focus on? (e.g., data flow, error handling, performance, security)"

3. **Analyze the code thoroughly:**
   - Read the target file(s)
   - Understand overall purpose and functionality
   - Trace execution flow and data transformations
   - Identify dependencies and integrations
   - Note error handling and edge cases
   - Recognize architectural patterns (from `.rulesync/rules/architecture.md`)
   - Check related files for context (README, tests, types)

4. **Provide structured explanation:**

   **For Files:**
   - Start with purpose and context
   - Explain imports and dependencies
   - Walk through main logic step-by-step
   - Highlight edge cases, error handling, security measures
   - Note any non-obvious code or technical debt

   **For Folders/Modules:**
   - Explain module purpose and responsibility
   - Describe folder structure and organization
   - Identify main entry points and public API
   - Describe common usage patterns

   **For Features:**
   - Explain from user perspective
   - Trace implementation across files (frontend → backend → database)
   - Explain data flow through the system
   - Describe integration points and business logic

5. **Use clear, accessible language:**
   - Start with high-level concepts before details
   - Use analogies and examples when helpful
   - Define technical terms and jargon
   - Break complex logic into digestible chunks
   - Use Mermaid diagrams for complex flows when helpful
   - Highlight the "why" behind decisions

6. **Optionally provide improvement suggestions:**

   If requested, analyze for improvements using standards from:
   - `.rulesync/rules/code-quality.md` - Code quality opportunities
   - `.rulesync/rules/performance.md` - Performance optimizations
   - `.rulesync/rules/security.md` - Security enhancements
   - `.rulesync/rules/architecture.md` - Architectural improvements

   Format suggestions with:
   - Priority (High/Medium/Low)
   - Category (Code Quality/Performance/Security/etc.)
   - Current vs. Suggested approach
   - Benefits and trade-offs
   - Effort estimate

7. **Provide summary:**
   - Recap main points of explanation
   - Highlight most important takeaways
   - If suggestions provided, summarize top priorities
   - Offer to dive deeper into specific areas
   - Ask: "Would you like me to explain any specific part in more detail, or help implement any suggested improvements?"

---

## Notes

- Start broad, then focus on details
- Use examples to demonstrate concepts
- Explain trade-offs and design decisions
- Be honest about unclear code or technical debt
- Teach principles, not just mechanics
