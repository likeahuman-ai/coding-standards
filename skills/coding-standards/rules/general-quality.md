# General Code Quality

## No Over-Engineering

- Only make changes that are directly requested or clearly necessary
- Don't add error handling for scenarios that can't happen
- Don't create helpers/abstractions for one-time operations
- Three similar lines beat a premature abstraction
- Don't design for hypothetical future requirements
- Wait for the third occurrence before abstracting (Rule of Three)

## JavaScript/TypeScript Idioms

| Instead of | Use |
|---|---|
| `arr=[]; for...push` | `.map()` / `.filter()` / `.flatMap()` |
| `new Map(); for...set` | `new Map(entries)` / `Object.fromEntries()` |
| `JSON.parse(JSON.stringify())` | `structuredClone()` |
| `\|\| ''` / `\|\| 0` for defaults | `??` (nullish coalescing) |
| `for...in` on arrays | `for...of` or array methods |
| `Object.keys().forEach` | `Object.entries()` |
| Manual `reduce` to object | `Object.groupBy()` (ES2024) |
| Nested if/else chains | Early returns + guard clauses |
| Two-pass (build lookup then apply) | Single pass with `.map()` or `Object.fromEntries()` + `.map()` |

## File Hygiene

- No `console.log` in production component code (allowed in hooks/utils for debugging)
- No empty catch blocks — handle the error or at minimum log it
- No unused imports, variables, or functions
- No commented-out code blocks (delete it, git has history)

## Magic Values

- No hardcoded numbers in business logic — extract to named constants
- No hardcoded strings used in multiple places — centralize
- `setTimeout`/`setInterval` durations should be named constants
- Array indices used for logic should be explained or avoided

```typescript
// WRONG
setTimeout(cleanup, 5000)
if (items[3]) { ... }

// RIGHT
const CLEANUP_DELAY_MS = 5_000
setTimeout(cleanup, CLEANUP_DELAY_MS)

const SETTINGS_INDEX = 3
if (items[SETTINGS_INDEX]) { ... }
// Or better: use a named field instead of index
```

## Comments

- Comment-to-code ratio under 20%
- Only comment WHY, never WHAT
- Code should be self-documenting through naming
- Don't add JSDoc to every function — only when purpose isn't obvious
- No `// TODO` without a ticket/issue reference

## Defensive Coding

- Null checks: always, even with TypeScript strict mode
- Length checks: before `.map()` and array operations
- Network failures: retry logic + error toast + visual indicator
- Boundary checks: min/max on numeric inputs, max-length on text
- Optimistic update fails: silent rollback + toast explanation
- Empty states: illustration + descriptive text + action button
- Loading states: Suspense + skeletons (not spinners except buttons)

## Semantic Commits

```
<type>(<scope>): <subject>
```

Types: `feat`, `fix`, `refactor`, `docs`, `style`, `perf`, `test`, `chore`, `ci`, `build`

Rules: lowercase subject, no period, imperative mood, scope optional, under 72 chars.

## Self-Review Checklist

Before considering any function >10 lines done:
1. Can this be simpler?
2. Am I repeating something that exists?
3. Are all names explicit and intention-revealing?
4. Would a new team member understand this without comments?
