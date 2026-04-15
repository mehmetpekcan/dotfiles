---
targets:
  - '*'
root: false
description: Architecture best practices and patterns
globs:
  - '**/*'
cursor:
  description: Architecture best practices and patterns
  globs:
    - '**/*'
---

# Architecture Rules

## Architecture Best Practices

- **tRPC-First:** Use tRPC procedures for all API operations; leverage type safety end-to-end
- **Server Components:** Default to Server Components, use Client Components only when needed for interactivity
- **Slot Pattern:** Use slot pattern (composition) to pass server components to client components; never import server components in client code
- **Colocate Code:** Keep related tRPC routers and procedures together by domain
- **Monorepo Structure:** Use workspace packages (`@openai/*`) for shared code
- **File Conventions:** Follow tRPC router patterns and Next.js App Router conventions
- **Real-Time:** Plan for future real-time updates if needed
- **Type Safety:** Share Zod schemas and types between client and server
- **Error Handling:** Use TRPCError for consistent error responses
- **Slack API Compatible:** Follow Slack's API naming and structure conventions
- **Next.js 16 Params:** Route params are Promises; always await in async server components

---

## Next.js 16 App Router

### File Conventions

Shack uses Next.js App Router with tRPC instead of Server Actions:

```
app/
├── api/
│   └── trpc/
│       ├── [...openapi]/
│       │   └── route.ts           # OpenAPI REST endpoints
│       ├── [trpc]/
│       │   └── route.ts           # tRPC HTTP handler
│       ├── router.ts               # Main tRPC router
│       └── routers/
│           ├── user/
│           │   ├── index.ts        # User router
│           │   └── profile-set.ts  # Procedure implementation
│           ├── team/
│           ├── conversations/
│           ├── chat/
│           ├── reactions/
│           ├── stars/
│           ├── pins/
│           ├── files/
│           ├── bookmarks/
│           ├── search/
│           ├── reminders/
│           ├── usergroups/
│           └── admin/
├── client/
│   └── [clientId]/                 # Workspace-specific routes
│       ├── channel/
│       │   └── [channelId]/
│       │       └── page.tsx        # Server Component
│       └── layout.tsx
└── lib/
    ├── router/
    │   ├── trpc.ts                 # tRPC server setup
    │   ├── react.tsx               # Client provider
    │   ├── server.ts               # Server caller
    │   └── query-client.ts         # React Query setup
    ├── prisma.ts                   # Prisma client
    ├── validation/
    │   └── schemas.ts              # Shared Zod schemas
    └── zod/
        └── schemas/                # Auto-generated from Prisma
```

### Server Components vs Client Components

**Server Components (default - NO 'use client'):**

```typescript
// app/client/[clientId]/page.tsx
import { api } from '@/app/lib/router/server';

export default async function WorkspacePage({
  params,
}: {
  params: Promise<{ clientId: string }>; // Next.js 16: params is a Promise
}) {
  // Must await params in Next.js 16
  const { clientId } = await params;

  // Fetch data on server using tRPC server caller
  const team = await api.team.info({ team_id: clientId });

  return (
    <div>
      <h1>{team.name}</h1>
      <WorkspaceContent teamId={clientId} />
    </div>
  );
}
```

**Client Components ('use client' directive):**

```typescript
// components/MessageList.tsx
'use client';

import { api } from '@/app/lib/router/react';
import { useState } from 'react';

export function MessageList({ channelId }: { channelId: string }) {
  // Client-side tRPC query
  const messages = api.chat.historyQuery.useQuery({ channel: channelId });

  if (messages.isLoading) return <div>Loading...</div>;
  if (messages.error) return <div>Error loading messages</div>;

  return (
    <div>
      {messages.data?.messages.map((msg) => (
        <Message key={msg.id} message={msg} />
      ))}
    </div>
  );
}
```

### Server/Client Component Boundaries

Next.js 16 enforces strict boundaries between server and client components:

| Component Type | Can Import Server | Can Import Client | Can Receive Server as Props |
| -------------- | ----------------- | ----------------- | --------------------------- |
| **Server**     | ✅ Yes            | ✅ Yes            | N/A (is server)             |
| **Client**     | ❌ No             | ✅ Yes            | ✅ Yes                      |

**Critical Rules:**

