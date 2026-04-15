---
targets:
  - '*'
root: false
description: Unit and integration testing best practices and patterns
globs:
  - '**/*'
cursor:
  description: Unit and integration testing best practices and patterns
  globs:
    - '**/*'
---

# Unit Testing Rules

## Testing Best Practices

- **Test Behavior, Not Implementation:** Focus on what the code does, not how it does it
- **Arrange-Act-Assert (AAA):** Structure tests clearly with setup, execution, and verification
- **One Assertion Per Test:** Keep tests focused on a single behavior
- **Use Descriptive Names:** Test names should read like specifications
- **Mock External Dependencies:** Isolate the unit under test
- **Test Edge Cases:** Empty inputs, null values, boundary conditions, errors
- **Keep Tests Fast:** Unit tests should run in milliseconds
- **Avoid Test Interdependence:** Each test should be runnable independently
- **Use Test Helpers:** Leverage test helper functions for consistent setup
- **Test Error Handling:** Verify proper error messages and error states
- **Coverage Targets:** Aim for 90%+ coverage on tRPC procedures
- **Database Testing:** Use Docker test environment with SQLite
- **Prefer integration tests over mocks**; only mock when absolutely necessary. If mocking is required, place shareable mocks in jest.setup.ts
- **Test descriptions must be concise** and not start with "should". Example: use "it does" instead of "it should do"
- **Never clear, restore, or reset mocks manually**; this is handled globally

---

## Testing Framework

We use **Jest** for unit and integration testing.

- Jest config: `apps/frontend/jest.config.ts`
- Test setup: `apps/frontend/jest.setup.ts`
- Test command: `pnpm test`

For E2E testing with Playwright, see `{agent_directory}/{rules_directory}/e2e-testing.md`.

## Test File Organization

- Name test files as `<file_being_tested_name>.test.ts(x)` and place them in the same directory as the file being tested
- **Never use a `__tests__` or `**tests**` directory**
- Look for an existing test file before creating one
- All test files must have a root describe block named after the file being tested

---

## Unit Tests (Jest)

### Test Structure

From `apps/frontend/app/lib/test-helpers.test.ts`:

```typescript
import {describe, expect, it} from '@jest/globals'
import {createTestUser, createTestTeam, createTestConversation, createTestMessage} from './test-helpers'

describe('Test Helpers', () => {
	describe('createTestUser', () => {
		it('creates a test user with default values', async () => {
			const user = await createTestUser()

			expect(user).toBeDefined()
			expect(user.id).toBeDefined()
			expect(user.email).toContain('@example.com')
			expect(user.username).toContain('testuser-')
		})

		it('creates a test user with custom values', async () => {
			const customEmail = 'custom@test.com'
			const customUsername = 'customuser'

			const user = await createTestUser({email: customEmail, username: customUsername})

			expect(user.email).toBe(customEmail)
			expect(user.username).toBe(customUsername)
		})
	})

	describe('Integration - Workspace Member', () => {
		it('creates workspace with member', async () => {
			const user = await createTestUser()
			const team = await createTestTeam()
			const member = await createTestTeamMember(user.id, team.id)

			expect(member).toBeDefined()
			expect(member.user_id).toBe(user.id)
			expect(member.team_id).toBe(team.id)
		})
	})
})
```

## Testing User Events (React Testing Library)

- Use `userEvent` for simulating user interactions as it closely mimics real user actions
- **Do not use `fireEvent`** unless necessary

**GOOD Example:**

```typescript
it('handles user interactions correctly', async () => {
	const user = userEvent.setup()
	const {findByRole, getByRole} = renderTest()

	const input = await findByRole('textbox')
	const button = getByRole('button', {name: 'Submit'})

	await user.type(input, 'Hello')
	await user.click(button)

	expect(mockSubmit).toHaveBeenCalledWith('Hello')
})
```

## Falsy Assertions Requirements

**CRITICAL**: Always precede falsy assertions with truthy assertions to ensure correct state:

**GOOD Example:**

```typescript
it('tests something', async () => {
	const {queryByTestId, findByRole} = renderTest()

	// First, assert the existence of something
	expect(await findByRole('button')).toBeVisible()

	// Then make the falsy assertion
	expect(queryByTestId('something')).toBeNull()
})
```

**BAD Example:**

```typescript
it('tests something', async () => {
	const {queryByTestId} = renderTest()

	expect(queryByTestId('something')).not.toBeTruthy()
})
```

