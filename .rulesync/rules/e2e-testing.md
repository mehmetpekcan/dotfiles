---
targets:
  - '*'
root: false
description: E2E testing best practices and patterns with Playwright
globs:
  - '**/*'
cursor:
  description: E2E testing best practices and patterns with Playwright
  globs:
    - '**/*'
---

# E2E Testing Rules

## ⚠️ Critical E2E Rules - Follow These First

### 1. ALWAYS Use Page Object Model

**Every E2E test must use page objects.** Never write selectors directly in test specs.

```typescript
// ✅ GOOD: Page Object from the start
import {DMPage} from '../../page-objects/DMPage'

test('my test', async ({page, stateApi}) => {
	const {data, ids} = buildMinimalSeed()
	await stateApi.resetDatabase(data)
	await setupAuth(page, ids.userId, 'default', ids.teamId)

	const dmPage = new DMPage(page) // Create page object
	await dmPage.navigateToDM(ids.teamId, dmId) // Use page object methods
	await dmPage.expectUnreadBadgeVisible(dmId) // Use page object assertions
})

// ❌ BAD: Direct selectors in test (brittle, requires refactoring)
test('my test', async ({page}) => {
	await page.goto(`/client/${teamId}/${dmId}`)
	await page.locator('[data-testid="unread-badge"]').waitFor()
})
```

**Page objects to use:**

- `ChannelPage` - Channel views, message sending
- `DMPage` - Direct message views (extends ChannelPage)
- `WorkspacePage` - Workspace navigation, settings
- `BasePage` - Common utilities (clickSafe, typeSafe, waitForVisible)

### 2. NEVER Use page.waitForTimeout()

**Always use explicit waits.** Never use arbitrary timeouts.

```typescript
// ✅ GOOD: Wait for specific element state
const messageInput = page.locator('[data-testid="message-input"]')
await expect(messageInput).toBeVisible({timeout: 10000})

// ✅ GOOD: Use page object wait methods
await dmPage.waitForInputEnabled()

// ❌ BAD: Arbitrary timeout (flaky, slow, breaks tests)
await page.waitForTimeout(1000) // NEVER DO THIS
await page.waitForTimeout(2000) // NEVER DO THIS
```

**Acceptable wait patterns:**

- `expect(element).toBeVisible({ timeout: 10000 })`
- `expect(element).toBeEnabled()`
- `page.waitForSelector('[data-testid="x"]', { state: "visible" })`
- `page.waitForLoadState("domcontentloaded")`
- Page object methods like `waitForInputEnabled()`

### 3. Run Tests with -- Separator for pnpm

**When passing Playwright arguments through pnpm, use `--` to separate pnpm args from Playwright args.**

```bash
# ✅ GOOD: Use -- separator
pnpm test:e2e -- e2e/specs/dms/unread-handling.spec.ts --video=on
pnpm test:e2e -- --headed
pnpm test:e2e -- e2e/specs/dms/unread-handling.spec.ts --debug

# ❌ BAD: Missing -- separator (arguments ignored)
pnpm test:e2e e2e/specs/dms/unread-handling.spec.ts --video=on
```

**Common commands:**

```bash
# Run specific spec
pnpm test:e2e -- e2e/specs/dms/unread-handling.spec.ts

# Run with video for passing tests
pnpm test:e2e -- e2e/specs/dms/unread-handling.spec.ts --video=on

# Run in headed mode (see browser)
pnpm test:e2e -- e2e/specs/dms/unread-handling.spec.ts --headed

# Run specific test by name
pnpm test:e2e -- e2e/specs/dms/unread-handling.spec.ts -g "displays unread"

# Run with UI mode (no -- needed for separate command)
pnpm test:e2e:ui -- e2e/specs/dms/unread-handling.spec.ts
```

### 4. Use State API Pattern

**POST for test setup (wipes database), PATCH for mid-test state changes.**

```typescript
test("my test", async ({ page, stateApi }) => {
  // ✅ Setup: POST (wipe + create)
  const { data, ids } = buildMinimalSeed();
  await stateApi.resetDatabase(data);

  // Test navigation and assertions...

  // ✅ Scenario: PATCH (upsert without wiping)
  await stateApi.patchDatabase({
    Message: [buildMessage({ ... })],
  });

  // Continue test...
});
```

---

## E2E Testing Philosophy

**Key Principles (from STS-34 E2E Testing Framework):**

- **100% Feature Coverage:** All features in PRODUCT.md (STS-1 through STS-34) must have E2E tests
- **User Perspective:** Tests execute from end-user standpoint only, no implementation details
- **API-Based Setup:** Use API calls for test data creation/cleanup, NOT during test execution
- **High Resilience:** Explicit waits, stable `data-testid` selectors, avoid flaky patterns
- **Easy Debugging:** Clear failure messages, screenshots, traces, videos on failure
- **CI Integration:** Tests run in Docker, integrate seamlessly with GitHub Actions

**Constraints:**

- Only Playwright framework (no other E2E tools)
- Docker-based execution (application runs entirely in containers)
- Tests validate UI behavior, not code coverage
- APIs may be used for preconditions and validation, never during test execution
- No visual testing, performance testing, or mobile testing

### E2E Directory Structure

**Complete organization for `apps/frontend/e2e/`:**

```
apps/frontend/e2e/
├── fixtures/
│   ├── auth.ts                    # Authentication test fixtures
│   ├── api-helpers.ts             # tRPC API client for setup/teardown
│   └── test-data.ts               # Test data factories
├── page-objects/
│   ├── BasePage.ts                # Base page class with common utilities
│   ├── AuthPage.ts                # Login/signup page object
│   ├── WorkspacePage.ts           # Main workspace view
│   ├── ChannelPage.ts             # Channel view and interactions
│   └── DMPage.ts                  # Direct message view
├── specs/
│   ├── auth/
│   │   ├── login.spec.ts          # Login flow tests
│   │   ├── signup.spec.ts         # Registration tests
│   │   └── session.spec.ts        # Session persistence
│   ├── workspaces/
│   │   ├── create.spec.ts         # Workspace creation
│   │   ├── switch.spec.ts         # Workspace switching
│   │   └── members.spec.ts        # Member management
│   ├── channels/
│   │   ├── create.spec.ts         # Channel creation
│   │   ├── messages.spec.ts       # Message sending
│   │   ├── edit-delete.spec.ts    # Message operations
│   │   └── archive.spec.ts        # Archiving
│   ├── dms/
│   │   ├── direct.spec.ts         # Direct messages
│   │   └── group.spec.ts          # Group DMs
│   ├── threads/
│   │   ├── reply.spec.ts          # Thread replies
│   │   └── view.spec.ts           # Thread viewing
│   ├── reactions/
│   │   └── reactions.spec.ts      # Emoji reactions
│   ├── mentions/
│   │   └── mentions.spec.ts       # User/channel mentions
│   ├── search/
│   │   └── search.spec.ts         # Full-text search
│   ├── files/
│   │   ├── upload.spec.ts         # File uploads
│   │   └── preview.spec.ts        # File previews
│   └── presence/
│       └── status.spec.ts         # Online/offline status
├── helpers/
│   └── wait.ts                    # Custom wait utilities
├── setup.ts                       # Project-dependency setup (health checks)
└── playwright.config.ts           # Playwright configuration
```