1. **Client components cannot import server components** — this will cause a build error
2. **Client components CAN receive server components as props/children** — this is the solution
3. **In Next.js 16, route `params` is a Promise** — must be awaited in async server components

### Slot Pattern (Composition Pattern)

The **slot pattern** is the standard approach for passing server components to client components when you need client-side interactivity with server-side data fetching.

**When to use:**

- Client component needs to render a server component
- Maintaining server-side data fetching with client-side interactivity
- Preserving server-side prefetching benefits (React Query hydration)
- Avoiding "You're importing a component that needs 'next/headers'" errors

**Implementation:**

Real example from `apps/frontend/app/client/[clientId]/[chatId]/page.tsx`:

```typescript
// 1. Server component (page.tsx)
import { HomeNav } from "@/components/HomeNav/HomeNav"; // Server component
import { ClientPageContent } from "./ClientPageContent";

interface ClientPageProps {
  params: Promise<{ chatId: string; clientId: string }>; // Next.js 16
}

const ClientPage = async ({ params }: ClientPageProps) => {
  const { chatId, clientId } = await params; // Must await

  return (
    <ClientPageContent
      chatId={chatId}
      clientId={clientId}
      sidebar={<HomeNav clientId={clientId} />} // Pass as prop
    />
  );
};

export default ClientPage;
```

```typescript
// 2. Client component (ClientPageContent.tsx)
"use client";

import { useState } from "react";
import { ResizablePanel } from "@/components/Resizable/Resizable";

interface ClientPageContentProps {
  chatId: string;
  clientId: string;
  sidebar: React.ReactNode; // Receive server component as prop
}

const ClientPageContent = ({ chatId, clientId, sidebar }: ClientPageContentProps) => {
  const [isDragging, setIsDragging] = useState(false);

  return (
    <div>
      <ResizablePanel>{sidebar}</ResizablePanel>
      {/* Client-side interactive content */}
    </div>
  );
};
```

**Key Points:**

- Server component renders the server component (e.g., `<HomeNav />`)
- Server component passes it as a prop (e.g., `sidebar={<HomeNav />}`)
- Client component receives as `React.ReactNode` type
- Client component renders it (e.g., `{sidebar}`)
- No direct import of server component in client code

**Prop Naming Conventions:**

- `sidebar` - Navigation/menu server components
- `header` - Header server components
- `footer` - Footer server components
- `children` - Generic content slots (standard React pattern)

**Real Examples:**

- `apps/frontend/app/client/[clientId]/[chatId]/page.tsx` - Slot pattern with sidebar
- `apps/frontend/app/client/[clientId]/threads/page.tsx` - Slot pattern with sidebar
- `apps/frontend/app/client/[clientId]/dms/layout.tsx` - Server layout with children
- `apps/frontend/app/layout.tsx` - Root layout with children

**Benefits:**

- ✅ Maintains proper Next.js 16 server/client boundaries
- ✅ Preserves server-side data fetching and prefetching
- ✅ Enables client-side interactivity (useState, useEffect, event handlers)
- ✅ Type-safe with TypeScript
- ✅ Clear separation of concerns

