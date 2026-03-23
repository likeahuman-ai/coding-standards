---
name: lint
description: Run a comprehensive code quality audit on any codebase. Auto-detects stack, applies matching rules from coding-standards. Use /lint to run on the full project or /lint path/to/file for a specific file or directory.
user-invocable: true
args: "[path] — file or directory to audit (defaults to all source files)"
---

# /lint — Code Quality Enforcer

Run a deep audit against coding standards. Auto-detects the project's stack and applies the right rules.

**Rules source of truth:** `~/.claude/skills/coding-standards/` — all rules live there.
**Severity mapping:** `coding-standards/lint-config.md` defines BLOCKING vs WARNING vs INFO.
**Folder organization:** Use `/organize` instead — it's the specialized tool for restructuring.

## How It Works

### Step 1: Detect Stack

Read project root for config files to determine language/framework:

| File | Stack |
|---|---|
| `package.json` + `tsconfig.json` | TypeScript/Node.js |
| `next.config.*` | Next.js |
| `pyproject.toml` / `requirements.txt` | Python |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `Gemfile` | Ruby |
| `composer.json` | PHP |
| `pubspec.yaml` | Flutter/Dart |

Then detect sub-frameworks by checking for their config files and dependencies:
- `convex/schema.ts` -> Convex
- `prisma/schema.prisma` -> Prisma
- `drizzle.config.ts` -> Drizzle
- `@trpc/server` in deps -> tRPC
- `tailwind.config.*` -> Tailwind
- `@clerk`, `next-auth` in deps -> Auth provider

See `~/.claude/skills/coding-interview/stack-detection.md` for the full detection matrix.

### Step 2: Load Matching Rules

Read only the relevant rule files from `coding-standards/rules/`:

| Detected | Load these rules |
|---|---|
| Any project | `general-quality.md`, `naming-conventions.md`, `file-organization.md`, `security.md`, `error-handling.md`, `reuse-first.md` |
| TypeScript | + `typescript-quality.md`, `types-and-constants.md` |
| React/Next.js | + `react-patterns.md`, `component-architecture.md`, `state-management.md` |
| Tailwind | + `tailwind-and-tokens.md` |
| Convex | + `convex-backend.md` |
| Node.js backend | + `nodejs-backend.md` |
| Python | Apply Python equivalents from general rules (see below) |
| Go | Apply Go equivalents from general rules (see below) |
| Rust | Apply Rust equivalents from general rules (see below) |

### Step 3: Scan Target Files

If argument given: scan that file or directory.
If no argument: scan all source files matching the detected stack:

| Stack | Default scan pattern |
|---|---|
| TypeScript/JS | `src/**/*.{ts,tsx,js,jsx}` + `convex/**/*.ts` |
| Python | `**/*.py` excluding `venv/`, `__pycache__/`, `.tox/` |
| Go | `**/*.go` excluding `vendor/` |
| Rust | `src/**/*.rs` |
| Ruby | `app/**/*.rb`, `lib/**/*.rb` |
| PHP | `app/**/*.php`, `src/**/*.php` |

### Step 4: Apply Universal Checks (All Languages)

These checks apply to every file regardless of stack:

**BLOCKING:**
- Hardcoded secrets (passwords, API keys, tokens in source)
- Merge conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)
- Debug statements left in production code (language-specific patterns below)
- `eval()` or equivalent code injection risks

**WARNING:**
- File over 200 lines (suggest splitting)
- Commented-out code blocks (delete it, git has history)
- Empty catch/except/rescue blocks
- Magic numbers in business logic
- TODO without ticket reference
- Duplicate constants across files

### Step 5: Apply Language-Specific Checks

