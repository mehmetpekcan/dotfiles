---
targets:
  - '*'
root: false
description: React hooks best practices and patterns
globs:
  - '**/*'
cursor:
  description: React hooks best practices and patterns
  globs:
    - '**/*'
---

## General Hooks Principles

- **Avoid useEffect unless absolutely necessary**; see https://react.dev/learn/you-might-not-need-an-effect
- **Use early returns** to avoid nested conditionals
- **Keep hooks simple and focused** on a single responsibility
- **Follow the Rules of Hooks** - only call hooks at the top level

## Custom Hooks Best Practices

### Hook Naming

- **Use descriptive names** that clearly indicate what the hook does
- **Be consistent** with naming patterns across the codebase

### Hook Structure

```typescript
// GOOD: Simple, focused custom hook
function useUser(userId: string) {
	const user = use(fetchUser(userId)) // Using React 19's `use` hook

	return {user, isAdmin: user.role === 'admin', displayName: user.name || user.email}
}

// BAD: Hook doing too many things
function useUserData(userId: string) {
	const user = use(fetchUser(userId))
	const posts = use(fetchUserPosts(userId))
	const comments = use(fetchUserComments(userId))
	const followers = use(fetchUserFollowers(userId))

	// Complex logic mixing multiple concerns - split into separate hooks
	return {user, posts, comments, followers}
}
```

## State Management with Hooks

### Avoid Storing Derived State

**GOOD Example:**

```typescript
function useShoppingCart(items: CartItem[]) {
	// Calculate derived state during render, don't store it
	const totalPrice = items.reduce((sum, item) => sum + item.price, 0)
	const itemCount = items.length
	const isEmpty = itemCount === 0

	return {items, totalPrice, itemCount, isEmpty}
}
```

**BAD Example:**

```typescript
function useShoppingCart(items: CartItem[]) {
	const [totalPrice, setTotalPrice] = useState(0)
	const [itemCount, setItemCount] = useState(0)
	const [isEmpty, setIsEmpty] = useState(true)

	// Don't use useEffect for derived state
	useEffect(() => {
		setTotalPrice(items.reduce((sum, item) => sum + item.price, 0))
		setItemCount(items.length)
		setIsEmpty(items.length === 0)
	}, [items])

	return {items, totalPrice, itemCount, isEmpty}
}
```

### Local State Management

- **Keep state as local as possible** to minimize re-renders
- **Use useState for simple state**
- **Use useReducer for complex state logic**
- **Use context sparingly** and only for truly global state

## Performance Optimization

### Avoid Unnecessary Memoization

**GOOD Example (No memoization needed):**

```typescript
function useUserProfile(userId: string) {
	const [user] = api.users.getById.useSuspenseQuery({userId})

	// Simple calculations don't need memoization
	const displayName = user.name || user.email
	const isVerified = user.emailVerified && user.phoneVerified

	return {user, displayName, isVerified}
}
```

**GOOD Example (Memoization for complex branching):**

```typescript
function useUserPermissions(user: User, organizationId: string) {
	const permissions = useMemo(() => {
		if (!user.organizations) return []

		const org = user.organizations.find(o => o.id === organizationId)
		if (!org) return []

		if (org.role === 'admin') return ['read', 'write', 'delete', 'admin']
		if (org.role === 'editor') return ['read', 'write']
		if (org.role === 'viewer') return ['read']

		return []
	}, [user.organizations, organizationId])

	return permissions
}
```

### Event Handlers and Callbacks

- **Don't wrap event handlers in useCallback** unless necessary
- **Use event handlers directly** in most cases
- **Only use useCallback** when passing callbacks to optimized components

## Data Fetching with Hooks

### Colocate Data Fetching

Fetch data close to where it's used, not at parent level.

```typescript
// ✅ GOOD: Component fetches its own data
function UserSearchResults({ searchQuery }: { searchQuery: string }) {
  const { searchResults } = useSearchResults({
    searchQuery,
    includedTypes: ['user']
  });
  return <div>{searchResults.map(...)}</div>;
}

// ❌ BAD: Parent fetches and passes down
function SearchPage() {
  const users = useUserSearch(query);
  const channels = useChannelSearch(query);
  const files = useFileSearch(query);
  return <UserResults users={users} />; // Prop drilling
}
```

### Share Logic with Custom Hooks

Extract reusable data fetching logic into shared hooks.

```typescript
// ✅ GOOD: Shared hook eliminates duplication
function useSearchResults({searchQuery, includedTypes}) {
	const [results] = api.search.all.useSuspenseQuery({query: searchQuery})
	return useMemo(() => filterByType(results, includedTypes), [results, includedTypes])
}

// Multiple components use same hook
function SearchBar() {
	const {searchResults} = useSearchResults({searchQuery, includedTypes: ['user']})
}
function SearchPage() {
	const {searchResults} = useSearchResults({searchQuery, includedTypes: []})
}
```

