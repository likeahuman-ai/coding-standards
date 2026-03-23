---
name: coding-interview
description: Interview a developer to extract their coding preferences, analyze their codebase for patterns, and generate/update coding-standards files. Use when onboarding a new project, onboarding a new developer, or when standards need a refresh.
user-invocable: true
args: "[new|refresh|extend] — new = fresh interview, refresh = re-analyze codebase against existing standards, extend = add rules for a new area"
---

# /coding-interview — Coding Style Interview

Extract a developer's coding DNA through structured conversation and codebase analysis. Produces or updates `~/.claude/skills/coding-standards/` files.

## When to Use

- **New project** — no coding-standards exist yet, need to establish them
- **Onboarding** — developer has an existing codebase, wants standards extracted from their actual code
- **Refresh** — standards exist but codebase has evolved, re-analyze for drift
- **Extend** — need to add rules for a new area (e.g., adding mobile, adding a new backend)

## The Interview Flow

### Phase 1: Codebase Analysis (Silent — No Questions Yet)

Before asking anything, analyze the codebase to understand what patterns already exist. This prevents asking obvious questions the code already answers.

**Run these searches in parallel:**

1. **Stack detection** — Read `stack-detection.md` for the full matrix. Check config files (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, etc.) to identify language, framework, and sub-frameworks.
2. **Frontend patterns** (if applicable) — Read 5-8 source files across different domains. Pick files from different areas (auth, main feature, settings). Note:
   - How types/interfaces are defined (inline vs extracted)
   - How exports work (named vs default)
   - How styling is handled (Tailwind cn(), CSS modules, styled-components, etc.)
   - File lengths and structure
   - Component/function patterns
3. **Backend patterns** — Read 3-5 backend files (API routes, database queries, controllers, services). Note:
   - Auth/authorization patterns
   - Input validation approach
   - Error handling patterns
   - Database access patterns (ORM, query builders, raw SQL)
4. **State management** (if frontend) — Search for state stores, data fetching patterns, context/providers
5. **File organization** — Map the directory structure, note domain-driven vs technical grouping
6. **Existing standards** — Check for CLAUDE.md, linter configs (.eslintrc, ruff.toml, .golangci.yml), formatter configs (prettier, black)
7. **Git patterns** — Check recent commits for commit message style, branch naming

**Output of Phase 1:** Internal notes (not shown to user yet). A profile of what the codebase already tells us.

### Phase 2: Present Findings + First Questions

Present what you found as a **"Code Style Profile"** — a summary of their patterns organized by category. Then ask targeted questions about things the code DOESN'T answer.

**Template:**

```
Based on your codebase, here's what I see as your coding style:

## Component Architecture
- [observed pattern]
- [observed pattern]

## TypeScript
- [observed pattern]

## State Management
- [observed pattern]

## Backend
- [observed pattern]

## File Organization
- [observed pattern]

**Questions I couldn't answer from the code:**

1. [Specific question about an ambiguous pattern]
2. [Question about a preference not visible in code]
3. [Question about something inconsistent across files]
```

**Good questions to ask:**
- "I see two different patterns for X — which do you prefer?"
- "You have types inline in some files and extracted in others — what's your rule?"
- "I didn't find state management for X — is that intentional?"
- "Your backend has auth on most functions but not these 3 — are those intentionally public?"

**Bad questions (the code already answers):**
- "Do you use TypeScript?" (obviously yes if .ts files exist)
- "Do you use Tailwind?" (obviously yes if className with Tailwind classes exists)
- "What's your component naming convention?" (visible from file names)

### Phase 3: Deep Dive — One Topic at a Time

Go through each coding-standards topic, presenting your understanding and asking for confirmation or correction. **One topic per message, not all at once.**

