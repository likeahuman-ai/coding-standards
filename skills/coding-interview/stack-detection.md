# Stack Detection — What to Look For Per Language/Framework

When running Phase 1 (Silent Analysis), detect the stack first, then use the matching analysis template below.

## Step 1: Detect the Stack

### Primary detection — config files at project root

```
package.json          -> Node.js / JavaScript / TypeScript
tsconfig.json         -> TypeScript
next.config.*         -> Next.js
nuxt.config.*         -> Nuxt (Vue)
svelte.config.*       -> SvelteKit
astro.config.*        -> Astro
angular.json          -> Angular
remix.config.*        -> Remix
gatsby-config.*       -> Gatsby
vite.config.*         -> Vite (check deps for React/Vue/Svelte)
Cargo.toml            -> Rust
go.mod                -> Go
pyproject.toml        -> Python (modern)
requirements.txt      -> Python
setup.py              -> Python (legacy)
manage.py             -> Django
Gemfile               -> Ruby
pom.xml               -> Java (Maven)
build.gradle*         -> Java/Kotlin (Gradle)
composer.json         -> PHP
artisan               -> Laravel
pubspec.yaml          -> Dart/Flutter
*.csproj / *.sln      -> C# / .NET
mix.exs               -> Elixir
build.sbt             -> Scala
stack.yaml            -> Haskell
deno.json             -> Deno
Makefile              -> Check contents for language hints
docker-compose.yml    -> Check services for stack hints
terraform/*.tf        -> Terraform / IaC
serverless.yml        -> Serverless Framework
```

### Sub-framework detection — dependencies and directories

| Signal | Framework |
|---|---|
| **JS/TS Backends** | |
| `convex/` with `schema.ts` | Convex |
| `prisma/schema.prisma` | Prisma ORM |
| `drizzle.config.ts` | Drizzle ORM |
| `@trpc/server` in deps | tRPC |
| `express` in deps | Express.js |
| `fastify` in deps | Fastify |
| `@nestjs/core` in deps | NestJS |
| `hono` in deps | Hono |
| `elysia` in deps | Elysia (Bun) |
| **JS/TS Frontend** | |
| `react` + `next` in deps | Next.js (React) |
| `react` without `next` | React (Vite/CRA) |
| `vue` in deps | Vue.js |
| `@angular/core` in deps | Angular |
| `svelte` in deps | Svelte/SvelteKit |
| `astro` in deps | Astro |
| `solid-js` in deps | SolidJS |
| `@remix-run/react` in deps | Remix |
| `gatsby` in deps | Gatsby |
| **BaaS / Database** | |
| `supabase` or `@supabase/supabase-js` | Supabase |
| `firebase` or `@firebase/app` | Firebase |
| `@planetscale/database` | PlanetScale |
| `mongoose` in deps | MongoDB (Mongoose) |
| `typeorm` in deps | TypeORM |
| `sequelize` in deps | Sequelize |
| `knex` in deps | Knex.js |
| **Auth** | |
| `@clerk` in deps | Clerk |
| `next-auth` or `@auth/` in deps | Auth.js / NextAuth |
| `lucia` in deps | Lucia auth |
| `passport` in deps | Passport.js |
| **Styling** | |
| `tailwind.config.*` | Tailwind CSS |
| `styled-components` or `@emotion` in deps | CSS-in-JS |
| `sass` or `.scss` files | SCSS |
| `@vanilla-extract` in deps | Vanilla Extract |
| **Testing** | |
| `jest.config.*` or `vitest.config.*` | JS testing |
| `playwright.config.*` | E2E testing |
| `cypress.config.*` | Cypress E2E |
| `.rspec` | RSpec (Ruby) |
| `pytest.ini` or `conftest.py` | Pytest (Python) |
| **PHP sub-frameworks** | |
| `artisan` + `routes/web.php` | Laravel |
| `symfony.lock` or `config/bundles.php` | Symfony |
| `wp-config.php` or `wp-content/` | WordPress |
| `craft` or `config/general.php` | Craft CMS |
| **Python sub-frameworks** | |
| `manage.py` + `settings.py` | Django |
| `fastapi` in deps | FastAPI |
| `flask` in deps | Flask |
| `celery` in deps | Celery (background jobs) |
| **Deployment** | |
| `.github/workflows/` | GitHub Actions |
| `.gitlab-ci.yml` | GitLab CI |
| `vercel.json` | Vercel |
| `fly.toml` | Fly.io |
| `wrangler.toml` | Cloudflare Workers |
| `render.yaml` | Render |
| `railway.toml` | Railway |
| `Procfile` | Heroku |
| `app.yaml` | Google Cloud |

