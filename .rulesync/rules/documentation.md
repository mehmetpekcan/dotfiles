---
targets:
  - '*'
root: false
description: Documentation best practices and patterns
globs:
  - '**/*'
cursor:
  description: Documentation best practices and patterns
  globs:
    - '**/*'
---

# Documentation Rules

## Documentation Best Practices

- **Clarity Over Brevity:** Better to be clear than concise
- **Maintain Context:** Document the "why" more than the "what"
- **Update Proactively:** Update docs when code changes
- **Assume Fresh Eyes:** Write for someone unfamiliar with the code
- **Use Examples:** Show, don't just tell with code examples
- **Stay Current:** Remove outdated comments and documentation
- **Be Specific:** Avoid vague terms like "handles things" or "processes data"
- **Document Assumptions:** State implicit assumptions explicitly
- **Link Related Docs:** Reference related files, functions, or external resources
- **Test Documentation:** Verify that examples and instructions actually work
- **Use JSDoc:** Document all public functions, types, and classes with JSDoc
- **README Files:** Every app and package should have a README
- **Type Comments:** Add inline comments to complex types for clarity

---

## Technical Specification Documentation

### Testing Plan Section Guidelines

**CRITICAL:** When documenting testing plans in technical specifications, define test requirements and coverage—NOT actual test implementations.

**Specification Phase (this document):**

- ✅ WHAT to test (test scenarios, user flows, edge cases)
- ✅ Required assertions (what outcomes must be verified)
- ✅ Test scope and setup requirements (data, environment, selectors)
- ✅ Coverage summary (critical requirements validated)
- ❌ NOT actual test code implementation
- ❌ NOT prescriptive test syntax or framework specifics

**Implementation Phase (developer task):**

- Developer writes actual test code based on spec requirements
- Developer chooses implementation details (helper functions, test structure, etc.)
- Developer follows e2e-testing.md and unit-testing.md rules for HOW to write tests

**Format for Test Requirements:**

```markdown
#### Test Scope

**Setup Requirements:**

- Environment/data setup needs
- Navigation/preconditions
- Selector strategy (data-testid, ARIA roles)

#### Required Test Coverage

##### Test Area: [Feature Name]

**Test: [Scenario name]**

- **Setup:** [Initial conditions if any]
- **Actions:** [User interactions to perform]
- **Assertions:** [Expected outcomes to validate]
- **Edge Cases:** [Special conditions to handle]

**Test: [Another scenario]**

- **Assertion:** [Expected initial state]
- **Action:** [User interaction]
- **Assertion:** [Expected outcome]

#### Coverage Summary

**Critical Requirements Validated:**

- ✅ Requirement 1 (description)
- ✅ Requirement 2 (critical - explain why)

**Edge Cases:**

- Scenario 1 description
- Scenario 2 description
```

**Example (GOOD):**

```markdown
### E2E Tests

**Test File:** `apps/frontend/e2e/specs/navigation/homenav-collapse.spec.ts`

#### Required Coverage

**Test: Default expanded state**

- **Assertion:** Multiple channel items (> 1) are visible on page load
- **Assertion:** First channel item is visible

**Test: Collapse functionality**

- **Action:** Click Channels header button
- **Assertion:** After collapse, only 1 channel item visible (the active one)

**Test: Active item visibility (CRITICAL)**

- **Setup:** Identify currently active channel
- **Action:** Click header to collapse
- **Assertion:** Active channel remains visible
- **Assertion:** Other channels are hidden
```

