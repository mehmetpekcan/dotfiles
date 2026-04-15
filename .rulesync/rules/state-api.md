---
targets:
  - '*'
root: false
description: State API patterns for E2E test setup and RL environment configuration
globs:
  - '**/state-api/**'
  - '**/api/state/**'
  - '**/*.test.ts'
  - '**/e2e/**'
cursor:
  description: State API patterns for E2E test setup and RL environment configuration
  globs:
    - '**/state-api/**'
    - '**/api/state/**'
    - '**/*.test.ts'
    - '**/e2e/**'
---

# State API Rules

## Overview

The State API (`state-api-library`) provides a standardized REST interface for managing database state. It's designed for:

- **E2E Test Setup** — Quickly establish database state before test runs
- **RL Environment Configuration** — Configure environments for reinforcement learning agents
- **Development Seeding** — Reset and populate databases during development

**Key Documentation:**

- [Adoption Guide](packages/state-api-library/state-api-adoption-guide.md) — Step-by-step integration instructions
- [Package README](packages/state-api-library/README.md) — API reference and architecture

---

## When to Use State API

| Use Case             | Recommended Approach                |
| -------------------- | ----------------------------------- |
| E2E test data setup  | ✅ State API (`POST /api/state`)    |
| RL environment reset | ✅ State API (`DELETE /api/state`)  |
| Development seeding  | ✅ State API or Prisma seed scripts |
| Production data      | ❌ Never use State API              |
| Unit test mocking    | ❌ Use Vitest mocks instead         |

---

## Architecture

### App-Specific Files

The State API requires these app-specific files:

```
lib/
├── state-api-config.ts              # Central configuration
└── state-api-adapters/
    ├── context.ts                   # App-specific context factory
    ├── handlers/                    # Entity handlers
    │   ├── index.ts                 # Handler registry
    │   └── {entity}.handler.ts      # Entity-specific handlers
    ├── types.ts                     # Type definitions
    └── index.ts                     # Re-exports
app/api/state/
├── route.ts                         # Main state endpoint
└── schema/
    └── route.ts                     # OpenAPI schema endpoint
```

### Configuration Pattern

```typescript
// lib/state-api-config.ts
import {createStateApi} from 'state-api-library'
import {prisma} from '@/lib/prisma'
import {handlers, createContext, ctxSchema} from '@/lib/state-api-adapters'
import path from 'path'

const schemaPath = path.join(process.cwd(), 'prisma/schema.prisma')

export const stateApiPromise = createStateApi({
	schemaPath,
	prisma,
	handlers,
	createContext,
	ctxSchema,
	aiInstructions: `
    ## {App Name} State API
    - Entity creation order and constraints
    - Relationship documentation for RL agents
  `,
	auth: {username: process.env.STATE_API_USERNAME ?? 'openai', password: process.env.STATE_API_PASSWORD ?? 'voyager'},
	withTransaction: fn => prisma.$transaction(fn, {timeout: 120000, maxWait: 30000})
})

export async function getStateApi() {
	return stateApiPromise
}
```

---

## Entity Handler Patterns

### Required Handler Structure

Every entity handler must implement:

```typescript
import {z} from 'zod'
import type {EntityHandler} from 'state-api-library'
import type {AppContext} from '../types'

// Schemas for each operation type
const createSchema = z.object({
	id: z.string().uuid()
	// All required fields for creation
})

const updateSchema = z.object({
	id: z.string().uuid()
	// Optional fields for partial updates
})

const deleteSchema = z.object({id: z.string().uuid()})

const outputSchema = z.object({
	// Must match what list() returns
	// Should be compatible with createSchema for GET/POST symmetry
})

export const entityHandler: EntityHandler<AppContext> = {
	createSchema,
	updateSchema,
	deleteSchema,
	outputSchema,

	aiInstructions: `
    ## Entity Documentation
    - Field constraints and formats
    - Relationship dependencies
  `,

	async create(data, ctx) {
		const input = createSchema.parse(data)
		await ctx.db.entity.create({data: input})
	},

	async update(data, ctx) {
		const input = updateSchema.parse(data)
		const {id, ...updates} = input
		await ctx.db.entity.update({where: {id}, data: updates})
	},

	async list(ctx) {
		const entities = await ctx.db.entity.findMany()
		return entities.map(e => ({
			// Transform to POST-compatible format
		}))
	},

	async delete(data, ctx) {
		const input = deleteSchema.parse(data)
		await ctx.db.entity.delete({where: {id: input.id}})
	}
}
```

