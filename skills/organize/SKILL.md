---
name: organize
description: Audit and reorganize any project folder into domain-driven structure. Detects framework/language, applies best practices, proposes groupings, and executes moves with import updates.
user_invocable: true
args: "[path] — folder to audit (defaults to current working directory)"
---

# /organize — Domain-Driven File Organization

Audit any folder's file organization, detect its framework/language, apply best practices, and propose + execute domain-driven restructuring.

## Workflow

### Step 1: Detect Context

Analyze the target folder to determine:

1. **Framework/runtime** — detect from config files, imports, file patterns:
   | Signal | Framework |
   |--------|-----------|
   | `convex/` with `query()`, `mutation()`, `action()` | Convex backend |
   | `src/app/` with `page.tsx`, `layout.tsx` | Next.js App Router |
   | `src/components/` with `.tsx` files | React component library |
   | `src/routes/` or `+page.svelte` | SvelteKit |
   | `*.py` with `models.py`, `views.py` | Django |
   | `*.py` with `routers/`, `schemas/` | FastAPI |
   | `*.go` with `cmd/`, `internal/` | Go project |
   | `*.rs` with `Cargo.toml` | Rust project |
   | `src/` with `index.ts` and `*.service.ts` | NestJS |
   | Generic `.ts`/`.js` files | Node.js/TypeScript |

2. **Current organization style** — flat, prefix-based, partially nested, fully domain-driven

3. **File count and complexity** — small (<15 files, probably fine), medium (15-40, could benefit), large (40+, definitely needs structure)

### Step 2: Look Up Best Practices

Check framework-specific conventions using built-in knowledge or documentation:
- Framework-specific conventions (e.g., Next.js App Router uses file-based routing, Convex namespaces functions by path)
- Community patterns (e.g., "screaming architecture", feature-first, domain-driven)
- Known constraints (e.g., some frameworks change API paths when files move to subdirectories)

**Framework-specific patterns:**

#### Convex
```
convex/
├── admin/           # Admin-only queries, mutations, actions
│   ├── users.ts
│   ├── workshops.ts
│   └── analytics.ts
├── auth/            # Authentication, access control
│   ├── access.ts
│   └── users.ts
├── billing/         # Stripe, products, purchases
│   ├── stripe.ts
│   └── products.ts
├── course/          # Courses, modules, lessons, progress
│   ├── courses.ts
│   ├── modules.ts
│   └── lessonProgress.ts
├── email/           # All email-related logic
│   ├── brevo.ts
│   ├── lifecycle.ts
│   └── templates.ts
├── workshop/        # Workshop domain
│   ├── workshops.ts
│   ├── participants.ts
│   └── insights.ts
├── webhooks/        # All webhook handlers
│   ├── clerk.ts
│   ├── stripe.ts
│   └── luma.ts
├── lib/             # Shared utilities
├── _generated/      # Auto-generated (never touch)
├── schema.ts        # Root schema
├── http.ts          # HTTP routes
└── crons.ts         # Cron jobs
```

**IMPORTANT:** Moving `convex/adminUsers.ts` → `convex/admin/users.ts` changes the API from `api.adminUsers.fn` to `api.admin.users.fn`. ALL frontend imports must be updated.

#### Next.js Components
```
src/components/
├── auth/            # Login, signup, guards
├── course/          # Course cards, lesson views
├── dashboard/       # Dashboard widgets
├── marketing/       # Landing page sections
├── settings/        # User settings
└── shared/          # Truly cross-cutting (modals, etc.)
```

#### Generic TypeScript/Node
```
src/
├── modules/
│   ├── users/       # User domain
│   │   ├── users.service.ts
│   │   ├── users.controller.ts
│   │   ├── users.types.ts
│   │   └── users.constants.ts
│   ├── billing/
│   └── auth/
├── lib/             # Shared utilities
└── types/           # Shared types
```

### Step 3: Analyze Current Structure

1. **List all files** in the target folder
2. **Group by naming patterns** — detect prefixes/suffixes:
   - `admin*.ts` → admin domain
   - `workshop*.ts` → workshop domain
   - `email*.ts` → email domain
   - `*.helpers.ts`, `*.constants.ts`, `*.types.ts` → support files follow their parent
3. **Identify orphans** — files that don't clearly belong to a group
4. **Count cross-references** — which files import from which (affects grouping)

### Step 4: Present Domain Mapping

Generate a clear table showing the proposed reorganization:

```
## Proposed Domain Mapping

| Current File | → New Location | Domain |
|---|---|---|
| adminUsers.ts | admin/users.ts | admin |
| adminWorkshops.ts | admin/workshops.ts | admin |
| workshopEmails.ts | workshop/emails.ts | workshop |
| ... | ... | ... |

### Breaking Changes
- `api.adminUsers.listAll` → `api.admin.users.listAll`
- `api.workshopEmails.send` → `api.workshop.emails.send`

### Files That Stay
- schema.ts (root config)
- http.ts (root config)
- crons.ts (root config)
```

**STOP HERE** — wait for user approval before executing moves.

### Step 5: Execute Reorganization

Only after user approves:

1. **Create domain folders**
2. **Move files** using `git mv` (preserves history)
3. **Update all imports** across the entire codebase:
   - Convex: update `api.oldPath.fn` → `api.new.path.fn` in all frontend files
   - Components: update import paths
   - Internal: update relative imports between moved files
4. **Run typecheck** — `pnpm typecheck` to verify nothing broke
5. **Run the app** — verify it still works
6. **Commit** with descriptive message

### Root Config Files (Never Move)

These files must stay at the folder root regardless of framework:
- `schema.ts` / `schema.prisma` / `models.py`
- `http.ts` / `routes.ts` / `urls.py`
- `crons.ts` / `celery.py`
- `auth.config.ts` / `settings.py`
- `convex.config.ts` / `next.config.ts`
- `_generated/` / `__pycache__/`
- `seed.ts` + `seed.*.ts` (seeding stays together at root)

### Naming Conventions Per Framework

| Framework | File naming | Folder naming |
|---|---|---|
| Convex | camelCase.ts (required by runtime) | camelCase/ |
| Next.js src/ | kebab-case.tsx | kebab-case/ |
| React components | kebab-case.tsx | kebab-case/ |
| Python | snake_case.py | snake_case/ |
| Go | snake_case.go | lowercase/ |
| Rust | snake_case.rs | snake_case/ |

### Support File Conventions

Support files follow their parent domain:
- `workshops.ts` → `workshop/workshops.ts`
- `workshopInsights.helpers.ts` → `workshop/insights.helpers.ts`
- `workshopInsights.types.ts` → `workshop/insights.types.ts`
- `workshopInsights.constants.ts` → `workshop/insights.constants.ts`

When a domain has many support files, the prefix becomes redundant inside the folder:
- `workshopFeedbackEmails.ts` → `workshop/feedbackEmails.ts` (drop `workshop` prefix)
- `workshopFeedbackEmails.constants.ts` → `workshop/feedbackEmails.constants.ts`

## Flags

- `/organize convex/` — audit and reorganize the convex folder
- `/organize src/components/` — audit and reorganize components
- `/organize --dry-run` — show proposed changes without executing
- `/organize --execute` — skip approval step (use with caution)