---

## Step 2: Language-Specific Analysis Templates

After detecting the stack, use the matching template to know WHAT to look for.

---

### TypeScript / JavaScript — General

**Applies to all JS/TS projects. Combine with framework-specific sections below.**

**Language patterns:**
- Strict mode: `tsconfig.json` -> `strict: true`?
- `any` usage frequency
- Type organization: co-located vs centralized vs inline
- Enum vs const assertion
- Utility types: Pick, Omit, Partial, Record
- Null handling: optional chaining, nullish coalescing, strict null checks
- Module system: ESM vs CJS
- Path aliases: `@/` configured?

**Code quality:**
- Linter: ESLint config and rules
- Formatter: Prettier config
- Import sorting: eslint-plugin-import, simple-import-sort
- Package manager: npm vs pnpm vs yarn vs bun

**Questions:**
- "I see [X] for state management — is that intentional or legacy?"
- "Strict mode is [on/off] — do you want to enforce it?"
- "Components average [N] lines — is that your target?"

---

### React (Next.js, Remix, Vite, Gatsby)

**Component patterns:**
- Props: inline vs extracted, interface vs type
- Exports: named vs default
- Styling: Tailwind cn() vs CSS modules vs styled-components vs inline
- State: useState vs Zustand vs Redux vs Jotai vs signals
- Data fetching: useEffect+fetch vs React Query vs SWR vs Server Components
- Forms: React Hook Form vs Formik vs native
- Validation: Zod vs Yup vs Joi vs Valibot
- Component size: average and max lines
- File structure: flat vs domain vs feature-based

**Next.js-specific:**
- Server vs Client components pattern
- App Router vs Pages Router
- Server Actions usage
- ISR / revalidation strategy
- Middleware patterns
- `next/image`, `next/font` usage

**Remix-specific:**
- Loader/action patterns
- Form vs fetcher usage
- Error boundary strategy
- Nested routing usage

**Questions:**
- "Server Components are [used/not used] — is that intentional?"
- "I see useEffect+fetch in [N] places — should these be Server Components or React Query?"

---

### Vue.js / Nuxt

**Component patterns:**
- Composition API vs Options API
- `<script setup>` usage
- Props: defineProps with types vs runtime validation
- Emits: defineEmits pattern
- State: Pinia vs Vuex vs composables
- Styling: scoped CSS vs Tailwind vs CSS modules
- Component naming: PascalCase vs kebab-case in templates

**Nuxt-specific:**
- Auto-imports enabled?
- Server routes (`server/api/`) patterns
- useFetch vs useAsyncData vs $fetch
- Middleware patterns
- Layout system usage
- Composables organization

**Questions:**
- "I see both Options API and Composition API — which is the standard going forward?"
- "Pinia stores are [well-organized/scattered] — what's your domain grouping?"

---

### Angular

**Component patterns:**
- Standalone components vs NgModule
- Signals vs RxJS observables
- Change detection: OnPush vs Default
- Template style: inline vs external
- State: NgRx vs NGXS vs signals vs services
- Forms: reactive vs template-driven
- Dependency injection patterns

**Architecture:**
- Feature modules organization
- Lazy loading strategy
- Shared module patterns
- Interceptor usage
- Guard patterns
- Resolver patterns

**Questions:**
- "I see both standalone and NgModule components — migrating or mixed intentionally?"
- "RxJS operators: I see [complex chains/simple pipes] — what's the complexity tolerance?"

---

### Svelte / SvelteKit