**Topic order:**
1. Reuse philosophy (do they prefer extending existing or creating new?)
2. Component patterns (anatomy, props, extraction rules)
3. Naming (confirm what code shows, ask about edge cases)
4. File organization (domain-driven? feature-driven? flat?)
5. Types and constants (where they live, reuse hierarchy)
6. State management (what tool for what kind of state)
7. Backend patterns (auth, validation, error handling)
8. Security (what they care about most)
9. Quality (over-engineering tolerance, comment philosophy)

**For each topic:**
1. Present what you found: "Here's how you do X based on your code..."
2. Ask: "Is this accurate? Anything missing or wrong?"
3. Ask one deepening question: "What about [edge case]?"
4. Move to next topic only after confirmation

### Phase 4: Gap Analysis

After confirming all topics, identify what's NOT covered:

- "I notice you don't have patterns for [area]. Want to establish rules for that?"
- "Your codebase doesn't have [pattern] yet, but it might need it as it grows. Want to pre-define it?"
- "I found inconsistencies in [area] — want to pick one approach and codify it?"

### Phase 5: Generate Standards

Before generating, ask the developer where to save:

> "Where should I save the coding standards?
>
> **A) Project (recommended for teams)** — saves to `.claude/` in your project repo. Your whole team gets the same rules when they clone the repo. Committed to git.
>
> **B) Personal** — saves to `~/.claude/skills/` on your machine only. Good for personal preferences across all your projects.
>
> **C) Both** — shared rules in the project, personal overrides in your home directory."

#### Option A: Project-scoped (team)

```
your-project/
  .claude/
    settings.json               # Can reference the standards
    rules/                      # Project coding standards (committed to git)
      coding-standards.md       # Entry point with philosophy + manifest
      reuse-first.md
      naming-conventions.md
      file-organization.md
      [stack-specific].md       # Only the rules matching this project's stack
      ...
    checklists/
      before-creating.md
      before-committing.md
  scripts/
    check-coding-standards.sh   # Pre-commit hook (committed to git)
```

This means:
- Standards are **version-controlled** alongside the code
- Every developer who clones the repo gets the same rules
- Claude Code auto-reads `.claude/rules/*.md` for every conversation in this project
- PRs can include rule changes (reviewed like any code change)
- The pre-commit hook is also committed — enforced for the whole team

#### Option B: Personal (individual)

```
~/.claude/skills/coding-standards/
  SKILL.md
  lint-config.md
  rules/
    [all rule files]
  checklists/
    [all checklists]
```

This means:
- Rules apply to YOU across all projects
- Not shared with teammates
- Good for personal style preferences that apply everywhere

#### Option C: Both (team + personal overrides)

- Shared rules in `.claude/rules/` (committed)
- Personal overrides or additions in `~/.claude/skills/coding-standards/`
- Personal rules take precedence when both exist for the same topic

#### What gets generated

Files created (in whichever location chosen):
- Entry point with philosophy + manifest
- `lint-config.md` — severity levels (BLOCKING/WARNING/INFO)
- `rules/` — only the rule files matching your detected stack (see stack-detection.md Step 4)
- `checklists/before-creating.md` — 5 pre-coding questions
- `checklists/before-committing.md` — post-write validation checklist
- `scripts/check-coding-standards.sh` — pre-commit hook (always in PROJECT repo)

**If new project (`/coding-interview new`):**
- Full interview, generates all files in chosen location

**If refresh (`/coding-interview refresh`):**
- Re-analyze codebase against existing standards
- Report drift: "Standards say X, but code does Y in these files"
- Propose updates to standards or fixes to code
- Ask which direction to go (update standard or fix code)

**If extend (`/coding-interview extend`):**
- Ask what area to add (e.g., "mobile", "testing", "CI/CD")
- Interview on that topic only
- Add new rule file(s) to existing structure

### Phase 7: Test, Validate & Refactor

The standards are only useful if the codebase actually passes them. This phase catches existing violations and helps fix them.

#### Step 1: Dry Run the Hook

Run the pre-commit hook against the FULL codebase (not just staged files):

