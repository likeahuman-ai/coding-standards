# Error Handling & Resilience

## Error Boundaries (Next.js)

Every route segment should have an `error.tsx`:

```typescript
// src/app/(platform)/error.tsx
"use client"

import { useEffect } from "react"
import * as Sentry from "@sentry/nextjs"
import { Button } from "@likeahuman-ai/dls/ui/button"

export default function PlatformError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => { Sentry.captureException(error) }, [error])

  const message = parseUserMessage(error)

  return (
    <div className="flex min-h-[60vh] flex-col items-center justify-center gap-4">
      <h2 className="text-xl font-semibold text-text-primary">{message.title}</h2>
      <p className="text-text-secondary">{message.body}</p>
      <Button onClick={reset}>Try again</Button>
    </div>
  )
}
```

Map ConvexError messages to user-friendly text:

```typescript
const KNOWN_ERRORS: Record<string, { title: string; body: string }> = {
  "Authentication required": { title: "Session expired", body: "Please sign in again." },
  "Course access required": { title: "No access", body: "Purchase or join a workshop." },
  "Your course access has expired": { title: "Access expired", body: "Renew to continue." },
}
```

## Error Handling by Context

| Context | Pattern | Example |
|---|---|---|
| Convex query | Return `null` | `.first()` returns null, frontend renders empty state |
| Convex mutation | Throw `ConvexError` | `throw new ConvexError(AUTH_ERRORS.NOT_AUTHENTICATED)` |
| Convex action | Return result object | `{ success: false, error: "Brevo timeout" }` |
| Webhook handler | Log + continue | `try { sideEffect() } catch(e) { console.error(e) }` |
| Server Action | Return result object | `{ success: false, error: "Validation failed" }` |
| API route | HTTP status + JSON | `NextResponse.json({ error }, { status: 400 })` |
| React component | Error boundary | `error.tsx` catches and shows fallback UI |

## Centralized Error Messages

```typescript
// convex/lib/authHelpers.ts
const AUTH_ERRORS = {
  NOT_AUTHENTICATED: "Authentication required",
  ADMIN_REQUIRED: "Admin access required",
  NO_COURSE_ACCESS: "Course access required",
  ACCESS_EXPIRED: "Your course access has expired",
} as const
```

Never scatter error strings across files. Centralize in `lib/` per domain.

## UI Error States

| Scenario | Pattern |
|---|---|
| Network failure | Retry logic + error toast + visual indicator |
| Optimistic update fails | Silent rollback + toast with explanation |
| Empty data | Illustration + descriptive text + action button (not just "No data") |
| Loading | `<Suspense>` + skeleton (not spinners, except for buttons) |
| Not found | `not-found.tsx` with navigation back |

## Retry Patterns

### Exponential Backoff (Convex scheduler)

```typescript
if (retryCount < 5) {
  const delay = Math.min(5000 * Math.pow(2, retryCount), 60000)
  await ctx.scheduler.runAfter(delay, internal.same.function, {
    ...args, retryCount: retryCount + 1,
  })
}
```

### Third-Party API Timeout

```typescript
const controller = new AbortController()
const timeout = setTimeout(() => controller.abort(), 8_000) // 8s max
try {
  const response = await fetch(url, { signal: controller.signal })
  // ...
} catch (error) {
  if (error instanceof DOMException && error.name === "AbortError") {
    return { success: false, error: "Request timed out" }
  }
  return { success: false, error: error instanceof Error ? error.message : "Unknown" }
} finally {
  clearTimeout(timeout)
}
```

## Eventual Consistency (Convex + Webhooks)

```typescript
// After Stripe checkout, Convex mutation may not have run yet
function LearnDashboard() {
  const access = useQuery(api.courseAccess.getMyCourseAccess, { courseSlug })
  const justPurchased = useSearchParams().get("session_id")

  // Show processing state while Convex catches up
  if (justPurchased && access === undefined) {
    return <PurchaseProcessingState />
  }
  // ...
}
```

Never poll or setTimeout to "wait for Convex" — useQuery is reactive and will update automatically.

## What NOT to Do

- Never show raw error.message to users (leaks internals)
- Never `catch {}` (empty) — at minimum log the error
- Never throw from Server Actions (breaks progressive enhancement)
- Never throw from Convex actions (can't be retried, return result object instead)
- Never retry indefinitely — cap at 5 retries with backoff
- Never fail a webhook on side-effect errors — log and continue