**Naming Conventions:**

- **Spec files:** `{feature-name}.spec.ts` in appropriate `/specs/{domain}/` folder
- **Page objects:** `{PageName}Page.ts` in `/page-objects/`
- **Fixtures:** `{domain}-helpers.ts` in `/fixtures/`
- **Helpers:** `{utility-name}.ts` in `/helpers/`

### Playwright Configuration

From `apps/frontend/playwright.config.ts` (enhanced per STS-34):

```typescript
import {defineConfig, devices} from '@playwright/test'

export default defineConfig({
	testDir: './e2e/specs', // Point to specs subdirectory
	testMatch: '**/*.spec.ts',
	fullyParallel: true,
	forbidOnly: !!process.env.CI,
	retries: process.env.CI ? 2 : 0, // 2 retries in CI for resilience
	workers: process.env.CI ? 2 : undefined,
	reporter: [
		['html', {outputFolder: 'playwright-report'}],
		['json', {outputFile: 'playwright-results.json'}],
		['junit', {outputFile: 'playwright-results.xml'}]
	],
	use: {
		baseURL: process.env.CI ? 'http://localhost:80' : 'http://localhost:3000',
		trace: 'on-first-retry', // Capture trace on first retry
		screenshot: 'only-on-failure', // Screenshots on test failure
		video: 'retain-on-failure', // Videos on test failure
		actionTimeout: 10000, // 10s for actions (click, fill, etc.)
		navigationTimeout: 30000 // 30s for navigation
	},
	projects: [{name: 'chromium', use: {...devices['Desktop Chrome']}}],
	// Setup via project dependency — see "setup" project in projects array
	webServer: {
		command: 'docker compose up -d',
		url: 'http://localhost:80',
		reuseExistingServer: !process.env.CI,
		timeout: 120000
	}
})
```

**Key Configuration:**

- **testDir:** `./e2e/specs` - organized by feature domain
- **Retries:** 2 retries in CI (resilience against flakes)
- **Workers:** 2 workers in CI (controlled parallelism)
- **Reporters:** HTML, JSON, JUnit (CI integration)
- **Timeouts:** Action (10s), Navigation (30s)
- **Diagnostics:** Screenshots, videos, traces on failure

### Page Object Pattern

**CRITICAL:** Always use Page Object Pattern for E2E tests to isolate UI changes.

**Base Page Class:**

```typescript
// e2e/page-objects/BasePage.ts

import {Page, Locator} from '@playwright/test'

export class BasePage {
	constructor(protected page: Page) {}

	protected async waitForVisible(locator: Locator): Promise<void> {
		await locator.waitFor({state: 'visible'})
	}

	protected async waitForHidden(locator: Locator): Promise<void> {
		await locator.waitFor({state: 'hidden'})
	}

	protected async waitForStable(locator: Locator): Promise<void> {
		// Wait for element to stop animating
		await locator.waitFor({state: 'stable'})
	}

	protected async clickSafe(locator: Locator): Promise<void> {
		await locator.waitFor({state: 'visible'})
		await locator.scrollIntoViewIfNeeded()
		await locator.click({force: false})
	}

	protected async typeSafe(locator: Locator, text: string): Promise<void> {
		await locator.waitFor({state: 'visible'})
		await locator.fill(text)
	}
}
```

**Channel Page Object:**

```typescript
// e2e/page-objects/ChannelPage.ts

import {Page, Locator, expect} from '@playwright/test'
import {BasePage} from './BasePage'

export class ChannelPage extends BasePage {
	private readonly messageInput: Locator
	private readonly messageList: Locator
	private readonly sendButton: Locator
	private readonly channelHeader: Locator

	constructor(page: Page) {
		super(page)
		this.messageInput = page.locator('[data-testid="message-input"]')
		this.messageList = page.locator('[data-testid="message-list"]')
		this.sendButton = page.locator('[data-testid="send-button"]')
		this.channelHeader = page.locator('[data-testid="channel-header"]')
	}

	async navigateToChannel(workspaceId: string, channelId: string): Promise<void> {
		await this.page.goto(`/client/${workspaceId}/${channelId}`)
		await this.waitForVisible(this.messageInput)
		await this.waitForVisible(this.channelHeader)
	}

	async sendMessage(text: string): Promise<void> {
		await this.typeSafe(this.messageInput, text)
		await this.clickSafe(this.sendButton)
		// Wait for message to appear
		await this.waitForMessage(text)
	}

	async waitForMessage(text: string): Promise<void> {
		await this.page.waitForSelector(`[data-message-content="${text}"]`, {state: 'visible', timeout: 5000})
	}

	async getLastMessage(): Promise<string> {
		const messages = this.messageList.locator('[data-message]')
		return (await messages.last().textContent()) ?? ''
	}

	async replyToMessage(messageText: string, replyText: string): Promise<void> {
		const message = this.page.locator(`[data-message-content="${messageText}"]`)
		await message.hover()
		await this.clickSafe(this.page.locator('[data-testid="reply-button"]'))

		const threadInput = this.page.locator('[data-testid="thread-input"]')
		await this.typeSafe(threadInput, replyText)
		await this.clickSafe(this.page.locator('[data-testid="thread-send"]'))
	}

	async addReaction(messageText: string, emoji: string): Promise<void> {
		const message = this.page.locator(`[data-message-content="${messageText}"]`)
		await message.hover()
		await this.clickSafe(this.page.locator('[data-testid="add-reaction"]'))
		await this.clickSafe(this.page.locator(`[data-emoji="${emoji}"]`))
	}
}
```

### State API Fixture Pattern (RECOMMENDED)

**State API provides atomic database management for E2E tests:**

- **POST /api/state** - Replace entire database (wipe + create)
- **PATCH /api/state** - Upsert records without wiping
- **GET /api/state** - Query database state

```typescript
// e2e/fixtures/state-api.ts
import {test as base} from '@playwright/test'

export type StateData = Record<string, Array<Record<string, unknown>>>

export interface StateApiFixture {
	resetDatabase(data: StateData): Promise<void> // POST - wipe + create
	patchDatabase(data: StateData): Promise<void> // PATCH - upsert only
	getState(tables?: string[]): Promise<StateData> // GET - verify state
	getApiTokenForUser(userId: string): Promise<string | null>
}

export const test = base.extend<{stateApi: StateApiFixture}>({
	stateApi: async ({}, use) => {
		const baseUrl = process.env.FRONTEND_URL ?? 'http://localhost:80'
		const adminToken = process.env.ADMIN_API_TOKEN ?? '123'

		await use({
			async resetDatabase(data) {
				const response = await fetch(`${baseUrl}/api/state`, {
					method: 'POST',
					headers: {Authorization: `Bearer ${adminToken}`, 'Content-Type': 'application/json'},
					body: JSON.stringify(data)
				})
				if (!response.ok) throw new Error(`State API POST failed: ${response.status}`)
			},
			async patchDatabase(data) {
				const response = await fetch(`${baseUrl}/api/state`, {
					method: 'PATCH',
					headers: {Authorization: `Bearer ${adminToken}`, 'Content-Type': 'application/json'},
					body: JSON.stringify(data)
				})
				if (!response.ok) throw new Error(`State API PATCH failed: ${response.status}`)
			},
			async getState(tables) {
				const url = tables ? `${baseUrl}/api/state?tables=${tables.join(',')}` : `${baseUrl}/api/state`
				const response = await fetch(url, {headers: {Authorization: `Bearer ${adminToken}`}})
				if (!response.ok) throw new Error('State API GET failed')
				return await response.json()
			},
			async getApiTokenForUser(userId) {
				const state = await this.getState(['ApiToken'])
				const tokens = state.ApiToken as Array<{user_id: string; token: string}>
				return tokens.find(t => t.user_id === userId)?.token ?? null
			}
		})
	}
})

export {expect} from '@playwright/test'
```

