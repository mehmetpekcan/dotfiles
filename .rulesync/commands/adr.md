---
targets:
  - '*'
description: ''
---

# ADR Task

**Persona:** Execute this task as the `@architect` subagent (Archer, Principal Architect 🧠).  
Load the persona characteristics from `~/.rulesync/subagents/architect.md` before proceeding.

**Required Context:** Review these rules before proceeding:

- `~/.rulesync/rules/architecture.md` - Architectural patterns and decisions
- `~/.rulesync/rules/documentation.md` - Documentation standards

---

## Task Objective

Create Architecture Decision Records (ADRs) to document important technical decisions, the context behind them, alternatives considered, and their consequences. Build a searchable history of why the system is designed the way it is.

---

## Task Instructions

1. **Ask discovery questions:**
   1. "What decision needs to be documented?"
      - Provide a brief description
   2. "What's the status of this decision?"
      - a) Proposed (under discussion)
      - b) Accepted (approved and implemented)
      - c) Deprecated (no longer recommended)
      - d) Superseded (replaced by another decision)
   3. "What prompted this decision?"
      - Business requirement, technical constraint, incident, etc.

2. **Gather decision context:**

   Ask follow-up questions to understand:
   - What problem are we solving?
   - What are the constraints?
   - What are the goals and non-goals?
   - Who are the stakeholders?
   - What's the timeline?

3. **Explore alternatives:**

   For each option considered:
   - What's the approach?
   - What are the pros?
   - What are the cons?
   - What's the estimated effort?
   - What are the risks?

4. **Document the decision:**

   Generate ADR number:
   - Check existing ADRs in `/docs/decisions/`
   - Use next sequential number (e.g., `0023`)

   Create file: `/docs/decisions/{nnnn}-{slug}.md`

   Template:

   ```markdown
   # {Number}. {Title}

   **Date:** {YYYY-MM-DD}  
   **Status:** {Proposed | Accepted | Deprecated | Superseded}  
   **Author:** {Name/Role}  
   **Stakeholders:** {List of people involved}

   {If Superseded, add: "Superseded by [ADR-XXXX](link)"}  
   {If Supersedes, add: "Supersedes [ADR-YYYY](link)"}

   ---

   ## Context and Problem Statement

   {Describe the context and problem that requires a decision}

   {Include:}

   - What is the background?
   - What triggered this decision?
   - What constraints exist? (technical, business, timeline)

   ---

   ## Decision Drivers

   Key factors influencing this decision:

   - {Driver 1: e.g., "Must scale to 100K users"}
   - {Driver 2: e.g., "Team expertise in technology X"}
   - {Driver 3: e.g., "Budget constraint of $X"}
   - {Driver 4: e.g., "Must ship by Q2"}

   ---

   ## Considered Options

   ### Option 1: {Name}

   **Description:**
   {Detailed description of this approach}

   **Pros:**

   - ✅ {Positive aspect}
   - ✅ {Positive aspect}

   **Cons:**

   - ❌ {Negative aspect}
   - ❌ {Negative aspect}

   **Estimated Effort:** {time estimate}

   ### Option 2: {Name}

   {Repeat structure}

   ### Option 3: {Name}

   {Repeat structure}

   ---

   ## Decision Outcome

   **Chosen Option:** {Option N - Name}

   **Justification:**

   We chose {Option N} because:

   - {Reason 1}
   - {Reason 2}
   - {Reason 3}

   This option best addresses {key decision drivers} while accepting
   {tradeoffs}.

   ---

   ## Consequences

   ### Positive

   - ✅ {Benefit 1}
   - ✅ {Benefit 2}
   - ✅ {Benefit 3}

   ### Negative

   - ⚠️ {Tradeoff 1}
   - ⚠️ {Tradeoff 2}
   - ⚠️ {Risk 1}

   ### Neutral

   - ℹ️ {Impact 1}
   - ℹ️ {Impact 2}

   ---

   ## Implementation

   {High-level implementation approach}

   **Key Components:**

   - {Component 1}
   - {Component 2}

   **Migration Path (if applicable):**

   1. {Step 1}
   2. {Step 2}

   **Rollback Plan:**
   {How to rollback if this doesn't work}

   ---

   ## Validation

   **How we'll measure success:**

   - {Metric 1}
   - {Metric 2}

   **Timeline:**

   - {Milestone 1}: {date}
   - {Milestone 2}: {date}

   **Review Date:** {When to reassess this decision}

   ---

   ## References

   - {Link to relevant spec, RFC, discussion}
   - {Link to benchmark, research, article}
   - {Link to related ADR}

   ---

   ## Related Decisions

   - [ADR-XXXX](link) - {Related decision}
   - [ADR-YYYY](link) - {Related decision}
   ```

