# Before Committing — Post-Write Validation

Run through this checklist after writing code, before committing.

## BLOCKING (must fix)

### TypeScript
- [ ] No `any` types
- [ ] No `@ts-ignore` (use `@ts-expect-error` with explanation if needed)
- [ ] Max 3 `as` assertions per file
- [ ] `pnpm typecheck` passes

### React
- [ ] No `useEffect` for derived state
- [ ] No `useEffect` + `fetch()` pattern
- [ ] No unnecessary `"use client"` (no hooks/events/browser APIs used)
- [ ] No `export default` in non-page files
- [ ] No raw `<img>` tags (use `next/image`)

### Design System
- [ ] No hardcoded hex colors in components
- [ ] All font sizes on the type scale (12-14-16-18-20-24-28-32-36-40-48-56-64)
- [ ] All spacing on 4px rhythm
- [ ] `cn()` used for all conditional classes (no template literals)

### Code Organization
- [ ] No inline types in files >40 lines (extract to domain `types.ts`)
- [ ] No inline constants (extract to domain `constants.ts`)
- [ ] No barrel files (`index.ts` re-exports)
- [ ] No duplicate constants/types across files

### Security
- [ ] Auth check on every Convex function (or comment why public)
- [ ] No secrets in `NEXT_PUBLIC_*` variables
- [ ] No `dangerouslySetInnerHTML` with unsanitized user input
- [ ] No `eval()` or `new Function()`

### Backend
- [ ] Soft delete only (never `ctx.db.delete()`)
- [ ] `createdAt` + `updatedAt` on every insert/patch
- [ ] Webhook handlers check idempotency
- [ ] Actions return `{ success, error }` (never throw)
- [ ] External API calls have timeouts

## WARNING (should fix)

### File Size
- [ ] Components under 100 lines (200 max)
- [ ] Pages under 250 lines

### Quality
- [ ] No `console.log` in component code
- [ ] No empty catch blocks
- [ ] No magic numbers (extract to constants)
- [ ] No commented-out code
- [ ] Comment-to-code ratio under 20%

### Reuse
- [ ] No new component that duplicates existing DLS component
- [ ] No new type that could be `Pick`/`Omit` of existing type
- [ ] No new constant that exists elsewhere in codebase

### Naming
- [ ] Files: `kebab-case.tsx` (components) or `camelCase.ts` (Convex)
- [ ] Components: `PascalCase`
- [ ] Constants: `UPPER_SNAKE_CASE`
- [ ] Booleans: `is`/`has`/`can`/`needs` prefix
- [ ] No abbreviations (`btn`, `usr`, `val`)

### State
- [ ] No prop drilling past 2 levels
- [ ] URL-representable state uses `useSearchParams`
- [ ] Server state uses Convex useQuery or React Query (not useState+useEffect)