### Handler Registry

```typescript
// lib/state-api-adapters/handlers/index.ts
import type {EntityHandlerRegistry} from 'state-api-library'
import type {AppContext} from '../types'

import {userHandler} from './user.handler'
import {postHandler} from './post.handler'

// Entity names must match PascalCase (same as Prisma model names)
export const handlers: EntityHandlerRegistry<AppContext> = {User: userHandler, Post: postHandler}
```

---

## API Endpoints

| Method    | Endpoint            | Description                                                      |
| --------- | ------------------- | ---------------------------------------------------------------- |
| `GET`     | `/api/state`        | Retrieve current state in POST-compatible format                 |
| `POST`    | `/api/state`        | Reset database and apply new state                               |
| `PATCH`   | `/api/state`        | Update entities without reset                                    |
| `DELETE`  | `/api/state`        | Reset database (no body) or delete specific entities (with body) |
| `OPTIONS` | `/api/state`        | Get endpoint info and schema                                     |
| `GET`     | `/api/state/schema` | Get OpenAPI 3.1 specification                                    |

### Authentication

All endpoints require HTTP Basic Auth. Default credentials: `openai:voyager`

```bash
curl -u openai:voyager http://localhost:3000/api/state
```

---

## GET/POST Symmetry

**Critical Requirement:** The data returned by `GET /api/state` must be directly usable as input to `POST /api/state`.

```typescript
// 1. GET returns current state
const state = await fetch('/api/state').then(r => r.json())

// 2. POST with same data should recreate identical state
await fetch('/api/state', {method: 'POST', body: JSON.stringify(state)})
```

To ensure symmetry:

1. **`outputSchema`** must match what `list()` returns
2. **`list()`** must return all fields required by `createSchema`
3. **Dates** must be serialized consistently (ISO strings)
4. **Foreign keys** must use the same field names

---

## Foreign Key Dependencies

The library automatically resolves foreign key dependencies using topological sort. However, AI instructions should document the creation order:

```typescript
aiInstructions: `
  ## Creation Order
  1. User (no dependencies)
  2. Workspace (depends on User via ownerId)
  3. Post (depends on User via authorId, Workspace via workspaceId)

  ## Constraint Notes
  - authorId must reference an existing User.id
  - workspaceId must reference an existing Workspace.id
`,
```

---

## Error Handling

State API returns detailed, self-healing error responses:

```json
{
	"ok": false,
	"error": {
		"code": "FOREIGN_KEY_VIOLATION",
		"message": "Referenced entity does not exist",
		"details": [
			{
				"path": "/Post/0/authorId",
				"message": "User with id 'user-999' does not exist",
				"received": "user-999",
				"expected": {"type": "string", "format": "uuid", "suggestions": ["Create User entity first"]}
			}
		]
	}
}
```

### Common Error Codes

| Code                          | Cause                     | Fix                                 |
| ----------------------------- | ------------------------- | ----------------------------------- |
| `VALIDATION_ERROR`            | Invalid JSON Schema       | Check field types and formats       |
| `FOREIGN_KEY_VIOLATION`       | Referenced entity missing | Create parent entities first        |
| `UNIQUE_CONSTRAINT_VIOLATION` | Duplicate value           | Use unique values for unique fields |
| `UNAUTHORIZED`                | Auth failed               | Check Basic Auth credentials        |

---

## E2E Test Integration

Use State API for test data setup:

```typescript
// app/e2e/fixtures/api-helpers.ts
export async function setupTestData(baseUrl: string, data: StatePayload) {
	const response = await fetch(`${baseUrl}/api/state`, {
		method: 'POST',
		headers: {'Content-Type': 'application/json', Authorization: 'Basic ' + btoa('openai:voyager')},
		body: JSON.stringify(data)
	})

	if (!response.ok) {
		const error = await response.json()
		throw new Error(`State API error: ${error.error.message}`)
	}

	return response.json()
}

// app/e2e/specs/feature.spec.ts
test.beforeEach(async () => {
	await setupTestData(baseUrl, {
		User: [{id: 'user-1', email: 'test@example.com', name: 'Test'}],
		Post: [{id: 'post-1', title: 'Test Post', authorId: 'user-1'}]
	})
})
```

