# Claude Code Coding Standards

A plugin for Claude Code that interviews you about your coding preferences, generates personalized standards, and enforces them with a pre-commit hook. Works with any stack.

## What's inside

| Skill | Command | What it does |
|-------|---------|-------------|
| **Coding Interview** | `/coding-standards:coding-interview` | Analyzes your codebase, interviews you step-by-step, generates personalized coding standards + pre-commit hook |
| **Coding Standards** | Auto-loaded | Rule files generated for YOUR stack — only the ones that match |
| **Lint** | `/coding-standards:lint` | On-demand code quality audit. Auto-detects your stack and applies matching rules |
| **Organize** | `/coding-standards:organize` | Restructures any folder into domain-driven layout with import updates |

## Install

### Option A: Plugin install (recommended)

```
/plugin install coding-standards@likeahuman-ai
```

This installs it as a Claude Code plugin. Skills are loaded automatically, no manual setup needed.

### Option B: Manual install

```bash
git clone https://github.com/likeahuman-ai/coding-standards.git
cd coding-standards
./setup.sh
```

Then add to your `~/.claude/CLAUDE.md`:
```
Auto-loaded skills: coding-standards/SKILL.md
```

### Get started

In Claude Code:

```
/coding-standards:coding-interview new
```

This will:
1. Silently analyze your codebase to detect your stack and patterns
2. Present a "Code Style Profile" based on what it found
3. Interview you topic-by-topic to confirm and deepen
4. Find gaps and suggest rules for uncovered areas
5. Generate coding-standards files personalized to your stack
6. Set up a pre-commit hook that enforces the rules
7. Run a dry test and help you fix existing violations

## How it works

### The Interview (7 phases)

| Phase | What happens |
|-------|-------------|
| 1. Silent Analysis | Reads your codebase — detects stack, components, backend, config, git history |
| 2. Present Findings | Shows your "Code Style Profile" and asks targeted questions |
| 3. Deep Dive | One topic at a time with examples from YOUR code |
| 4. Gap Analysis | Identifies missing standards, inconsistencies, backend gaps |
| 5. Generate Standards | Writes only the rule files matching your detected stack |
| 6. Wire Into CLAUDE.md | Connects standards to Claude Code, cleans up duplicates |
| 7. Test & Refactor | Dry runs the hook, triages violations, batch refactors |

### Supported stacks (25+)

The interview and linter auto-detect and adapt to your project:

| Category | Frameworks & Languages |
|----------|----------------------|
| **JS/TS Frontend** | React, Next.js, Vue/Nuxt, Angular, Svelte/SvelteKit, Astro, Remix, Gatsby, SolidJS |
| **JS/TS Backend** | Express, Fastify, NestJS, Hono, Elysia, tRPC, Convex |
| **Python** | Django, FastAPI, Flask, Celery |
| **PHP** | Laravel (deep), Symfony, WordPress |
| **Ruby** | Rails (deep) |
| **Go** | Chi, Gin, Echo, Fiber + standard layout |
| **Rust** | Axum, Actix-web, Rocket, Warp |
| **Java** | Spring Boot (deep) |
| **Kotlin** | Ktor, Android/Compose |
| **C# / .NET** | ASP.NET Minimal API + Controllers, EF Core |
| **Elixir** | Phoenix, LiveView |
| **Scala** | Play, Akka |
| **Deno** | Fresh, Oak |
| **Mobile** | React Native/Expo, Flutter/Dart, SwiftUI, Kotlin/Compose |
| **Infrastructure** | Terraform, Docker, GitHub Actions, GitLab CI |
| **Databases/ORMs** | Prisma, Drizzle, TypeORM, Sequelize, Mongoose, Ecto, EF Core, Eloquent |
| **Auth** | Clerk, Auth.js/NextAuth, Lucia, Passport, Spring Security |
| **Styling** | Tailwind, CSS Modules, styled-components, Vanilla Extract, SCSS |

### Pre-commit hook

Generated per-project with checks matching your detected stack. Runs on staged files only — fast, zero API cost.

**14 language check blocks:** TypeScript/JS, Python, Go, Rust, Ruby, PHP/Laravel, C#, Elixir, Kotlin, Scala, Dart, Swift + universal checks

**BLOCKING** (rejects commit): hardcoded secrets, debug statements left in code, `eval()`, merge conflict markers, `.env` files staged

**WARNING** (allows commit, shows alert): file size, production print/log statements, empty catch blocks, force unwraps, mutable where immutable preferred

Supports `.coding-standards-ignore` for accepted tech debt.

### What gets generated

The interview generates ONLY the files matching your stack — not all of them. Example for a Next.js + Convex + Tailwind project:

```
~/.claude/skills/coding-standards/
  SKILL.md                          # Entry point (auto-loaded)
  lint-config.md                    # Severity levels (BLOCKING/WARNING/INFO)
  rules/
    reuse-first.md                  # Extend don't reinvent, building brick philosophy
    component-architecture.md       # Component anatomy, props, composition (React)
    naming-conventions.md           # Every naming rule for your stack
    file-organization.md            # Domain-driven structure
    types-and-constants.md          # Type reuse hierarchy (TypeScript)
    typescript-quality.md           # Strict mode, branded types (TypeScript)
    react-patterns.md               # Server/client, hooks (React/Next.js)
    tailwind-and-tokens.md          # cn(), CVA, design tokens (Tailwind)
    state-management.md             # Zustand, URL state, server state
    convex-backend.md               # Queries, mutations, actions (Convex)
    security.md                     # Auth, validation, XSS
    error-handling.md               # Error boundaries, retry, resilience
    general-quality.md              # Idioms, comments, magic values
  checklists/
    before-creating.md              # 5 questions before creating any new file
    before-committing.md            # Post-write validation checklist
```

A Django + FastAPI project would get different files:

```
  rules/
    reuse-first.md                  # Same universal rules
    naming-conventions.md           # Python naming (snake_case, etc.)
    file-organization.md            # Django app structure
    python-quality.md               # Type hints, bare except, imports
    django-patterns.md              # Models, views, serializers, queries
    fastapi-patterns.md             # Routers, Pydantic, dependency injection
    security.md                     # Auth, validation, OWASP
    error-handling.md               # Exception patterns
    general-quality.md              # Same universal rules
```

A Go project would get:

```
  rules/
    reuse-first.md
    naming-conventions.md           # Go naming (exported vs unexported)
    file-organization.md            # cmd/, internal/, pkg/
    go-patterns.md                  # Error handling, interfaces, concurrency
    security.md
    error-handling.md               # if err != nil patterns
    general-quality.md
```

## Modes

| Command | When to use |
|---------|-------------|
| `/coding-standards:coding-interview new` | First time — full interview + standard generation |
| `/coding-standards:coding-interview refresh` | Quarterly — re-analyze codebase for drift |
| `/coding-standards:coding-interview extend` | Add rules for a new area (mobile, testing, CI/CD) |
| `/coding-standards:lint` | Before shipping — deep audit |
| `/coding-standards:lint path/to/file` | Quick check on specific file |
| `/coding-standards:organize path/to/dir` | Restructure a messy directory |

## Philosophy

1. **Reuse first** — extend existing components/types/constants before creating new ones
2. **Building bricks** — components are small, generic, reusable units that get composed into features
3. **Domain-driven** — organize by what things DO, not what they ARE
4. **Minimum viable complexity** — three similar lines beat a premature abstraction
5. **Code speaks louder** — observe patterns before asking preferences
6. **One source of truth** — one type, one constant, one component per concept

## CLAUDE.md integration (manual install only)

If you used `./setup.sh` (not plugin install), add this to your `~/.claude/CLAUDE.md`:

```markdown
**Auto-loaded skills:** `coding-standards/SKILL.md` (coding rules and quality standards)
```

Plugin installs handle this automatically.

## Update

**Plugin:**
```
/plugin update coding-standards@likeahuman-ai
```

**Manual:**
```bash
cd coding-standards && git pull && ./setup.sh
```

## Uninstall

**Plugin:**
```
/plugin uninstall coding-standards@likeahuman-ai
```

**Manual:**
```bash
rm -rf ~/.claude/skills/coding-standards
rm -rf ~/.claude/skills/coding-interview
rm -rf ~/.claude/skills/lint
rm -rf ~/.claude/skills/organize
```
Then remove the `coding-standards/SKILL.md` line from `~/.claude/CLAUDE.md`.

## Troubleshooting

| Problem | Solution |
|---|---|
| Skills not recognized after plugin install | Run `/reload-plugins` to pick up the changes |
| `/lint` shows no results | Check that source files exist in the expected paths (`src/**/*.ts`, `**/*.py`, etc.) |
| Pre-commit hook blocks everything | Run `./scripts/check-coding-standards.sh` directly to see output. Fix violations or add to `.coding-standards-ignore` |
| Pre-commit hook permission denied | `chmod +x scripts/check-coding-standards.sh` |
| Standards feel wrong for my project | Run `/coding-standards:coding-interview refresh` to re-analyze and adjust |
| Want to add rules for a new area | Run `/coding-standards:coding-interview extend` |
| Hook checks wrong language | Verify the file extension filters in `scripts/check-coding-standards.sh` match your project |

## Requirements

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) v1.0.33+
- git + bash (no other dependencies)
- Works on macOS and Linux

## License

MIT — see [LICENSE](LICENSE)

---

Built by [likeahuman.ai](https://likeahuman.ai)
