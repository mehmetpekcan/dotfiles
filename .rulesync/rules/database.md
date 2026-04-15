---
targets:
  - '*'
root: false
description: Database best practices and patterns
globs:
  - '**/*'
cursor:
  description: Database best practices and patterns
  globs:
    - '**/*'
---

# Database Rules

## Database Best Practices

- **Use Prisma Client:** Always use the Prisma client from `@/app/lib/prisma`
- **Hard Deletes with Flags:** Use `deleted: true` boolean flag pattern, not soft-delete extension
- **Authorize in tRPC:** Authorization handled in tRPC context and middleware, not in queries
- **Optimize Queries:** Use `select` and `include` judiciously, add `take` limits
- **No Decimal Fields:** SQLite uses INTEGER for timestamps and amounts (avoid Decimal.js)
- **Use Transactions:** Wrap multi-step operations in `$transaction`
- **Index Properly:** Add indexes for frequently queried fields
- **Batch Operations:** Use batch queries for large datasets to avoid N+1 problems
- **Connection Management:** Prisma's SQLite adapter manages connections for app usage
- **Slack Schema:** Follow Slack's data model conventions (User, Team, Conversation, Message)

---

## Prisma Client Setup

### better-sqlite3 Adapter Configuration

From `apps/frontend/app/lib/prisma.ts`:

```typescript
import {PrismaClient} from '@prisma/client'
import {PrismaBetterSqlite3} from '@prisma/adapter-better-sqlite3'

const adapter = new PrismaBetterSqlite3({url: process.env.DATABASE_URL!})

const prismaClientSingleton = () => {
	return new PrismaClient({
		adapter,
		log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error']
	})
}

declare const globalThis: {prismaGlobal: ReturnType<typeof prismaClientSingleton>} & typeof global

const prisma = globalThis.prismaGlobal ?? prismaClientSingleton()

export default prisma

if (process.env.NODE_ENV !== 'production') globalThis.prismaGlobal = prisma
```

**Always import from `@/app/lib/prisma`:**

```typescript
// ✅ GOOD: Use singleton client
import prisma from '@/app/lib/prisma'

// ❌ BAD: Don't create new client instances
import {PrismaClient} from '@prisma/client'
const prisma = new PrismaClient()
```

---

## Deletion Pattern

### Hard Deletes with Boolean Flag

Shack uses a `deleted` boolean flag instead of soft-delete extensions:

```typescript
// Mark user as deleted (hard delete with flag)
await prisma.user.update({where: {id: userId}, data: {deleted: true}})

// Query automatically includes deleted check
const activeUsers = await prisma.user.findMany({
	where: {deleted: false} // Explicitly filter
})

// To include deleted users
const allUsers = await prisma.user.findMany({where: {OR: [{deleted: false}, {deleted: true}]}})
```

**Key Models with Deletion Flags:**

- `User` - Uses `deleted` boolean
- `Team` - No deletion (permanent)
- `Conversation` - Uses `is_archived` boolean
- `Message` - Hard delete (no flag)
- `UserGroup` - Uses `deleted_at` DateTime (soft delete)

---

## Schema Organization

### Slack-Compatible Schema

From `apps/frontend/prisma/schema.prisma`:

```prisma
datasource db {
  provider = "sqlite"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}


// ===== User Models =====

model User {
  id       String @id @default(cuid(2))
  email    String @unique
  username String @unique
  status   Status @default(ACTIVE)

  // Slack user fields
  deleted      Boolean @default(false)
  color        String?
  real_name    String?
  tz           String?
  tz_offset    Int?
  is_bot       Boolean @default(false)
  // ... more Slack fields

  // Timestamps
  created_at DateTime @default(now())
  updated_at DateTime @updatedAt
  updated    Int?     // Unix timestamp (Slack)

  // Relations
  team_memberships TeamMember[]
  messages         Message[]
  reactions        Reaction[]

  @@map("users")
}

// ===== Team Models =====

model Team {
  id      String @id @default(cuid(2))
  name    String
  slug    String @unique
  domain  String?

  created_at DateTime @default(now())
  updated_at DateTime @updatedAt

  // Relations
  members       TeamMember[]
  conversations Conversation[]

  @@map("teams")
}

// ===== Conversation Models =====
// Unified model for channels, DMs, and groups

model Conversation {
  id              String  @id @default(cuid(2))
  name            String?
  context_team_id String

  // Type indicators (Slack uses booleans)
  is_channel  Boolean @default(true)
  is_group    Boolean @default(false)
  is_im       Boolean @default(false)
  is_mpim     Boolean @default(false)
  is_private  Boolean @default(false)
  is_archived Boolean @default(false)

  // Timestamps (Slack uses Unix timestamps)
  created Int @default(0)
  updated Int?

  created_at DateTime @default(now())
  updated_at DateTime @updatedAt

  // Relations
  team     Team      @relation(fields: [context_team_id], references: [id])
  messages Message[]
  members  ConversationMember[]

  @@map("conversations")
}
```

---

## Query Patterns

### Basic Queries

```typescript
import prisma from '@/app/lib/prisma'

// Find by ID
const user = await prisma.user.findUnique({where: {id: userId}})

// Find by unique field with deleted filter
const user = await prisma.user.findFirst({where: {email: 'user@example.com', deleted: false}})

// Find many with filtering
const conversations = await prisma.conversation.findMany({
	where: {context_team_id: teamId, is_archived: false, is_channel: true},
	orderBy: {created: 'desc'},
	take: 50
})
```

### Queries with Relationships

```typescript
const conversation = await prisma.conversation.findFirst({
	where: {id: conversationId, is_archived: false},
	include: {
		team: true,
		members: {include: {user: {select: {id: true, username: true, display_name: true, image_72: true}}}},
		messages: {
			where: {parent_message_id: null}, // Top-level only
			orderBy: {created_at: 'desc'},
			take: 50,
			include: {user: true, reactions: {include: {user: {select: {id: true, username: true}}}}}
		}
	}
})
```

### Authorization in tRPC Context

Authorization is handled in tRPC middleware, not in queries:

```typescript
// In tRPC procedure (context already has userId from token)
export const conversationsRouter = createTRPCRouter({
	info: protectedProcedure.input(z.object({channel: z.string()})).query(async ({ctx, input}) => {
		// ctx.userId is guaranteed to exist (protectedProcedure)

		const conversation = await prisma.conversation.findFirst({
			where: {id: input.channel},
			include: {
				members: {
					where: {user_id: ctx.userId} // Check membership
				}
			}
		})

		if (!conversation) {
			throw new TRPCError({code: 'NOT_FOUND', message: 'channel_not_found'})
		}

		// Verify user is a member
		if (conversation.members.length === 0) {
			throw new TRPCError({code: 'FORBIDDEN', message: 'not_in_channel'})
		}

		return conversation
	})
})
```

---

## Message Creation Pattern

### Always Use `generateMessageId()` Helper