5. **Update ADR index:**

   Create/update `/docs/decisions/README.md`:

   ```markdown
   # Architecture Decision Records

   Index of all ADRs for Shack.

   ## Active Decisions

   | Number                           | Title                           | Date       | Status   |
   | -------------------------------- | ------------------------------- | ---------- | -------- |
   | [0023](0023-token-auth.md)       | Token-Based Authentication      | 2025-10-29 | Accepted |
   | [0022](0022-deletion-pattern.md) | Deletion Pattern (deleted flag) | 2025-10-15 | Accepted |

   ## Deprecated Decisions

   | Number                     | Title              | Date       | Superseded By                         |
   | -------------------------- | ------------------ | ---------- | ------------------------------------- |
   | [0010](0010-api-routes.md) | API Routes Pattern | 2024-06-12 | [ADR-0020](0020-trpc-architecture.md) |

   ## By Category

   ### Architecture

   - [ADR-0023](0023-token-auth.md) - Token-Based Authentication
   - [ADR-0020](0020-trpc-architecture.md) - tRPC Architecture Pattern

   ### Database

   - [ADR-0022](0022-deletion-pattern.md) - Deletion Pattern (deleted boolean flag)
   - [ADR-0018](0018-libsql-migration.md) - SQLite adapter migration history

   ### Infrastructure

   - [ADR-0015](0015-docker-deployment.md) - Docker Deployment
   ```

6. **Link to related artifacts:**

   Ask about related documentation:
   - Technical specifications
   - Product briefs
   - Pull requests
   - Issues or discussions
   - External research or articles

   Add links to the ADR

7. **Generate diagram (if helpful):**

   Offer to create diagram illustrating the decision:
   - Architecture diagram showing new structure
   - Flow diagram showing new process
   - Comparison diagram of options considered

8. **Set review cadence:**

   For major decisions, suggest:
   - Review checkpoint dates
   - Success metrics to track
   - When to consider deprecating

9. **Provide summary:**

   ```markdown
   ## 📋 ADR Created

   **Number:** ADR-0023  
   **Title:** Token-Based Authentication  
   **File:** `/docs/decisions/0023-token-auth.md`

   **Decision:**
   Use token-based authentication (ApiToken model) for all API access.

   **Key Points:**

   - Evaluated 3 options (session-based, JWT, API tokens)
   - Chose API tokens for Slack API compatibility
   - Tokens support Bearer and x-slack-token headers
   - Expected benefits: Simple offline auth, Slack API parity

   **Status:** Accepted  
   **Review Date:** 2026-01-15

   **Next Steps:**

   1. Share with team for feedback
   2. Link to implementation spec
   3. Update project roadmap
   ```

---

## Notes

- 📝 Write ADRs for significant decisions only, not every small choice
- 🎯 Focus on "why" not "how" (implementation goes in specs)
- 🔍 Make ADRs searchable and discoverable
- 🔗 Link related ADRs to show decision evolution
- ⏰ Set review dates for major decisions
- 📊 Include data/research supporting the decision
- 🤝 List stakeholders for accountability

---

## When to Write an ADR

**DO write ADRs for:**

- ✅ Choosing technology or frameworks
- ✅ Architectural patterns and structures
- ✅ Data modeling approaches
- ✅ Security or compliance decisions
- ✅ Major refactorings or migrations
- ✅ Build/deploy process changes
- ✅ Third-party service selections

**DON'T write ADRs for:**

- ❌ Code style preferences (use linter config)
- ❌ Routine bug fixes
- ❌ Feature implementations (use specs)
- ❌ Trivial choices
- ❌ Personal preferences

---

## Example ADRs

### Example 1: Technology Choice

```markdown
# 0023. Token-Based Authentication

**Status:** Accepted  
**Date:** 2025-10-29

## Context

Shack is an offline Slack clone that must be compatible with Slack's API.
Slack uses token-based authentication, so we need an API token system.

## Decision Drivers

- App Router compatibility
- Type safety
- Developer experience
- Migration cost

## Considered Options

1. Session-based authentication (cookies)
2. JWT tokens
3. API tokens (Slack-style)

## Decision

Use API tokens with Bearer/x-slack-token headers

## Consequences

**Positive:**

- Full App Router support
- Better TypeScript types
- Improved middleware

**Negative:**

- 2-week migration
- Breaking changes

## References

- [Slack API Authentication](https://api.slack.com/authentication)
- apps/frontend/prisma/schema.prisma (ApiToken model)
```

### Example 2: Architectural Pattern

```markdown
# 0022. Deletion Pattern with Boolean Flag

**Status:** Accepted  
**Date:** 2025-10-15

## Context

Need to mark records as deleted without losing data. Slack uses deleted boolean flags.

## Decision

Use `deleted` boolean flag on User model (hard deletes for messages).

## Consequences

- Explicit filtering required in queries (where: { deleted: false })
- Can restore deleted users
- Simpler than soft-delete extension
- Slack API compatible
```

---

## Output Example

```markdown
## 📋 ADR-0023 Created

### Token-Based Authentication

**File:** `/docs/decisions/0023-token-auth.md`

**Summary:**
Decided to use token-based authentication (ApiToken model) for Slack API
compatibility and offline-first architecture.

**Alternatives Considered:**

1. Session-based (rejected - requires cookies, complex for API)
2. JWT tokens (rejected - overkill for offline use)
3. API tokens (selected - Slack-compatible, simple)

**Impact:**

- Affects: All API authentication, tRPC context
- Effort: 1 sprint
- Risk: Low (simple pattern, well-documented)

**Timeline:**

- Decision: 2025-10-29
- Implementation: Sprint 24
- Review: 2026-01-15

**Links:**

- [Slack API Auth Docs](https://api.slack.com/authentication)
- [ApiToken Schema](apps/frontend/prisma/schema.prisma)

**Index Updated:** `/docs/decisions/README.md`
```