## Mocking Guidelines

### Preferred Mocking Syntax

**GOOD Example:**

```typescript
// Mock the entire module at the top of the file
jest.mock('@example/hooks', () => ({
	...jest.requireActual<typeof import('@example/hooks')>('@example/hooks'),
	__esModule: true,
	useCalculation: jest.fn()
}))

const mockUseCalculation = jest.mocked(useCalculation)

function renderTest() {
	mockUseCalculation.mockImplementation(() => ({performCalculation: jest.fn(), isLoading: false}))
	// rest of setup...
}
```

**BAD Example:**

```typescript
// NEVER use requireMock
const mockFunction = jest.requireMock('path/to/module').functionName
```

### Mocking Timers

- Use `jest.useFakeTimers()` when testing Date-dependent code
- **NEVER mock the Date constructor directly**

**GOOD Example:**

```typescript
describe('time-dependent tests', () => {
	beforeEach(() => {
		jest.useFakeTimers({now: new Date('10/10/2024')})
	})

	afterAll(() => {
		jest.useRealTimers()
	})

	it('tests time functionality', () => {
		// Test implementation
	})
})
```

## Behavioral Testing

- **Avoid simple render tests**; focus on behavior and interactions
- **Test meaningful assertions** for interactive elements and branching logic
- Ensure tests include user interaction or state changes

**GOOD Example:**

```typescript
it('calls onClose when primary CTA is pressed', async () => {
	const user = userEvent.setup()
	const mockOnClose = jest.fn()
	const {getByRole} = renderTest(mockOnClose)

	const button = getByRole('button', {name: 'Okay'})
	expect(button).not.toBeDisabled()

	await user.click(button)

	await waitFor(() => {
		expect(mockOnClose).toHaveBeenCalled()
	})
})
```

**BAD Example:**

```typescript
it('renders with basic payment method data', async () => {
	const {findByText} = renderTest()

	expect(await findByText('Test Bank Account')).toBeInTheDocument()
})
```

### Testing tRPC Procedures

From `apps/frontend/app/api/trpc/routers/chat/post-message.test.ts`:

```typescript
import {describe, it, expect, beforeEach, afterEach} from '@jest/globals'
import {appRouter} from '@/app/api/trpc/router'
import {createTestContext, createTestUser, createTestTeam, createTestConversation} from '@/app/lib/test-helpers'
import {TRPCError} from '@trpc/server'

describe('chat.postMessage', () => {
	let user: Awaited<ReturnType<typeof createTestUser>>
	let team: Awaited<ReturnType<typeof createTestTeam>>
	let conversation: Awaited<ReturnType<typeof createTestConversation>>
	let caller: ReturnType<typeof appRouter.createCaller>

	beforeEach(async () => {
		user = await createTestUser()
		team = await createTestTeam()
		conversation = await createTestConversation(team.id)

		// Add user to conversation
		await prisma.conversationMember.create({data: {user_id: user.id, conversation_id: conversation.id}})

		// Create caller with user context
		caller = appRouter.createCaller(await createTestContext({userId: user.id, teamId: team.id}))
	})

	it('posts message successfully', async () => {
		const result = await caller.chat.postMessage({channel: conversation.id, text: 'Hello, world!'})

		expect(result.ok).toBe(true)
		expect(result.ts).toBeDefined()
		expect(result.message?.content).toBe('Hello, world!')
	})

	it('fails when channel not found', async () => {
		await expect(caller.chat.postMessage({channel: 'invalid_id', text: 'Hello'})).rejects.toThrow(TRPCError)
	})

	it('fails when user not in private channel', async () => {
		const privateConversation = await createTestConversation(team.id, {is_private: true})

		await expect(caller.chat.postMessage({channel: privateConversation.id, text: 'Hello'})).rejects.toThrow(TRPCError)
	})
})
```

### Testing Seed Scripts

Seed scripts use State API pattern (HTTP POST to `/api/state`). Test patterns:

- **Builder functions:** Test independently, verify return arrays with correct structure and ID constant usage
- **HTTP integration:** Test State API POST with mock fetch or test server
- **Message ID generation:** Use `withFakeTimers` helper when testing pre-generation
- **State object format:** Verify structure matches State API requirements (table names as keys, arrays as values)

### Preventing Message ID Collisions in Integration Tests