**Component patterns:**
- Runes ($state, $derived) vs legacy ($:, let)
- Props: $props() pattern
- Store patterns: writable vs custom stores
- Styling: scoped CSS vs Tailwind
- Component composition: slots vs snippets
- Event handling: on: directives vs callback props

**SvelteKit-specific:**
- Load functions: +page.ts vs +page.server.ts
- Form actions vs API routes
- Hooks (handle, handleError)
- Adapter choice (node, vercel, static)

**Questions:**
- "Using Svelte 5 runes or legacy reactive declarations?"
- "Load functions: I see [server/universal/mixed] — what's the rule?"

---

### Astro

**Patterns:**
- Island architecture: which components are hydrated?
- Content Collections usage
- Framework mixing: React + Vue + Svelte in same project?
- Styling: Tailwind vs scoped CSS
- Data fetching: Astro.glob vs content collections vs fetch
- SSG vs SSR vs hybrid

**Questions:**
- "I see [React/Vue/Svelte] islands — is one framework preferred for interactive parts?"
- "Content Collections vs markdown files — which is the standard?"

---

### Python — General

**Applies to all Python projects. Combine with framework-specific sections below.**

**Language patterns:**
- Type hints: comprehensive vs partial vs none
- Type checker: mypy vs pyright vs none
- Formatting: black vs ruff format vs autopep8
- Linting: ruff vs flake8 vs pylint
- Import sorting: isort vs ruff
- Docstrings: Google style vs NumPy style vs none
- Error handling: exceptions vs result types
- Config: pydantic-settings vs python-decouple vs env vars
- Testing: pytest vs unittest, fixture patterns
- Async: asyncio usage, sync vs async preference

**Questions:**
- "Type hints are [comprehensive/partial/missing] — what's your standard?"
- "I see both sync and async code — what's your rule for when to use which?"

---

### Django

**Model patterns:**
- Fat models vs thin models
- Mixins and abstract base classes
- Custom managers and querysets
- Signal usage vs explicit calls

**View patterns:**
- Class-based views (CBV) vs function-based views (FBV)
- DRF viewsets vs APIView vs generic views
- Serializers: DRF vs Pydantic vs marshmallow
- Permission classes

**Query patterns:**
- select_related, prefetch_related usage
- QuerySet chaining style
- Raw SQL frequency
- N+1 prevention

**Other:**
- Admin customization depth
- Migration discipline
- Celery task patterns
- Template vs API-only

**Questions:**
- "Models use [fat/thin] pattern — where does business logic live?"
- "I see raw SQL in [file] but ORM elsewhere — intentional?"

---

### FastAPI

**Patterns:**
- Router organization: domain-based vs flat
- Dependency injection depth
- Pydantic model organization (schemas/ vs models/)
- Response model patterns
- Background tasks vs Celery vs Arq
- Middleware composition
- CORS configuration
- WebSocket patterns

**Questions:**
- "Pydantic models are [co-located/centralized] — which is the standard?"
- "I see both sync and async endpoints — what's your rule?"

---

### Flask

**Patterns:**
- Blueprints: how organized?
- App factory pattern usage
- Extension patterns (Flask-SQLAlchemy, Flask-Login, etc.)
- Request validation: marshmallow vs pydantic vs manual
- Error handling: errorhandler decorators
- Configuration: from_object vs from_envvar

**Questions:**
- "Blueprints are organized by [domain/type] — which is preferred?"
- "I see both Flask-WTF and manual validation — standardize?"

---

### Go

**Project patterns:**
- Structure: standard layout (`cmd/`, `internal/`, `pkg/`) vs flat
- Error handling: `if err != nil` style, error wrapping (`%w`), sentinel errors
- Interface patterns: implicit, where defined (consumer vs producer)
- Concurrency: goroutine patterns, channel usage, sync primitives, errgroup
- Testing: table-driven tests, testify vs standard lib, golden files
- Logging: slog vs zerolog vs zap
- Config: viper vs envconfig vs flags vs koanf
- HTTP: stdlib vs chi vs gin vs echo vs fiber