### Shared Builder Library

**Import builders from `@/app/lib/seed-builders` (same builders used by seed scripts):**

```typescript
import {buildMinimalSeed, buildUser, buildConversation} from '@/app/lib/seed-builders'

// Minimal seed creates baseline: AppConfiguration, User, Team, ApiToken, Conversation
const {data, ids} = buildMinimalSeed()
await stateApi.resetDatabase(data)

// Reference IDs from seed (no hardcoded strings!)
await page.goto(`/client/${ids.teamId}/${ids.conversationId}`)
```

**Builder Functions:**

- `buildMinimalSeed(options?)` - Minimal baseline (returns `{ data, ids }`)
- `buildFullSeed()` - Complete seed with all workspaces/users
- `buildUser(data)` - Single user record
- `buildConversation(data)` - Single conversation record
- `buildMessage(data)` - Single message record

### Test Helper Functions

```typescript
// e2e/helpers/test-utils.ts
import {buildMinimalSeed} from '@/app/lib/seed-builders'

// Generate unique test IDs with nanosecond precision
export function generateTestId(): string

// Merge State API payloads (combines table arrays)
export function mergeStateData(...payloads: StateData[]): StateData

// Set up localStorage authentication
export async function setupAuth(page, userId, username, teamId): Promise<void>

// Complete test setup: database + auth + navigation
export async function setupTestWithMinimalSeed(options: {
	page: Page
	stateApi: StateApiFixture
	seedOptions?: MinimalSeedOptions
	navigateTo?: 'workspace' | 'channel' | null
	channelId?: string
}): Promise<MinimalSeedResult>

// Send message in current channel
export async function sendMessage(page: Page, text: string): Promise<void>

// Navigate helpers with consistent options
export async function navigateToWorkspace(page: Page, teamId: string): Promise<void>
export async function navigateToChannel(page: Page, teamId, channelId): Promise<void>
```

### Custom Wait Utilities

**Shack-Specific Wait Helpers:**

```typescript
// e2e/helpers/wait.ts

import {Page, Locator} from '@playwright/test'

export async function waitForMessageDelivery(page: Page, expectedText: string): Promise<void> {
	await page.waitForFunction(
		text => {
			const messages = document.querySelectorAll('[data-message-content]')
			return Array.from(messages).some(msg => msg.getAttribute('data-message-content') === text)
		},
		expectedText,
		{timeout: 5000}
	)
}

export async function waitForSidebarUpdate(page: Page, expectedChannelName: string): Promise<void> {
	await page.waitForSelector(`[data-sidebar-channel="${expectedChannelName}"]`, {state: 'visible', timeout: 5000})
}

export async function waitForTypingIndicator(page: Page, username: string): Promise<void> {
	await page.waitForSelector(`[data-typing-user="${username}"]`, {state: 'visible', timeout: 3000})
}
```

### Project-Dependency Setup

Setup runs as a Playwright test via project dependency (replaces globalSetup/globalTeardown):

```typescript
// e2e/setup.ts

import {test as setup, expect} from '@playwright/test'

setup('verify server health', async ({request}) => {
	const baseURL = process.env.CI ? `http://localhost:${process.env.PORT ?? '80'}` : 'http://localhost:3000'

	if (process.env.CI) {
		await expect(async () => {
			const resp = await request.get(`${baseURL}/api/health`)
			expect(resp.ok()).toBeTruthy()
			const data = await resp.json()
			expect(data.status).toBe('healthy')
			expect(data.database).toBe('connected')
		}).toPass({timeout: 120_000, intervals: [3_000]})
	}
})
```

Benefits over globalSetup:

- Traces recorded and visible in trace viewer / HTML report
- Full fixture support (request context, etc.)
- Can skip with `--no-deps` during local dev
- Standard retry/parallelism support

### Test Data Isolation Strategy

**Fresh Data Per Test:**

```typescript
// ✅ GOOD: Create unique test data per test
test('creates channel', async ({authenticatedPage, apiClient}) => {
	const workspace = await apiClient.team.create({name: `Workspace ${Date.now()}`})

	const channelName = `test-channel-${Date.now()}`
	const channel = await apiClient.conversations.create({name: channelName, team_id: workspace.id})

	// Test implementation with unique data
})

// ❌ BAD: Shared test data (causes conflicts)
const SHARED_WORKSPACE_ID = 'workspace_123' // Hardcoded!

test('creates channel', async ({authenticatedPage}) => {
	await authenticatedPage.goto(`/client/${SHARED_WORKSPACE_ID}`)
	// Conflicts if multiple tests run in parallel
})
```

**Test Cleanup:**

```typescript
test.afterEach(async ({apiClient}, testInfo) => {
	// Clean up resources created during test
	if (testInfo.testData?.workspaceId) {
		await teardownTestWorkspace(apiClient, testInfo.testData.workspaceId)
	}
})
```

### Selector Strategy

**Priority Order (MANDATORY):**

```typescript
// 1️⃣ BEST: data-testid attributes (most stable)
await page.click('[data-testid="send-message"]')
await page.fill('[data-testid="message-input"]', 'Hello')

// 2️⃣ GOOD: ARIA roles (accessible and stable)
await page.getByRole('button', {name: 'Send'})
await page.getByRole('textbox', {name: 'Message'})

// 3️⃣ OK: Text content (for static text)
await page.getByText('Welcome to OpenAI!')

// 4️⃣ AVOID: CSS selectors (brittle to UI changes)
await page.locator('.message-input') // ❌ Don't use!
```

**data-testid Naming Convention:**

- Use kebab-case: `data-testid="message-input"`
- Be descriptive: `data-testid="channel-create-button"`
- For dynamic items: `data-message-id="msg_123"`

### Resilience Patterns

**Explicit Waits Over Timeouts:**

```typescript
// ✅ GOOD: Wait for specific state
await page.waitForSelector('[data-testid="message-list"]', {state: 'visible'})
await channelPage.sendMessage('Test')

// ✅ GOOD: Wait for network idle
await page.goto(url, {waitUntil: 'networkidle'})

