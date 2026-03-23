# Security Standards

## Input Validation — Both Sides

- **Client:** Zod schemas for form validation
- **Server:** Convex argument validators (`v.string()`, `v.id()`) on every function
- **Server Actions:** Re-validate with `schema.safeParse()` (don't trust client)
- **Rule:** Never trust client input. Validate at EVERY system boundary.

## Auth — On Every Protected Route

```typescript
// Convex functions
const identity = await requireAuth(ctx)    // throws if unauthenticated
const admin = await requireAdmin(ctx)       // throws if not admin
const access = await requireCourseAccess(ctx, courseId) // throws if no access

// API routes
const { userId } = await auth()
if (!userId) return NextResponse.json({ error: "Unauthorized" }, { status: 401 })

// Server Actions
const { userId } = await auth()
if (!userId) return { success: false, error: "Not authenticated" }
```

Rule: every Convex function has an auth guard OR a comment explaining why it's public.

## Secrets

- No secrets in `NEXT_PUBLIC_` variables — only public keys (Google Maps, Umami)
- No hardcoded API keys, tokens, or passwords in source
- All secrets via environment variables
- Convex secrets set in dashboard, accessed via `process.env.X` in actions only
- Validate env vars at startup (t3-env or Zod schema)
- `.env.*` files in `.gitignore`, `.env.example` maintained in repo

## XSS Prevention

```typescript
// React auto-escapes — safe for text
<div>{userInput}</div>

// DANGEROUS — only for CMS rich text, NEVER user input
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(content) }} />

// HTML email templates — sanitize user data before interpolation
const safeName = sanitizeForHtml(user.firstName)
```

## Code Injection

- No `eval()`, no `new Function()`
- No raw database queries — always Convex query builders
- No string interpolation in queries

## Webhook Security

- Verify signatures/tokens FIRST (Svix for Clerk, token for Brevo)
- Return generic error messages (never expose internals)
- Check idempotency (prevent duplicate processing)
- Non-blocking side effects in try-catch (don't fail the webhook)

```typescript
// Generic responses only
return new Response("Bad request", { status: 400 })   // not "Missing workshopId field"
return new Response("Unauthorized", { status: 401 })    // not "Invalid Svix signature"
```

## Email Security

- Normalize emails on ingest: `email.toLowerCase().trim()`
- Sanitize user-provided text before HTML email interpolation
- Never include secrets or full URLs with tokens in logged output

## OWASP Top 10 Quick Reference

| # | Risk | Our Prevention |
|---|---|---|
| A01 | Broken Access Control | Auth guards on every function |
| A02 | Cryptographic Failures | Secrets in env vars only |
| A03 | Injection | Convex query builders, Zod validation |
| A04 | Insecure Design | Auth on backend first, then hide on frontend |
| A05 | Security Misconfiguration | Secure headers in next.config |
| A06 | Vulnerable Components | Keep dependencies updated |
| A07 | Auth Failures | Clerk handles MFA, session management |
| A08 | Data Integrity | Input validation, webhook signature verification |
| A09 | Logging Failures | Structured logging, no PII in logs |
| A10 | SSRF | Validate URLs, allowlist destinations |

## Secure Headers

```javascript
// next.config — security headers
{ key: 'X-Frame-Options', value: 'SAMEORIGIN' },
{ key: 'X-Content-Type-Options', value: 'nosniff' },
{ key: 'Strict-Transport-Security', value: 'max-age=63072000; includeSubDomains' },
{ key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
```
