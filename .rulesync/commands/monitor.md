---
targets:
  - '*'
description: ''
---

# MONITOR Task

**Persona:** Execute this task as the `@developer` subagent (Devin, Staff Engineer 💻).  
Load the persona characteristics from `~/.rulesync/subagents/developer.md` before proceeding.

**Required Context:** Review these rules before proceeding:

- `~/.rulesync/rules/code-quality.md` - Logging standards and error handling patterns
- `~/.rulesync/rules/security.md` - Security considerations for logging
- `~/.rulesync/rules/architecture.md` - tRPC procedures and component patterns

---

## Task Objective

Add comprehensive structured logging and error tracking to code to improve observability, debugging, and monitoring in production.

---

## Task Instructions

1. **Ask discovery questions:**
   1. "What code should I add monitoring to?" (file path, function, or feature)
   2. "What level of monitoring is needed?" (basic logging, detailed tracing, error tracking)
   3. "Are there specific error scenarios we need to track?"
   4. "Should I add error boundaries for frontend components?"

2. **Review existing monitoring patterns:**
   - Check how console.log and console.error are used in the codebase
   - Review error handling in tRPC procedures
   - Examine existing TRPCError patterns

3. **Add structured logging:**

   **For tRPC Procedures:**

   ```typescript
   import {protectedProcedure, createTRPCRouter} from '@/app/lib/router/trpc'
   import {TRPCError} from '@trpc/server'
   import {z} from 'zod'
   import prisma from '@/app/lib/prisma'

   export const chatRouter = createTRPCRouter({
   	postMessage: protectedProcedure
   		.input(z.object({channel: z.string(), text: z.string()}))
   		.mutation(async ({ctx, input}) => {
   			console.log('[chat.postMessage] Starting', {
   				userId: ctx.userId,
   				channelId: input.channel,
   				textLength: input.text.length
   			})

   			try {
   				const message = await prisma.message.create({
   					data: {conversation_id: input.channel, user_id: ctx.userId, content: input.text}
   				})

   				console.log('[chat.postMessage] Success', {messageId: message.id, channelId: input.channel})

   				return {ok: true, message}
   			} catch (error) {
   				console.error('[chat.postMessage] Failed', {
   					error: error instanceof Error ? error.message : 'Unknown error',
   					userId: ctx.userId,
   					channelId: input.channel
   				})

   				throw new TRPCError({code: 'INTERNAL_SERVER_ERROR', message: 'message_post_failed', cause: error})
   			}
   		})
   })
   ```

4. **Add error boundaries for React components:**

   **Create error boundary component:**

   ```typescript
   'use client';

   import { Component, type ReactNode } from 'react';

   interface Props {
     children: ReactNode;
     fallback?: ReactNode;
     name: string;
   }

   interface State {
     hasError: boolean;
     error?: Error;
   }

   export class ErrorBoundary extends Component<Props, State> {
     constructor(props: Props) {
       super(props);
       this.state = { hasError: false };
     }

     static getDerivedStateFromError(error: Error): State {
       return { hasError: true, error };
     }

     componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
       console.error('[ErrorBoundary] Component error caught', {
         component: this.props.name,
         error: error.message,
         stack: error.stack,
         componentStack: errorInfo.componentStack,
       });
     }

     render() {
       if (this.state.hasError) {
         return this.props.fallback || (
           <div>Something went wrong. Please try again.</div>
         );
       }

       return this.props.children;
     }
   }
   ```

   **Use in components:**

   ```typescript
   export function FeaturePage() {
     return (
       <ErrorBoundary name="FeaturePage" fallback={<ErrorFallback />}>
         <FeatureContent />
       </ErrorBoundary>
     );
   }
   ```

5. **Use TRPCError for API errors:**

   Use TRPCError for consistent error responses:

   ```typescript
   import {TRPCError} from '@trpc/server'

   // Channel not found
   throw new TRPCError({code: 'NOT_FOUND', message: 'channel_not_found'})

   // User not authorized
   throw new TRPCError({code: 'FORBIDDEN', message: 'not_in_channel'})

   // Validation error
   throw new TRPCError({code: 'BAD_REQUEST', message: 'invalid_channel_name'})

   // Internal error
   throw new TRPCError({code: 'INTERNAL_SERVER_ERROR', message: 'operation_failed', cause: originalError})
   ```