**Anti-Pattern: Direct Import (DON'T DO THIS)**

```typescript
// ❌ BAD: Client component importing server component
"use client";
import { HomeNavServer } from "@/components/HomeNav/HomeNavServer"; // ❌ ERROR!

export function ClientComp() {
  return <HomeNavServer />; // ❌ Build error: needs 'next/headers'
}
```

```typescript
// ✅ GOOD: Use slot pattern instead
// Server component (page.tsx)
const Page = async () => {
  return <ClientComp sidebar={<HomeNavServer />} />;
};

// Client component
"use client";
interface Props { sidebar: React.ReactNode; }
export function ClientComp({ sidebar }: Props) {
  return <div>{sidebar}</div>;
}
```

---

## tRPC Architecture

### Router Organization

From `apps/frontend/app/api/trpc/router.ts`:

```typescript
import {createTRPCRouter} from '@/app/lib/router/trpc'
import {userRouter} from './routers/user'
import {teamRouter} from './routers/team'
import {conversationsRouter} from './routers/conversations'
import {chatRouter} from './routers/chat'
// ... more routers

export const appRouter = createTRPCRouter({
	users: userRouter, // users.* endpoints
	team: teamRouter, // team.* endpoints
	conversations: conversationsRouter, // conversations.* endpoints
	chat: chatRouter, // chat.* endpoints
	reactions: reactionRouter, // reactions.* endpoints
	stars: starRouter, // stars.* endpoints
	pins: pinRouter, // pins.* endpoints
	files: fileRouter, // files.* endpoints
	bookmarks: bookmarkRouter, // bookmarks.* endpoints
	search: searchRouter, // search.* endpoints
	reminders: reminderRouter, // reminders.* endpoints
	usergroups: usergroupRouter, // usergroups.* endpoints
	admin: adminRouter // admin.* endpoints
})

export type AppRouter = typeof appRouter
```

### tRPC Procedures

**Public Procedure (no auth required):**

```typescript
import {publicProcedure, createTRPCRouter} from '@/app/lib/router/trpc'
import {z} from 'zod'

export const teamRouter = createTRPCRouter({
	info: publicProcedure.input(z.object({team_id: z.string()})).query(async ({input}) => {
		const team = await prisma.team.findFirst({where: {id: input.team_id, deleted: false}})

		if (!team) {
			throw new TRPCError({code: 'NOT_FOUND', message: 'team_not_found'})
		}

		return team
	})
})
```

**Protected Procedure (auth required):**

```typescript
import {protectedProcedure, createTRPCRouter} from '@/app/lib/router/trpc'
import {z} from 'zod'

export const chatRouter = createTRPCRouter({
	postMessage: protectedProcedure
		.input(z.object({channel: z.string(), text: z.string(), thread_ts: z.string().optional()}))
		.mutation(async ({ctx, input}) => {
			// ctx.userId is guaranteed to be non-null in protectedProcedure

			const message = await prisma.message.create({
				data: {
					conversation_id: input.channel,
					user_id: ctx.userId,
					content: input.text,
					parent_message_id: input.thread_ts
				},
				include: {user: true, reactions: true}
			})

			return {ok: true, message}
		})
})
```

### tRPC Context and Authentication

From `apps/frontend/app/lib/router/trpc.ts`:

```typescript
export const createTRPCContext = async (opts: {headers?: Headers} = {}) => {
	const headers = opts.headers
	let userId: string | null = null
	let teamId: string | null = null

	// Extract token from Authorization or x-slack-token header
	const authHeader = headers?.get('authorization')
	const slackToken = headers?.get('x-slack-token')
	const token = authHeader?.replace('Bearer ', '') ?? slackToken

	if (token) {
		// Validate token against ApiToken table
		const apiToken = await prisma.apiToken.findUnique({
			where: {token},
			select: {user_id: true, expires_at: true, user: {select: {team_memberships: {select: {team_id: true}, take: 1}}}}
		})

		if (apiToken && (!apiToken.expires_at || apiToken.expires_at > new Date())) {
			userId = apiToken.user_id
			teamId = apiToken.user.team_memberships[0]?.team_id ?? null
		}
	}

	return {headers: opts.headers, userId, teamId} as const
}

// Protected procedure enforces authentication
export const protectedProcedure = t.procedure.use(({ctx, next}) => {
	if (!ctx.userId) {
		throw new TRPCError({code: 'UNAUTHORIZED', message: 'not_authed'})
	}

	return next({ctx: {userId: ctx.userId, teamId: ctx.teamId ?? ''}})
})
```

### OpenAPI Generation

tRPC routers automatically generate REST endpoints:

```typescript
// apps/frontend/app/api/[...openapi]/route.ts
import {appRouter} from '@/app/api/trpc/router'
import {createOpenApiNextHandler} from 'trpc-to-openapi'

export const {GET, POST, PUT, DELETE} = createOpenApiNextHandler({router: appRouter, createContext: createTRPCContext})
```

Access at:

- API Docs: `http://localhost:80/api-docs`
- OpenAPI Spec: `http://localhost:80/api/openapi.json`

---

## Health Check Endpoint

**Location:** `apps/frontend/app/api/health/route.ts`

**Purpose:** Validates database has required data (AppConfiguration, User, Team, TeamMember, ApiToken, Conversation, ConversationMember).

**Response:** Always returns 200. Check `healthy` boolean and `database.valid` for status. Returns `database.missing` object with details when unhealthy.

**Docker HEALTHCHECK:** Configured in Dockerfile to query `/api/health` every 30s. Container reports unhealthy when database missing required data.

**Usage:** `curl http://localhost:80/api/health`

---

## Docker Deployment

### Single Container Architecture

The application runs in a single Docker container with embedded SQLite database (better-sqlite3 adapter).

From `Dockerfile`:

```dockerfile
# Multi-stage build
FROM node:22-slim AS builder
# Build stage: Install deps, build Next.js app

FROM node:22-slim AS runner
# Runtime stage: Copy build, run migrations, start server
EXPOSE 80
CMD ["sh", "-c", "pnpm prisma:migrate && pnpm prisma:seed && pnpm start"]
```

**Development Workflow:**

```bash
# Build Docker image
docker buildx build --load -t shack:latest .

# Run container
docker run -d \
  --name shack_app \
  -p 80:80 \
  shack:latest

# View logs
docker logs -f shack_app

# Access points:
# - Web UI: http://localhost:80
```

---

## Monorepo Structure

### Workspace Organization

```
shack/
├── apps/
│   ├── frontend/              # Next.js 16 app
│       ├── app/               # App Router pages
│       │   ├── api/trpc/      # tRPC routers
│       │   ├── client/        # Client pages
│       │   └── lib/           # Shared utilities
│       ├── components/        # React components
│       ├── prisma/            # Database schema
│       └── package.json
│
├── packages/
│   └── constants/             # Shared constants
│       ├── src/index.ts
│       └── package.json
├── tools/
│   ├── eslint/                # Shared ESLint config
│   ├── prettier/              # Shared Prettier config
│   ├── tailwind/              # Shared Tailwind config
│   └── tsconfig/              # Shared TypeScript config
└── turbo.json                 # Turborepo configuration
```

### Importing Workspace Packages

```typescript
// ✅ GOOD: Workspace alias
import {CULTURAL_INTERVIEW_CONSTANT} from '@openai/constants'

// ✅ GOOD: Internal imports
import prisma from '@/app/lib/prisma'
import {api} from '@/app/lib/router/react'

// ❌ BAD: Relative paths
import {CONSTANT} from '../../../packages/constants'
```

---

## Error Handling

### tRPC Error Responses

```typescript
import {TRPCError} from '@trpc/server'

export const teamRouter = createTRPCRouter({
	create: protectedProcedure.input(z.object({name: z.string()})).mutation(async ({ctx, input}) => {
		// Authorization check
		if (!canCreateTeam(ctx.userId)) {
			throw new TRPCError({code: 'FORBIDDEN', message: 'insufficient_permissions'})
		}

		// Validation error
		if (input.name.length < 3) {
			throw new TRPCError({code: 'BAD_REQUEST', message: 'name_too_short'})
		}

		try {
			return await prisma.team.create({data: {name: input.name}})
		} catch (error) {
			throw new TRPCError({code: 'INTERNAL_SERVER_ERROR', message: 'team_creation_failed', cause: error})
		}
	})
})
```

### Error Boundaries

```typescript
// app/error.tsx
'use client';

import { useEffect } from 'react';

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error('Page error:', error);
  }, [error]);

  return (
    <div>
      <h2>Something went wrong!</h2>
      <button onClick={reset}>Try again</button>
    </div>
  );
}
```

---

## Anti-Patterns

### Don't: Use Server Actions (use tRPC instead)

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

### Don't: Skip Authentication

```typescript
// ❌ BAD: No auth check
export const userRouter = createTRPCRouter({
	delete: publicProcedure.input(z.object({id: z.string()})).mutation(async ({input}) => {
		await prisma.user.delete({where: {id: input.id}})
	})
})

// ✅ GOOD: Protected procedure
export const userRouter = createTRPCRouter({
	delete: protectedProcedure.input(z.object({id: z.string()})).mutation(async ({ctx, input}) => {
		// Verify user can delete this user
		if (ctx.userId !== input.id) {
			throw new TRPCError({code: 'FORBIDDEN'})
		}

		await prisma.user.delete({where: {id: input.id}})
	})
})
```

---

## Related Documentation

- [tRPC Documentation](https://trpc.io/docs)
- [Next.js 16 Documentation](https://nextjs.org/docs)
- [Turborepo Documentation](https://turbo.build/repo/docs)
- `PRODUCT.md` - Complete product scope and features
- `{agent_directory}/{rules_directory}/code-quality.md` - Code quality standards
- `{agent_directory}/{rules_directory}/database.md` - Database patterns
- `{agent_directory}/{rules_directory}/security.md` - Security patterns