When testing tRPC procedures that create multiple messages quickly (e.g., in loops), message ID collisions can occur because message IDs are generated from Unix timestamps (seconds). Messages created within the same second will have identical IDs, causing database unique constraint violations.

**Use `withFakeTimers` helper to prevent collisions:**

The `withFakeTimers` helper mocks `Date.now()` to control message ID generation without blocking async operations (unlike `jest.useFakeTimers()` which can block database calls).

**Common Patterns:**

```typescript
// Pattern 1: Loop with multiple messages
it('supports cursor-based pagination', async () => {
	await withFakeTimers(async ({advanceTime}) => {
		for (let i = 0; i < 5; i++) {
			await caller.chat.postMessage({channel: testConversation.id, text: `Message ${i}`})
			advanceTime() // Advance after each message
		}
	})
})

// Pattern 2: Parent message + reply
it('posts a threaded reply message', async () => {
	await withFakeTimers(async ({advanceTime}) => {
		const parentResult = await caller.chat.postMessage({channel: testConversation.id, text: 'Parent message'})
		advanceTime() // Advance before creating reply

		await caller.chat.postMessage({channel: testConversation.id, text: 'Thread reply', thread_ts: parentResult.ts})
	})
})

// Pattern 3: Operations that create multiple messages
it('creates separate system messages for each channel', async () => {
	await withFakeTimers(async ({advanceTime}) => {
		const result = await caller.team.inviteTeammates({
			team_id: teamId,
			emails: [email],
			channel_ids: [channel1.id, channel2.id] // Creates 2 system messages
		})
		advanceTime() // Advance after operation completes
	})
})
```

**Best Practices:**

1. **Always advance time after message creation operations**
2. **Advance time before creating dependent messages** (e.g., replies)
3. **Wrap entire test in `withFakeTimers`** when multiple messages are created
4. **Don't use for single message tests** (no collision risk)

**Key Points:**

- **When to use:** Integration tests creating multiple messages via API endpoints in loops or rapid succession
- **How it works:** Mocks `Date.now()` (used by `generateMessageId()`) to return controlled timestamps
- **Why not `jest.useFakeTimers()`:** Blocks async operations like database calls, causing timeouts
- **Automatic cleanup:** The `withFakeTimers` wrapper automatically restores `Date.now()` after test completes
- **Default behavior:** Advances time by 1 second (1000ms) per `advanceTime()` call

**When NOT to use:**

- Single message creation tests (no collision risk)
- Tests that need real timestamps for validation
- Tests creating messages with explicit dates via `generateMessageId(date)` parameter
- Tests that don't create messages (e.g., read-only queries)

### Test Helpers

From `apps/frontend/app/lib/test-helpers.ts`:

```typescript
import prisma from './prisma'
import type {Prisma} from '@prisma/client'
import {randomBytes} from 'crypto'

export async function createTestUser(overrides?: Partial<Prisma.UserCreateInput>) {
	const randomId = randomBytes(4).toString('hex')

	return await prisma.user.create({
		data: {email: `testuser-${randomId}@example.com`, username: `testuser-${randomId}`, deleted: false, ...overrides}
	})
}

export async function createTestTeam(overrides?: Partial<Prisma.TeamCreateInput>) {
	const randomId = randomBytes(4).toString('hex')

	return await prisma.team.create({data: {name: 'Test Workspace name', slug: `test-slug-${randomId}`, ...overrides}})
}

export async function createTestConversation(teamId: string, overrides?: Partial<Prisma.ConversationCreateInput>) {
	return await prisma.conversation.create({
		data: {
			name: 'test-channel',
			context_team_id: teamId,
			is_channel: true,
			created: Math.floor(Date.now() / 1000),
			...overrides
		}
	})
}

export async function createTestContext({userId, teamId}: {userId?: string | null; teamId?: string | null} = {}) {
	return {headers: new Headers(), userId: userId ?? null, teamId: teamId ?? null}
}
```

---

## Testing with Docker

### Test Environment Setup

From `apps/frontend/package.json`:

```json
{
	"scripts": {
		"pretest": "docker compose -f ../../docker-compose.yml --env-file ../../.env.test up -d && pnpm prisma:generate && pnpm db:reset:test",
		"test": "npx dotenv-cli -e ../../.env.test -- jest",
		"db:reset:test": "npx dotenv-cli -e ../../.env.test -- pnpm prisma:migrate"
	}
}
```