**Questions:**
- "Interfaces defined at [consumer/producer] — which convention?"
- "Error wrapping: fmt.Errorf with %w, or a library?"
- "Context propagation: [consistent/inconsistent] — what's the rule?"
- "Package exports: [a lot/minimal] — API surface philosophy?"

---

### Rust

**Project patterns:**
- Crate structure: workspace vs single crate
- Error handling: anyhow vs thiserror vs custom
- Async runtime: tokio vs async-std
- Web framework: Axum vs Actix-web vs Rocket vs Warp
- Serialization: serde derive patterns
- Testing: unit vs integration, proptest, test organization
- Trait patterns: impl blocks organization, trait objects vs generics
- Ownership: clone frequency, Arc/Rc usage
- Unsafe: frequency and `// SAFETY:` documentation
- Logging: tracing vs log crate

**Questions:**
- "`unwrap()` in [N] places — acceptable or should be `?` / `expect()`?"
- "Error types: [custom/anyhow/thiserror] — standard?"
- "Clone usage: [rare/frequent] — philosophy?"

---

### Java / Spring Boot

**Architecture:**
- Layered (Controller -> Service -> Repository) vs hexagonal vs clean
- Spring Boot version and conventions
- DI: constructor injection (preferred) vs field injection
- Configuration: application.yml vs properties, profiles

**Patterns:**
- DTOs vs records vs entities in API layer
- Exception handling: @ControllerAdvice, custom exceptions
- Validation: Jakarta Bean Validation (@Valid, @NotNull)
- Security: Spring Security config, method security
- Testing: @SpringBootTest vs @WebMvcTest vs unit tests, Mockito

**Questions:**
- "DTOs and records coexist — which going forward?"
- "Services are [thin/fat] — where does business logic live?"
- "Field injection vs constructor injection — which is standard?"

---

### Kotlin (Spring/Ktor/Android)

**Kotlin-specific:**
- Null safety: `!!` usage frequency
- Coroutines: structured concurrency, Flow usage
- Data classes vs regular classes
- Extension functions organization
- Sealed classes for state/error modeling

**Ktor-specific:**
- Routing: typed routes vs string-based
- Plugin composition
- Serialization: kotlinx.serialization vs Gson vs Jackson

**Android-specific:**
- Jetpack Compose vs XML layouts
- ViewModel patterns
- Navigation: Compose Navigation vs Navigation Component
- State: StateFlow vs LiveData vs Compose state
- Hilt dependency injection

**Questions:**
- "`!!` in [N] places — acceptable or should be safe calls?"
- "Coroutines: [structured/ad-hoc] — what's the pattern?"

---

### C# / .NET / ASP.NET

**Architecture:**
- Minimal API vs Controller-based
- Clean Architecture vs N-tier vs vertical slices
- Dependency injection: built-in vs Autofac vs Scrutor
- CQRS / MediatR patterns

**Patterns:**
- Nullable reference types enabled?
- Record types vs classes
- Entity Framework: code-first vs database-first, migrations
- Error handling: Result pattern vs exceptions
- Validation: FluentValidation vs DataAnnotations
- Testing: xUnit vs NUnit, Moq vs NSubstitute

**Questions:**
- "Nullable reference types: [enabled/disabled] — enforce?"
- "Minimal API vs controllers — which for new endpoints?"
- "EF migrations: [disciplined/ad-hoc] — what's the process?"

---

### PHP / Laravel

**Architecture:**
- Standard MVC vs DDD vs service layer vs action pattern
- Laravel version and conventions

**Eloquent patterns:**
- Scopes (local and global)
- Accessors and mutators (Attribute casting)
- Relationship definitions and eager loading
- Model events vs observers
- Custom collections

**Routing & Controllers:**
- Resource controllers vs single action controllers
- Route model binding
- Form Requests for validation
- API Resources for response transformation
- Middleware usage

**Other patterns:**
- Queue/job patterns: dispatch, ShouldQueue, batching
- Event/Listener patterns
- Service Provider organization
- Facade usage vs dependency injection
- Blade components vs Livewire vs Inertia
- Testing: Pest vs PHPUnit, factory patterns

