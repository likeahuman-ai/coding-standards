# Stack Detection — What to Look For Per Language/Framework

When running Phase 1 (Silent Analysis), detect the stack first, then use the matching analysis template below.

## Step 1: Detect the Stack

Check these files in order:

```
package.json          -> Node.js / JavaScript / TypeScript
tsconfig.json         -> TypeScript
next.config.*         -> Next.js
nuxt.config.*         -> Nuxt
svelte.config.*       -> SvelteKit
astro.config.*        -> Astro
vite.config.*         -> Vite (React/Vue/Svelte)
angular.json          -> Angular
remix.config.*        -> Remix
Cargo.toml            -> Rust
go.mod                -> Go
pyproject.toml        -> Python (modern)
requirements.txt      -> Python (legacy)
setup.py              -> Python (legacy)
Gemfile               -> Ruby
pom.xml               -> Java (Maven)
build.gradle          -> Java/Kotlin (Gradle)
composer.json         -> PHP
pubspec.yaml          -> Dart/Flutter
*.csproj              -> C# / .NET
Makefile              -> Could be anything — check contents
docker-compose.yml    -> Check services for stack hints
```

Then detect sub-frameworks:

| Signal | Framework |
|---|---|
| `convex/` directory with `schema.ts` | Convex backend |
| `prisma/schema.prisma` | Prisma ORM |
| `drizzle.config.ts` | Drizzle ORM |
| `src/trpc/` or `@trpc/server` in deps | tRPC |
| `supabase/` or `@supabase/supabase-js` | Supabase |
| `firebase.json` or `@firebase` | Firebase |
| `.storybook/` | Storybook |
| `tailwind.config.*` | Tailwind CSS |
| `styled-components` or `@emotion` in deps | CSS-in-JS |
| `sass` or `.scss` files | SCSS |
| `clerk` in deps | Clerk auth |
| `next-auth` or `@auth/` in deps | NextAuth / Auth.js |
| `stripe` in deps | Stripe payments |
| `jest.config.*` or `vitest.config.*` | Testing framework |
| `playwright.config.*` | E2E testing |
| `.github/workflows/` | GitHub Actions CI |
| `Dockerfile` | Docker |
| `vercel.json` | Vercel deployment |
| `fly.toml` | Fly.io deployment |
| `wrangler.toml` | Cloudflare Workers |

## Step 2: Language-Specific Analysis Templates

After detecting the stack, use the matching template to know WHAT to look for during codebase analysis.

---

### TypeScript / JavaScript (React, Next.js, Vue, Svelte, Node)

**Component patterns to analyze:**
- Props: inline vs extracted, interface vs type
- Exports: named vs default
- Styling: Tailwind cn() vs CSS modules vs styled-components vs inline
- State: useState vs Zustand vs Redux vs Jotai vs signals
- Data fetching: useEffect+fetch vs React Query vs SWR vs framework-native
- Forms: React Hook Form vs Formik vs native vs framework-native
- Validation: Zod vs Yup vs Joi vs Valibot
- Component size: average lines, max lines
- File structure: flat vs domain vs feature-based

**Backend patterns to analyze:**
- API style: REST routes vs tRPC vs GraphQL
- Auth: Clerk vs NextAuth vs custom vs Supabase auth
- Database: Convex vs Prisma vs Drizzle vs raw SQL vs Supabase
- Validation: Zod vs Convex validators vs Joi
- Error handling: throw vs return result vs HTTP status
- Middleware: how auth/validation/logging are composed

**TypeScript-specific:**
- Strict mode enabled?
- `any` usage frequency
- Type organization: co-located vs centralized
- Enum vs const assertion usage
- Utility type usage (Pick, Omit, Partial)

**Questions unique to TS/JS:**
- "I see [X] for state management — is that intentional or legacy?"
- "Your validation uses [Zod/Yup] on client but [different] on server — align or keep separate?"
- "Components average [N] lines — is that your target or has it drifted?"

---

### Python (Django, FastAPI, Flask)

**Project patterns to analyze:**
- Structure: monolith vs microservices vs serverless
- Typing: type hints usage, mypy/pyright strictness
- Config: pydantic settings vs python-decouple vs env vars
- Testing: pytest vs unittest, fixture patterns
- Imports: absolute vs relative, isort config
- Docstrings: Google style vs NumPy style vs none
- Error handling: exceptions vs result types
- Formatting: black, ruff, autopep8

**Django-specific:**
- Model patterns: fat models vs thin, mixins, abstract bases
- View style: CBV vs FBV vs DRF viewsets
- Serializers: DRF vs Pydantic vs marshmallow
- Query patterns: select_related, prefetch_related usage
- Signals vs explicit calls
- Admin customization depth
- Migration discipline

**FastAPI-specific:**
- Router organization: domain-based vs flat
- Dependency injection patterns
- Pydantic model organization
- Background tasks vs Celery vs Arq
- Middleware composition
- Response model patterns

**Questions unique to Python:**
- "I see both sync and async views — what's your rule for when to use which?"
- "Your models use [mixins/abstract bases/plain] — is that the pattern you want everywhere?"
- "Docstrings are [present in some/missing in most] — what's your standard?"
- "I see raw SQL in [file] but ORM elsewhere — intentional for performance?"

---

### Go

**Project patterns to analyze:**
- Structure: standard layout (`cmd/`, `internal/`, `pkg/`) vs flat
- Error handling: `if err != nil` style, error wrapping, sentinel errors
- Interface patterns: implicit, where defined (consumer vs producer)
- Concurrency: goroutine patterns, channel usage, sync primitives
- Testing: table-driven tests, testify vs standard lib
- Logging: slog vs zerolog vs zap
- Config: viper vs envconfig vs flags
- HTTP: stdlib vs chi vs gin vs echo vs fiber

