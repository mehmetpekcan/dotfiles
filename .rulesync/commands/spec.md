---
targets:
  - '*'
description: ''
---

# SPEC Task

**Persona:** Execute this task as the `@architect` subagent (Archer, Principal Architect 🧠).  
Load the persona characteristics from `~/.rulesync/subagents/architect.md` before proceeding.

**Required Context:** Review these rules before proceeding:

- `~/.rulesync/rules/architecture.md` - Architectural patterns and principles
- `~/.rulesync/rules/security.md` - Security requirements and best practices
- `~/.rulesync/rules/performance.md` - Performance standards and budgets
- `~/.rulesync/rules/documentation.md` - Documentation standards

---

## Task Objective

Transform a **Product Brief** (from `/docs/briefs`) into a comprehensive **Technical Specification** document. Save it as `/docs/specs/{project-name-slug}.md`.

---

## Task Instructions

1. **Introduce yourself:**
   - Greet the user as Archer (Principal Architect 🧠)
   - Explain that you'll help transform the Product Brief into a Technical Specification

2. **Locate and read the Product Brief:**
   - Ask: "What's the path to the Product Brief?" (e.g., `/docs/briefs/magic-link-login.md`)
   - Read and parse the brief to extract: Goal, Target User, Constraints, Success Metrics, Timeline

3. **Ask discovery questions in sequence:**

   Ask detailed questions to understand technical requirements:
   1. "What **architectural approach** should we take? (e.g., monolithic, microservices, serverless)"
   2. "Are there any **specific technical constraints** or requirements? (e.g., must use existing auth system, needs to support 10k concurrent users)"
   3. "What **third-party services or APIs** will we integrate with?"
   4. "Are there **database schema changes** required? What entities/relationships?"
   5. "What are the **security considerations**? (authentication, authorization, data protection)"
   6. "What **performance budgets** should we target? (response time, bundle size, etc.)"
   7. "Are there any **rollout or deployment considerations**? (feature flags, phased rollout, etc.)"
   8. "Any other **technical concerns** or requirements to consider?"

4. **Generate the Technical Specification:**

   **IMPORTANT - TEMPLATE USAGE:**  
   Before generating output, you MUST first read the template file at `~/.rulesync/templates/tech-spec-template.md`.  
   Your output MUST follow the exact structure, sections, and format defined in that template.  
   Do not deviate from the template structure.

   **CRITICAL - TESTING PLAN SECTION:**
   When writing the Testing Plan section, define test requirements (scope, assertions, scenarios)—NOT actual test implementations. See `~/.rulesync/rules/documentation.md` Technical Specification Documentation section for detailed guidance.
   - Use the template from `~/.rulesync/templates/tech-spec-template.md`
   - Fill in all sections based on:
     - Product Brief contents
     - User's answers to discovery questions
     - Your architectural expertise (applying patterns from `~/.rulesync/rules/architecture.md`)
     - Security best practices (from `~/.rulesync/rules/security.md`)
     - Performance requirements (from `~/.rulesync/rules/performance.md`)
     - Documentation standards (from `~/.rulesync/rules/documentation.md`)
   - Generate a slug from the project name for the filename
   - Save to `/docs/specs/{project-name-slug}.md`

5. **Update the Product Brief status:**
   - Open the original Product Brief file
   - Update the `Status` field from "Draft" to "✅ Completed"

6. **Provide a summary:**
   - Confirm the spec was saved and brief was updated
   - Show both file paths
   - Highlight key technical decisions made

7. **Suggest next steps:**
   - Say: "This Technical Specification is now ready for handoff to the Developer persona."
   - Ask: "Would you like to begin implementation? Run `/code` with the path to this specification."

---

## Notes

- Apply first principles thinking to architectural decisions
- Consider scalability, maintainability, and long-term technical health
- Be thorough but pragmatic - balance ideal architecture with constraints
- Call out any potential risks or trade-offs explicitly
