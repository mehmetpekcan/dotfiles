---
targets:
  - '*'
root: false
description: Security best practices and patterns
globs:
  - '**/*'
cursor:
  description: Security best practices and patterns
  globs:
    - '**/*'
---

# Security Rules

## Security Best Practices

- **Token-Based Auth:** Validate API tokens on every request via tRPC context
- **Authorization Always:** Verify user has permission to access resources in tRPC procedures
- **Input Validation:** Validate all inputs with Zod schemas
- **Secure Tokens:** Use cryptographically secure random tokens
- **SQL Injection Prevention:** Use Prisma parameterized queries (never raw SQL with user input)
- **Environment Variables:** Never commit secrets to version control
- **Error Messages:** Don't leak sensitive information in error messages
- **CORS Configuration:** Configure CORS appropriately for API endpoints

---

## Authentication

Shack uses **token-based authentication** via the `ApiToken` model.

### API Token Model

From `apps/frontend/prisma/schema.prisma`:

```prisma
model ApiToken {
  id         String    @id @default(cuid(2))
  token      String    @unique
  user_id    String
  name       String?
  scopes     String?
  created_at DateTime  @default(now())
  expires_at DateTime?
  last_used  DateTime?

  user User @relation("UserApiTokens", fields: [user_id], references: [id], onDelete: Cascade)

  @@index([token])
  @@index([user_id])
  @@map("api_tokens")
}
```

### Token Generation

```typescript
import crypto from 'crypto'
import prisma from '@/app/lib/prisma'

export async function createApiToken(userId: string, name?: string, expiresInDays?: number) {
	// Generate cryptographically secure random token
	const token = `xoxb-${crypto.randomBytes(32).toString('hex')}`

	const expiresAt = expiresInDays ? new Date(Date.now() + expiresInDays * 24 * 60 * 60 * 1000) : null

	return await prisma.apiToken.create({data: {token, user_id: userId, name, expires_at: expiresAt}})
}
```

### Token Validation

From `apps/frontend/app/lib/router/trpc.ts`:

```typescript
export const createTRPCContext = async (opts: {headers?: Headers} = {}) => {
	const headers = opts.headers
	let userId: string | null = null
	let teamId: string | null = null

	// Extract token from Authorization header or x-slack-token header
	const authHeader = headers?.get('authorization')
	const slackToken = headers?.get('x-slack-token')
	const token = authHeader?.replace('Bearer ', '') ?? slackToken

	if (token) {
		try {
			// Validate token against ApiToken table
			const apiToken = await prisma.apiToken.findUnique({
				where: {token},
				select: {
					user_id: true,
					expires_at: true,
					id: true,
					user: {select: {team_memberships: {select: {team_id: true}, take: 1}}}
				}
			})

			// Check if token exists and is not expired
			if (apiToken) {
				const isExpired = apiToken.expires_at && apiToken.expires_at < new Date()
				if (!isExpired) {
					userId = apiToken.user_id
					teamId = apiToken.user.team_memberships[0]?.team_id ?? null

					// Update last_used timestamp (async, don't await)
					prisma.apiToken.update({where: {id: apiToken.id}, data: {last_used: new Date()}}).catch(() => {
						// Silently fail - not critical
					})
				}
			}
		} catch {
			// Invalid token, userId remains null
		}
	}

	return {headers: opts.headers, userId, teamId} as const
}
```

### Using Tokens in API Calls

**HTTP Request:**

```bash
# Bearer token
curl -X POST http://localhost:80/api/trpc/chat.postMessage \
  -H "Authorization: Bearer xoxb-abc123..." \
  -H "Content-Type: application/json" \
  -d '{"channel":"ch_123","text":"Hello"}'

# Slack-compatible header
curl -X POST http://localhost:80/api/trpc/chat.postMessage \
  -H "x-slack-token: xoxb-abc123..." \
  -H "Content-Type: application/json" \
  -d '{"channel":"ch_123","text":"Hello"}'
```

**Client-Side:**

```typescript
'use client';

import { api } from '@/app/lib/router/react';

export function ChatInput({ channelId }: { channelId: string }) {
  const postMessage = api.chat.postMessage.useMutation();

  const handleSubmit = async (text: string) => {
    try {
      await postMessage.mutateAsync({
        channel: channelId,
        text,
      });
    } catch (error) {
      console.error('Failed to send message:', error);
    }
  };

  return <input onKeyPress={(e) => e.key === 'Enter' && handleSubmit(e.target.value)} />;
}
```

---

## Authorization

### tRPC Middleware Pattern

```typescript
// Public procedure - no auth required
export const publicProcedure = t.procedure

// Protected procedure - auth required
export const protectedProcedure = t.procedure.use(({ctx, next}) => {
	if (!ctx.userId) {
		throw new TRPCError({code: 'UNAUTHORIZED', message: 'not_authed'})
	}

	return next({ctx: {userId: ctx.userId, teamId: ctx.teamId ?? ''}})
})
```

### Resource Authorization

```typescript
export const conversationsRouter = createTRPCRouter({
	archive: protectedProcedure.input(z.object({channel: z.string()})).mutation(async ({ctx, input}) => {
		// 1. Check if conversation exists
		const conversation = await prisma.conversation.findFirst({where: {id: input.channel}})

		if (!conversation) {
			throw new TRPCError({code: 'NOT_FOUND', message: 'channel_not_found'})
		}

		// 2. Check if user is a member
		const member = await prisma.conversationMember.findFirst({
			where: {conversation_id: input.channel, user_id: ctx.userId}
		})

		if (!member) {
			throw new TRPCError({code: 'FORBIDDEN', message: 'not_in_channel'})
		}

		// 3. Check if user has admin role (if needed)
		if (member.role !== 'ADMIN') {
			throw new TRPCError({code: 'FORBIDDEN', message: 'insufficient_permissions'})
		}

		// 4. Perform operation
		await prisma.conversation.update({where: {id: input.channel}, data: {is_archived: true}})

		return {ok: true}
	})
})
```

