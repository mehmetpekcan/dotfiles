---
targets:
  - '*'
root: false
description: Code quality best practices and patterns
globs:
  - '**/*'
cursor:
  description: Code quality best practices and patterns
  globs:
    - '**/*'
---

# Code Quality Rules

## Implementation Best Practices

- **tRPC-First Architecture:** Use tRPC procedures for all API operations
- **Type Safety:** Use TypeScript strictly, no `any` types
- **Error Handling:** Use TRPCError for consistent error responses
- **Input Validation:** Validate all inputs with Zod schemas
- **Loading States:** Show loading indicators for async operations
- **Security:** Validate tokens and check authorization in tRPC context
- **Performance:** Consider database query efficiency and bundle size
- **Accessibility:** Ensure WCAG 2.1 AA compliance for UI components
- **Responsive Design:** Test across mobile, tablet, and desktop viewports
- **Logging:** Use structured logging with appropriate log levels
- **Slack API Compatibility:** Follow Slack's API naming conventions
- **Code removal:** Never mark old code as legacy or deprecated. Instead, remove it completely and perform the codebase migration
- **No Markdown Files** Don't create any documentation .md files unless explicitly requested

---

## Code Quality Standards

Every implementation must meet these standards:

### TypeScript

- No `any` types (use `unknown` if type is truly unknown, then narrow with type guards)
- Proper type annotations on function parameters and returns
- Use discriminated unions for complex state
- Leverage type guards for runtime checks
- Use `const` assertions where appropriate

```typescript
// ✅ GOOD: Strict typing
export async function getTeamInfo(teamId: string): Promise<Team> {
	const team = await prisma.team.findFirst({where: {id: teamId}})

	if (!team) {
		throw new TRPCError({code: 'NOT_FOUND', message: 'team_not_found'})
	}

	return team
}

// ❌ BAD: Using any
export async function getTeamInfo(teamId: any): Promise<any> {
	return await prisma.team.findFirst({where: {id: teamId}})
}
```

### tRPC Procedures

Real pattern from `apps/frontend/app/api/trpc/routers/chat/post-message.ts`:

```typescript
import {protectedProcedure, createTRPCRouter} from '@/app/lib/router/trpc'
import {TRPCError} from '@trpc/server'
import {z} from 'zod'
import prisma from '@/app/lib/prisma'

export const chatRouter = createTRPCRouter({
	postMessage: protectedProcedure
		.meta({
			openapi: {method: 'POST', path: '/chat.postMessage', tags: ['chat'], summary: 'Sends a message to a channel'}
		})
		.input(
			z.object({
				channel: z.string().describe('Channel, private group, or DM to send message to'),
				text: z.string().describe('Text of the message to send'),
				thread_ts: z.string().optional().describe('Thread timestamp to reply to'),
				blocks: z.array(z.any()).optional(),
				metadata: z.record(z.any()).optional()
			})
		)
		.output(
			z.object({
				ok: z.boolean(),
				channel: z.string().optional(),
				ts: z.string().optional(),
				message: z.any().optional(),
				error: z.string().optional()
			})
		)
		.mutation(async ({ctx, input}) => {
			try {
				// 1. Validate conversation exists
				const conversation = await prisma.conversation.findFirst({where: {id: input.channel}})

				if (!conversation) {
					throw new TRPCError({code: 'NOT_FOUND', message: 'channel_not_found'})
				}

				// 2. Check user is member
				const member = await prisma.conversationMember.findFirst({
					where: {conversation_id: input.channel, user_id: ctx.userId}
				})

				if (!member && conversation.is_private) {
					throw new TRPCError({code: 'FORBIDDEN', message: 'not_in_channel'})
				}

				// 3. Create message
				const message = await prisma.message.create({
					data: {
						conversation_id: input.channel,
						user_id: ctx.userId,
						content: input.text,
						parent_message_id: input.thread_ts,
						blocks: input.blocks,
						metadata: input.metadata
					},
					include: {user: true, reactions: true}
				})

				return {ok: true, channel: input.channel, ts: message.id, message}
			} catch (error) {
				if (error instanceof TRPCError) {
					throw error
				}

				throw new TRPCError({code: 'INTERNAL_SERVER_ERROR', message: 'message_post_failed', cause: error})
			}
		})
})
```

**tRPC Procedure Checklist:**

1. Use `protectedProcedure` or `publicProcedure`
2. Add `.meta()` with OpenAPI documentation
3. Define `.input()` with Zod schema
4. Define `.output()` with Zod schema
5. Validate authorization in procedure body
6. Perform operation with proper error handling
7. Return consistent response format
8. Throw TRPCError for errors with appropriate codes

### Error Handling

```typescript
import {TRPCError} from '@trpc/server'

// Common error codes
throw new TRPCError({
	code: 'UNAUTHORIZED', // 401 - No valid token
	message: 'not_authed'
})

throw new TRPCError({
	code: 'FORBIDDEN', // 403 - Valid token but no permission
	message: 'insufficient_permissions'
})

throw new TRPCError({
	code: 'NOT_FOUND', // 404 - Resource doesn't exist
	message: 'channel_not_found'
})

throw new TRPCError({
	code: 'BAD_REQUEST', // 400 - Invalid input
	message: 'invalid_name'
})

throw new TRPCError({
	code: 'INTERNAL_SERVER_ERROR', // 500 - Unexpected error
	message: 'operation_failed',
	cause: originalError
})
```

### Validation with Zod

