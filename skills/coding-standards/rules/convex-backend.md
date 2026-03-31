# Convex Backend Standards

> This file covers Convex-specific patterns. For general Node.js/TypeScript backend patterns (API routes, Server Actions, ORMs like Prisma/Drizzle, tRPC, raw SQL), see `nodejs-backend.md`. For state management between frontend and backend, see `state-management.md`.

## Function Type Selection

```
What are you doing?
  Reading data only         -> query() or internalQuery()
  Writing to DB only        -> mutation() or internalMutation()
  Calling external API      -> action() or internalAction() with "use node"
  Handling HTTP request     -> httpAction()

Public vs Internal?
  Called from frontend      -> query() / mutation() (public)
  Called from backend only  -> internalQuery() / internalMutation() / internalAction()
  Private helper            -> prefix with _ (_logActivity, _clearTable)
```

## Auth Guard — On Every Function

```typescript
// Public content (landing page) — no auth, but ALWAYS comment why
export const listPublished = query({
  // Public: visible to unauthenticated users for landing page
  handler: async (ctx) => { ... }
})

// Authenticated user
const identity = await requireAuth(ctx)

// Admin only
const admin = await requireAdmin(ctx)

// Course access with admin bypass
const access = await requireCourseAccess(ctx, courseId)
```

No function without either an auth guard or a comment explaining why it's public.

## Query Patterns

```typescript
// ALWAYS use indexed lookups — never full table scans
ctx.db.query("table").withIndex("by_field", q => q.eq("field", value))

// ALWAYS filter soft deletes
results.filter(r => !r.deletedAt)

// ALWAYS cap results
.take(50)      // bounded list
.first()       // single doc (returns null)
.unique()      // single doc (throws if >1)
// Use .collect() sparingly — only when you truly need ALL records

// Parallel fetching for related data
const [invites, participants] = await Promise.all([
  ctx.db.query("workshopInvites").withIndex("by_workshop", q => q.eq("workshopId", id)).take(1000),
  ctx.db.query("workshopParticipants").withIndex("by_workshop", q => q.eq("workshopId", id)).take(1000),
])
```

## Mutation Patterns

### Upsert Pattern

```typescript
const existing = await ctx.db.query("table")
  .withIndex("by_key", q => q.eq("key", value))
  .first()

if (existing) {
  await ctx.db.patch(existing._id, { ...updates, updatedAt: Date.now() })
  return existing._id
}

const id = await ctx.db.insert("table", {
  ...data,
  createdAt: Date.now(),
  updatedAt: Date.now(),
})
return id
```

### Audit Fields — On Every Table

```typescript
// ALWAYS on insert:
createdAt: Date.now(),
updatedAt: Date.now(),

// ALWAYS on patch:
updatedAt: Date.now(),

// Soft delete — NEVER ctx.db.delete():
await ctx.db.patch(id, { deletedAt: Date.now(), updatedAt: Date.now() })
```

## Schema Conventions

| Thing | Pattern | Example |
|---|---|---|
| Table names | Plural camelCase | `courses`, `workshopInvites` |
| Fields | camelCase | `clerkUserId`, `accessExpiresAt` |
| Foreign keys | `{table}Id` | `courseId`, `workshopId` |
| Timestamps | `*At` suffix | `createdAt`, `deletedAt` |
| Booleans | `is`/`has`/`needs` | `isPublished`, `hasAccess` |
| Enums | `v.union(v.literal(...))` | Never plain `v.string()` |
| Indexes | `by_{field}` | `by_user`, `by_user_course` |

## Action Pattern (External APIs)

```typescript
"use node"  // Required for env vars, fetch, Node.js APIs

export const send = internalAction({
  args: { ... },
  handler: async (ctx, args): Promise<{ success: boolean; error?: string }> => {
    const apiKey = process.env.API_KEY
    if (!apiKey) throw new Error("Missing API_KEY")

    const controller = new AbortController()
    const timeout = setTimeout(() => controller.abort(), 8_000)

    try {
      const response = await fetch(url, {
        method: "POST",
        headers: { "api-key": apiKey, "Content-Type": "application/json" },
        body: JSON.stringify(data),
        signal: controller.signal,
      })

      if (!response.ok) {
        return { success: false, error: `${response.status}: ${await response.text()}` }
      }
      return { success: true }
    } catch (error) {
      if (error instanceof DOMException && error.name === "AbortError") {
        return { success: false, error: "Request timed out (8s)" }
      }
      return { success: false, error: error instanceof Error ? error.message : "Unknown" }
    } finally {
      clearTimeout(timeout)
    }
  },
})
```

## Webhook Handler Pattern

```typescript
export const handleWebhook = httpAction(async (ctx, request) => {
  // 1. Verify signature/token FIRST
  // 2. Parse payload
  // 3. Check idempotency (prevent duplicate processing)
  // 4. Validate required fields -> 400 if missing
  // 5. Route by event type (switch)
  // 6. DB operations via ctx.runMutation()
  // 7. Non-blocking side effects in try-catch
  // 8. Return Response(null, { status: 200 })
})
```

### Webhook Idempotency — All Sources

Every webhook handler must check for duplicate deliveries:

```typescript
const alreadyProcessed = await ctx.runMutation(internal.lib.checkIdempotency, {
  source: "stripe",
  externalEventId: event.id,
})
if (alreadyProcessed) return new Response(null, { status: 200 })
```

## Async Side Effects

```typescript
// Fire-and-forget (non-blocking)
await ctx.scheduler.runAfter(0, internal.activity._log, { ... })

// Retry with exponential backoff
if (retryCount < 5) {
  const delay = Math.min(5000 * Math.pow(2, retryCount), 60000)
  await ctx.scheduler.runAfter(delay, internal.same.function, {
    ...args, retryCount: retryCount + 1,
  })
}

// Fan-out for bulk operations (avoid action timeouts)
const batchSize = 10
for (let i = 0; i < items.length; i += batchSize) {
  const batch = items.slice(i, i + batchSize)
  await ctx.scheduler.runAfter(i * 100, internal.process.batch, {
    ids: batch.map(item => item._id),
  })
}
```

## Error Handling by Function Type

| Context | Pattern |
|---|---|
| Query — record not found | Return `null` (let frontend handle) |
| Mutation — business rule violation | `throw new ConvexError(AUTH_ERRORS.X)` |
| Mutation — record not found | `throw new Error("X not found")` |
| Action — external API failure | Return `{ success: false, error }` (never throw) |
| Webhook — side effect failure | `try-catch`, log, continue (don't fail webhook) |
| Validators | Throw automatically — no manual checks needed |

## Pagination (Cursor-Based)

```typescript
export const listPaginated = query({
  args: {
    paginationOpts: v.object({
      cursor: v.union(v.string(), v.null()),
      numItems: v.number(),
    }),
  },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("table")
      .withIndex("by_created_at")
      .order("desc")
      .paginate({
        cursor: args.paginationOpts.cursor ?? null,
        numItems: Math.min(args.paginationOpts.numItems, 100), // CAP page size
      })
  },
})
```

## What NOT to Do

- Never `.collect()` without strong reason — always `.take(N)` or `.first()`
- Never `ctx.db.delete()` — always soft delete with `deletedAt`
- Never `v.string()` for status/enum fields — use `v.union(v.literal(...))`
- Never call external APIs from mutations — use actions with `"use node"`
- Never hardcode API keys — always `process.env.X` in actions
- Never let webhook handlers crash on side-effect failures
- Never skip `createdAt`/`updatedAt` on insert/patch
