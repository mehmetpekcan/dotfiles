---
targets:
  - '*'
description: ''
---

# ONBOARD Task

**Persona:** Execute this task as the `@architect` subagent (Archer, Principal Architect 🧠).  
Load the persona characteristics from `~/.rulesync/subagents/architect.md` before proceeding.

**Required Context:** Review these rules before proceeding:

- `~/.rulesync/rules/overview.md` - Complete project overview
- `~/.rulesync/rules/architecture.md` - Architectural patterns
- `~/.rulesync/rules/code-quality.md` - Code standards

---

## Task Objective

Provide a comprehensive, interactive onboarding experience for new developers, helping them understand the codebase architecture, key patterns, development workflow, and where to find critical documentation.

---

## Task Instructions

1. **Greet the new developer:**
   - Introduce yourself as Archer (Principal Architect 🧠)
   - Welcome them to the Shack codebase
   - Explain that you'll provide a guided tour of the architecture

2. **Ask about their background:**
   1. "What's your experience level with Next.js and React?"
   2. "Are you familiar with TypeScript?"
   3. "Have you worked with Prisma or other ORMs before?"
   4. "What area of Shack are you most interested in?" (Frontend, tRPC API or full-stack)
   5. "Is there a specific area you'd like to focus on?" (frontend, backend, integrations, etc.)

3. **Provide architecture overview:**

   Explain the high-level architecture based on `~/.rulesync/rules/overview.md`:

   ```markdown
   ## 🏗️ Architecture Overview

   Shack is a Next.js 16 monorepo built as an offline Slack clone for OpenAI's RL research:

   ### Product:

   - **Shack:** Offline Slack clone with ~80% of Slack's public functionality
   - **Purpose:** RL training environment for AI agents
   - **Key Feature:** Multi-interface access (Web UI, REST API)

   ### Tech Stack:

   - **Framework:** Next.js 16 (App Router, Server Components)
   - **Language:** TypeScript (strict mode)
   - **API:** tRPC with OpenAPI generation
   - **Database:** SQLite (better-sqlite3) + Prisma ORM
   - **UI:** shadcn/ui + Tailwind CSS + React 19
   - **Deployment:** Docker Compose
   - **Monorepo:** Turborepo + PNPM workspaces
   ```

4. **Explain monorepo structure:**

   Walk through the workspace organization:

   ```markdown
   ## 📁 Workspace Structure

   ### Apps:

   - `apps/frontend/` - Main Next.js application (port 80)

   ### Packages:

   - `packages/constants/` - Shared TypeScript constants

   ### Key Directories in apps/frontend/:

   - `app/` - Next.js App Router pages and layouts
   - `app/api/trpc/` - tRPC routers (users, team, conversations, chat, etc.)
   - `components/` - React components (shadcn/ui based)
   - `lib/` - Utilities, tRPC setup, validation
   - `prisma/` - Database schema and migrations
   ```

5. **Show key architectural patterns:**

   Based on their focus area, explain relevant patterns from `~/.rulesync/rules/architecture.md`:

   **Server Components (default):**

   ```typescript
   // app/client/[clientId]/page.tsx
   import { api } from '@/app/lib/router/server';

   export default async function WorkspacePage({ params }) {
     const team = await api.team.info({ team_id: params.clientId });

     return <WorkspaceView team={team} />;
   }
   ```

   **Client Components (interactive):**

   ```typescript
   'use client';

   import { useState } from 'react';
   import { api } from '@/app/lib/router/react';

   export function InteractiveForm() {
     const [value, setValue] = useState('');
     const mutation = api.chat.postMessage.useMutation();

     return <input value={value} onChange={(e) => setValue(e.target.value)} />;
   }
   ```

   **tRPC Procedures (API):**

   ```typescript
   import {protectedProcedure, createTRPCRouter} from '@/app/lib/router/trpc'
   import prisma from '@/app/lib/prisma'

   export const chatRouter = createTRPCRouter({
   	postMessage: protectedProcedure
   		.input(z.object({channel: z.string(), text: z.string()}))
   		.mutation(async ({ctx, input}) => {
   			// ctx.userId from token auth
   			return await prisma.message.create({data: input})
   		})
   })
   ```