**CRITICAL:** All message creation MUST use the `generateMessageId()` helper function to ensure message IDs are Unix timestamps (matching Slack's `ts` field format).

```typescript
import {generateMessageId} from '@/app/lib/message-helpers'

// ✅ GOOD: Always set id using generateMessageId()
const message = await prisma.message.create({
	data: {
		id: generateMessageId(), // Unix timestamp string with 4-char hex suffix (e.g., "1234567890abcd")
		content: 'Hello world',
		user_id: userId,
		conversation_id: channelId
	}
})

// ✅ GOOD: For seed/test data with specific dates
const message = await prisma.message.create({
	data: {
		id: generateMessageId(specificDate), // Use date parameter for historical data
		content: 'Historical message',
		user_id: userId,
		conversation_id: channelId,
		created_at: specificDate
	}
})

// ❌ BAD: Don't rely on Prisma default (cuid)
const message = await prisma.message.create({
	data: {
		// Missing id - will use cuid(2) default, breaking Slack compatibility
		content: 'Hello world',
		user_id: userId,
		conversation_id: channelId
	}
})

// ❌ BAD: Don't manually calculate timestamp
const message = await prisma.message.create({
	data: {
		id: String(Math.floor(Date.now() / 1000)), // Duplicated logic
		content: 'Hello world',
		user_id: userId,
		conversation_id: channelId
	}
})
```

### Helper Function

From `apps/frontend/app/lib/message-helpers.ts`:

```typescript
/**
 * Generate a message ID as a Unix timestamp string with uniqueness suffix
 * Format: "{timestamp}{4-char-hex-suffix}" (e.g., "1234567890abcd")
 * This matches Slack's message ID format (ts field) while preventing collisions
 *
 * @param date - Optional Date to use for the timestamp. If not provided, uses current time.
 * @returns Unix timestamp string with 4-character hex suffix (seconds since epoch + suffix)
 */
export function generateMessageId(date?: Date): string {
	const timestamp = date ? date.getTime() : Date.now()
	const seconds = Math.floor(timestamp / 1000)

	// Add 4-character random hex suffix to ensure uniqueness within same second
	// This maintains Slack compatibility (timestamp-based) while preventing collisions
	// 2 bytes = 4 hex chars = 65,536 possible values per second
	const suffix = crypto.randomBytes(2).toString('hex')

	return `${seconds}${suffix}`
}
```

**Note:** The 4-character hex suffix provides 65,536 possible values per second, preventing ID collisions when multiple messages are created within the same second. The timestamp portion can still be extracted using `parseInt(id, 10)` if needed.

### Usage in Different Contexts

**Production Code (tRPC Routers):**

```typescript
// apps/frontend/app/api/trpc/routers/chat/post-message.ts
const message = await prisma.message.create({
	data: {
		id: generateMessageId(),
		content: messageContent,
		user_id: ctx.userId,
		conversation_id: input.channel,
		parent_message_id: input.thread_ts ?? undefined
	}
})
```

**Test Helpers:**

```typescript
// apps/frontend/app/lib/test-helpers.ts
export async function createTestMessage(userId: string, channelId: string, data?: {content?: string}) {
	return prisma.message.create({
		data: {
			id: generateMessageId(),
			content: data?.content ?? 'Test Message content',
			user_id: userId,
			conversation_id: channelId
		}
	})
}
```

**Batch Operations (createMany):**

```typescript
// For seed data or test fixtures with specific dates
await prisma.message.createMany({
	data: testDates.map((date, i) => ({
		id: generateMessageId(date), // Generate ID from date
		conversation_id: testConversation.id,
		user_id: testUser.id,
		content: `Message ${i + 1}`,
		created_at: date
	}))
})
```

**Creating Messages in Loops (CRITICAL - Prevents ID Collisions):**

When creating multiple messages in a loop (e.g., sharing files to multiple channels, creating system messages for multiple channels), **always increment the timestamp** to ensure unique message IDs. While `generateMessageId()` now includes a random suffix to prevent collisions within the same second, incrementing timestamps provides additional safety and ensures proper chronological ordering.

**Pattern 1: Using messageIndex counter (most common):**

```typescript
// ✅ GOOD: Incrementing dates in loop
async function createMessageWithFiles(channelIds: string[], initialComment: string, userId: string) {
	// Use incrementing dates to ensure unique message IDs when multiple
	// messages are created in quick succession (e.g., sharing to multiple channels)
	let messageIndex = 0
	for (const channelId of channelIds) {
		const messageDate = new Date(Date.now() + messageIndex * 1000)
		await prisma.message.create({
			data: {
				id: generateMessageId(messageDate), // Pass incremented date
				content: initialComment,
				user_id: userId,
				conversation_id: channelId,
				subtype: 'file_share'
			}
		})
		messageIndex++ // Increment after each message
	}
}
```

**Pattern 2: Using baseTime with channelIndex:**

```typescript
// ✅ GOOD: Base time with incrementing index
const baseTime = Date.now()
let channelIndex = 0

for (const [channelId, addedUsers] of channelAdditions.entries()) {
	// Use unique timestamp for each system message to avoid ID collisions
	const messageDate = new Date(baseTime + channelIndex * 1000)
	await createSystemMessage(
		channelId,
		addedUsers,
		inviterName,
		messageDate // Pass incremented date to helper
	)
	channelIndex++ // Increment after each message
}
```

**Real Examples from Codebase:**

1. **File sharing to multiple channels:**
   - `apps/frontend/app/api/trpc/routers/file/upload.ts:206-223`
   - `apps/frontend/app/api/trpc/routers/file/complete-upload-external.ts:190-207`

2. **System messages for multiple channels:**
   - `apps/frontend/app/api/trpc/routers/admin/users/invite.ts:244-257`

**❌ BAD: Missing increment (causes ID collisions):**

```typescript
// ❌ BAD: All messages get same ID if created in same second
for (const channelId of channelIds) {
	await prisma.message.create({
		data: {
			id: generateMessageId(), // Same timestamp for all messages!
			content: initialComment,
			conversation_id: channelId
		}
	})
}
```

**Key Points:**

- **Always increment by 1000ms (1 second)** per message to ensure unique Unix timestamps
- **Use `messageIndex` or `channelIndex`** counter starting at 0
- **Pass incremented date** to `generateMessageId(date)` - don't call it without parameters in loops
- **Increment counter after** each message creation
- **This pattern is required** whenever creating messages in loops, especially when sharing to multiple channels

**Seed Scripts:**

```typescript
// apps/frontend/prisma/seed.ts
async function createMessage(userId: string, conversationId: string, data: {content: string; created_at?: Date}) {
	const {generateMessageId} = await import('../app/lib/message-helpers')
	return prisma.message.create({
		data: {
			id: generateMessageId(data.created_at), // Use date if provided
			content: data.content,
			user_id: userId,
			conversation_id: conversationId,
			created_at: data.created_at
		}
	})
}
```

### Why This Pattern Matters

1. **Slack API Compatibility:** Message IDs are timestamp-based (with suffix) to match Slack's `ts` field format
2. **Consistency:** All messages use the same ID format across the codebase
3. **Maintainability:** Centralized logic in helper function
4. **Testability:** Helper supports optional date parameter for test fixtures
5. **ID Collision Prevention:** The 4-character hex suffix prevents collisions within the same second (65,536 possible values). When creating messages in loops, incrementing timestamps provides additional safety and ensures proper chronological ordering (see "Creating Messages in Loops" section above)
6. **Backward Compatibility:** Existing messages with pure numeric IDs continue to work. `parseInt(id, 10)` can extract the timestamp portion from both old and new formats

### Schema Note

The Prisma schema has `@default(cuid(2))` as a fallback, but **this default should never be used**. Always explicitly set `id: generateMessageId()`:

```prisma
model Message {
  id String @id @default(cuid(2)) // Used as Slack's ts (timestamp) identifier
  // ... other fields
}
```

---

## Unix Timestamp Handling

Slack uses Unix timestamps extensively. Shack stores both DateTime and INTEGER:

```typescript
// Creating records with Unix timestamps
const conversation = await prisma.conversation.create({
	data: {
		name: 'engineering',
		context_team_id: teamId,
		is_channel: true,
		created: Math.floor(Date.now() / 1000), // Unix seconds
		created_at: new Date() // DateTime for ORM
	}
})

// Updating Unix timestamps
await prisma.conversation.update({where: {id: conversationId}, data: {updated: Math.floor(Date.now() / 1000)}})

// Querying by Unix timestamp
const recentMessages = await prisma.message.findMany({
	where: {
		conversation_id: channelId,
		created_at: {
			gte: new Date(Date.now() - 24 * 60 * 60 * 1000) // Last 24 hours
		}
	}
})
```

---

## Migrations

### Prisma DB Push Workflow

Shack uses Prisma's DB push workflow for SQLite:

```bash
# Run migrations
pnpm prisma:migrate

# This executes: prisma db push --accept-data-loss
```

No custom migration shim is required for the SQLite adapter setup.

### Creating Migrations

```bash
# 1. Update schema.prisma
# 2. Run migration tool
pnpm prisma:migrate

# 3. Migrations stored in prisma/migrations/
```

---

## Batch Queries

### Avoid N+1 Queries

```typescript
// ❌ BAD: N+1 query problem
const teams = await prisma.team.findMany()
for (const team of teams) {
	const members = await prisma.teamMember.findMany({where: {team_id: team.id}}) // N additional queries!
}

// ✅ GOOD: Single query with include
const teams = await prisma.team.findMany({
	include: {
		members: {
			include: {user: {select: {id: true, username: true, display_name: true}}},
			take: 100 // Limit nested results
		}
	}
})
```

### Batch Operations

```typescript
// Create multiple records at once
// IMPORTANT: Always include id for messages using generateMessageId()
import {generateMessageId} from '@/app/lib/message-helpers'

await prisma.message.createMany({
	data: [
		{id: generateMessageId(), conversation_id: 'ch1', user_id: 'u1', content: 'Message 1'},
		{id: generateMessageId(), conversation_id: 'ch1', user_id: 'u2', content: 'Message 2'},
		{id: generateMessageId(), conversation_id: 'ch2', user_id: 'u3', content: 'Message 3'}
	]
})

// Update multiple records
await prisma.user.updateMany({where: {created_at: {lt: new Date('2024-01-01')}}, data: {color: '4bbe2e'}})
```

---

## Transactions

Use transactions for operations that must succeed or fail together:

```typescript
// Example: Create message and update conversation updated timestamp
import {generateMessageId} from '@/app/lib/message-helpers'

await prisma.$transaction(async tx => {
	// Create message (always use generateMessageId())
	const message = await tx.message.create({
		data: {id: generateMessageId(), conversation_id: channelId, user_id: userId, content: text}
	})

	// Update conversation timestamp
	await tx.conversation.update({where: {id: channelId}, data: {updated: Math.floor(Date.now() / 1000)}})

	// Update num_members count
	const memberCount = await tx.conversationMember.count({where: {conversation_id: channelId}})

	await tx.conversation.update({where: {id: channelId}, data: {num_members: memberCount}})

	return message
})
```

---

## Performance Optimization

### Use Indexes

```prisma
model Message {
  id              String @id @default(cuid(2))
  conversation_id String
  user_id         String
  created_at      DateTime @default(now())

  // Add indexes for frequently queried fields
  @@index([conversation_id])
  @@index([user_id])
  @@index([created_at])
  @@index([parent_message_id]) // For threads
  @@map("messages")
}
```

### Limit Results

```typescript
// Always add take for potentially large result sets
const recentMessages = await prisma.message.findMany({
	where: {conversation_id: channelId},
	orderBy: {created_at: 'desc'},
	take: 100 // Limit to 100 most recent
})
```

### Use Select for Large Objects

```typescript
// ❌ BAD: Fetches all fields including large ones
const users = await prisma.user.findMany()

// ✅ GOOD: Only fetch needed fields
const users = await prisma.user.findMany({
	select: {id: true, username: true, display_name: true, image_72: true, status: true}
})
```

---

## Database Management

### Prisma Commands

```bash
# Generate Prisma client (after schema changes)
pnpm prisma:generate

# Run migrations
pnpm prisma:migrate

# Open Prisma Studio (visual database editor)
pnpm prisma:studio

# Seed database with test data
pnpm prisma:seed
```

### Prisma Studio

```bash
# Launch visual database editor
pnpm prisma:studio

# Opens at http://localhost:5555
```

### Database Seeding

**CRITICAL:** Seed scripts must use the State API pattern (HTTP POST to `/api/state`), not direct Prisma writes.

**Pattern:**

```typescript
// 1. Define ID constants at top
const USER_IDS = { SAM_ALTMAN: "user_sam_altman" } as const;
const TEAM_IDS = { OPENAI: "workspace_openai" } as const;

// 2. Builder functions return data arrays (not write to Prisma)
function buildUsers() {
  return [{ id: USER_IDS.SAM_ALTMAN, email: "...", ... }];
}

// 3. Pre-generate message IDs
const messageIds = { msg_1: generateMessageId(date) };

// 4. Build state object and POST to State API
const stateData = { User: buildUsers(), Team: buildTeams(), ... };
await fetch(`${FRONTEND_URL}/api/state`, {
  method: "POST",
  headers: { Authorization: `Bearer ${ADMIN_TOKEN}` },
  body: JSON.stringify(stateData),
});
```

**Key Rules:**

- Use centralized ID constants for foreign keys (explicit relationships)
- Builder functions return arrays, organized by domain
- Pre-generate message IDs before building state object
- Single HTTP POST with all tables (atomic transaction)
- No direct Prisma writes in seed scripts

See `apps/frontend/prisma/seed.ts` for complete example.

---

## Anti-Patterns

### Don't: Use Soft-Delete Extension

```typescript
// ❌ BAD: Soft-delete extension (not used in Shack)
import prisma from '@/app/lib/prisma' // better-sqlite3 adapter
const users = await prisma.user.findMany() // Auto-filters deleted

// ✅ GOOD: Explicit deleted flag
import prisma from '@/app/lib/prisma'
const users = await prisma.user.findMany({where: {deleted: false}})
```

### Don't: Use Decimal Fields

```typescript
// ❌ BAD: Decimal fields (not supported well in SQLite)
model Account {
  balance Decimal @db.Decimal(10, 2)
}

// ✅ GOOD: Use INTEGER for amounts (in cents)
model Subscription {
  amount_cents Int // Store as cents: $10.00 = 1000
}

// ✅ GOOD: Use INTEGER for Unix timestamps
model Message {
  created Int // Unix timestamp in seconds
}
```

### Don't: Skip Authorization Checks

```typescript
// ❌ BAD: No authorization in tRPC procedure
export const conversationsRouter = createTRPCRouter({
	archive: protectedProcedure.input(z.object({channel: z.string()})).mutation(async ({input}) => {
		// Anyone can archive any channel!
		await prisma.conversation.update({where: {id: input.channel}, data: {is_archived: true}})
	})
})

// ✅ GOOD: Check membership before archiving
export const conversationsRouter = createTRPCRouter({
	archive: protectedProcedure.input(z.object({channel: z.string()})).mutation(async ({ctx, input}) => {
		// Check if user is channel member
		const member = await prisma.conversationMember.findFirst({
			where: {conversation_id: input.channel, user_id: ctx.userId}
		})

		if (!member) {
			throw new TRPCError({code: 'FORBIDDEN', message: 'not_in_channel'})
		}

		await prisma.conversation.update({where: {id: input.channel}, data: {is_archived: true}})
	})
})
```

### Don't: Use Raw SQL with User Input

```typescript
// ❌ BAD: SQL injection vulnerability
const email = userInput
const user = await prisma.$queryRawUnsafe(`SELECT * FROM users WHERE email = '${email}'`)

// ✅ GOOD: Use Prisma's query builder
const user = await prisma.user.findFirst({where: {email: userInput}})

// ✅ ACCEPTABLE: Parameterized raw query (if needed)
const users = await prisma.$queryRaw`
  SELECT * FROM users WHERE email = ${userInput}
`
```

---

## Related Documentation

- [Prisma Documentation](https://www.prisma.io/docs)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- `apps/frontend/prisma/schema.prisma` - Database schema
- `{agent_directory}/{rules_directory}/performance.md` - Query optimization
- `{agent_directory}/{rules_directory}/security.md` - Authorization patterns