// ✅ GOOD: Wait for element to be enabled
await expect(sendButton).toBeEnabled()
await sendButton.click()

// ❌ BAD: Fixed timeout (flaky!)
await page.waitForTimeout(1000)
await channelPage.sendMessage('Test')
```

**Stable Element References:**

```typescript
// ✅ GOOD: Store locator, wait before each action
const sendButton = page.locator('[data-testid="send-button"]')
await expect(sendButton).toBeVisible()
await expect(sendButton).toBeEnabled()
await sendButton.click()

// ❌ BAD: Re-query element without waiting
await page.click('[data-testid="send-button"]') // May not be ready!
```

### Complete E2E Test Examples

**Example 1: Minimal Seed Pattern**

```typescript
// e2e/specs/channels/messages.spec.ts
import {test, expect} from '../../fixtures/state-api'
import {buildMinimalSeed} from '@/app/lib/seed-builders'
import {setupAuth, sendMessage} from '../../helpers/test-utils'

test.describe('Channel Messages', () => {
	test('sends a simple text message', async ({page, stateApi}) => {
		// Arrange: Minimal seed (User, Team, Token, Conversation)
		const {data, ids} = buildMinimalSeed()
		await stateApi.resetDatabase(data)
		await setupAuth(page, ids.userId, 'default', ids.teamId)

		// Act: Navigate to channel and send message (reference IDs from seed)
		await page.goto(`/client/${ids.teamId}/${ids.conversationId}`)
		await sendMessage(page, 'Hello, world!')

		// Assert: Message visible
		await expect(page.getByText('Hello, world!')).toBeVisible()
	})

	test('displays message timestamps', async ({page, stateApi}) => {
		const {data, ids} = buildMinimalSeed()
		await stateApi.resetDatabase(data)
		await setupAuth(page, ids.userId, 'default', ids.teamId)

		await page.goto(`/client/${ids.teamId}/${ids.conversationId}`)
		await sendMessage(page, 'Test message')

		const timestamp = page.locator('[data-message-timestamp]').last()
		await expect(timestamp).toBeVisible()
		await expect(timestamp).toHaveText(/\d{1,2}:\d{2}\s(AM|PM)/)
	})
})
```

**Example 2: Custom Data Pattern**

```typescript
// e2e/specs/channels/custom-data.spec.ts
import {test, expect} from '../../fixtures/state-api'
import {buildMinimalSeed, buildUser, buildConversation} from '@/app/lib/seed-builders'
import {mergeStateData, generateTestId, setupAuth} from '../../helpers/test-utils'

test.describe('Custom Data Example', () => {
	test('creates conversation with custom user', async ({page, stateApi}) => {
		// Arrange: Build custom data
		const testId = generateTestId()
		const {data: minimalData, ids} = buildMinimalSeed()

		const alice = buildUser({
			id: `user_alice_${testId}`,
			email: `alice_${testId}@example.com`,
			username: 'alice',
			display_name: 'Alice Johnson'
		})

		const engineering = buildConversation({
			id: `conv_eng_${testId}`,
			name: 'engineering',
			teamId: ids.teamId // Reference minimal team
		})

		// Merge minimal + custom data
		const testData = mergeStateData(minimalData, {
			User: [alice],
			Conversation: [engineering],
			ConversationMember: [
				{user_id: alice.id, conversation_id: engineering.id, role: 'MEMBER', created_at: new Date()}
			],
			TeamMember: [{user_id: alice.id, team_id: ids.teamId, role: 'MEMBER', created_at: new Date()}]
		})

		await stateApi.resetDatabase(testData)
		await setupAuth(page, ids.userId, 'default', ids.teamId)

		// Act: Navigate to custom conversation
		await page.goto(`/client/${ids.teamId}/${engineering.id}`)

		// Assert: Custom data visible
		await expect(page.getByText('#engineering')).toBeVisible()
	})
})
```

**Example 3: Helper Function Pattern**

```typescript
// Using setupTestWithMinimalSeed helper
import {test, expect} from '../../fixtures/state-api'
import {setupTestWithMinimalSeed, sendMessage} from '../../helpers/test-utils'

test('sends message using helper', async ({page, stateApi}) => {
	// One-line setup: database + auth + navigation
	const {ids} = await setupTestWithMinimalSeed({page, stateApi, navigateTo: 'channel'})

	// Test implementation
	await sendMessage(page, 'Hello from helper!')
	await expect(page.getByText('Hello from helper!')).toBeVisible()
})
```

**Example 2: Thread Reply Flow (from STS-34)**

```typescript
// e2e/specs/threads/reply.spec.ts

import {test, expect} from '../../fixtures/auth'
import {ChannelPage} from '../../page-objects/ChannelPage'

test.describe('Thread Replies', () => {
	test('replies to a message in thread', async ({authenticatedPage, apiClient}) => {
		// Setup via API
		const {workspace, channels} = await setupTestWorkspace(apiClient)

		const parentMessage = await apiClient.chat.postMessage({channel: channels.general.id, text: 'Parent message'})

		const channelPage = new ChannelPage(authenticatedPage)
		await channelPage.navigateToChannel(workspace.id, channels.general.id)

		// Click reply button
		await authenticatedPage.hover(`[data-message-id="${parentMessage.ts}"]`)
		await authenticatedPage.click('[data-testid="reply-button"]')

		// Verify thread panel opens
		await expect(authenticatedPage.locator('[data-testid="thread-panel"]')).toBeVisible()

		// Type reply
		const threadInput = authenticatedPage.locator('[data-testid="thread-input"]')
		await threadInput.fill('Reply message')
		await authenticatedPage.click('[data-testid="thread-send"]')

		// Verify reply appears
		await expect(authenticatedPage.locator('[data-message-content="Reply message"]')).toBeVisible()
	})

	test('shows thread reply count in main view', async ({authenticatedPage, apiClient}) => {
		// Setup with existing thread
		const {workspace, channels} = await setupTestWorkspace(apiClient)

		const parentMessage = await apiClient.chat.postMessage({channel: channels.general.id, text: 'Parent message'})

		// Create two replies via API
		await apiClient.chat.postMessage({channel: channels.general.id, text: 'Reply 1', thread_ts: parentMessage.ts})
		await apiClient.chat.postMessage({channel: channels.general.id, text: 'Reply 2', thread_ts: parentMessage.ts})

		const channelPage = new ChannelPage(authenticatedPage)
		await channelPage.navigateToChannel(workspace.id, channels.general.id)

		// Verify reply count
		const replyCount = authenticatedPage.locator(`[data-message-id="${parentMessage.ts}"] [data-testid="reply-count"]`)
		await expect(replyCount).toBeVisible()
		await expect(replyCount).toHaveText('2')
	})
})
```

**Example 3: File Upload (from STS-34)**

```typescript
// e2e/specs/files/upload.spec.ts

import {test, expect} from '../../fixtures/auth'
import {ChannelPage} from '../../page-objects/ChannelPage'
import * as path from 'path'