---

## Anti-Patterns

### Don't: Skip Handler Validation

```typescript
// ❌ BAD: No schema validation
async create(data, ctx) {
  await ctx.db.entity.create({ data }); // Unvalidated input!
}

// ✅ GOOD: Always validate with schema
async create(data, ctx) {
  const input = createSchema.parse(data);
  await ctx.db.entity.create({ data: input });
}
```

### Don't: Break GET/POST Symmetry

```typescript
// ❌ BAD: list() returns different shape than createSchema expects
async list(ctx) {
  return ctx.db.user.findMany({
    select: { id: true, name: true }, // Missing required fields!
  });
}

// ✅ GOOD: Return all fields needed for create
async list(ctx) {
  const users = await ctx.db.user.findMany();
  return users.map((u) => ({
    id: u.id,
    email: u.email,
    name: u.name,
  }));
}
```

### Don't: Use State API in Production

```typescript
// ❌ BAD: Production data manipulation
if (process.env.NODE_ENV === 'production') {
	await stateApi.applyState(payload) // NEVER DO THIS
}

// ✅ GOOD: Restrict to non-production
if (process.env.NODE_ENV === 'production') {
	throw new Error('State API disabled in production')
}
```

### Don't: Hardcode Entity Order

```typescript
// ❌ BAD: Manual ordering (brittle)
const CREATION_ORDER = ['User', 'Workspace', 'Post']

// ✅ GOOD: Let library resolve from FK relationships
// The library uses topological sort on Prisma schema
```

---

## Troubleshooting

### "Unknown entity type" Error

Entity name in payload doesn't match handler registry:

```typescript
// Payload uses lowercase
{ "user": [...] }

// Registry uses PascalCase
export const handlers = {
  User: userHandler,  // Must match exactly
};
```

### "Foreign key constraint failed" Error

Creating entities in wrong order. Check:

1. Parent entities exist before children
2. Referenced IDs are correct UUIDs
3. `aiInstructions` documents correct creation order

### "Transaction timeout" Error

Large payloads need longer timeouts:

```typescript
withTransaction: (fn) =>
  prisma.$transaction(fn, {
    timeout: 300000,  // 5 minutes
    maxWait: 60000,   // 1 minute
  }),
```

### GET/POST Asymmetry Errors

Your `list()` output doesn't match `createSchema`:

1. Verify `outputSchema` matches `list()` return shape
2. Ensure `list()` returns all fields needed by `createSchema`
3. Check date serialization (use ISO strings)

---

---

## State API CLI

### Overview

The **State API CLI** (`packages/state-api-cli`) is a schema-agnostic conformance testing tool that validates State API implementations. It provides:

- **Property-based testing** with `fast-check` for dynamic test data generation
- **11 generic test suites** covering auth, CRUD, error handling, security, and more
- **Zero entity knowledge** — fetches JSON Schema at runtime and adapts
- **CI/CD integration** — JSON report output for automated testing
- **Extensibility** — Add custom test suites for application-specific entities

### CLI vs. Direct API Calls

| Use Case                          | Recommended Approach           | Rationale                                               |
| --------------------------------- | ------------------------------ | ------------------------------------------------------- |
| **E2E test data setup**           | ✅ Direct API calls (fetch)    | Simpler, fewer dependencies, full control               |
| **State API conformance testing** | ✅ CLI (`pnpm state-api test`) | Comprehensive validation, property-based testing        |
| **CI/CD validation**              | ✅ CLI in GitHub Actions       | Automated conformance checks, JSON reports              |
| **Development testing**           | ✅ Either approach             | Use CLI for thorough validation, direct calls for speed |
| **Custom entity validation**      | ✅ CLI custom suites           | Reusable test infrastructure, type-safe assertions      |

### CLI Installation & Usage

The CLI is included in the template repository:

```bash
# Run all conformance tests
pnpm state-api test --url http://localhost:3000

# Run specific test suites
pnpm state-api test --url http://localhost:3000 --suite auth,post,patch,delete

# Generate JSON report for CI
pnpm state-api test --url http://localhost:3000 --output ./conformance-results.json

# Verbose output (show all assertions)
pnpm state-api test --url http://localhost:3000 --verbose

# Custom credentials
pnpm state-api test --url http://localhost:3000 --username admin --password secret
```

