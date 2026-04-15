# Technical Specification: {Project Name}

**Date:** {YYYY-MM-DD}  
**Author:** {Current Git User}
**Product Brief:** `docs/briefs/{brief-slug}.md`

## Overview

### Purpose

{High-level purpose of this specification}

### Scope

{What is included and excluded from this specification}

### References

- Product Brief: `docs/briefs/{brief-slug}.md`
- Related Specs: {Links to related specifications}

---

## Product Brief Summary

### Problem Statement

{From Product Brief}

### Goal

{From Product Brief}

### Success Criteria

{From Product Brief}

---

## Architecture

### System Architecture

{High-level system architecture description and diagrams}

### Architectural Approach

{Monolithic / Microservices / Serverless / etc.}

**Rationale:** {Why this approach was chosen}

### Component Overview

{Key components and their responsibilities}

- **{Component 1}:** {Responsibility}
- **{Component 2}:** {Responsibility}

### Technology Stack

{Technologies and frameworks to be used}

- **{Technology}:** {Version} - {Purpose}
- **{Technology}:** {Version} - {Purpose}

---

## Data Model

### Database Schema

{Database schema changes, new tables, relationships}

```prisma
{Prisma schema example}
```

### Entities

{Key entities and their relationships}

- **{Entity 1}:** {Description}
- **{Entity 2}:** {Description}

### Data Flow

{How data flows through the system}

---

## API Design

### Endpoints

{New or modified API endpoints}

#### `{Method} {Path}`

**Description:** {Endpoint description}

**Request:**

```typescript
{Request type}
```

**Response:**

```typescript
{Response type}
```

**Errors:**

- `{Error Code}`: {Description}

### Authentication & Authorization

{Authentication and authorization requirements}

---

## Security Considerations

### Authentication

{Authentication approach and requirements}

### Authorization

{Authorization model and access control}

### Data Protection

{Data encryption, privacy, and protection measures}

### Security Best Practices

{Security practices to follow}

---

## Performance Requirements

### Performance Budgets

- **Response Time:** {Target}ms
- **Bundle Size:** {Target}KB
- **Database Query Time:** {Target}ms

### Scalability

{Scalability requirements and considerations}

### Optimization Strategies

{Performance optimization approaches}

---

## Testing Plan

### Testing Requirements

{High-level testing requirements and scope}

### Test Scenarios

{Key test scenarios to cover}

1. **{Scenario 1}:** {Description}
   - **Given:** {Precondition}
   - **When:** {Action}
   - **Then:** {Expected result}

2. **{Scenario 2}:** {Description}
   - **Given:** {Precondition}
   - **When:** {Action}
   - **Then:** {Expected result}

### Test Coverage Goals

{Target test coverage percentages}

- Unit Tests: {Target}%
- Integration Tests: {Target}%
- E2E Tests: {Target}% of critical flows (Note: E2E tests are created by human QA engineers)

### Test Assertions

{Key assertions to verify}

- {Assertion 1}
- {Assertion 2}

---

## Deployment & Rollout

### Deployment Strategy

{How this will be deployed}

### Feature Flags

{Feature flags needed for gradual rollout}

### Rollout Plan

{Phased rollout approach if applicable}

### Rollback Plan

{How to rollback if issues occur}

---

## Documentation Requirements

### Code Documentation

{Documentation requirements for code}

### API Documentation

{API documentation requirements}

### User Documentation

{User-facing documentation needs}

---

## Dependencies

### External Dependencies

{Third-party services, APIs, or libraries}

- **{Dependency}:** {Version} - {Purpose}

### Internal Dependencies

{Other parts of the system this depends on}

- **{Module/Service}:** {Dependency description}

---

## Risks & Mitigations

### Technical Risks

| Risk   | Impact            | Probability       | Mitigation   |
| ------ | ----------------- | ----------------- | ------------ |
| {Risk} | {High/Medium/Low} | {High/Medium/Low} | {Mitigation} |

### Operational Risks

{Operational risks and mitigations}

---

## Open Questions

{Questions that need to be answered}

1. {Question 1}
2. {Question 2}

---

## Implementation Plan

### Phase 1: {Phase Name}

{Description}

**Tasks:**

1. {Task 1}
2. {Task 2}

**Timeline:** {Duration}

### Phase 2: {Phase Name}

{Description}

**Tasks:**

1. {Task 1}
2. {Task 2}

**Timeline:** {Duration}

---

## Success Criteria

{How we'll measure success}

- {Criterion 1}
- {Criterion 2}

---

## Next Steps

1. {Next step 1}
2. {Next step 2}

---

**Status:** Draft → {Next Status}  
**Last Updated:** {YYYY-MM-DD}