6. **Add logging at key points:**

   Log at these critical moments:
   - ✅ Procedure entry (with input parameters)
   - ✅ Database operations
   - ✅ Business logic decisions
   - ✅ Errors and exceptions
   - ✅ Procedure exit (with results)

7. **Follow security best practices:**
   - ❌ Never log passwords, API tokens
   - ✅ Be cautious with user data in logs
   - ✅ Log error codes, not sensitive error details
   - ✅ Use structured logging (JSON objects) for easy parsing

8. **Add performance monitoring:**

   Track execution time for slow operations:

   ```typescript
   const startTime = Date.now()

   try {
   	const result = await slowOperation()
   	const duration = Date.now() - startTime

   	console.log('[Operation] Completed', {operation: 'slowOperation', duration, ...(duration > 1000 && {slow: true})})

   	return result
   } catch (error) {
   	console.error('[Operation] Failed', {
   		operation: 'slowOperation',
   		duration: Date.now() - startTime,
   		error: error instanceof Error ? error.message : 'Unknown'
   	})
   	throw error
   }
   ```

9. **Test error scenarios:**

   Add tests to verify error handling:

   ```typescript
   import {describe, it, expect} from '@jest/globals'
   import {appRouter} from '@/app/api/trpc/router'
   import {createTestContext} from '@/app/lib/test-helpers'
   import {TRPCError} from '@trpc/server'

   describe('chat.postMessage monitoring', () => {
   	it('should handle errors correctly', async () => {
   		const caller = appRouter.createCaller(await createTestContext({userId: 'user_123', teamId: 'team_456'}))

   		// Test error scenario
   		await expect(caller.chat.postMessage({channel: 'invalid_channel', text: 'Hello'})).rejects.toThrow(TRPCError)
   	})

   	it('should succeed with valid input', async () => {
   		const caller = appRouter.createCaller(await createTestContext({userId: 'user_123', teamId: 'team_456'}))

   		const result = await caller.chat.postMessage({channel: 'valid_channel', text: 'Hello'})

   		expect(result.ok).toBe(true)
   		expect(result.message).toBeDefined()
   	})
   })
   ```

10. **Run quality checks:**

    ```bash
    pnpm lint
    pnpm typecheck
    pnpm test
    ```

11. **Provide summary:**
    - List all functions/components with added monitoring
    - Show example log outputs
    - Highlight error scenarios covered
    - Provide logging query examples for monitoring

---

## Notes

- 💻 Use structured logging (key-value pairs) for easy querying
- 🔒 Be cautious with sensitive data in logs (API tokens, passwords)
- ⚡ Keep logging performant (avoid heavy computations)
- 📊 Log enough context for debugging but not too much noise
- ✅ Test error paths to ensure they're handled correctly
- 🎯 Use consistent log prefixes (e.g., [chat.postMessage])

---

## Logging Levels

Use appropriate console methods:

- **`console.log`:** Normal operations, milestones
- **`console.warn`:** Recoverable issues, deprecations
- **`console.error`:** Errors requiring attention
- **`console.debug`:** Development debugging (remove in production)

---

## Example Output

````markdown
## 🔍 Monitoring Added

### Procedures Instrumented:

1. ✅ `chat.postMessage` - tRPC mutation with full logging
2. ✅ `conversations.create` - Channel creation with monitoring
3. ✅ `conversations.archive` - Channel archival with monitoring

### Error Boundaries Added:

1. ✅ `MessageListPage` - Error boundary with fallback UI
2. ✅ `ChannelSection` - Isolated error handling

### Logging Added:

- Procedure entry/exit with parameters
- Database queries and mutations
- Error scenarios with TRPCError codes
- Performance metrics for slow operations

### Security:

- ✅ API tokens not logged
- ✅ Sensitive user data handled carefully
- ✅ Error messages don't leak sensitive info

### Testing:

- ✅ Unit tests verify logging behavior
- ✅ Error scenarios tested and logged
- ✅ Performance thresholds validated

### Log Analysis:

```bash
# Find errors in Docker logs
docker compose logs frontend | grep ERROR

# Find slow operations
docker compose logs frontend | grep "slow: true"

# Track message failures
docker compose logs frontend | grep "Failed"

# Monitor API requests
docker compose logs frontend | grep "Starting"
```
````