**Questions:**
- "I see both Facades and DI — which is preferred?"
- "Validation: FormRequest [everywhere/sometimes] — standardize?"
- "Blade vs Livewire vs Inertia — which for interactive parts?"
- "Service classes in [some/all] domains — the pattern?"

---

### PHP / Symfony

**Patterns:**
- Bundle organization
- Doctrine entity patterns
- Form component usage
- Security: voters vs access control
- Messenger component for async
- Event dispatcher patterns
- Twig templates vs API-only

---

### PHP / WordPress

**Patterns:**
- Theme vs plugin development
- Custom Post Types and taxonomies
- ACF vs native custom fields
- Hook system: actions and filters
- REST API customization
- Block editor (Gutenberg) patterns
- Database: $wpdb vs ORM

---

### Ruby / Rails

**Architecture:**
- Standard Rails vs service objects vs CQRS vs dry-rb
- Rails version and conventions

**Model patterns:**
- Validations, callbacks, concerns
- ActiveRecord scopes
- Polymorphic associations
- STI vs polymorphism

**Controller patterns:**
- Thin controllers, before_action usage
- Strong parameters
- Respond_to patterns
- API mode vs full-stack

**Other:**
- Background jobs: Sidekiq vs delayed_job vs solid_queue vs good_job
- Testing: RSpec vs minitest, FactoryBot, shoulda-matchers
- View: ERB vs Haml vs Slim, ViewComponent, Hotwire/Turbo
- Stimulus patterns

**Questions:**
- "Service objects in [some/all] domains — standard?"
- "Concerns for shared behavior — or mixins?"
- "N+1: [includes/preload/eager_load] — what's the rule?"

---

### Elixir / Phoenix

**Patterns:**
- Context module organization (bounded contexts)
- Ecto schema and changeset patterns
- GenServer and process architecture
- LiveView vs API-only vs both
- PubSub patterns
- Telemetry usage
- Testing: ExUnit, Mox for mocks

**Questions:**
- "Contexts: [well-bounded/leaky] — how strict are the boundaries?"
- "LiveView vs dead views — what's the split?"
- "GenServer: [few/many] — when do you reach for one?"

---

### Scala / Play / Akka

**Patterns:**
- FP style: pure functions, immutability, for-comprehensions
- Effect system: Cats Effect vs ZIO vs vanilla Futures
- Case classes and sealed traits
- Dependency injection: compile-time (MacWire) vs runtime (Guice)
- Testing: ScalaTest vs MUnit vs specs2

---

### Deno / Fresh

**Patterns:**
- Import maps vs URL imports
- Permission model usage
- Fresh islands architecture
- Oak/Hono middleware patterns
- Testing: Deno.test patterns

---

### Mobile — React Native / Expo

**Patterns:**
- Navigation: React Navigation vs Expo Router
- State: Zustand vs Redux vs Jotai vs MMKV
- Styling: StyleSheet vs NativeWind vs Tamagui
- Animation: Reanimated vs Animated API
- Platform-specific: Platform.select, .ios.tsx/.android.tsx
- Native modules: Expo modules vs bare RN

---

### Mobile — Flutter / Dart

**Patterns:**
- State: BLoC vs Riverpod vs Provider vs GetX
- Architecture: clean architecture vs MVVM vs MVC
- Widget organization: small atomic widgets vs large pages
- Routing: go_router vs auto_route vs Navigator 2.0
- Networking: Dio vs http package
- Local storage: Hive vs shared_preferences vs drift

---

### Mobile — Swift / SwiftUI

**Patterns:**
- Architecture: MVVM vs MVC vs TCA (The Composable Architecture)
- UI: SwiftUI vs UIKit vs mixed
- Concurrency: async/await vs Combine vs GCD
- Data: CoreData vs SwiftData vs Realm vs UserDefaults
- Networking: URLSession vs Alamofire
- Testing: XCTest, snapshot testing

---

### Mobile — Kotlin / Android

