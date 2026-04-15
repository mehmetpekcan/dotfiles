---
targets:
  - '*'
root: false
description: Integrations best practices and patterns
globs:
  - '**/*'
cursor:
  description: Integrations best practices and patterns
  globs:
    - '**/*'
---

# Integration Rules

## Integration Best Practices

- **Offline-First:** No external API integrations; all functionality is self-contained
- **Local File Storage:** Store uploaded files locally, not in cloud storage
- **Error Handling:** Implement proper error handling and logging
- **Type Safety:** Share types between services using TypeScript
- **Testing:** Test integrations with Docker test environment

---

## File Upload Integration

### Local File Storage

Shack stores files locally, not in cloud storage:

```typescript
import {writeFile} from 'fs/promises'
import {join} from 'path'
import crypto from 'crypto'

export const fileRouter = createTRPCRouter({
	getUploadURLExternal: protectedProcedure
		.input(z.object({filename: z.string(), length: z.number(), alt_text: z.string().optional()}))
		.mutation(async ({ctx, input}) => {
			// Generate upload token
			const uploadUrl = crypto.randomBytes(32).toString('hex')

			// Create file record
			const file = await prisma.file.create({
				data: {
					name: input.filename,
					size: input.length,
					user_id: ctx.userId,
					upload_url: uploadUrl,
					upload_expires: new Date(Date.now() + 60 * 60 * 1000), // 1 hour
					upload_completed: false,
					alt_text: input.alt_text
				}
			})

			return {ok: true, upload_url: `/api/files/upload/${uploadUrl}`, file_id: file.id}
		}),

	completeUploadExternal: protectedProcedure
		.input(z.object({file_id: z.string(), title: z.string().optional()}))
		.mutation(async ({ctx, input}) => {
			const file = await prisma.file.update({
				where: {id: input.file_id, user_id: ctx.userId},
				data: {upload_completed: true, title: input.title, url_private: `/api/files/download/${input.file_id}`}
			})

			return {ok: true, file}
		})
})
```

**File Upload Flow:**

1. Frontend calls `getUploadURLExternal` → gets upload token
2. Frontend uploads file to `/api/files/upload/{token}`
3. Backend saves file to local storage
4. Frontend calls `completeUploadExternal` → marks upload complete
5. File available at `/api/files/download/{file_id}`

---

## Testing Integrations

### File Upload Testing

```typescript
import {describe, it, expect} from '@jest/globals'
import {appRouter} from '@/app/api/trpc/router'
import {createTestContext} from '@/app/lib/test-helpers'

describe('File Upload Integration', () => {
	it('should generate upload URL', async () => {
		const caller = appRouter.createCaller(await createTestContext({userId: 'user_123', teamId: 'team_456'}))

		const result = await caller.files.getUploadURLExternal({filename: 'test.png', length: 1024})

		expect(result.ok).toBe(true)
		expect(result.upload_url).toBeDefined()
		expect(result.file_id).toBeDefined()
	})
})
```

---

## Anti-Patterns

### Don't: Use External APIs

```typescript
// ❌ BAD: External API call (breaks offline-first)
export const userRouter = createTRPCRouter({
	sendEmail: protectedProcedure.input(z.object({to: z.string(), subject: z.string()})).mutation(async ({input}) => {
		await fetch('https://api.sendgrid.com/v3/mail/send', {
			method: 'POST'
			// ... external API call
		})
	})
})

// ✅ GOOD: Mock implementation for offline
export const userRouter = createTRPCRouter({
	sendEmail: protectedProcedure.input(z.object({to: z.string(), subject: z.string()})).mutation(async ({input}) => {
		console.log(`[Mock Email] To: ${input.to}, Subject: ${input.subject}`)
		return {ok: true, message: 'Email sent (mock)'}
	})
})
```

---

## Related Documentation

- [tRPC Documentation](https://trpc.io/docs)
- `{agent_directory}/{rules_directory}/architecture.md` - Architecture patterns
- `{agent_directory}/{rules_directory}/security.md` - Security patterns
