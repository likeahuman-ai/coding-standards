# Node.js Backend Standards

Patterns for Next.js Server Actions, API routes, environment management, logging, dates, and other server-side concerns outside Convex.

## When to Use What

```
Convex query/mutation     -> Real-time reactive data, database CRUD
Convex action             -> Side effects calling third-party APIs from Convex runtime
Convex httpAction         -> Incoming webhooks (Stripe, Clerk, Luma, Brevo)
Next.js API route         -> Needs Clerk auth cookies, Node.js SDK, or Next.js features
Next.js Server Action     -> Form submissions, revalidation, simple mutations without reactivity

NEVER:
- Use API routes as proxy to Convex (call Convex directly)
- Use httpAction for anything needing Clerk cookies (middleware doesn't run on Convex)
- Duplicate logic between API routes and Convex functions
```

## Server Action Pattern

```typescript
"use server"

import { auth } from "@clerk/nextjs/server"
import { revalidatePath } from "next/cache"
import { z } from "zod"

type ActionResult<T = void> =
  | { success: true; data: T }
  | { success: false; error: string; fieldErrors?: Record<string, string[]> }

const schema = z.object({
  displayName: z.string().min(1).max(100).trim(),
})

export async function updateProfile(
  _prevState: ActionResult,
  formData: FormData,
): Promise<ActionResult> {
  // 1. Auth
  const { userId } = await auth()
  if (!userId) return { success: false, error: "Not authenticated" }

  // 2. Validate
  const parsed = schema.safeParse({ displayName: formData.get("displayName") })
  if (!parsed.success) {
    return { success: false, error: "Validation failed", fieldErrors: parsed.error.flatten().fieldErrors }
  }

  // 3. Do the thing
  // ...

  // 4. Revalidate + return
  revalidatePath("/account")
  return { success: true, data: undefined }
}
```

Rules: Always return result objects, never throw from Server Actions (breaks progressive enhancement).

## API Route Middleware Pattern

```typescript
// src/lib/api-utils.ts
export function createApiHandler<T>(options: {
  schema: z.ZodType<T>
  rateLimit?: { limit: number; windowMs: number }
  handler: (params: { userId: string; body: T }) => Promise<NextResponse>
}) {
  return async (request: Request): Promise<NextResponse> => {
    // 1. Auth check
    const { userId } = await auth()
    if (!userId) return NextResponse.json({ error: "Unauthorized" }, { status: 401 })

    // 2. Rate limit (if configured)
    // 3. Parse + validate body with Zod
    // 4. Execute handler in try-catch with Sentry
  }
}
```

## Environment Variable Management

### Convex Actions — Centralized Access

```typescript
// convex/lib/env.ts
function requireEnv(name: string): string {
  const value = process.env[name]
  if (!value) throw new Error(`Missing env var: ${name}. Set in Convex dashboard.`)
  return value
}

export const env = {
  get stripeSecretKey() { return requireEnv("STRIPE_SECRET_KEY") },
  get brevoApiKey() { return requireEnv("BREVO_API_KEY") },
  get appUrl() { return process.env.NEXT_PUBLIC_APP_URL ?? "https://academy.likeahuman.ai" },
} as const
```

Never scatter `process.env.X` across action files with inconsistent fallbacks.

### Next.js — Validate at Startup

```typescript
// src/lib/env.ts — validated with t3-env or Zod
```

## Input Sanitization

Beyond Zod/Convex validators — sanitize content before storage:

```typescript
// convex/lib/sanitize.ts

// Normalize email: lowercase + trim (EVERY ingest point)
export function normalizeEmail(email: string): string {
  return email.toLowerCase().trim()
}

// Sanitize user text for storage
export function sanitizeText(input: string, maxLength = 500): string {
  return input
    .trim()
    .replace(/\0/g, "")                    // null bytes
    .replace(/[\x01-\x09\x0B\x0C\x0E-\x1F]/g, "") // control chars
    .replace(/\s+/g, " ")                  // collapse whitespace
    .slice(0, maxLength)
}

// Sanitize for HTML email templates
export function sanitizeForHtml(input: string): string {
  return input
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;")
}
```

Rule: Every mutation that stores user-provided text must sanitize. Every webhook that receives email must normalize.

## Date/Time Handling

