# File Organization

## Core Principle: Domain-Driven Structure

Group files by **what they do** (domain), not **what they are** (type). This applies to every language.

```
// WRONG: grouped by type (technical)
controllers/
  user_controller.py
  course_controller.py
  billing_controller.py
models/
  user.py
  course.py
  billing.py
services/
  user_service.py
  course_service.py
  billing_service.py

// RIGHT: grouped by domain
user/
  controller.py
  model.py
  service.py
  types.py
course/
  controller.py
  model.py
  service.py
billing/
  controller.py
  model.py
  service.py
shared/
  utils.py
  constants.py
```

## The Separation Rule

Source files contain ONE concern. Support files are co-located per domain, not per source file.

| Content | Location | Example |
|---|---|---|
| Types/interfaces | Domain-level `types` file | `user/types.ts`, `user/types.py` |
| Constants/config | Domain-level `constants` file | `billing/constants.ts` |
| Helper/utility functions | `lib/` or `utils/` (shared) or domain `utils` | `lib/dates.ts`, `user/utils.py` |
| Validation schemas | `lib/validations/` or domain co-located | `validations/checkout.ts` |

**One types file per domain, NOT per source file:**

```
// WRONG
user/
  user-card.types.ts
  user-profile.types.ts
  user-settings.types.ts

// RIGHT
user/
  user-card.tsx
  user-profile.tsx
  user-settings.tsx
  types.ts              <- all user domain types
  constants.ts          <- all user domain constants
```

## Language-Specific Directory Conventions

### TypeScript / Next.js
```
src/
  app/                    # Route files only (page, layout, loading, error)
  components/{domain}/    # Domain-grouped components
  hooks/                  # Custom hooks
  lib/                    # Shared utilities
    validations/          # Zod schemas
    constants.ts          # App-wide constants
  types/                  # Shared types
  stores/                 # State stores (Zustand, etc.)
```

### Python / Django
```
project/
  {domain}/               # Django apps = domains
    models.py
    views.py
    serializers.py
    services.py           # Business logic (not in views)
    tests/
  common/                 # Shared utilities
    utils.py
    constants.py
```

### Python / FastAPI
```
src/
  {domain}/
    router.py
    schemas.py            # Pydantic models
    service.py
    repository.py
  core/                   # Config, deps, middleware
  lib/                    # Shared utilities
```

### Go
```
cmd/                      # Entry points
  server/main.go
internal/                 # Private packages
  {domain}/
    handler.go
    service.go
    repository.go
    model.go
pkg/                      # Public packages (if library)
```

### Rust
```
src/
  {domain}/
    mod.rs
    handler.rs
    service.rs
    model.rs
  lib.rs / main.rs
```

## Import Rules (Universal Principles)

| Rule | Example |
|---|---|
| Absolute imports in app code | `@/lib/utils`, `from project.common.utils` |
| Relative imports within a package/module | `from .models import User`, `../../lib/utils` |
| Import order: stdlib -> external -> internal -> local | Every language follows this |

## No Duplication Rules

- A constant in 2+ files -> extract to shared location
- A utility in 2+ files -> extract to `lib/` or `shared/`
- A type in 2+ files -> extract to `types/` or domain `types` file

## No Barrel Files (TypeScript/JS)

No `index.ts` files that only re-export. Import from the source directly.

## Files That Never Move (Root Config)

Every project has root files that stay at project root regardless of restructuring:
- Config: `tsconfig.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`
- Schema: `schema.ts`, `schema.prisma`, `models.py`
- CI/CD: `.github/`, `Dockerfile`, `docker-compose.yml`
- Generated: `_generated/`, `__pycache__/`, `target/`, `node_modules/`

## When to Suggest `/organize`

If `/lint` finds >5 file organization violations, suggest running `/organize` for a full restructuring instead of fixing files one by one.