test.describe('File Uploads', () => {
	test('uploads an image file', async ({authenticatedPage, apiClient}) => {
		const {workspace, channels} = await setupTestWorkspace(apiClient)

		const channelPage = new ChannelPage(authenticatedPage)
		await channelPage.navigateToChannel(workspace.id, channels.general.id)

		// Upload file
		const fileInput = authenticatedPage.locator('[data-testid="file-input"]')
		const testImagePath = path.join(__dirname, '../fixtures/test-image.png')
		await fileInput.setInputFiles(testImagePath)

		// Wait for upload completion
		await authenticatedPage.waitForSelector('[data-testid="upload-complete"]', {state: 'visible', timeout: 10000})

		// Verify file appears in message list
		await expect(authenticatedPage.locator('[data-testid="file-attachment"]')).toBeVisible()
	})

	test('shows image preview', async ({authenticatedPage, apiClient}) => {
		// Setup...

		// Verify image preview is rendered
		const preview = authenticatedPage.locator('[data-testid="image-preview"]')
		await expect(preview).toBeVisible()

		// Verify image has alt text
		await expect(preview.locator('img')).toHaveAttribute('alt', /test-image/)
	})
})
```

### Test Coverage Matrix

**Required E2E Coverage (from STS-34):**

| Feature                    | Test Files                                                                      | Primary Scenarios                                                          | API Preconditions  |
| -------------------------- | ------------------------------------------------------------------------------- | -------------------------------------------------------------------------- | ------------------ |
| **Authentication (STS-1)** | `auth/login.spec.ts`<br>`auth/signup.spec.ts`<br>`auth/session.spec.ts`         | Login valid/invalid<br>Registration<br>Session persistence<br>Logout       | None               |
| **Workspaces (STS-2)**     | `workspaces/create.spec.ts`<br>`workspaces/switch.spec.ts`<br>`members.spec.ts` | Create workspace<br>Switch workspaces<br>Add/remove members                | User exists        |
| **Channels (STS-4)**       | `channels/create.spec.ts`<br>`messages.spec.ts`<br>`edit-delete.spec.ts`        | Create public/private<br>Send/edit/delete messages<br>Archive              | Workspace + user   |
| **Messages (STS-3)**       | `channels/messages.spec.ts`                                                     | Send message<br>Timestamps<br>Rich text<br>Markdown                        | Channel + user     |
| **DMs (STS-5)**            | `dms/direct.spec.ts`<br>`dms/group.spec.ts`                                     | Start DM<br>Send DM<br>Group DM creation                                   | 2+ users           |
| **Threads (STS-6)**        | `threads/reply.spec.ts`<br>`threads/view.spec.ts`                               | Reply to message<br>View thread<br>Thread notifications<br>One-level depth | Message exists     |
| **Reactions (STS-7)**      | `reactions/reactions.spec.ts`                                                   | Add reaction<br>View counts<br>Remove reaction<br>See who reacted          | Message exists     |
| **Mentions (STS-8)**       | `mentions/mentions.spec.ts`                                                     | @username<br>#channel<br>@channel<br>@here                                 | Channel + 2+ users |
| **Presence (STS-9)**       | `presence/status.spec.ts`                                                       | Online status<br>Typing indicators<br>Last seen                            | 2+ users           |
| **Search (STS-32)**        | `search/search.spec.ts`                                                         | Search username/channel<br>Full-text search<br>Autocomplete                | Messages exist     |
| **Files (STS-33)**         | `files/upload.spec.ts`<br>`files/preview.spec.ts`                               | Upload image/PDF<br>Preview file<br>Download                               | User + channel     |

**Test Execution Strategy:**

- Run independent test files in parallel (Playwright workers)
- Use separate browser contexts per test
- Share test database across workers (SQLite handles locking)
- Default timeout: 30s per test
- Extended timeout for slow operations (uploads, search): 60s

### Running E2E Tests

```bash
# Run all E2E tests
pnpm test:e2e

# Run with Playwright UI (interactive mode)
pnpm test:e2e:ui

# Run specific test file
pnpm playwright test e2e/specs/channels/messages.spec.ts

# Run specific test by name
pnpm playwright test -g "sends a simple text message"

# Run in headed mode (see browser)
pnpm playwright test --headed

# Run with debug mode
pnpm playwright test --debug

# Generate HTML report
pnpm playwright show-report

# Update snapshots (if using visual regression)
pnpm playwright test --update-snapshots
```

### Debugging E2E Tests

**1. Interactive UI Mode:**

```bash
pnpm test:e2e:ui
```

Features:

- Step through tests interactively
- See screenshots at each step
- Inspect locators in real-time
- Time-travel through execution
- Pick which tests to run

**2. Debug Mode with Playwright Inspector:**

```bash
pnpm playwright test --debug
```

Or add breakpoint in test:

```typescript
test('debuggable test', async ({page}) => {
	await page.goto('http://localhost:3000')

	// Test pauses here, opens Playwright Inspector
	await page.pause()

	await page.click('[data-testid="button"]')
})
```

**3. Trace Viewer:**

```bash
# Run tests with trace
pnpm playwright test --trace on

# Open trace viewer after failure
npx playwright show-trace trace.zip
```

Trace includes:

- Screenshot at each action
- Network requests
- Console logs
- DOM snapshots
- Timeline of events

**4. Screenshots on Failure:**

Automatically captured (configured in `playwright.config.ts`):

```typescript
use: {
  screenshot: 'only-on-failure',
  video: 'retain-on-failure',
}
```

Access in `playwright-results/` directory after test run.

### CI/CD Integration

**GitHub Actions Workflow:**

```yaml
# .github/workflows/e2e-tests.yml

name: E2E Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  e2e-tests:
    runs-on: ubuntu-latest
    timeout-minutes: 30

    steps:
      - uses: actions/checkout@v4

      - name: Setup pnpm
        uses: pnpm/action-setup@v2
        with:
          version: 8

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'

      - name: Install dependencies
        run: pnpm install

      - name: Start Docker services
        run: docker compose --env-file .env up -d

      - name: Wait for services
        run: |
          timeout 60 bash -c 'until curl -f http://localhost:80/health; do sleep 2; done'

      - name: Install Playwright browsers
        run: cd apps/frontend && npx playwright install --with-deps

      - name: Run E2E tests
        run: cd apps/frontend && pnpm test:e2e
        env:
          CI: true
          FRONTEND_URL: http://localhost:80

      - name: Upload test report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: playwright-report
          path: apps/frontend/playwright-report/
          retention-days: 30

      - name: Upload screenshots
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: e2e-screenshots
          path: apps/frontend/playwright-results/
          retention-days: 7
```

### State API Testing Best Practices

**0. Start with Minimal Seed - Add Only What You Need:**

**CRITICAL:** Tests should be as focused as possible. Always start with `buildMinimalSeed()` as the baseline, then add only the specific data required for your test scenario.

```typescript
// ✅ GOOD: Minimal seed only (test needs just baseline data)
test('sends message in default channel', async ({page, stateApi}) => {
	const {data, ids} = buildMinimalSeed()
	await stateApi.resetDatabase(data)
	// Test uses default user, team, and general channel
})