**Example (BAD - Don't Do This):**

```typescript
// ❌ BAD: Actual test implementation in spec
test('collapses channels section', async ({page}) => {
	const channelsButton = page.getByRole('button', {name: 'Channels'})
	await channelsButton.click()
	expect(await page.getByTestId('channel-item').count()).toBe(1)
})
```

**Rationale:**

- Specs define requirements, not solutions
- Test implementations are implementation details
- Allows developer flexibility in test structure
- Keeps specs concise and maintainable
- Separates concerns (architecture vs coding)

---

## Documentation Patterns

### Inline Comment Pattern

```typescript
// ✅ GOOD: Explains why, provides context
// We use EventEmitter for in-memory message broadcasting
// because Shack is offline-first and runs as a single instance
const messageEvents = new EventEmitter()

// ❌ BAD: States the obvious
// Create event emitter
const messageEvents = new EventEmitter()
```

Real example from tRPC routers:

```typescript
// Check if user is a member before allowing access
const member = await prisma.conversationMember.findFirst({where: {conversation_id: channelId, user_id: ctx.userId}})

if (!member) {
	throw new TRPCError({code: 'FORBIDDEN', message: 'not_in_channel'})
}
```

### JSDoc Pattern

Example for tRPC procedures:

````typescript
/**
 * Posts a message to a channel, group, or DM.
 *
 * Slack API compatibility: chat.postMessage
 * https://api.slack.com/methods/chat.postMessage
 *
 * @param input - Message parameters
 * @param input.channel - Channel, private group, or DM to send message to
 * @param input.text - Text of the message to send
 * @param input.thread_ts - Thread timestamp to reply to (optional)
 * @returns Message object with ok status
 *
 * @throws {TRPCError} NOT_FOUND - Channel not found
 * @throws {TRPCError} FORBIDDEN - User not in private channel
 * @throws {TRPCError} INTERNAL_SERVER_ERROR - Message posting failed
 *
 * @example
 * ```typescript
 * const result = await api.chat.postMessage({
 *   channel: 'C1234567890',
 *   text: 'Hello, world!',
 * });
 * ```
 */
export const chatRouter = createTRPCRouter({
	postMessage: protectedProcedure
		.input(z.object({channel: z.string(), text: z.string(), thread_ts: z.string().optional()}))
		.mutation(async ({ctx, input}) => {
			// Implementation
		})
})
````

### Type Documentation Pattern

```typescript
/**
 * Represents a Slack conversation object.
 *
 * Conversations are the unified model for channels, DMs, and groups.
 * Slack API: https://api.slack.com/types/conversation
 *
 * @see apps/frontend/prisma/schema.prisma for full schema
 */
export interface Conversation {
	/** Unique conversation identifier */
	id: string

	/** Channel name (null for DMs/MPDMs) */
	name: string | null

	/** Team/workspace ID */
	context_team_id: string

	/** Type indicators (Slack uses booleans) */
	is_channel: boolean // true for public channels
	is_group: boolean // true for private channels
	is_im: boolean // true for 1-on-1 DMs
	is_mpim: boolean // true for group DMs
	is_private: boolean // true for private channels/groups
	is_archived: boolean // true for archived conversations

	/** Unix timestamp of creation (Slack field) */
	created: number

	/** DateTime for ORM queries */
	created_at: Date
}
```

---

## README Structure

Every app and package should have a README:

### README Template

```markdown
# App/Package Name

Brief one-sentence description.

## Overview

1-2 paragraphs explaining the purpose and role in Shack.

## Key Features

- Feature 1 - Brief description
- Feature 2 - Brief description
- Feature 3 - Brief description

## Architecture

Explain the architecture specific to this app/package.

## Usage Examples

### Basic Usage

\`\`\`typescript
import { functionName } from './module';

const result = functionName(arg1, arg2);
\`\`\`

### Advanced Usage

\`\`\`typescript
// More complex example
\`\`\`

## API Reference

### `functionName(arg1, arg2)`

Description of what it does.

**Parameters:**

- `arg1` (type): Description
- `arg2` (type): Description

**Returns:** Description of return value

**Example:**

\`\`\`typescript
const result = functionName('value', 123);
\`\`\`

## Development

\`\`\`bash

# Run in development mode

pnpm dev

# Run tests

pnpm test
\`\`\`

## Related Documentation

- [Related Doc 1](./path/to/doc)
- [Related Doc 2](./path/to/doc)
```

---

## Anti-Patterns

### Don't: Write Obvious Comments

```typescript
// ❌ BAD: Obvious comment
const users = [] // Create empty array

// ✅ GOOD: No comment needed (code is self-explanatory)
const users = []
```

### Don't: Leave Outdated Comments

```typescript
// ❌ BAD: Comment doesn't match code
// Fetch user by email
const user = await prisma.user.findFirst({
	where: {id: userId} // Actually fetching by ID now
})

// ✅ GOOD: Update comment when code changes
// Fetch user by ID
const user = await prisma.user.findFirst({where: {id: userId}})
```

### Don't: Omit Examples in READMEs

```markdown
<!-- ❌ BAD: No examples -->

## Usage

Import the function and use it.

<!-- ✅ GOOD: Concrete examples -->

## Usage

\`\`\`typescript
import { parseMessage } from '@/app/lib/utils';

const result = parseMessage('@alice hello!');
console.log(result.mentions); // ['alice']
\`\`\`
```

---

## Related Documentation

- [TypeScript JSDoc Reference](https://www.typescriptlang.org/docs/handbook/jsdoc-supported-types.html)
- [README Best Practices](https://github.com/matiassingers/awesome-readme)
- `README.md` - Main project documentation
- `PRODUCT.md` - Product specification
- `{agent_directory}/{rules_directory}/code-quality.md` - Code quality standards