```typescript
import {z} from 'zod'

// Define reusable schemas
const channelNameSchema = z
	.string()
	.min(1, 'Channel name required')
	.max(80, 'Channel name too long')
	.regex(/^[a-z0-9-_]+$/, 'Channel name must be lowercase alphanumeric with dashes')

const conversationCreateSchema = z.object({
	name: channelNameSchema,
	is_private: z.boolean().default(false),
	team_id: z.string()
})

// Use in tRPC procedure
export const conversationsRouter = createTRPCRouter({
	create: protectedProcedure.input(conversationCreateSchema).mutation(async ({ctx, input}) => {
		// Input is validated by Zod
		const conversation = await prisma.conversation.create({
			data: {
				name: input.name,
				context_team_id: input.team_id,
				is_channel: true,
				is_private: input.is_private,
				created: Math.floor(Date.now() / 1000)
			}
		})

		return {ok: true, channel: conversation}
	})
})
```

---

## Components

### Server Components (default)

```typescript
// app/client/[clientId]/page.tsx
import { api } from '@/app/lib/router/server';

export default async function WorkspacePage({
  params,
}: {
  params: { clientId: string };
}) {
  // Fetch data on server using tRPC server caller
  const team = await api.team.info({ team_id: params.clientId });

  if (!team) {
    return <div>Team not found</div>;
  }

  return (
    <div>
      <h1>{team.name}</h1>
      <WorkspaceContent teamId={params.clientId} />
    </div>
  );
}
```

### Client Components (interactive)

```typescript
// components/MessageInput.tsx
'use client';

import { api } from '@/app/lib/router/react';
import { useState } from 'react';
import { Button } from '@/components/Button/Button';

export function MessageInput({ channelId }: { channelId: string }) {
  const [text, setText] = useState('');

  const postMessage = api.chat.postMessage.useMutation({
    onSuccess: () => {
      setText('');
    },
    onError: (error) => {
      console.error('Failed to send message:', error);
    },
  });

  const handleSubmit = () => {
    if (!text.trim()) return;

    postMessage.mutate({
      channel: channelId,
      text,
    });
  };

  return (
    <div>
      <input
        value={text}
        onChange={(e) => setText(e.target.value)}
        onKeyPress={(e) => e.key === 'Enter' && handleSubmit()}
      />
      <Button onClick={handleSubmit} disabled={postMessage.isPending}>
        {postMessage.isPending ? 'Sending...' : 'Send'}
      </Button>
    </div>
  );
}
```

---

## Anti-Patterns

### Don't: Use Server Actions

```typescript
// ❌ BAD: Server Actions (not used in Shack)
'use server'

export async function createTeam(data: FormData) {
	const name = data.get('name')
	return await prisma.team.create({data: {name}})
}

// ✅ GOOD: tRPC procedure
export const teamRouter = createTRPCRouter({
	create: protectedProcedure.input(z.object({name: z.string()})).mutation(async ({ctx, input}) => {
		return await prisma.team.create({data: {name: input.name}})
	})
})
```

### Don't: Skip Input Validation

```typescript
// ❌ BAD: No validation
export const userRouter = createTRPCRouter({
	updateProfile: protectedProcedure
		.input(z.any()) // No validation!
		.mutation(async ({ctx, input}) => {
			await prisma.user.update({
				where: {id: ctx.userId},
				data: input // Dangerous - could set any field
			})
		})
})

// ✅ GOOD: Strict validation
export const userRouter = createTRPCRouter({
	updateProfile: protectedProcedure
		.input(
			z.object({
				real_name: z.string().optional(),
				display_name: z.string().max(80).optional(),
				status_text: z.string().max(100).optional()
			})
		)
		.mutation(async ({ctx, input}) => {
			await prisma.user.update({where: {id: ctx.userId}, data: input})
		})
})
```

### Don't: Use Client Components Unnecessarily

```typescript
// ❌ BAD: Client component for static content
'use client';

export default function AboutPage() {
  return <div>About Shack...</div>;
}

// ✅ GOOD: Server component (default)
export default function AboutPage() {
  return <div>About Shack...</div>;
}
```

## Constants Over Magic Numbers

- Replace hard-coded values with named constants
- Use descriptive constant names that explain the value's purpose
- Keep constants at the top of the file or in a dedicated constants file

## Meaningful Names

- Variables, functions, and classes should reveal their purpose
- Names should explain why something exists and how it's used
- Avoid abbreviations unless they're universally understood

## Single Responsibility

- Each function should do exactly one thing
- Functions should be small and focused
- If a function needs a comment to explain what it does, it should be split

## DRY (Don't Repeat Yourself)

- Extract repeated code into reusable functions
- Share common logic through proper abstraction
- Maintain single sources of truth

## Clean Structure

- Keep related code together
- Organize code in a logical hierarchy
- Use consistent file and folder naming conventions

## Encapsulation

- Hide implementation details
- Expose clear interfaces
- Move nested conditionals into well-named functions

## Testing

- Write tests before fixing bugs
- Keep tests readable and maintainable
- Test edge cases and error conditions

---

## Related Documentation

- [tRPC Documentation](https://trpc.io/docs)
- [Zod Documentation](https://zod.dev/)
- `apps/frontend/app/api/trpc/router.ts` - Main tRPC router
- `{agent_directory}/{rules_directory}/architecture.md` - Architecture patterns
- `{agent_directory}/{rules_directory}/security.md` - Security patterns
- `{agent_directory}/{rules_directory}/unit-testing.md` - Unit and integration testing patterns
