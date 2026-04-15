---
targets:
  - '*'
root: false
description: React component best practices
globs:
  - '**/*'
cursor:
  description: React component best practices
  globs:
    - '**/*'
---

## Component Structure

- Always write clear, readable, and idiomatic React and TypeScript code
- Use TypeScript for all new components
- Never use `forwardRef`; React 19 passes refs automatically
- Avoid `useEffect` unless absolutely necessary; see https://react.dev/learn/you-might-not-need-an-effect
- **Colocated data fetching:** Components should fetch their own data, not receive pre-processed query results
- **Minimal props:** Pass filters/IDs down, not processed data

## Type Definitions

- Follow the comprehensive type definition guidelines in the **typescript-types** rule
- **ALWAYS define interfaces and types OUTSIDE function/component declarations**
- Keep type definitions in the SAME FILE as the component that uses them

**GOOD Example:**

```tsx
// Types defined outside, colocated with usage
interface UserFormProps {
	initialData?: UserFormData
	onSubmit: (data: UserFormData) => void
	isLoading?: boolean
}

function UserForm({initialData, onSubmit, isLoading}: UserFormProps) {
	// Component implementation
}
```

## Performance and State Management

- Follow the comprehensive performance and state management guidelines in the **react-hooks** rule
- **Avoid storing derived state**; compute it during render
- Keep state as local as possible to minimize re-renders
- Avoid unnecessary O(n) loops and expensive operations in render functions

## Data Fetching Patterns

Components should be responsible for their own data needs.

```tsx
// ✅ GOOD: Component fetches its own data
function UserList({searchQuery}: {searchQuery: string}) {
	const {searchResults} = useSearchResults({searchQuery, includedTypes: ['user']})
	return (
		<div>
			{searchResults.map(u => (
				<User key={u.id} {...u} />
			))}
		</div>
	)
}

// ❌ BAD: Parent processes and passes down
function SearchPage() {
	const {searchResults} = useSearchResults({searchQuery})
	const users = searchResults.filter(r => r.type === 'user')
	return <UserList users={users} /> // Prop drilling processed data
}
```

## Code Style

- Use early returns to avoid deeply nested conditionals
- Prefer ES6+ syntax
- Add explanatory comments for obscure or complex code, focusing on the "why" rather than the "what"
- Never leave TODOs, placeholders, or incomplete work