```typescript
// RULE: All timestamps in Convex are Unix MILLISECONDS. Period.
type UnixMs = number

// Convert external API timestamps (often seconds) to ms
export function secondsToMs(seconds: number): UnixMs {
  return seconds * 1000
}

// Convert ISO strings (from APIs) to ms
export function isoToMs(iso: string): UnixMs {
  const ms = new Date(iso).getTime()
  if (Number.isNaN(ms)) throw new Error(`Invalid ISO date: ${iso}`)
  return ms
}

// Named duration constants
export const MS_PER_DAY = 24 * 60 * 60 * 1000
export const MS_PER_HOUR = 60 * 60 * 1000
```

**Pitfall:** Brevo webhook `ts_event` is Unix SECONDS. Convex `Date.now()` is MILLISECONDS. Always convert.

**Client-side display:** Use `Intl.DateTimeFormat` with explicit locale and timezone. Never rely on server locale.

## Structured Logging

```typescript
// convex/lib/log.ts
type LogLevel = "info" | "warn" | "error"

export function log(level: LogLevel, message: string, context: {
  source: string
  action: string
  [key: string]: unknown
}) {
  const entry = { level, message, ...context, timestamp: new Date().toISOString() }
  switch (level) {
    case "error": console.error(JSON.stringify(entry)); break
    case "warn":  console.warn(JSON.stringify(entry)); break
    default:      console.log(JSON.stringify(entry)); break
  }
}
```

**Rules:**
- ALWAYS include `source` + `action`
- NEVER log: full request bodies, auth tokens, email content, PII
- DO log: event IDs, clerkUserId, operation results, timing (durationMs)

## Third-Party Integration Resilience

```typescript
// Always set timeouts on external API calls
const controller = new AbortController()
const timeout = setTimeout(() => controller.abort(), 8_000)
try {
  const response = await fetch(url, { signal: controller.signal, ... })
  // ...
} finally {
  clearTimeout(timeout)
}

// Use singleton pattern for SDK clients (Stripe)
let _stripe: Stripe | null = null
export function getStripe(): Stripe {
  if (!_stripe) {
    _stripe = new Stripe(env.stripeSecretKey, {
      apiVersion: "2026-02-25.clover",
      timeout: 10_000,
      maxNetworkRetries: 2,
    })
  }
  return _stripe
}
```

## API Response Shapes

```
Convex query    -> returns data or null (NEVER throws for "not found")
Convex mutation -> throws ConvexError for business rule violations, returns ID on success
Convex action   -> returns { success: true; data } | { success: false; error: string }
Next.js API     -> NextResponse.json({ data }) or NextResponse.json({ error }, { status })
Server Action   -> ActionResult<T> (success/error union)
```

## Caching Strategy

```
Marketing pages (landing, pricing)  -> ISR with revalidate (300s)
Platform pages (dashboard, lessons) -> Real-time queries (no cache)
Admin pages                         -> Real-time queries
API responses                       -> No cache (always fresh)
```

## ORM / Database Patterns (Non-Convex Projects)

When using Prisma, Drizzle, or raw SQL instead of Convex:

### Query Patterns

```typescript
// Always use parameterized queries — NEVER string interpolation
// Prisma
const user = await prisma.user.findUnique({ where: { email } })

// Drizzle
const user = await db.select().from(users).where(eq(users.email, email))

// Raw SQL — ALWAYS parameterized
const user = await sql`SELECT * FROM users WHERE email = ${email}`
```

### Transaction Pattern

```typescript
// Group related writes in transactions
await prisma.$transaction([
  prisma.order.create({ data: orderData }),
  prisma.inventory.update({ where: { id: itemId }, data: { stock: { decrement: 1 } } }),
])
```

### Migration Discipline

- Every schema change needs a migration file
- Migrations must be reversible (up + down)
- Never modify an already-applied migration
- Test migrations against a copy of production data before deploying

### Soft Delete (Universal)

Regardless of ORM, soft delete is the default:

```typescript
// NEVER physically delete
await prisma.user.delete({ where: { id } })

// ALWAYS soft delete
await prisma.user.update({ where: { id }, data: { deletedAt: new Date() } })

// ALWAYS filter in queries
const users = await prisma.user.findMany({ where: { deletedAt: null } })
```

### Audit Fields (Universal)

Every table gets: `createdAt`, `updatedAt`, `deletedAt` (optional).

## tRPC Patterns (When Used)

```typescript
// Organize by domain router
const appRouter = router({
  user: userRouter,
  course: courseRouter,
  billing: billingRouter,
})

// Every procedure needs auth middleware
const protectedProcedure = t.procedure.use(isAuthed)
const adminProcedure = t.procedure.use(isAdmin)

// Input validation with Zod
export const courseRouter = router({
  getBySlug: protectedProcedure
    .input(z.object({ slug: z.string() }))
    .query(async ({ ctx, input }) => { ... }),
})
```