```bash
# Temporarily stage everything to simulate a full check
git stash
git add -A
./scripts/check-coding-standards.sh
git reset HEAD .
git stash pop
```

Report results:
> "Ran the standards against your full codebase. Found:
> - X BLOCKING violations across Y files
> - Z warnings across W files
> - Top 3 patterns to fix: [list]"

#### Step 2: Triage — Fix or Accept

For each violation category, ask the developer:

```
Found 12 files with `any` type usage. Options:
  A) Fix all now (I'll refactor each to use proper types)
  B) Fix the worst 3, create a ticket for the rest
  C) Accept as-is and lower severity to WARNING
  D) Add to .coding-standards-ignore (tech debt, will fix later)
```

**Never auto-fix without asking.** Present the plan, let them choose.

#### Step 3: Batch Refactoring

When the developer chooses to fix, group refactors into logical batches:

```
Batch 1: Type extraction (extract inline types to domain types.ts files)
  - components/course/course-card.tsx -> components/course/types.ts
  - components/workshop/feedback-form.tsx -> components/workshop/types.ts
  ... 8 more files

Batch 2: Constant centralization (move duplicated constants to shared location)
  - COURSE_SLUG defined in 3 files -> src/lib/constants.ts
  ... 4 more constants

Batch 3: Component reuse (replace inline styling with DLS components)
  - custom card div in feature-card.tsx -> use <Card> from DLS
  ... 2 more files

Batch 4: Backend auth gaps (add auth guards to unprotected functions)
  - convex/courses.ts:listDrafts -> add requireAdmin()
  ... 3 more functions
```

**Rules for refactoring:**
- One batch = one commit (atomic, reviewable)
- Run typecheck after each batch
- Run the hook after each batch to verify violations decrease
- Commit message: `refactor(standards): [batch description]`
- Never refactor and add features in the same commit

#### Step 4: Create the Ignore File (If Needed)

For tech debt the developer accepts but wants to track:

```
# .coding-standards-ignore
# Lines here are known violations accepted as tech debt.
# Format: file:rule:reason
#
# Review quarterly. Remove lines as violations are fixed.

src/legacy/old-dashboard.tsx:any:legacy code, full rewrite planned Q3
convex/migrations/backfill_users.ts:audit-fields:one-time migration, won't run again
```

The pre-commit hook should skip files/rules listed here. Add to the hook:

```bash
IGNORE_FILE=".coding-standards-ignore"
is_ignored() {
  local file="$1" rule="$2"
  [ -f "$IGNORE_FILE" ] && grep -q "^${file}:${rule}:" "$IGNORE_FILE"
}
```

#### Step 5: Verify Clean State

After all refactoring batches:

```bash
./scripts/check-coding-standards.sh
```

Expected output:
```
PASSED — all clean (or PASSED with N accepted warnings)
Checked X files
```

If clean, confirm:
> "Your codebase now passes all coding standards. The pre-commit hook will enforce these going forward. Any new violations will be caught before commit."

#### Step 6: Ongoing Maintenance

Suggest to the developer:

> "To keep standards healthy over time:
> - Run `/coding-interview refresh` quarterly to check for drift
> - Run `/lint` before shipping features for a deep audit
> - Review `.coding-standards-ignore` quarterly — delete fixed violations
> - When you add a new pattern or convention, run `/coding-interview extend` to codify it"

## Interview Principles

1. **Code speaks louder than opinions** — observe patterns before asking about preferences
2. **One topic at a time** — don't overwhelm with a wall of questions
3. **Show, don't ask** — present what you found and ask "is this right?" rather than "what do you do?"
4. **Depth over breadth** — better to deeply understand 5 rules than superficially cover 50
5. **Examples anchor understanding** — always show code examples from THEIR codebase
6. **Respect existing decisions** — don't suggest changing things that work, codify what exists
7. **Flag inconsistencies, don't judge** — "I see two patterns" not "this is wrong"
8. **The developer knows best** — if they say "that's intentional", accept it and document it