// ✅ GOOD: Minimal + focused custom data (test needs specific user)
test('displays custom user profile', async ({page, stateApi}) => {
	const {data: minimalData, ids} = buildMinimalSeed()

	const customUser = buildUser({id: `user_${generateTestId()}`, username: 'alice', display_name: 'Alice Johnson'})

	await stateApi.resetDatabase(
		mergeStateData(minimalData, {
			User: [customUser],
			TeamMember: [{user_id: customUser.id, team_id: ids.teamId, role: 'MEMBER'}]
		})
	)
	// Test focused on this specific user's profile
})

// ❌ BAD: Full seed when minimal would work (unnecessary data)
test('sends message in default channel', async ({page, stateApi}) => {
	const {data} = buildFullSeed() // Includes 3 workspaces, 20+ users, 50+ channels!
	await stateApi.resetDatabase(data) // Slower, harder to debug
	// Test only needs default channel - full seed is overkill
})

// ❌ BAD: Creating data the test doesn't use
test('sends message', async ({page, stateApi}) => {
	const {data: minimalData, ids} = buildMinimalSeed()

	// Creating 10 users but test doesn't use them
	const extraUsers = Array.from({length: 10}, (_, i) => buildUser({id: `user_${i}`, username: `user${i}`}))

	await stateApi.resetDatabase(
		mergeStateData(minimalData, {
			User: extraUsers // Unused data clutters test
		})
	)
	// Test only sends one message - why create 10 users?
})
```

**Benefits of Minimal Seed:**

- **Faster execution** (~500-800ms vs ~2.5s for full seed)
- **Easier debugging** (less data to inspect when tests fail)
- **Clear intent** (obvious what data the test actually needs)
- **Less maintenance** (fewer changes needed when seed data evolves)
- **Better isolation** (minimal baseline reduces test interdependencies)

**When to Use Full Seed:**

- Legacy tests migrating from old pattern (temporary)
- Tests requiring multiple workspaces, many users, or complex channel hierarchies
- Search tests needing realistic data volume
- UI tests validating performance with realistic data

**Rule of Thumb:**

- Can your test work with 1 user, 1 team, 1 channel? → Use `buildMinimalSeed()`
- Need specific users/channels? → `buildMinimalSeed()` + custom data via `mergeStateData()`
- Need full workspace ecosystem? → `buildFullSeed()` (rare)

**1. POST for Setup, PATCH for Scenarios:**

```typescript
// ✅ GOOD: POST at test start (wipe + create)
test('test with fresh data', async ({page, stateApi}) => {
	const {data, ids} = buildMinimalSeed()
	await stateApi.resetDatabase(data) // POST - fresh state

	// Test implementation...
})

// ✅ GOOD: PATCH during test (simulate hard-to-reach state)
test('handles external message edit', async ({page, stateApi}) => {
	const {data, ids} = buildMinimalSeed()
	await stateApi.resetDatabase(data)

	// ... test setup ...

	// Simulate another user editing the message
	await stateApi.patchDatabase({Message: [{id: messageId, content: 'Edited by another user'}]})

	// Verify UI updates...
})

// ❌ BAD: PATCH for initial setup
test('bad pattern', async ({page, stateApi}) => {
	await stateApi.patchDatabase(data) // PATCH leaves residual data!
})
```

**2. No Hardcoded IDs - Use Builder References:**

```typescript
// ✅ GOOD: Reference IDs from builders
const {data, ids} = buildMinimalSeed()
await page.goto(`/client/${ids.teamId}/${ids.conversationId}`)

// ✅ GOOD: Named entity references (full seed)
const {data, teams, conversations} = buildFullSeed()
await page.goto(`/client/${teams.openai.id}/${conversations.general.id}`)

// ❌ BAD: Hardcoded strings (breaks when IDs change)
await page.goto(`/client/workspace_openai/channel_general`)
```

**3. Call resetDatabase() in Test Body (Not beforeEach):**

```typescript
// ✅ GOOD: Explicit setup in test (visible, fast enough)
test('sends message', async ({page, stateApi}) => {
	const {data, ids} = buildMinimalSeed()
	await stateApi.resetDatabase(data) // ~500-800ms

	// Test implementation...
})

// ❌ BAD: Hidden setup in beforeEach (less clear)
test.beforeEach(async ({stateApi}) => {
	const {data} = buildMinimalSeed()
	await stateApi.resetDatabase(data) // Hidden from test body
})

test('sends message', async ({page}) => {
	// Where did the data come from? Not clear!
})
```

**4. Use Helper Functions to Reduce Boilerplate:**

```typescript
// ✅ GOOD: One-line setup with helper
const {ids} = await setupTestWithMinimalSeed({page, stateApi, navigateTo: 'channel'})

// ❌ BAD: Repetitive setup in every test
const {data, ids} = buildMinimalSeed()
await stateApi.resetDatabase(data)
await setupAuth(page, ids.userId, 'default', ids.teamId)
await page.goto(`/client/${ids.teamId}/${ids.conversationId}`)
```

### E2E Testing Best Practices

**1. Use Page Objects for All Tests:**

```typescript
// ✅ GOOD: Page Object encapsulates selectors and actions
test('sends message', async ({authenticatedPage}) => {
	const channelPage = new ChannelPage(authenticatedPage)
	await channelPage.sendMessage('Hello')
	expect(await channelPage.getLastMessage()).toContain('Hello')
})

// ❌ BAD: Direct selector usage (brittle)
test('sends message', async ({page}) => {
	await page.fill('[data-testid="message-input"]', 'Hello')
	await page.click('[data-testid="send-button"]')
	expect(await page.locator('[data-message]:last-child').textContent()).toContain('Hello')
})
```

**2. Use API for Setup, UI for Test:**

```typescript
// ✅ GOOD: API for setup, UI for test
test('user can reply in thread', async ({authenticatedPage, apiClient}) => {
	// Setup via API (fast, reliable)
	const {workspace, channels} = await setupTestWorkspace(apiClient)
	const parentMsg = await apiClient.chat.postMessage({channel: channels.general.id, text: 'Parent'})

	// Navigate and test via UI (user perspective)
	await authenticatedPage.goto(`/client/${workspace.id}/${channels.general.id}`)
	await authenticatedPage.click(`[data-message-id="${parentMsg.ts}"] [data-testid="reply"]`)
	// ... UI interactions
})

// ❌ BAD: Create everything via UI (slow, brittle)
test('user can reply in thread', async ({page}) => {
	await page.goto('/')
	await page.click('[data-testid="create-workspace"]')
	await page.fill('[data-testid="workspace-name"]', 'Test')
	// ... many slow UI steps
})
```

**3. Use Dynamic Test Data:**

```typescript
// ✅ GOOD: Unique data per test run
const channelName = `test-channel-${Date.now()}`
const username = `testuser-${Date.now()}`