### CLI Test Suites

The CLI includes **11 generic conformance test suites** (60+ tests total):

| Suite            | Tests | Coverage                                                                    |
| ---------------- | ----- | --------------------------------------------------------------------------- |
| **auth**         | 10    | HTTP Basic Auth, Bearer rejection, malformed credentials, OPTIONS preflight |
| **schema**       | 7     | `/api/state/schema` endpoint structure, entity validation                   |
| **post**         | 6     | POST /api/state (wipe + create), empty payload handling                     |
| **patch**        | 4     | PATCH /api/state (upsert without wipe), conflict resolution                 |
| **delete**       | 3     | DELETE /api/state (full reset, selective deletion)                          |
| **symmetry**     | 3     | POST → GET roundtrip, data preservation validation                          |
| **error-format** | 5     | Error response structure: `{ ok: false, error: { code, message } }`         |
| **error-codes**  | 12    | Standard error codes (VALIDATION_ERROR, FOREIGN_KEY_VIOLATION, etc.)        |
| **options**      | 3     | OPTIONS endpoint, CORS preflight, allowed methods                           |
| **security**     | 4     | Path traversal prevention, injection attacks, security headers              |
| **context**      | 5     | Context object handling (workspace_id, user_id injection)                   |

**Baseline Requirements:**

All test suites are **fully generic** and only require a `User` entity with these fields:

- `id` (string, UUID format)
- `email` (string, email format)
- `username` (string)

This baseline schema is supported by all State API implementations in the template.

### Test Contract: Throw to Fail

**Important:** Tests must throw an Error to indicate failure. The `runTest` helper uses try/catch to determine pass/fail:

- ✅ **PASS:** Test function completes without throwing
- ❌ **FAIL:** Test function throws an Error (message becomes the failure reason)

```typescript
// ✅ CORRECT: Use assertions that throw on failure
tests.push(
	await runTest('validates input', async () => {
		const response = await client.post({User: [{invalid: true}]})
		assertStatus(response, 400) // Throws if status !== 400
	})
)

// ❌ WRONG: Returning false doesn't fail the test!
tests.push(
	await runTest('validates input', async () => {
		const response = await client.post({User: [{invalid: true}]})
		if (response.status !== 400) return false // This does NOT fail!
	})
)
```

Use assertion helpers from `src/utils/assertions.ts` (`assertStatus`, `assertOk`, `assertEqual`, etc.) which throw on failure.

### Extending with Custom Test Suites

Add application-specific test suites to validate custom entities:

```typescript
// packages/state-api-cli/src/suites/my-entity.suite.ts
import type {TestSuite} from './index.js'
import {runTest} from '../utils/test-runner.js'
import {assertStatus, assertOk, assertEqual} from '../utils/assertions.js'

export const myEntitySuite: TestSuite = {
	name: 'my-entity',
	async run(client, reporter, config) {
		const tests = []

		// Test: Entity creation
		tests.push(
			await runTest('MyEntity creates successfully', async () => {
				const response = await client.post({
					MyEntity: [{id: 'test-id-123', name: 'Test Entity', description: 'A test entity'}]
				})
				assertStatus(response, 200)
				assertOk(response)
			})
		)

		// Test: Entity validation
		tests.push(
			await runTest('MyEntity validates required fields', async () => {
				const response = await client.post({
					MyEntity: [{id: 'test-id-789'}] // Missing required name field
				})

				assertStatus(response, 400)
				assertEqual(response.data.ok, false, 'Expected error response')
				assertEqual(response.data.error?.code, 'VALIDATION_ERROR', 'Expected VALIDATION_ERROR code')
			})
		)

		return tests
	}
}
```

**Register the custom suite:**

```typescript
// packages/state-api-cli/src/suites/index.ts
import {myEntitySuite} from './my-entity.suite.js'

export const allSuites: Record<string, TestSuite> = {
	// ... generic suites
	'my-entity': myEntitySuite
}
```

**Build and run:**

```bash
pnpm --filter state-api-cli build
pnpm state-api test --url http://localhost:3000 --suite my-entity
```

