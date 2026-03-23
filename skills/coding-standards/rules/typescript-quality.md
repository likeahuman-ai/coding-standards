# TypeScript Quality

## Non-Negotiable Rules

- **Strict mode always enabled** — no exceptions
- **Never use `any`** — use `unknown` and narrow with type guards
- **No `@ts-ignore`** — fix the type error or use `@ts-expect-error` with explanation
- **Minimize `as` assertions** — max 3 per file, use type guards and discriminated unions instead
- **No non-null assertions (`!`)** — unless null case is truly impossible AND documented

## Type Guards Over Assertions

```typescript
// WRONG: assertion
const user = data as User

// RIGHT: type guard
function isUser(data: unknown): data is User {
  return typeof data === "object" && data !== null && "email" in data
}
if (isUser(data)) { /* data is User here */ }
```

## Discriminated Unions

```typescript
// Use for state machines and multi-shape returns
type AccessResult =
  | { state: "active"; tier: string; expiresAt: number }
  | { state: "expired"; expiredAt: number }
  | { state: "none" }

// Exhaustive switch — catches missing cases at compile time
function handleAccess(result: AccessResult) {
  switch (result.state) {
    case "active": return renderDashboard(result.tier)
    case "expired": return renderExpired(result.expiredAt)
    case "none": return renderPurchase()
    default: {
      const _exhaustive: never = result
      throw new Error(`Unhandled state: ${_exhaustive}`)
    }
  }
}
```

## Branded Types for IDs

```typescript
// Prevent accidentally swapping IDs that are all strings
type ClerkUserId = string & { readonly __brand: "ClerkUserId" }
type StripeCustomerId = string & { readonly __brand: "StripeCustomerId" }

function grantAccess(clerkId: ClerkUserId, tier: string) { ... }

const clerkId = identity.subject as ClerkUserId
const stripeId = customer.id as StripeCustomerId
grantAccess(clerkId, "pro")    // OK
grantAccess(stripeId, "pro")   // TypeScript error
```

## Const Assertions Over Enums

```typescript
// WRONG: enum
enum Status { Active = "active", Expired = "expired" }

// RIGHT: const assertion
const STATUS = { ACTIVE: "active", EXPIRED: "expired" } as const
type Status = typeof STATUS[keyof typeof STATUS]
```

## Convex Validator Types

```typescript
// Use v.union(v.literal(...)) for enums — never plain v.string()
tier: v.union(v.literal("solo"), v.literal("pro"), v.literal("vip"))

// Use Doc<"tableName"> for document types
import { Doc } from "@convex/_generated/dataModel"
type Course = Doc<"courses">
```

## Result Type for Actions

```typescript
type Result<T, E = string> =
  | { success: true; data: T }
  | { success: false; error: E }

// Forces callers to check success before accessing data
function processPayment(): Result<{ accessId: string }> { ... }
```

## Inference Rules

- Use inference where the compiler can deduce types — don't annotate the obvious
- DO annotate: exported function return types, complex objects, public API boundaries
- DON'T annotate: local variables, arrow function params in `.map()`, obvious initializers