**Test Workflow:**

1. `docker compose` starts test database
2. `prisma:generate` creates Prisma client
3. `db:reset:test` runs migrations on test database
4. `jest` runs tests with test environment variables

### Jest Configuration

From `apps/frontend/jest.config.ts`:

```typescript
import type {Config} from 'jest'

const config: Config = {
	preset: 'ts-jest',
	testEnvironment: 'node',
	setupFilesAfterEnv: ['<rootDir>/jest.setup.ts'],
	testMatch: ['**/*.test.ts', '**/*.test.tsx'],
	moduleNameMapper: {'^@/(.*)$': '<rootDir>/$1'},
	coverageDirectory: '<rootDir>/coverage/',
	testTimeout: 10000,
	maxWorkers: '50%',
	forceExit: true // Prevents hanging on open handles
}

export default config
```

---

## Testing Real-Time Features

### WebSocket Testing

```typescript
import {describe, it, expect} from '@jest/globals'
import WebSocket from 'ws'

describe('WebSocket Server', () => {
	it('connect and receive messages', done => {
		const ws = new WebSocket('ws://localhost:8091')

		ws.on('open', () => {
			// Subscribe to channel
			ws.send(
				JSON.stringify({
					id: 1,
					jsonrpc: '2.0',
					method: 'subscription',
					params: {path: 'chat.onAdd', input: {channelId: 'ch_123'}}
				})
			)
		})

		ws.on('message', data => {
			const message = JSON.parse(data.toString())
			expect(message.result).toBeDefined()
			ws.close()
			done()
		})
	})
})
```

## Hook Testing

### Testing Custom Hooks

```typescript
// Use renderHook for testing custom hooks
import {act, renderHook} from '@testing-library/react'

describe('useToggle', () => {
	it('initializes with false by default', () => {
		const {result} = renderHook(() => useToggle())

		expect(result.current.value).toBe(false)
	})

	it('toggles value when toggle is called', () => {
		const {result} = renderHook(() => useToggle())

		act(() => {
			result.current.toggle()
		})

		expect(result.current.value).toBe(true)
	})
})
```

---

## Storybook Testing

### Component Stories

From `apps/frontend/components/Button/Button.stories.tsx`:

```typescript
import type {Meta, StoryObj} from '@storybook/nextjs-vite'
import {Button} from './Button'

const meta: Meta<typeof Button> = {
	title: 'Components/Button',
	component: Button,
	parameters: {layout: 'centered'},
	tags: ['autodocs']
}

export default meta
type Story = StoryObj<typeof Button>

export const Default: Story = {args: {children: 'Button'}}

export const Destructive: Story = {args: {children: 'Delete', variant: 'destructive'}}

export const Outline: Story = {args: {children: 'Cancel', variant: 'outline'}}
```

---

## Anti-Patterns

### Don't: Test Implementation Details

```typescript
// ❌ BAD: Testing internal state
it('sets loading state', () => {
  const component = render(<MessageList />);
  expect(component.state.loading).toBe(true);
});

// ✅ GOOD: Test observable behavior
it('shows loading indicator', () => {
  render(<MessageList />);
  expect(screen.getByText('Loading messages...')).toBeInTheDocument();
});
```

### Don't: Create Test Interdependencies

```typescript
// ❌ BAD: Tests depend on execution order
let userId: string
it('creates user', () => {
	userId = createTestUser()
})
it('updates user', () => {
	updateUser(userId) // Depends on previous test
})

// ✅ GOOD: Each test is independent
it('updates user', async () => {
	const user = await createTestUser()
	await updateUser(user.id)
})
```

---

## Test Coverage

### Unit Test Coverage

Check coverage with:

```bash
pnpm test -- --coverage
```

Coverage reports are generated in `apps/frontend/coverage/`.

**Coverage Targets:**

- **tRPC Procedures:** 90%+ (critical business logic)
- **Utility Functions:** 80%+
- **Components:** 70%+ (focus on behavior)
- **Overall:** 80%+

---

## Related Documentation

- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [Storybook Documentation](https://storybook.js.org/docs)
- `apps/frontend/jest.config.ts` - Jest configuration
- `apps/frontend/app/lib/test-helpers.ts` - Unit test helper functions
- `{agent_directory}/{rules_directory}/e2e-testing.md` - E2E testing patterns
- `{agent_directory}/{rules_directory}/code-quality.md` - Code quality standards
