---
targets:
  - '*'
root: false
description: Performance best practices and patterns
globs:
  - '**/*'
cursor:
  description: Performance best practices and patterns
  globs:
    - '**/*'
---

# Performance Rules

## Performance Best Practices

- **Database Queries:** Optimize with `select`, `include`, `take`, and proper indexing
- **SQLite Optimization:** Use indexes, limit result sets, avoid complex joins
- **Batch Operations:** Use `Promise.all()` and Prisma batch queries to avoid N+1 problems
- **Bundle Size:** Monitor bundle size, lazy load heavy components
- **Image Optimization:** Use Next.js `<Image>` component with proper sizing
- **Server Components:** Default to Server Components for better performance
- **Code Splitting:** Use dynamic imports for large dependencies
- **Database Indexes:** Add indexes for frequently queried fields
- **Pagination:** Always paginate large result sets
- **React Query as State Management:** Call the same query multiple times - React Query deduplicates and caches automatically

---

## SQLite Query Optimization

### Use `select` for Specific Fields

```typescript
// ❌ BAD: Fetches all fields (including large JSON blobs)
const users = await prisma.user.findMany({where: {deleted: false}})

// ✅ GOOD: Only fetch needed fields
const users = await prisma.user.findMany({
	where: {deleted: false},
	select: {id: true, username: true, display_name: true, image_72: true, status: true}
})
```

### Limit Results with `take`

```typescript
// Always add take for potentially large result sets
const recentMessages = await prisma.message.findMany({
	where: {conversation_id: channelId},
	orderBy: {created_at: 'desc'},
	take: 100 // Limit to 100 most recent
})
```

### Avoid N+1 Query Problems

```typescript
// ❌ BAD: N+1 queries
const teams = await prisma.team.findMany()
for (const team of teams) {
	const members = await prisma.teamMember.findMany({where: {team_id: team.id}}) // N additional queries!
}

// ✅ GOOD: Single query with include
const teams = await prisma.team.findMany({
	include: {
		members: {
			take: 100, // Limit nested results
			include: {user: {select: {id: true, username: true, display_name: true}}}
		}
	}
})
```

### Add Database Indexes

From `apps/frontend/prisma/schema.prisma`:

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
  @@index([parent_message_id])
  @@map("messages")
}
```

---

### Minimize Payload Size

```typescript
// ❌ BAD: Send entire message object
emitMessageEvent({
	type: 'add',
	message: fullMessage, // Includes all fields
	channelId
})

// ✅ GOOD: Send only necessary fields
emitMessageEvent({
	type: 'add',
	message: {
		id: message.id,
		conversation_id: message.conversation_id,
		user_id: message.user_id,
		content: message.content,
		created_at: message.created_at
		// Omit large fields like blocks, metadata
	},
	channelId
})
```

### Connection Management

```typescript
// Keep-alive to prevent connection drops
applyWSSHandler({
	wss,
	router: appRouter,
	createContext,
	keepAlive: {
		enabled: true,
		pingMs: 30000, // Ping every 30 seconds
		pongWaitMs: 5000 // Wait 5 seconds for pong
	}
})
```

### Subscription Cleanup

```typescript
// Always clean up subscriptions
api.chat.onAdd.useSubscription(
	{channelId},
	{
		onData: message => {
			// Handle message
		}
	}
)

// Unsubscribes automatically when component unmounts
```

---

## Bundle Size Optimization

### Dynamic Imports

```typescript
import dynamic from 'next/dynamic';

// Lazy load heavy TipTap editor
const RichTextEditor = dynamic(() => import('./RichTextEditor'), {
  loading: () => <div>Loading editor...</div>,
  ssr: false,
});

export function MessageInput() {
  const [showEditor, setShowEditor] = useState(false);

  return (
    <div>
      <button onClick={() => setShowEditor(true)}>
        Expand editor
      </button>
      {showEditor && <RichTextEditor />}
    </div>
  );
}
```

### Tree Shaking

```typescript
// ❌ BAD: Imports entire library
import _ from 'lodash'
const result = _.uniq(array)