## Output Quality

The generated standards must be:
- **Actionable** — every rule has a clear right/wrong code example
- **Enforceable** — every BLOCKING rule can be checked by grep/script
- **Stack-agnostic where possible** — global standards work across projects
- **Project-specific where needed** — token catalogs, DLS inventories stay in project CLAUDE.md

## File Structure to Generate

```
~/.claude/skills/coding-standards/
├── SKILL.md                          # Entry point + manifest
├── lint-config.md                    # Severity levels
├── rules/
│   ├── reuse-first.md                # Extend vs create philosophy
│   ├── component-architecture.md     # Component anatomy, props, CVA
│   ├── naming-conventions.md         # All naming rules
│   ├── file-organization.md          # Domain-driven structure
│   ├── types-and-constants.md        # Type/constant reuse hierarchy
│   ├── typescript-quality.md         # Strict mode, type patterns
│   ├── react-patterns.md             # Server/client, hooks, anti-patterns
│   ├── tailwind-and-tokens.md        # Styling rules (if Tailwind)
│   ├── state-management.md           # Where state lives
│   ├── [backend].md                  # Backend-specific (convex/prisma/etc)
│   ├── security.md                   # Auth, validation, secrets
│   ├── error-handling.md             # Boundaries, retry, resilience
│   └── general-quality.md            # Idioms, comments, defensive coding
└── checklists/
    ├── before-creating.md            # Pre-coding guard
    └── before-committing.md          # Post-write checklist
```

Not all files are needed for every project. Skip files for areas the project doesn't use (e.g., skip convex-backend.md for a Prisma project).

### Phase 6: Wire Into CLAUDE.md

After generating all files, integrate them so Claude always sees the standards:

1. **Global CLAUDE.md** (`~/.claude/CLAUDE.md`):
   - Add `coding-standards/SKILL.md` to auto-loaded skills list
   - Remove any duplicated coding rules (they now live in coding-standards)
   - Add a "Coding Standards" section pointing to the skill

2. **Project CLAUDE.md** (if exists):
   - Remove duplicated coding rules
   - Keep project-specific info (token catalogs, DLS inventory, workflow)
   - Add pointer: "All coding rules in `~/.claude/skills/coding-standards/`"

3. **Existing lint/organize skills** (if they exist):
   - Update to reference `coding-standards/lint-config.md` for severity
   - Remove their own rule copies

4. **Delete redundant files**:
   - Any old skill files whose content was consolidated into coding-standards
   - Confirm with developer before deleting

5. **Confirm with developer**:
   > "Standards are set up. Here's what changed:
   > - Created: [N] rule files in coding-standards/
   > - Updated: CLAUDE.md (removed [N] lines of duplicated rules)
   > - Deleted: [list of old files]
   > - Pre-commit hook: [installed/offered]
   >
   > From now on, coding-standards/ is the single source of truth.
   > Use `/coding-interview refresh` anytime to re-analyze."

## Sub-Files (Read During Execution)

| File | Purpose |
|---|---|
| `stack-detection.md` | What to look for per language/framework. Analysis templates for TS, Python, Go, Rust, Ruby, PHP, mobile. |
| `hook-generation.md` | Pre-commit hook templates per ecosystem. Husky, pre-commit, Lefthook, raw git hooks. Check blocks for TS, Python, Go, Rust, Ruby, PHP + universal checks. |

## Integration with Pre-Commit Hook

After generating standards, ALWAYS offer to set up enforcement:

1. Read `hook-generation.md` for the right hook system + check blocks
2. Generate `scripts/check-coding-standards.sh` with stack-appropriate checks
3. Wire it into the project's hook system (Husky, pre-commit, Lefthook, or raw)
4. Test it on staged files
5. Confirm with developer what's BLOCKING vs WARNING
