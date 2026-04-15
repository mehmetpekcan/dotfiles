---
targets:
  - '*'
root: false
description: Types best practices and patterns
globs:
  - '**/*'
cursor:
  description: Types best practices and patterns
  globs:
    - '**/*'
---

## Type Definition Principles

- **ALWAYS define interfaces and types OUTSIDE function/component declarations**
- Keep type definitions in the SAME FILE as the component/function that uses them
- **NEVER create separate `types.ts` files** unless the types are shared across multiple files
- Use descriptive names that clearly indicate the purpose

## Type Preference Hierarchy

Follow this strict hierarchy to avoid duplication:

1. **First: API response types** - use types from your API layer (e.g., tRPC RouterOutputs if using tRPC)
   - Use `OkType<RouterOutputs[...]>` for Slack API-compatible union responses
   - Use `RouterOutputs["router"]["procedure"]` for direct procedure outputs
2. **Second: Zod schemas** - for validation and input types
3. **Third: Database types** - from Prisma or your database client
4. **Last: Custom types** - only when absolutely necessary

Use `Pick`, `Omit`, `Partial`, `OkType`, and other utility types to derive from existing types instead of creating duplicates.

## GOOD Examples

**Using API response types:**

```tsx
// If using tRPC
import type {RouterOutputs, OkType} from '@/app/lib/router/react'

// Extract full response type
type ChannelsData = RouterOutputs['conversations']['list']
type SingleChannel = RouterOutputs['conversations']['info']

// For Slack API-compatible responses that return unions with ok: boolean
// Use OkType to extract the { ok: true } variant
type UserInfo = OkType<RouterOutputs['users']['info']>
// UserInfo is now { ok: true, user: SlackUserSchema } (not the union)

// Access nested properties from the ok variant
type User = OkType<RouterOutputs['users']['info']>['user']

interface ChannelsListProps {
	data: ChannelsData
}

// If using a different API layer, define response types from your API
type ChannelsResponse = Awaited<ReturnType<typeof fetchChannels>>
```

**Using OkType for Slack API-compatible responses:**

Many tRPC procedures return Slack API-compatible responses with union types:

```tsx
// tRPC procedure output schema
z.union([z.object({ok: z.literal(true), user: SlackUserSchema}), z.object({ok: z.literal(false), error: z.string()})])
```

Use `OkType` to extract only the successful response variant:

```tsx
import type {OkType, RouterOutputs} from '@/app/lib/router/react'

// Extract the successful variant
type SuccessfulUserInfo = OkType<RouterOutputs['users']['info']>
// Type: { ok: true, user: SlackUserSchema }

// Access nested properties safely
function getCreatorDisplayName(creator: OkType<RouterOutputs['users']['info']>['user']) {
	return creator.profile.display_name ?? creator.real_name ?? 'Unknown'
}
```

**Real example from codebase:**

```31:37:apps/frontend/app/lib/router/react.tsx
/**
 * Inference helper for outputs that are ok. Use this on APIs that return a
 * union of responses including z.object({ ok: z.literal(true), ... }).
 *
 * @example type User = OkType<RouterOutputs['users']['info']>
 */
export type OkType<T extends { ok: boolean }> = Extract<T, { ok: true }>;
```

```78:87:apps/frontend/components/ChatMessageHeader/ChannelChatMessageHeader.tsx
function getCreatorDisplayName(
  creator: OkType<RouterOutputs["users"]["info"]>["user"]
) {
  return (
    creator.profile.display_name ??
    creator.real_name ??
    creator.name ??
    "Unknown"
  );
}
```

**Using Zod for input validation:**

```tsx
// In components
import type {MessageInput} from '@/schemas/message'

// In schemas/message.ts or app/lib/schemas/message.ts
export const messageSchema = z.object({
	content: z.string().min(1).max(2000),
	channelId: z.string(),
	mentions: z.array(z.string()).optional()
})

export type MessageInput = z.infer<typeof messageSchema>

interface MessageFormProps {
	initialData?: Partial<MessageInput>
	onSubmit: (data: MessageInput) => void
}
```

**Deriving from Prisma types:**

```tsx
import type {Channel, Message, User} from '@prisma/client'

// Extend with relations
type ChannelWithMessages = Channel & {messages: Message[]}

// Pick specific fields
type ChannelSummary = Pick<Channel, 'id' | 'name' | 'isPrivate'>

// Omit auto-generated fields for create operations
type CreateChannelData = Omit<Channel, 'id' | 'createdAt' | 'updatedAt'>
```

## BAD Examples