// ✅ GOOD: Use native JavaScript
const result = [...new Set(array)]
```

---

## Pagination

### Cursor-Based Pagination

```typescript
export const chatRouter = createTRPCRouter({
	historyQuery: publicProcedure
		.input(
			z.object({
				channel: z.string(),
				cursor: z.string().optional(), // Message ID
				limit: z.number().min(1).max(1000).default(100)
			})
		)
		.query(async ({input}) => {
			const messages = await prisma.message.findMany({
				where: {conversation_id: input.channel},
				take: input.limit + 1, // Fetch one extra to check if there's more
				...(input.cursor && {
					cursor: {id: input.cursor},
					skip: 1 // Skip the cursor itself
				}),
				orderBy: {created_at: 'desc'},
				include: {user: true, reactions: true}
			})

			const hasMore = messages.length > input.limit
			const items = hasMore ? messages.slice(0, -1) : messages
			const nextCursor = hasMore ? items[items.length - 1].id : null

			return {ok: true, messages: items, has_more: hasMore, response_metadata: {next_cursor: nextCursor}}
		})
})
```

---

## Performance Targets

### Database Queries

- **Simple queries:** < 50ms
- **Complex queries with joins:** < 200ms
- **Full-text search:** < 500ms

### Real-Time Messaging

- **Typing indicators:** < 50ms
- **Presence updates:** < 100ms

### API Response Times

- **tRPC queries:** < 200ms
- **tRPC mutations:** < 500ms

### Bundle Size

- **First Load JS:** < 200KB (gzipped)
- **Page-specific JS:** < 50KB (gzipped)

---

## Anti-Patterns

### Don't: Load All Data Upfront

```typescript
// ❌ BAD: Load everything
const allMessages = await prisma.message.findMany({where: {conversation_id: channelId}}) // Could be thousands!

// ✅ GOOD: Paginate
const recentMessages = await prisma.message.findMany({
	where: {conversation_id: channelId},
	orderBy: {created_at: 'desc'},
	take: 100
})
```

### Don't: Forget to Add Indexes

```prisma
// ❌ BAD: No indexes on frequently queried fields
model Message {
  id              String
  conversation_id String  // Queried often but no index!
  user_id         String  // Queried often but no index!
}

// ✅ GOOD: Add indexes
model Message {
  id              String
  conversation_id String
  user_id         String

  @@index([conversation_id])
  @@index([user_id])
}
```

---

## React Query as State Management

**Use React Query as your state management layer.** Call the same query multiple times in different components - React Query deduplicates requests and serves cached data.

```typescript
// ✅ GOOD: Call the same query in multiple components
// Component 1
function UserResults({ searchQuery }) {
  const [users] = api.users.list.useSuspenseQuery({ team_id: clientId });
  const matching = users.members.filter(...);
  return <>{matching.map(...)}</>;
}

// Component 2 (calls same query - React Query deduplicates)
function UserCount({ searchQuery }) {
  const [users] = api.users.list.useSuspenseQuery({ team_id: clientId });
  return <Badge>{users.members.length}</Badge>;
}

// Result: Only 1 network request, data is shared via React Query cache

// ❌ BAD: Complex prop drilling to avoid "duplicate" fetches
function Parent() {
  const [users] = api.users.list.useSuspenseQuery({ team_id: clientId });
  return (
    <>
      <UserResults users={users.members} />
      <UserCount users={users.members} />
    </>
  );
}
```

**Key insight:** Don't avoid calling queries because you think it's wasteful. React Query handles deduplication, caching, and revalidation automatically.

---

## Related Documentation

- [SQLite Performance Tips](https://www.sqlite.org/performance.html)
- [Prisma Performance](https://www.prisma.io/docs/guides/performance-and-optimization)
- [Next.js Performance](https://nextjs.org/docs/app/building-your-application/optimizing)
- `{agent_directory}/{rules_directory}/database.md` - Database optimization
- `{agent_directory}/{rules_directory}/architecture.md` - Architecture patterns
