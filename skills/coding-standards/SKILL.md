---
name: coding-standards
description: Single source of truth for all coding rules, conventions, and quality standards. Auto-loaded at conversation start. Sub-files loaded on-demand based on the work being done.
---

# Coding Standards

This is the authoritative reference for how code should be written across all projects. When rules conflict between files, this skill wins.

## Core Philosophy

1. **Reuse first** — extend existing components/types/constants before creating new ones
2. **Building bricks** — components are small, generic, reusable units (like `Card`, `Badge`, `Input`) that get composed into larger features. The business logic lives in the composition, not the brick itself.
3. **Domain-driven** — organize files by what they do (auth/, billing/, courses/), not what they are (controllers/, models/, utils/). A "domain" = a feature area or bounded context in your app.
4. **Minimum viable complexity** — three similar lines beat a premature abstraction. Extract only when the third occurrence appears.
5. **Single source of truth** — one type, one constant, one component per concept. If it exists, import it. Don't duplicate.

## How This Skill Works

**SKILL.md** (this file) is auto-loaded every conversation. It gives Claude the philosophy and a manifest of sub-files. The sub-files are read on-demand based on what you're working on.

## Rule Files — Read Before Working

| File | Read when... |
|------|-------------|
| `rules/reuse-first.md` | Creating ANY new component, type, constant, or hook |
| `rules/component-architecture.md` | Building or modifying React components |
| `rules/naming-conventions.md` | Naming anything (files, components, variables, functions) |
| `rules/file-organization.md` | Creating files, moving files, structuring directories |
| `rules/types-and-constants.md` | Creating or extracting types, interfaces, or constants |
| `rules/typescript-quality.md` | Writing TypeScript (always) |
| `rules/react-patterns.md` | Working with React/Next.js components, hooks, pages |
| `rules/tailwind-and-tokens.md` | Writing className, styling, using design tokens |
| `rules/convex-backend.md` | Working in the `convex/` directory |
| `rules/nodejs-backend.md` | Server Actions, API routes, env vars, logging, dates |
| `rules/security.md` | Auth, validation, user input, secrets, external data |
| `rules/error-handling.md` | Error boundaries, retries, resilience, error propagation |
| `rules/state-management.md` | Working with state (Zustand, URL params, server state, forms) |
| `rules/general-quality.md` | Always — JS idioms, comments, magic values, defensive coding |

## Checklists — Use at Key Moments

| File | Use when... |
|------|-------------|
| `checklists/before-creating.md` | BEFORE creating any new file (component, hook, type, constant) |
| `checklists/before-committing.md` | AFTER writing code, before committing |

## Lint Integration

`lint-config.md` defines which rules are BLOCKING (must fix) vs WARNING (should fix). The `/lint` skill references this for severity levels.

## Quick Reference — The Non-Negotiables

These rules apply to EVERY file, EVERY time:

- **No `any`** — use `unknown` and narrow
- **No `export default`** — named exports only (except page/layout)
- **No hardcoded hex colors** — use Tailwind tokens
- **No prop drilling** — Zustand or FormProvider after 2 levels
- **No useEffect for derived state** — compute during render
- **No barrel files** — no `index.ts` that re-exports
- **`cn()` for all conditional classes** — never template literals
- **Auth check on every Convex function** — unless explicitly public with comment
- **Soft delete only** — never `ctx.db.delete()`, always `deletedAt`
- **Check before creating** — read `checklists/before-creating.md` first
