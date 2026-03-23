# Lint Configuration — Severity Levels

This file maps coding standards rules to severity levels for the `/lint` skill and the pre-commit hook.

### Severity definitions

| Level | Pre-commit hook | `/lint` report | What it means |
|---|---|---|---|
| **BLOCKING** | Rejects the commit | Must fix before shipping | Rule violation that causes bugs, security issues, or severe inconsistency |
| **WARNING** | Allows commit, shows alert | Should fix, not blocking | Code smell or drift from standards that won't cause immediate issues |
| **INFO** | Not checked | Suggestion only | Opportunity to improve — not a violation |

## BLOCKING (must fix before shipping)

These violations fail the lint check:

| Rule | Source File | What to Check |
|---|---|---|
| `any` type usage | `typescript-quality.md` | Grep for `: any`, `as any` |
| `@ts-ignore` | `typescript-quality.md` | Grep for `@ts-ignore` |
| Excessive `as` assertions | `typescript-quality.md` | Count `as ` per file, flag >3 |
| Inline types in >40 line file | `types-and-constants.md` | Types in component files |
| Inline constants in components | `types-and-constants.md` | `UPPER_CASE` const in .tsx files |
| `export default` in non-page | `naming-conventions.md` | Grep `export default` outside page/layout |
| Hardcoded hex in components | `tailwind-and-tokens.md` | Grep `#[0-9a-fA-F]{3,8}` in .tsx |
| Off-scale font sizes | `tailwind-and-tokens.md` | Check `text-[Xpx]` against scale |
| Template literal className | `tailwind-and-tokens.md` | Grep for className={` |
| `useEffect` for derived state | `react-patterns.md` | useState + useEffect + setter pattern |
| `useEffect` + `fetch()` | `react-patterns.md` | useEffect with fetch/axios |
| Missing auth in Convex function | `convex-backend.md` | No requireAuth/requireAdmin/comment |
| `ctx.db.delete()` | `convex-backend.md` | Grep for `ctx.db.delete` |
| No `dangerouslySetInnerHTML` without sanitize | `security.md` | Check for DOMPurify usage |
| Prop drilling past 2 levels | `state-management.md` | Form props (watch, setValue, errors) through layers |
| Barrel files | `file-organization.md` | `index.ts` that only re-exports |
| Raw `<img>` tags | `react-patterns.md` | Grep for `<img ` in .tsx |

## WARNING (should fix, not blocking)

| Rule | Source File | What to Check |
|---|---|---|
| File >100 lines | `component-architecture.md` | wc -l on .tsx files |
| File >200 lines | `component-architecture.md` | Hard limit — flag prominently |
| `console.log` in components | `general-quality.md` | Grep console.log in .tsx |
| Empty catch blocks | `general-quality.md` | Grep `catch.*\{\s*\}` |
| Magic numbers | `general-quality.md` | setTimeout with literals, array indices |
| Commented-out code | `general-quality.md` | Multi-line comments containing code |
| Duplicate constants | `types-and-constants.md` | Same value in 2+ files |
| New component duplicating DLS | `reuse-first.md` | New *-card, *-badge, *-button files |
| Off-rhythm spacing | `tailwind-and-tokens.md` | Custom spacing not on 4px grid |
| Missing Storybook story | `component-architecture.md` | New component without .stories.tsx |
| Abbreviations in names | `naming-conventions.md` | btn, usr, val, desc, etc. |
| No `"use client"` without hooks | `react-patterns.md` | Unnecessary client directive |

## INFO (suggestions, not violations)

| Rule | Source File | What to Check |
|---|---|---|
| Could use `Pick`/`Omit` | `types-and-constants.md` | Manual type that overlaps existing |
| Could compose existing components | `reuse-first.md` | New component with DLS styling |
| Missing optimistic update | `state-management.md` | Mutation without immediate UI feedback |
| No error boundary | `error-handling.md` | Route segment without error.tsx |

## How `/lint` Uses This

1. Scan target files for BLOCKING violations first
2. Then WARNING violations
3. Then INFO suggestions
4. Group by file, sorted by severity
5. Offer to auto-fix: type extraction, constant extraction, className conversion
6. Reference the source rule file for each violation