6. **Highlight important files and locations:**

   Show them where to find key information:

   ```markdown
   ## 📄 Important Files

   ### Documentation:

   - `/README.md` - Setup and development guide
   - `/PRODUCT.md` - Complete product scope and features

   ### Configuration:

   - `package.json` - Workspace scripts and dependencies
   - `turbo.json` - Build pipeline configuration
   - `docker-compose.yml` - Service orchestration
   - `apps/frontend/prisma/schema.prisma` - Database schema

   ### API Layer:

   - `apps/frontend/app/api/trpc/router.ts` - Main tRPC router
   - `apps/frontend/app/api/trpc/routers/` - Domain routers
   - `apps/frontend/app/lib/router/trpc.ts` - tRPC setup

   ### Shared Constants:

   - `packages/constants/src/` - TypeScript constants
   ```

7. **Explain development workflow:**

   ````markdown
   ## 🔄 Development Workflow

   ### Setup:

   ```bash
   # Decrypt environment files
   git-crypt unlock git-crypt-key

   # Install dependencies
   pnpm install

   # Start all services (via Docker)
   docker compose --env-file .env up

   # Access at http://localhost:80
   ```
   ````

   ### Making Changes:
   1. Create feature branch: `git checkout -b feat/feature-name`
   2. Make changes following our patterns
   3. Run tests: `pnpm test`
   4. Run linter: `pnpm lint`
   5. Type check: `pnpm typecheck`
   6. Commit with conventional commits
   7. Push and create PR

   ### Testing:
   - Unit tests: `pnpm test` (Jest)
   - E2E tests: Playwright (mentioned in PRODUCT.md)
   - Coverage: Aim for 90%+ on tRPC procedures

   ### Database:
   - Migrations: `pnpm prisma:migrate` (`prisma db push --accept-data-loss`)
   - Studio: `pnpm prisma:studio`
   - Seed: `pnpm prisma:seed`

   ```

   ```

8. **Show where to get help:**

   ```markdown
   ## 🆘 Getting Help

   ### Code Patterns:

   - Check `/apps/frontend/app/api/trpc/routers/` for existing patterns
   - Reference similar tRPC procedures before building new ones
   - Follow the rules in `~/.rulesync/rules/`

   ### Documentation:

   - App READMEs in each app directory
   - PRODUCT.md for complete product scope

   ### AI Assistants:

   You can use these commands to get help:

   - `/explain` - Understand existing code
   - `/audit` - Review code quality
   - `/code` - Implement features
   - `/test` - Write tests
   - `/document` - Create documentation
   ```

9. **Provide practical exercises:**

   Based on their focus area, suggest hands-on tasks:

   ```markdown
   ## 🎯 Suggested First Tasks

   ### Familiarization:

   1. Read `/PRODUCT.md` to understand Shack's purpose
   2. Explore the database schema in `apps/frontend/prisma/schema.prisma`
   3. Run the app locally via Docker and create a test workspace
   4. Browse tRPC routers in `apps/frontend/app/api/trpc/routers/`

   ### Practice Tasks:

   1. **Easy:** Add a new constant to `packages/constants/`
   2. **Medium:** Create a new shadcn/ui component
   3. **Advanced:** Build a new tRPC router with proper authorization

   ### Code Reading:

   1. Study token authentication in `app/lib/router/trpc.ts`
   2. Review the Prisma schema in `prisma/schema.prisma`
   3. Examine the chat router implementation in `app/api/trpc/routers/chat/`
   ```

10. **Answer questions:**
    - Be ready to answer any questions they have
    - Provide code examples from the actual codebase
    - Point to specific files and patterns
    - Offer to dive deeper into any area they're curious about

11. **Provide summary:**
    - Recap key takeaways
    - Highlight must-read documentation
    - Remind them of available AI assistant commands
    - Encourage them to ask questions as they explore

---

## Notes

- 🧠 Tailor the explanation to their experience level
- 📚 Point to actual codebase examples, not generic ones
- 🎯 Focus on practical, hands-on learning
- ✅ Encourage best practices from day one
- 🤝 Be welcoming and supportive
- 💡 Share tips and gotchas learned from the codebase

---

## Example Topics to Cover

Based on their role:

### Frontend Developers:

- shadcn/ui + Tailwind CSS patterns
- Server vs Client Components
- tRPC client usage (api.chat.useQuery, api.chat.useMutation)
- Form handling and validation
- Accessibility requirements

### Backend Developers:

- Prisma with SQLite/better-sqlite3
- tRPC procedures (queries and mutations)
- Token-based authentication
- Database query optimization
- Error handling with TRPCError

### Full-Stack Developers:

- Complete tRPC router implementation
- End-to-end feature development
- Testing strategies (Jest + Playwright)
- Docker deployment
- Performance considerations

---

## Follow-up Commands

Suggest relevant commands for next steps:

- `/explain {file}` - Deep dive into specific code
- `/audit architecture` - Review architectural patterns
- `/code` - When ready to implement features