// ❌ BAD: Hardcoded data (conflicts in parallel runs)
const channelName = 'test-channel'
const username = 'testuser'
```

**4. Group Related Tests:**

```typescript
test.describe('Channel Management', () => {
	test.describe('Creating Channels', () => {
		test('creates public channel', async ({page}) => {
			/* ... */
		})
		test('creates private channel', async ({page}) => {
			/* ... */
		})
		test('validates channel name', async ({page}) => {
			/* ... */
		})
	})

	test.describe('Archiving Channels', () => {
		test('archives channel', async ({page}) => {
			/* ... */
		})
		test('restores archived channel', async ({page}) => {
			/* ... */
		})
	})
})
```

**5. Explicit Waits for State Changes:**

```typescript
// ✅ GOOD: Wait for message delivery
await waitForMessageDelivery(page, 'Expected message')

// ✅ GOOD: Wait for element visibility
await expect(page.getByTestId('message')).toBeVisible()

// ❌ BAD: Arbitrary wait
await page.waitForTimeout(2000)
```

### E2E Test Checklist

Before marking E2E tests complete:

- [ ] All PRODUCT.md features (STS-1 to STS-34) have corresponding tests
- [ ] Tests use Page Object Pattern (no raw selectors in specs)
- [ ] All selectors use `data-testid` attributes
- [ ] API used for setup/teardown, not during test execution
- [ ] Tests run successfully in both local and CI environments
- [ ] Tests are independent and can run in parallel
- [ ] No hardcoded waits (`waitForTimeout`)
- [ ] Proper assertions using `expect` statements
- [ ] Error scenarios are tested
- [ ] Screenshots/traces captured on failure
- [ ] Test names are descriptive and readable
- [ ] Test data is cleaned up after each test

### Troubleshooting Common E2E Issues

**Issue 1: Test Timeout**

```typescript
// Increase timeout for slow operations
test('slow file upload', async ({page}) => {
	test.setTimeout(60000) // 60 seconds for this test

	await page.setInputFiles('[data-testid="file-input"]', 'large-file.mp4')
	await page.waitForSelector('[data-testid="upload-complete"]', {timeout: 30000})
})
```

**Issue 2: Element Not Found**

```typescript
// ✅ Solution: Use explicit waits
await expect(page.getByTestId('message')).toBeVisible({timeout: 10000})

// ✅ Solution: Wait for network idle
await page.waitForLoadState('networkidle')

// ✅ Solution: Wait for element to be attached
await page.waitForSelector('[data-testid="element"]', {state: 'attached'})
```

**Issue 3: Flaky Tests (Random Failures)**

```typescript
// ✅ Use stable selectors (data-testid)
await page.click('[data-testid="send-button"]')

// ✅ Wait for elements to be ready
const button = page.getByTestId('send-button')
await expect(button).toBeEnabled()
await expect(button).toBeVisible()
await button.click()

// ❌ Don't use arbitrary waits
await page.waitForTimeout(1000) // Flaky!
```

**Issue 4: Test Data Conflicts**

```typescript
// ✅ Generate unique IDs
const channelName = `channel-${Date.now()}-${Math.random().toString(36).slice(2)}`

// ✅ Clean up after test
test.afterEach(async ({apiClient, testInfo}) => {
	if (testInfo.workspace_id) {
		await teardownTestWorkspace(apiClient, testInfo.workspace_id)
	}
})
```

---

## E2E Anti-Patterns

### Don't: Use Arbitrary Waits

```typescript
// ❌ BAD: Arbitrary timeout (flaky)
await page.waitForTimeout(2000)
await page.click('[data-testid="button"]')

// ✅ GOOD: Wait for specific condition
await expect(page.getByTestId('button')).toBeEnabled()
await page.click('[data-testid="button"]')
```

### Don't: Use Fragile Selectors

```typescript
// ❌ BAD: CSS class selectors (brittle)
await page.click('.btn-primary')
await page.locator('div > div > button:nth-child(2)').click()

// ✅ GOOD: data-testid selectors (stable)
await page.click('[data-testid="send-button"]')
await page.getByTestId('send-button').click()
```

### Don't: Skip Page Objects

```typescript
// ❌ BAD: Raw selectors in test specs
test('sends message', async ({page}) => {
	await page.fill('[data-testid="message-input"]', 'Hello')
	await page.click('[data-testid="send-button"]')
	await expect(page.locator('[data-message]').last()).toContainText('Hello')
})

// ✅ GOOD: Page Object abstracts selectors
test('sends message', async ({authenticatedPage}) => {
	const channelPage = new ChannelPage(authenticatedPage)
	await channelPage.sendMessage('Hello')
	expect(await channelPage.getLastMessage()).toContain('Hello')
})
```

### Don't: Create Test Data via UI

```typescript
// ❌ BAD: Create everything via UI (slow, brittle)
test('sends message', async ({page}) => {
	await page.click('[data-testid="create-workspace"]')
	await page.fill('[data-testid="workspace-name"]', 'Test Workspace')
	await page.click('[data-testid="submit"]')
	await page.click('[data-testid="create-channel"]')
	await page.fill('[data-testid="channel-name"]', 'general')
	await page.click('[data-testid="submit"]')
	// Finally test actual feature... (slow!)
})

// ✅ GOOD: Use API for setup (fast, reliable)
test('sends message', async ({authenticatedPage, apiClient}) => {
	const {workspace, channels} = await setupTestWorkspace(apiClient)
	await authenticatedPage.goto(`/client/${workspace.id}/${channels.general.id}`)
	// Test actual feature immediately
})
```

### Don't: Share State Between Tests

```typescript
// ❌ BAD: Tests share state
let channelId: string

test('creates channel', async ({page, apiClient}) => {
	const channel = await apiClient.conversations.create({name: 'test'})
	channelId = channel.id // Shared state!
})

test('sends message to channel', async ({page}) => {
	// Depends on previous test
	await page.goto(`/client/workspace_openai/${channelId}`)
})

// ✅ GOOD: Each test is independent
test('sends message to channel', async ({page, apiClient}) => {
	// Create channel within test
	const {workspace, channels} = await setupTestWorkspace(apiClient)
	await page.goto(`/client/${workspace.id}/${channels.general.id}`)
})
```

### Don't: Test Implementation Details

```typescript
// ❌ BAD: Testing internal state or attributes
const button = page.locator('button')
expect(await button.getAttribute('disabled')).toBe('true')

// ✅ GOOD: Test user-observable behavior
const button = page.getByRole('button', {name: 'Send'})
await expect(button).toBeDisabled()
```

---

## E2E Advanced Patterns

### Network Interception & API Mocking

**Mock API Responses:**

```typescript
test('handles API errors gracefully', async ({page}) => {
	// Intercept API call and return error
	await page.route('**/api/trpc/chat.postMessage*', route => {
		route.fulfill({
			status: 500,
			contentType: 'application/json',
			body: JSON.stringify({error: {message: 'Internal server error', code: 'INTERNAL_SERVER_ERROR'}})
		})
	})

	await page.goto('http://localhost:3000/client/workspace_openai/channel_general')

	// Try to send message
	await page.fill('[data-testid="message-input"]', 'Test message')
	await page.press('[data-testid="message-input"]', 'Enter')

	// Verify error message is shown
	await expect(page.getByText(/Failed to send message/)).toBeVisible()
})
```

**Wait for Specific Network Requests:**

```typescript
test('waits for message to be persisted', async ({page}) => {
	// Wait for POST request to chat.postMessage
	const messageRequest = page.waitForRequest(
		request => request.url().includes('/chat.postMessage') && request.method() === 'POST'
	)

	await channelPage.sendMessage('Test message')

	const request = await messageRequest
	expect(request.postDataJSON()).toMatchObject({channel: expect.any(String), text: 'Test message'})
})
```

### Accessibility Testing in E2E

**Install axe-core for Playwright:**

```bash
pnpm add -D @axe-core/playwright
```

**Accessibility Test:**

```typescript
import {test, expect} from '@playwright/test'
import AxeBuilder from '@axe-core/playwright'