#### TypeScript/JavaScript
| Severity | Check |
|---|---|
| BLOCK | `any` type usage |
| BLOCK | `@ts-ignore` |
| BLOCK | `export default` in non-page files |
| BLOCK | Hardcoded hex colors in `.tsx` (if Tailwind detected) |
| BLOCK | Template literal `className` (if Tailwind detected) |
| BLOCK | Raw `<img>` tags (if Next.js detected) |
| WARN | `useEffect` for derived state |
| WARN | `useEffect` + `fetch()` |
| WARN | `console.log` in component files |
| WARN | Inline types in files >40 lines |
| WARN | Prop drilling through 2+ levels |
| INFO | Could use `Pick`/`Omit` instead of manual type |
| INFO | New component may duplicate existing DLS component |

#### Python
| Severity | Check |
|---|---|
| BLOCK | `bare except:` (catch specific exceptions) |
| BLOCK | Hardcoded secrets in source |
| BLOCK | `eval()` / `exec()` |
| WARN | `print()` in production code (use logging) |
| WARN | `import *` (import specific names) |
| WARN | Missing type hints on public functions |
| WARN | No docstring on public functions |
| WARN | `# type: ignore` without explanation |
| INFO | Could use dataclass/pydantic instead of plain dict |

#### Go
| Severity | Check |
|---|---|
| BLOCK | Hardcoded secrets |
| WARN | `fmt.Println` in production (use structured logging) |
| WARN | `panic()` in library code (return error) |
| WARN | `_ = err` (silenced error) |
| WARN | TODO without issue reference |
| INFO | Function >50 lines (consider splitting) |

#### Rust
| Severity | Check |
|---|---|
| BLOCK | Hardcoded secrets |
| WARN | `unwrap()` in production (use `?` or `expect()`) |
| WARN | `println!` in library code (use tracing/log) |
| WARN | `unsafe` without `// SAFETY:` comment |
| INFO | `clone()` frequency (consider borrowing) |

#### Ruby
| Severity | Check |
|---|---|
| BLOCK | `binding.pry` / `byebug` left in code |
| BLOCK | Hardcoded secrets |
| WARN | `puts`/`p` in production (use Rails.logger) |
| WARN | N+1 query patterns (missing `includes`) |
| INFO | Fat model methods (>20 lines, consider service object) |

#### PHP
| Severity | Check |
|---|---|
| BLOCK | `var_dump` / `dd()` / `dump()` left in code |
| BLOCK | Hardcoded secrets |
| WARN | `die()` / `exit()` in application code |
| WARN | Raw SQL without parameterization |

### Step 6: Check Folder Organization

For any stack, check:
- Are files grouped by domain or scattered by type?
- Are there barrel files (index re-exports)?
- Are support files (types, constants, helpers) co-located or scattered?
- Is the directory depth excessive (>4 levels)?

Reference `coding-standards/rules/file-organization.md` for the expected structure. If major reorganization is needed, suggest `/organize` instead of fixing inline.

### Step 7: Check Against .coding-standards-ignore

If `.coding-standards-ignore` exists, skip violations listed there. Report how many were skipped:
> "Skipped 3 ignored violations (see .coding-standards-ignore)"

### Step 8: Output Report

```
## BLOCKING (X issues)

### path/to/file.ext
- [RULE] Description — how to fix

## WARNING (Y issues)

### path/to/other-file.ext
- [RULE] Description — how to fix

## INFO (Z suggestions)

### path/to/another.ext
- [RULE] Suggestion

## SUMMARY
- Stack detected: [TypeScript + Next.js + Convex + Tailwind]
- X blocking issues across Y files
- Z warnings across W files
- Top 3 systemic patterns to fix first
- Ignored: N violations in .coding-standards-ignore
```

## After Reporting

1. Offer to **auto-fix** safe changes (type extraction, constant centralization, import ordering)
2. For each fix category, show what will change and ask before executing
3. Group fixes into logical commits: one commit per category
4. Re-run lint after fixes to verify violations decrease

## Dependencies

**None.** This skill uses only:
- `git` (for staged file detection)
- `grep` / `rg` (for pattern matching)
- `wc` (for line counting)
- Claude's built-in Read/Grep/Glob tools

No packages to install. No API calls. Works on any machine with git.