### Pass Filters, Not Processed Results

Pass search text/filters down, let components fetch their own data.

```typescript
// ✅ GOOD: Pass search query, component fetches
<SearchResults searchQuery={query} filterValue="users" />

// ❌ BAD: Process and pass results down
<SearchResults results={filteredResults} />
```

### Prefer Suspense-Compatible Patterns

**GOOD Example:**

```typescript
// Using React's `use` hook for Suspense support
function useChannelMessages(channelId: string) {
	const messages = use(fetchChannelMessages(channelId))

	return {messages, count: messages.length, hasMessages: messages.length > 0}
}

// Or with a library that supports Suspense
function useChannelMessages(channelId: string) {
	const {data: messages} = useSuspenseQuery({
		queryKey: ['messages', channelId],
		queryFn: () => fetchChannelMessages(channelId)
	})

	return {messages, count: messages.length, hasMessages: messages.length > 0}
}
```

**BAD Example:**

```typescript
// Manually handling loading and error states
function useChannelMessages(channelId: string) {
	const {data, isLoading, error} = useQuery({
		queryKey: ['messages', channelId],
		queryFn: () => fetchChannelMessages(channelId)
	})

	if (isLoading) return {loading: true}
	if (error) return {error}

	return {messages: data ?? [], count: data?.length ?? 0, hasMessages: (data?.length ?? 0) > 0}
}
```

### Prefetching for Performance

Use aggressive prefetching when user intent is clear.

```typescript
// ✅ GOOD: Prefetch on input focus (clear intent)
function SearchBar() {
  const queryClient = useQueryClient();

  const handleFocus = () => {
    queryClient.prefetchQuery({
      queryKey: ['search', 'all'],
      queryFn: () => api.search.all.query({ query: '' })
    });
  };

  return <input onFocus={handleFocus} />;
}

// ✅ GOOD: Prefetch on hover for likely navigation
<Link
  href={url}
  onMouseEnter={() => queryClient.prefetchQuery(['channel', id])}
>
  Channel
</Link>
```

### Mutation Hooks

```typescript
function useCreateChannel() {
	const queryClient = useQueryClient()

	return useMutation({
		mutationFn: createChannel,
		onSuccess: newChannel => {
			// Invalidate and refetch related queries
			queryClient.invalidateQueries({queryKey: ['channels']})

			showToast({title: 'Channel created', description: `#${newChannel.name} is ready to use`, variant: 'success'})
		},
		onError: error => {
			// Handle known errors with specific messages
			if (error instanceof DuplicateChannelError) {
				showToast({
					title: 'Channel already exists',
					description: 'Please choose a different name',
					variant: 'destructive'
				})
				return
			}

			// Log unexpected errors
			console.error('Failed to create channel:', error)

			showToast({title: 'Failed to create channel', description: 'Please try again', variant: 'destructive'})
		}
	})
}
```

## Form Handling with Hooks

### React Hook Form Integration

```typescript
import {z} from 'zod'
import {useForm} from 'react-hook-form'
import {zodResolver} from '@hookform/resolvers/zod'

const channelSchema = z.object({
	name: z
		.string()
		.min(1)
		.max(80)
		.regex(/^[a-z0-9-_]+$/),
	description: z.string().max(250).optional(),
	isPrivate: z.boolean().default(false)
})

type ChannelFormData = z.infer<typeof channelSchema>

function useChannelForm(initialData?: Partial<ChannelFormData>) {
	const form = useForm<ChannelFormData>({
		resolver: zodResolver(channelSchema),
		defaultValues: {
			name: initialData?.name ?? '',
			description: initialData?.description ?? '',
			isPrivate: initialData?.isPrivate ?? false
		}
	})

	const createChannel = useCreateChannel()

	const handleSubmit = form.handleSubmit(async data => {
		try {
			await createChannel.mutateAsync(data)
			form.reset()
		} catch (error) {
			// Error handling is done in the mutation
		}
	})

	return {form, handleSubmit, isSubmitting: createChannel.isPending}
}
```

## Common Anti-Patterns to Avoid

### Don't Use useEffect for Derived State

```typescript
// BAD: Using useEffect for derived state
function useUserDisplay(user: User) {
	const [displayName, setDisplayName] = useState('')

	useEffect(() => {
		setDisplayName(user.name || user.email)
	}, [user])

	return displayName
}

// GOOD: Calculate during render
function useUserDisplay(user: User) {
	return user.name || user.email
}
```

## Best Practices Summary

1. **Keep hooks simple and focused** on a single responsibility
2. **Use early returns** to avoid nested conditionals
3. **Calculate derived state during render** instead of storing it
4. **Use suspense queries** for all data fetching
5. **Handle errors appropriately** in mutation hooks
6. **Follow naming conventions** (always start with "use")
7. **Avoid unnecessary memoization** unless there's a clear performance benefit