test.describe('Accessibility', () => {
	test('channel page has no accessibility violations', async ({page}) => {
		await page.goto('http://localhost:3000/client/workspace_openai/channel_general')

		const accessibilityScanResults = await new AxeBuilder({page})
			.withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa'])
			.analyze()

		expect(accessibilityScanResults.violations).toEqual([])
	})

	test('all interactive elements are keyboard accessible', async ({page}) => {
		await page.goto('http://localhost:3000/client/workspace_openai/channel_general')

		// Tab through focusable elements
		await page.keyboard.press('Tab')
		await expect(page.locator(':focus')).toBeVisible()

		// Send message with keyboard only
		await page.keyboard.type('Keyboard test message')
		await page.keyboard.press('Enter')

		await expect(page.getByText('Keyboard test message')).toBeVisible()
	})
})
```

### Performance Assertions

```typescript
test('channel page loads within acceptable time', async ({page}) => {
	const startTime = Date.now()

	await page.goto('http://localhost:3000/client/workspace_openai/channel_general')

	// Wait for key content
	await expect(page.getByRole('heading', {name: '#general'})).toBeVisible()

	const loadTime = Date.now() - startTime

	// Assert load time is under 3 seconds
	expect(loadTime).toBeLessThan(3000)

	console.log(`✅ Page loaded in ${loadTime}ms`)
})
```

### Multi-User Testing

```typescript
test('multiple users can collaborate in real-time', async ({page, context}) => {
	// User 1 (already authenticated)
	const page1 = page
	await page1.goto('/client/workspace_openai/channel_general')

	// User 2 (new context)
	const page2 = await context.newPage()
	// Login as different user...
	await page2.goto('/client/workspace_openai/channel_general')

	// User 1 sends message
	await page1.fill('[data-testid="message-input"]', 'Message from user 1')
	await page1.press('[data-testid="message-input"]', 'Enter')

	// Verify both users see the message
	await expect(page1.getByText('Message from user 1')).toBeVisible()
	await expect(page2.getByText('Message from user 1')).toBeVisible({timeout: 5000})

	// User 2 reacts to message
	await page2.hover('[data-message-content="Message from user 1"]')
	await page2.click('[data-testid="add-reaction"]')
	await page2.click('[data-emoji="thumbsup"]')

	// Verify both users see the reaction
	await expect(page1.locator('[data-testid="reaction-thumbsup"]')).toBeVisible({timeout: 3000})
	await expect(page2.locator('[data-testid="reaction-thumbsup"]')).toBeVisible()

	await page2.close()
})
```

### Viewport Testing (Responsive Design)

```typescript
test.describe('Responsive Design', () => {
	test('mobile: sidebar is collapsible', async ({page}) => {
		// Set mobile viewport (iPhone 12)
		await page.setViewportSize({width: 390, height: 844})

		await page.goto('http://localhost:3000/client/workspace_openai/channel_general')

		// Verify sidebar is hidden on mobile
		const sidebar = page.getByRole('navigation')
		await expect(sidebar).not.toBeVisible()

		// Click menu button to open sidebar
		await page.click('[data-testid="mobile-menu-toggle"]')
		await expect(sidebar).toBeVisible()

		// Close sidebar
		await page.click('[data-testid="close-sidebar"]')
		await expect(sidebar).not.toBeVisible()
	})

	test('desktop: sidebar is always visible', async ({page}) => {
		// Set desktop viewport
		await page.setViewportSize({width: 1920, height: 1080})

		await page.goto('http://localhost:3000/client/workspace_openai/channel_general')

		// Verify sidebar is visible
		await expect(page.getByRole('navigation')).toBeVisible()
	})

	test('tablet: adaptive layout', async ({page}) => {
		// Set tablet viewport (iPad)
		await page.setViewportSize({width: 768, height: 1024})

		await page.goto('http://localhost:3000/client/workspace_openai/channel_general')

		// Verify layout adapts
		await expect(page.getByRole('navigation')).toBeVisible()
	})
})
```

---

## E2E Risks & Mitigations

**Common risks and how to mitigate them (from STS-34):**

| Risk                                  | Impact | Likelihood | Mitigation                                                                      |
| ------------------------------------- | ------ | ---------- | ------------------------------------------------------------------------------- |
| **Flaky tests due to timing issues**  | High   | Medium     | Use explicit waits for state changes, network idle checks, avoid fixed timeouts |
| **Tests break due to UI refactoring** | Medium | High       | Use stable data-testid selectors, Page Object pattern isolates UI changes       |
| **Slow test execution**               | Medium | Low        | Parallel test execution, optimize test setup/teardown, use Docker layer caching |
| **Test data conflicts**               | Low    | Low        | Isolated test data per test run, timestamp-based unique identifiers             |
| **CI resource constraints**           | Low    | Low        | Limit parallel workers, use lighter browser setup in CI                         |
| **File upload timeouts**              | Low    | Low        | Extended timeouts for uploads (30s+), verify upload complete state              |

---

## Test Coverage

### E2E Test Coverage

**100% Feature Coverage Required (from PRODUCT.md):**

All features listed in PRODUCT.md (STS-1 through STS-34) must have E2E test coverage. Track coverage in test coverage matrix:

- Authentication (STS-1): ✅ `e2e/specs/auth/`
- Workspaces (STS-2): ✅ `e2e/specs/workspaces/`
- Messages (STS-3): ✅ `e2e/specs/channels/messages.spec.ts`
- Channels (STS-4): ✅ `e2e/specs/channels/`
- Direct Messages (STS-5): ✅ `e2e/specs/dms/`
- Threads (STS-6): ✅ `e2e/specs/threads/`
- Reactions (STS-7): ✅ `e2e/specs/reactions/`
- ... (continue for all 34 features)

---

## Related Documentation

- [Playwright Documentation](https://playwright.dev/docs/intro)
- `apps/frontend/playwright.config.ts` - Playwright configuration
- `apps/frontend/e2e/` - E2E test directory
- `docs/specs/sts-34-e2e-tests.md` - E2E Testing Framework specification
- `PRODUCT.md` - Product features requiring test coverage
- `{agent_directory}/{rules_directory}/unit-testing.md` - Unit and integration testing patterns
- `{agent_directory}/{rules_directory}/code-quality.md` - Code quality standards