```tsx
// Don't duplicate existing types
interface MessageData {
  content: string;
  channelId: string;
  userId: string;
} // BAD: This duplicates MessageInput from schema

// Don't use z.infer outside schemas folder/files
const messageSchema = z.object({...});
type MessageInput = z.infer<typeof messageSchema>; // BAD: Define in schema file

// Don't create custom types when API types exist
interface ChannelListResponse {
  channels: Array<{
    id: string;
    name: string;
    isPrivate: boolean;
  }>;
} // BAD: Use API response type or derive from Prisma types
```

## Type Derivation Best Practices

- **Use utility types** (`Pick`, `Omit`, `Partial`, `Required`) to modify existing types
- **Compose types** using intersections (`&`) and unions (`|`)
- **Extract common patterns** into reusable type utilities
- **Only create z.infer types in the schemas folder** - import them elsewhere

**Advanced Examples:**

```tsx
// Utility type composition
type CreateChannelInput = Pick<Channel, 'name' | 'description'> & {workspaceId: string; creatorId: string}

// Conditional type derivation
type UserProfileData = User extends {password: infer P} ? Omit<User, 'password'> & {hasPassword: boolean} : User

// Extract nested types from API responses
type MessageStatus = Channel['messages'][number]['status']
type ChannelMember = Channel['members'][number]
```

## Component Type Patterns

**GOOD Type Definitions:**

```tsx
// Types defined outside, colocated with usage
interface ChannelFormData {
	name: string
	description: string
	isPrivate: boolean
}

interface ChannelFormProps {
	initialData?: ChannelFormData
	onSubmit: (data: ChannelFormData) => void
	isLoading?: boolean
}

function ChannelForm({initialData, onSubmit, isLoading}: ChannelFormProps) {
	// Component implementation
}
```

**Function Type Patterns:**

```tsx
// Function with separate type definition
type ProcessPaymentParams = {amount: number; currency: string; paymentMethodId: string}

type PaymentResult = {success: boolean; transactionId?: string; error?: string}

async function processPayment(params: ProcessPaymentParams): Promise<PaymentResult> {
	// Function implementation
}
```

## Type Safety Best Practices

- **Use strict TypeScript configuration**
- **Avoid `any` type** - use `unknown` for truly unknown types
- **Use type assertions sparingly** and only when necessary
- **Leverage TypeScript's type inference** where possible
- **Create type guards** for runtime type checking

**Type Guard Example:**

```tsx
function isUser(obj: unknown): obj is User {
	/** ... **/
}
```

## Common Type Utilities

Create reusable type utilities for common patterns:

```tsx
// Utility for making specific fields optional
type Optional<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>

// Utility for creating form data types
type FormData<T> = Omit<T, 'id' | 'createdAt' | 'updatedAt'>

// Utility for API response wrapping
type ApiResponse<T> = {data: T; success: boolean; error?: string}
```

## Project-Specific Type Utilities

### RouterOutputs

Inferred type from tRPC AppRouter for all procedure outputs:

```tsx
import type {RouterOutputs} from '@/app/lib/router/react'

// Access any procedure output type
type UserList = RouterOutputs['users']['list']
type ChannelInfo = RouterOutputs['conversations']['info']
type MessageHistory = RouterOutputs['conversations']['history']

// Extract nested array element types
type User = RouterOutputs['users']['list']['members'][number]
type Channel = RouterOutputs['conversations']['list']['channels'][number]
```

**Location:** `apps/frontend/app/lib/router/react.tsx`

### OkType

Extracts the `{ ok: true }` variant from union types returned by Slack API-compatible tRPC procedures.

**When to use:**

- When a tRPC procedure returns a union with `ok: z.literal(true)` and `ok: z.literal(false)` variants
- When you need to access properties that only exist on the successful response
- For type-safe access to nested properties in successful responses

**Usage:**

```tsx
import type {OkType, RouterOutputs} from '@/app/lib/router/react'

// Extract successful response variant
type SuccessfulUserInfo = OkType<RouterOutputs['users']['info']>
// Type: { ok: true, user: SlackUserSchema }

// Access nested properties
type User = OkType<RouterOutputs['users']['info']>['user']

// Use in function parameters
function processUser(user: OkType<RouterOutputs['users']['info']>['user']) {
	// TypeScript knows user has all properties from successful response
	return user.profile.display_name
}
```

**Location:** `apps/frontend/app/lib/router/react.tsx`

**Real examples:**

- `apps/frontend/components/ChatMessageHeader/ChannelChatMessageHeader.tsx:79` - Extracting user type from users.info response