**Questions unique to Go:**
- "I see interfaces defined at [consumer/producer] — which is your convention?"
- "Error wrapping: do you use fmt.Errorf with %w, or a library?"
- "Your packages export [a lot/minimal] — what's your API surface philosophy?"
- "Context propagation: I see it [consistently/inconsistently] — what's the rule?"

---

### Rust

**Project patterns to analyze:**
- Crate structure: workspace vs single crate
- Error handling: anyhow vs thiserror vs custom
- Async runtime: tokio vs async-std
- Serialization: serde patterns
- Testing: unit vs integration, test organization
- Trait patterns: impl blocks organization
- Ownership patterns: clone frequency, Arc/Rc usage
- Unsafe usage: frequency and documentation

**Questions unique to Rust:**
- "I see `unwrap()` in [N] places — is that acceptable or should it be `?` or `expect()`?"
- "Your error types are [custom/anyhow/thiserror] — is that the standard?"
- "Clone usage: I see it [rarely/frequently] — what's your philosophy?"

---

### Java / Kotlin

**Project patterns to analyze:**
- Architecture: layered vs hexagonal vs clean architecture
- DI: Spring vs Dagger vs manual
- Testing: JUnit 5 vs Kotest, Mockito vs MockK
- Patterns: DTO vs record, builder pattern usage
- Null safety: Optional vs nullable (Kotlin) vs annotations
- Error handling: checked exceptions vs unchecked vs Result
- Naming: Hungarian notation, interface prefix (I*)

**Questions unique to Java/Kotlin:**
- "I see both DTOs and records — which is the standard going forward?"
- "Your services are [thin/fat] — where does business logic live?"
- "Kotlin null safety: I see `!!` in [N] places — is that acceptable?"

---

### Ruby (Rails)

**Project patterns to analyze:**
- Architecture: standard Rails vs service objects vs CQRS
- Testing: RSpec vs minitest, factory patterns
- Model complexity: validations, callbacks, concerns
- Controller style: thin vs fat, before_action usage
- Background jobs: Sidekiq vs delayed_job vs solid_queue
- Naming: Rails conventions followed or customized

**Questions unique to Ruby:**
- "I see service objects in [some/all] domains — is that the pattern?"
- "Your models use [concerns/mixins/plain] for shared behavior — standard?"
- "N+1 queries: I see [includes/preload/none] — what's the rule?"

---

### PHP (Laravel)

**Project patterns to analyze:**
- Architecture: MVC vs DDD vs service layer
- Eloquent patterns: scopes, accessors, relationships
- Testing: PHPUnit vs Pest, factory patterns
- Request validation: FormRequest vs inline
- Error handling: exception handler customization
- Queue patterns: jobs, listeners, events

---

### Mobile (React Native / Flutter / Swift / Kotlin)

**React Native / Expo:**
- Navigation: React Navigation vs Expo Router
- State: Zustand vs Redux vs Jotai
- Styling: StyleSheet vs NativeWind vs styled-components
- Animation: Reanimated vs Animated API
- Platform-specific: Platform.select usage

**Flutter:**
- State: BLoC vs Riverpod vs Provider vs GetX
- Architecture: clean architecture vs MVVM
- Widget organization: small widgets vs large
- Routing: go_router vs auto_route

**Swift:**
- Architecture: MVVM vs MVC vs TCA
- UI: SwiftUI vs UIKit
- Concurrency: async/await vs Combine
- Data: CoreData vs SwiftData vs Realm

---

## Step 3: Universal Patterns (Check for ALL Stacks)

Regardless of language/framework, always analyze:

| Category | What to check |
|---|---|
| **Git** | Commit message style, branch naming, PR workflow |
| **CI/CD** | Pipeline config, what runs on PR, what runs on merge |
| **Testing** | Test coverage, test file organization, testing philosophy |
| **Documentation** | README quality, inline docs, API docs |
| **Security** | Secret management, auth patterns, input validation |
| **Error handling** | Consistency, error propagation, user-facing messages |
| **Logging** | Structured vs unstructured, what's logged, what's not |
| **Config management** | Env vars, feature flags, environment separation |
| **Code organization** | Flat vs nested, domain vs technical grouping |
| **Dependencies** | Up to date? Locked? Audited? |
| **Naming** | Consistent? What convention? Abbreviations? |
| **File size** | Average, max, at what point do they split? |
| **DRY threshold** | When do they extract? Rule of two? Three? |
| **Formatting** | Enforced by tool? Which one? Consistent? |

## Step 4: Generate Stack-Appropriate Standards

The coding-standards files generated should match the detected stack:

| Detected stack | Generate these rule files |
|---|---|
| Any | `reuse-first.md`, `naming-conventions.md`, `file-organization.md`, `general-quality.md`, `security.md`, `error-handling.md` |
| TypeScript | + `typescript-quality.md`, `types-and-constants.md` |
| React/Next.js | + `react-patterns.md`, `component-architecture.md`, `state-management.md` |
| Tailwind | + `tailwind-and-tokens.md` |
| Convex | + `convex-backend.md` |
| Prisma/Drizzle/SQL | + `database-patterns.md` |
| tRPC | + `trpc-patterns.md` |
| Python | + `python-quality.md`, `django-patterns.md` or `fastapi-patterns.md` |
| Go | + `go-patterns.md` |
| Rust | + `rust-patterns.md` |
| Mobile | + `mobile-patterns.md` |
| Node.js backend | + `nodejs-backend.md` |

Don't generate files for stacks that aren't in the project. Don't generate empty files.