**Patterns:**
- Jetpack Compose vs XML layouts
- ViewModel + StateFlow/SharedFlow
- Navigation: Compose Navigation vs Navigation Component
- DI: Hilt vs Koin vs manual
- Networking: Retrofit + OkHttp vs Ktor client
- Local: Room vs DataStore

---

### Infrastructure / DevOps

**Terraform:**
- Module organization
- State management: local vs remote (S3, Terraform Cloud)
- Variable patterns: tfvars vs env
- Naming conventions: resource naming

**Docker:**
- Multi-stage build patterns
- Docker Compose service organization
- Volume and network patterns
- .dockerignore thoroughness

**CI/CD (GitHub Actions / GitLab CI):**
- Job organization: lint -> test -> build -> deploy
- Reusable workflows / templates
- Secret management
- Environment promotion (dev -> staging -> prod)

---

## Step 3: Universal Patterns (Check for ALL Stacks)

Regardless of language/framework, always analyze:

| Category | What to check |
|---|---|
| **Git** | Commit message style, branch naming, PR workflow, merge strategy |
| **CI/CD** | Pipeline config, what runs on PR vs merge vs deploy |
| **Testing** | Coverage, file organization, testing philosophy (TDD? skip v1?) |
| **Documentation** | README quality, inline docs, API docs, ADRs |
| **Security** | Secret management, auth patterns, input validation, dependency scanning |
| **Error handling** | Consistency, propagation, user-facing messages, logging |
| **Logging** | Structured vs unstructured, what's logged, what's NOT logged (PII) |
| **Config management** | Env vars, feature flags, environment separation |
| **Code organization** | Flat vs nested, domain vs technical grouping |
| **Dependencies** | Up to date? Lock file committed? Audited for vulnerabilities? |
| **Naming** | Consistent convention? Abbreviations? Language-idiomatic? |
| **File size** | Average, max, at what point do they split? |
| **DRY threshold** | When do they extract? Rule of two? Three? Never? |
| **Formatting** | Enforced by tool? Which one? Consistent across team? |
| **Monorepo** | Turborepo, Nx, Lerna, pnpm workspaces, Cargo workspace? |

## Step 4: Generate Stack-Appropriate Standards

The coding-standards files generated should match the detected stack:

| Detected stack | Generate these rule files |
|---|---|
| **Any project** | `reuse-first.md`, `naming-conventions.md`, `file-organization.md`, `general-quality.md`, `security.md`, `error-handling.md` |
| TypeScript | + `typescript-quality.md`, `types-and-constants.md` |
| React / Next.js / Remix | + `react-patterns.md`, `component-architecture.md`, `state-management.md` |
| Vue / Nuxt | + `vue-patterns.md`, `component-architecture.md`, `state-management.md` |
| Angular | + `angular-patterns.md`, `state-management.md` |
| Svelte / SvelteKit | + `svelte-patterns.md`, `state-management.md` |
| Tailwind CSS | + `tailwind-and-tokens.md` |
| Convex | + `convex-backend.md` |
| Prisma / Drizzle / TypeORM / Sequelize | + `database-patterns.md` |
| tRPC | + `trpc-patterns.md` |
| Node.js backend (Express, Fastify, NestJS, Hono) | + `nodejs-backend.md` |
| Python (any) | + `python-quality.md` |
| Django | + `django-patterns.md` |
| FastAPI / Flask | + `fastapi-patterns.md` |
| Go | + `go-patterns.md` |
| Rust | + `rust-patterns.md` |
| Java / Spring Boot | + `java-patterns.md` |
| Kotlin | + `kotlin-patterns.md` |
| C# / .NET | + `dotnet-patterns.md` |
| PHP / Laravel | + `laravel-patterns.md` |
| PHP / Symfony | + `symfony-patterns.md` |
| Ruby / Rails | + `rails-patterns.md` |
| Elixir / Phoenix | + `elixir-patterns.md` |
| Mobile (any) | + `mobile-patterns.md` |
| Infrastructure | + `infra-patterns.md` |

Don't generate files for stacks that aren't in the project. Don't generate empty files. For multi-stack projects (e.g., Next.js + Python microservice), generate rule files for each detected stack.