### CI/CD Integration

The template includes a comprehensive State API conformance job in `.github/workflows/test.yml`. Key features:

- **Change detection** — Skips tests if no relevant files changed
- **Docker health checks** — Waits for container to be healthy before testing
- **Detailed reporting** — Generates summaries with pass/fail counts and failure details
- **Artifact upload** — Preserves JSON results for analysis

```yaml
# .github/workflows/test.yml (simplified)
state-api-conformance:
  name: 🔍 State API Conformance Tests
  runs-on: ubuntu-latest
  timeout-minutes: 15
  steps:
    - uses: actions/checkout@v4
    - uses: pnpm/action-setup@v4
    - uses: actions/setup-node@v4
      with:
        node-version-file: '.nvmrc'

    - name: Install dependencies
      run: pnpm install --frozen-lockfile

    - name: Build State API CLI
      run: |
        rm -rf packages/state-api-cli/dist
        pnpm --filter state-api-cli build

    - name: Generate Prisma Client
      run: pnpm prisma:generate

    - name: Build Docker Image
      run: docker buildx build --load --build-arg SEED_DATABASE=false -t app:latest .

    - name: Start Docker Container
      run: docker run -d --name app -p 80:80 app:latest

    - name: Wait for Container Health
      run: |
        timeout 120s bash -c 'until [ "$(docker inspect --format={{.State.Health.Status}} app)" = "healthy" ]; do sleep 2; done'

    - name: Run State API Conformance Tests
      run: pnpm state-api test --url http://localhost:80 --output ./state-api-conformance-results.json --verbose

    - name: Generate Conformance Summary
      if: success() || failure()
      run: |
        echo "## State API Conformance Test Results" >> $GITHUB_STEP_SUMMARY
        if [ -f "./state-api-conformance-results.json" ]; then
          jq -r '"\(.total) total tests, \(.passed) passed, \(.failed) failed"' ./state-api-conformance-results.json >> $GITHUB_STEP_SUMMARY
          FAILURES=$(jq -r '.failures | length' ./state-api-conformance-results.json)
          if [ "$FAILURES" -gt 0 ]; then
            echo "### ❌ Failures" >> $GITHUB_STEP_SUMMARY
            jq -r '.failures[] | "- **\(.suite)**: \(.test) - \(.error)"' ./state-api-conformance-results.json >> $GITHUB_STEP_SUMMARY
          fi
        fi

    - name: Dump Logs on Failure
      if: failure()
      run: docker logs app --tail 200

    - name: Stop Docker Container
      if: always()
      run: docker stop app && docker rm app || true

    - name: Upload Conformance Results
      if: always()
      uses: actions/upload-artifact@v4
      with:
        name: state-api-conformance-results
        path: state-api-conformance-results.json
        retention-days: 30
```

**Note:** The actual workflow in `.github/workflows/test.yml` includes additional optimizations like Blacksmith runners, Docker layer caching, and file change detection to skip tests when no relevant files are modified.

### CLI Best Practices

1. **Use CLI for conformance, direct API for E2E setup**
   - CLI provides comprehensive validation (60+ tests)
   - Direct API calls are simpler for test data setup

2. **Run CLI in CI/CD pipelines**
   - Catches State API regressions automatically
   - JSON reports integrate with test aggregators

3. **Run specific suites for focused testing**
   - Use `--suite` flag to run specific tests
   - Example: `--suite auth,post,symmetry,error-codes`

4. **Extend with custom suites for domain validation**
   - Validate application-specific business logic
   - Reuse CLI's test infrastructure and assertions

5. **Use verbose mode for debugging**
   - `--verbose` shows all assertions for detailed debugging
   - Generate JSON reports for failure analysis

---

## Related Documentation

- [State API Adoption Guide](packages/state-api-library/state-api-adoption-guide.md) — Full integration instructions
- [State API CLI README](packages/state-api-cli/README.md) — CLI usage and API reference
- [Package README](packages/state-api-library/README.md) — Library API reference
- [Technical Specification](docs/specs/state-api-library.md) — Architecture decisions
- [E2E Testing Rules](.rulesync/rules/e2e-testing.md) — E2E testing patterns
- [Database Rules](.rulesync/rules/database.md) — Database patterns
