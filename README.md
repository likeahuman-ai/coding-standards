# Claude Code Coding Standards

A skill suite for Claude Code that interviews you about your coding preferences, generates personalized standards, and enforces them with a pre-commit hook. Works with any stack.

## What's inside

| Skill | Command | What it does |
|-------|---------|-------------|
| **Coding Interview** | `/coding-interview` | Analyzes your codebase, interviews you step-by-step, generates personalized coding standards + pre-commit hook |
| **Coding Standards** | Auto-loaded | 14 rule files covering TypeScript, React, Python, Go, Rust, backend, security, state management, and more |
| **Lint** | `/lint` | On-demand code quality audit. Auto-detects your stack and applies matching rules |
| **Organize** | `/organize` | Restructures any folder into domain-driven layout with import updates |

## Quick start

```bash
git clone https://github.com/likeahuman-ai/coding-standards.git
cd coding-standards
./setup.sh
```

Then in Claude Code:

```
/coding-interview new
```

This will:
1. Silently analyze your codebase to detect patterns
2. Present a "Code Style Profile" based on what it found
3. Interview you topic-by-topic to confirm and deepen
4. Find gaps and suggest rules for uncovered areas
5. Generate all coding-standards files personalized to your stack
6. Set up a pre-commit hook that enforces the rules
7. Run a dry test and help you fix existing violations

## How it works

### The Interview (7 phases)

| Phase | What happens |
|-------|-------------|
| 1. Silent Analysis | Reads your codebase — components, backend, config, git history |
| 2. Present Findings | Shows your "Code Style Profile" and asks targeted questions |
| 3. Deep Dive | One topic at a time with examples from YOUR code |
| 4. Gap Analysis | Identifies missing standards, inconsistencies, backend gaps |
| 5. Generate Standards | Writes all rule files + pre-commit hook |
| 6. Wire Into CLAUDE.md | Connects standards to Claude Code, cleans up duplicates |
| 7. Test & Refactor | Dry runs the hook, triages violations, batch refactors |

### Stack detection

Auto-detects and adapts to your stack:

| Detected | What loads |
|----------|-----------|
| TypeScript | TypeScript quality, types/constants reuse, component architecture |
| React / Next.js | React patterns, server/client components, state management |
| Tailwind | className rules, design token enforcement |
| Python (Django/FastAPI) | Python quality, bare except, type hints, imports |
| Go | Error handling, panic prevention, structured logging |
| Rust | unwrap prevention, unsafe documentation, clippy patterns |
| Ruby (Rails) | Debug statements, N+1 queries, service objects |
| PHP (Laravel) | Debug functions, raw SQL, exit statements |
| Convex | Auth guards, soft deletes, schema conventions |
| Prisma / Drizzle | Transaction patterns, migration discipline |

### Pre-commit hook

Generated per-project with checks matching your stack. Runs on staged files only — fast, zero API cost.

**BLOCKING** (rejects commit): `any` types, hardcoded secrets, debug statements, eval(), merge markers

**WARNING** (allows commit, shows warning): file size, console.log, empty catch blocks, missing type hints

Supports `.coding-standards-ignore` for accepted tech debt.

## The rule files

```
~/.claude/skills/coding-standards/
  SKILL.md                          # Entry point (auto-loaded)
  lint-config.md                    # Severity levels (BLOCKING/WARNING/INFO)
  rules/
    reuse-first.md                  # Extend don't reinvent, building brick philosophy
    component-architecture.md       # Component anatomy, props, CVA, compound
    naming-conventions.md           # Every naming rule across languages
    file-organization.md            # Domain-driven structure per language
    types-and-constants.md          # Type reuse hierarchy, domain-level files
    typescript-quality.md           # Strict mode, branded types, discriminated unions
    react-patterns.md               # Server/client, hooks, anti-patterns
    tailwind-and-tokens.md          # cn(), CVA, design tokens, responsive
    state-management.md             # Zustand, URL state, server state, forms
    convex-backend.md               # Convex queries, mutations, actions, webhooks
    nodejs-backend.md               # Server Actions, API routes, ORMs, logging
    security.md                     # Auth, validation, XSS, OWASP
    error-handling.md               # Error boundaries, retry, resilience
    general-quality.md              # JS idioms, comments, magic values
  checklists/
    before-creating.md              # 5 questions before creating any new file
    before-committing.md            # Post-write validation checklist
```

## Modes

| Command | When to use |
|---------|-------------|
| `/coding-interview new` | First time — full interview + generation |
| `/coding-interview refresh` | Quarterly — re-analyze codebase for drift |
| `/coding-interview extend` | Add rules for a new area (mobile, testing, CI/CD) |
| `/lint` | Before shipping — deep audit |
| `/lint path/to/file` | Quick check on specific file |
| `/organize path/to/dir` | Restructure a messy directory |

## Philosophy

1. **Reuse first** — extend existing components/types/constants before creating new ones
2. **Building bricks** — components are generic materials, business logic lives in composition
3. **Domain-driven** — organize by what things DO, not what they ARE
4. **Minimum viable complexity** — three similar lines beat a premature abstraction
5. **Code speaks louder** — observe patterns before asking preferences
6. **One source of truth** — one type, one constant, one component per concept

## Requirements

- Claude Code CLI
- git + bash (no other dependencies)
- Works on macOS and Linux

## License

MIT

---

Built by [likeahuman.ai](https://likeahuman.ai)