---

## Input Validation

### Zod Schemas

All inputs are validated with Zod:

```typescript
import {z} from 'zod'

const messageSchema = z.object({
	channel: z.string().min(1, 'Channel ID required'),
	text: z.string().min(1, 'Message cannot be empty').max(40000, 'Message too long'),
	thread_ts: z.string().optional(),
	blocks: z.array(z.any()).optional(),
	metadata: z.record(z.any()).optional()
})

export const chatRouter = createTRPCRouter({
	postMessage: protectedProcedure.input(messageSchema).mutation(async ({ctx, input}) => {
		// Input is already validated by Zod
		const message = await prisma.message.create({
			data: {
				conversation_id: input.channel,
				user_id: ctx.userId,
				content: input.text,
				parent_message_id: input.thread_ts,
				blocks: input.blocks,
				metadata: input.metadata
			}
		})

		return {ok: true, message}
	})
})
```

### Auto-Generated Zod Schemas

Prisma automatically generates Zod schemas:

```typescript
// Auto-generated from schema.prisma
import {UserSchema, TeamSchema, MessageSchema} from '@/app/lib/zod/schemas'

// Use in validation
const validUser = UserSchema.parse(userData)
```

---

## Environment Variables

### Storing Secrets

```bash
# .env (encrypted with git-crypt)
DATABASE_URL=file:./prisma/dev.db
SQLD_AUTH_JWT_KEY=your-jwt-key
```

### Accessing Environment Variables

```typescript
// Server-side only
const dbUrl = process.env.DATABASE_URL

if (!dbUrl) {
	throw new Error('DATABASE_URL environment variable is required')
}
```

**Never expose secrets to client:**

```typescript
// ❌ BAD: Attempting to use server env in client component
'use client'

export function Component() {
	const apiKey = process.env.SECRET_KEY // undefined on client
}

// ✅ GOOD: Keep secrets on server (tRPC procedures)
export const adminRouter = createTRPCRouter({
	systemInfo: protectedProcedure.query(async ({ctx}) => {
		// Can access env vars safely on server
		const dbUrl = process.env.DATABASE_URL
		return {status: 'connected'}
	})
})
```

---

## Anti-Patterns

### Don't: Skip Token Validation

```typescript
// ❌ BAD: No token validation
export const createTRPCContext = async () => {
  return { userId: 'user_123', teamId: 'team_456' };
};

// ✅ GOOD: Validate token from headers
export const createTRPCContext = async (opts: { headers?: Headers } = {}) => {
  const token = opts.headers?.get('authorization')?.replace('Bearer ', '');

  if (!token) {
    return { userId: null, teamId: null };
  }

  const apiToken = await prisma.apiToken.findUnique({
    where: { token },
  });

  if (!apiToken || (apiToken.expires_at && apiToken.expires_at < new Date())) {
    return { userId: null, teamId: null };
  }

  return { userId: apiToken.user_id, teamId: /* ... */ };
};
```

### Don't: Return Sensitive Data

```typescript
// ❌ BAD: Exposes API tokens
export const userRouter = createTRPCRouter({
	profile: protectedProcedure.query(async ({ctx}) => {
		return await prisma.user.findUnique({
			where: {id: ctx.userId},
			include: {
				api_tokens: true // Exposes all user tokens!
			}
		})
	})
})

// ✅ GOOD: Only return safe fields
export const userRouter = createTRPCRouter({
	profile: protectedProcedure.query(async ({ctx}) => {
		return await prisma.user.findUnique({
			where: {id: ctx.userId},
			select: {
				id: true,
				email: true,
				username: true,
				display_name: true
				// Don't include api_tokens
			}
		})
	})
})
```

### Don't: Skip Authorization Checks

```typescript
// ❌ BAD: Anyone can delete any message
export const chatRouter = createTRPCRouter({
	delete: protectedProcedure.input(z.object({channel: z.string(), ts: z.string()})).mutation(async ({input}) => {
		await prisma.message.delete({where: {id: input.ts}})
	})
})

// ✅ GOOD: Check message ownership
export const chatRouter = createTRPCRouter({
	delete: protectedProcedure.input(z.object({channel: z.string(), ts: z.string()})).mutation(async ({ctx, input}) => {
		const message = await prisma.message.findUnique({where: {id: input.ts}})

		if (!message) {
			throw new TRPCError({code: 'NOT_FOUND', message: 'message_not_found'})
		}

		if (message.user_id !== ctx.userId) {
			throw new TRPCError({code: 'FORBIDDEN', message: 'cant_delete_message'})
		}

		await prisma.message.delete({where: {id: input.ts}})

		return {ok: true}
	})
})
```

---

## Related Documentation

- [tRPC Documentation](https://trpc.io/docs)
- [Zod Documentation](https://zod.dev/)
- `apps/frontend/app/lib/router/trpc.ts` - tRPC context and auth
- `{agent_directory}/{rules_directory}/code-quality.md` - Code quality standards
- `{agent_directory}/{rules_directory}/database.md` - Database patterns
