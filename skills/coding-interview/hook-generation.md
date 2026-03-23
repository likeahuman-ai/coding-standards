# Hook Generation — Pre-Commit Hooks Per Stack

After the interview produces coding standards, offer to generate enforcement hooks. The hook script adapts to whatever stack was detected.

## When to Offer

At the end of Phase 5 (Generate Standards), always ask:

> "Want me to set up a pre-commit hook that enforces these rules automatically? It runs on staged files only — fast, zero cost."

## Hook Setup Per Ecosystem

### Step 1: Detect Existing Hook System

```
.husky/              -> Husky (Node.js projects)
.pre-commit-config.yaml -> pre-commit framework (Python/polyglot)
.lefthook.yml        -> Lefthook (any language)
.git/hooks/pre-commit -> Raw git hook (any)
Makefile with lint target -> Makefile-based
```

If none exists, recommend based on stack:
- Node.js/TypeScript -> Husky + lint-staged
- Python -> pre-commit framework
- Go -> raw git hook or golangci-lint
- Rust -> raw git hook or cargo-husky
- Ruby -> overcommit
- Multi-language -> Lefthook or pre-commit framework

### Step 2: Install Hook Infrastructure

**Node.js (Husky):**
```bash
pnpm add -D husky lint-staged
npx husky init
```

**Python (pre-commit):**
```bash
pip install pre-commit
pre-commit install
```

**Go (raw hook):**
```bash
cp scripts/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

**Lefthook (universal):**
```bash
# macOS
brew install lefthook
lefthook install
```

### Step 3: Generate the Check Script

The script structure is the same for all languages — only the grep patterns and file extensions change.

#### Template: `scripts/check-coding-standards.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

# --- Colors ---
RED='\033[0;31m'; YELLOW='\033[0;33m'; GREEN='\033[0;32m'
DIM='\033[0;90m'; BOLD='\033[1m'; NC='\033[0m'

BLOCKING=0; WARNING=0; CHECKED=0

STAGED=$(git diff --cached --name-only --diff-filter=d 2>/dev/null || true)
[ -z "$STAGED" ] && exit 0

staged_content() { git show ":$1" 2>/dev/null || true; }

blocking() {
  echo -e "  ${RED}BLOCK${NC} ${DIM}[$2]${NC} $1"
  echo -e "        $3"
  BLOCKING=$((BLOCKING + 1))
}

warning() {
  echo -e "  ${YELLOW}WARN${NC}  ${DIM}[$2]${NC} $1"
  echo -e "        $3"
  WARNING=$((WARNING + 1))
}

echo -e "\n${BOLD}Coding Standards Check${NC}\n"

# === INSERT LANGUAGE-SPECIFIC CHECKS HERE ===

# --- Summary ---
echo ""
if [ "$BLOCKING" -gt 0 ]; then
  echo -e "${RED}${BOLD}BLOCKED${NC} — $BLOCKING blocking issue(s)"
  [ "$WARNING" -gt 0 ] && echo -e "${YELLOW}Also: $WARNING warning(s)${NC}"
  exit 1
elif [ "$WARNING" -gt 0 ]; then
  echo -e "${GREEN}${BOLD}PASSED${NC} with ${YELLOW}$WARNING warning(s)${NC}"
  exit 0
else
  echo -e "${GREEN}${BOLD}PASSED${NC} — all clean"
  exit 0
fi
```

### Step 4: Language-Specific Check Blocks

These blocks plug into the template above.

---

#### TypeScript / JavaScript

```bash
TS_FILES=$(echo "$STAGED" | grep -E '\.(ts|tsx|js|jsx)$' || true)
[ -z "$TS_FILES" ] && exit 0

for file in $TS_FILES; do
  content=$(staged_content "$file")
  CHECKED=$((CHECKED + 1))

  # No `any` type
  if echo "$content" | grep -qE ': any\b|as any\b|<any>' && ! echo "$file" | grep -q '\.d\.ts$'; then
    line=$(echo "$content" | grep -nE ': any\b|as any\b' | grep -v '^\s*//' | head -1 | cut -d: -f1)
    blocking "$file:$line" "typescript" "Found \`any\` — use \`unknown\` and narrow"
  fi

  # No @ts-ignore
  if echo "$content" | grep -q '@ts-ignore'; then
    blocking "$file" "typescript" "@ts-ignore — use @ts-expect-error with explanation"
  fi

  # No eval()
  if echo "$content" | grep -qE '\beval\s*\('; then
    blocking "$file" "security" "eval() found — code injection risk"
  fi

  # No console.log in components (tsx only)
  if echo "$file" | grep -qE '\.tsx$' && echo "$content" | grep -qE 'console\.(log|warn|error)'; then
    if ! echo "$file" | grep -qE '(hooks/|lib/|utils)'; then
      warning "$file" "quality" "console.log in component — remove before shipping"
    fi
  fi
done
```

**React-specific additions:**
```bash
TSX_FILES=$(echo "$STAGED" | grep -E '\.tsx$' || true)
for file in $TSX_FILES; do
  content=$(staged_content "$file")

  # No hardcoded hex in components
  if echo "$content" | grep -qE '#[0-9a-fA-F]{3,8}' | grep -v '^\s*//'; then
    blocking "$file" "design-tokens" "Hardcoded hex — use Tailwind token"
  fi

  # No template literal className
  if echo "$content" | grep -qE 'className=\{`'; then
    blocking "$file" "tailwind" "Template literal className — use cn()"
  fi

  # No raw <img>
  if echo "$content" | grep -qE '<img\s'; then
    blocking "$file" "react" "Raw <img> — use next/image <Image />"
  fi

  # No export default in non-page
  if echo "$content" | grep -qE '^export default ' && ! basename "$file" | grep -qE '^(page|layout|loading|error)\.tsx$'; then
    if ! echo "$content" | grep -q 'satisfies Meta'; then
      blocking "$file" "exports" "export default in non-page — use named exports"
    fi
  fi
done
```

---

#### Python

```bash
PY_FILES=$(echo "$STAGED" | grep -E '\.py$' || true)
[ -z "$PY_FILES" ] && exit 0

for file in $PY_FILES; do
  content=$(staged_content "$file")
  CHECKED=$((CHECKED + 1))

  # No bare except
  if echo "$content" | grep -qE '^\s*except\s*:'; then
    line=$(echo "$content" | grep -nE '^\s*except\s*:' | head -1 | cut -d: -f1)
    blocking "$file:$line" "error-handling" "Bare except — catch specific exceptions"
  fi

  # No print() in production code (skip tests, scripts, __main__)
  if ! echo "$file" | grep -qE '(test_|_test\.py|conftest|__main__|scripts/)'; then
    if echo "$content" | grep -qE '^\s*print\('; then
      warning "$file" "quality" "print() in production code — use logging"
    fi
  fi

  # No hardcoded secrets
  if echo "$content" | grep -qiE '(password|secret|api_key|token)\s*=\s*["\x27][^"\x27]+["\x27]'; then
    if ! echo "$file" | grep -qE '(test_|example|fixture|seed)'; then
      blocking "$file" "security" "Possible hardcoded secret"
    fi
  fi

  # No * imports (except __init__.py)
  if ! echo "$file" | grep -q '__init__\.py$'; then
    if echo "$content" | grep -qE '^from .+ import \*'; then
      warning "$file" "imports" "Wildcard import — import specific names"
    fi
  fi

  # Type hints check (if team requires them)
  # Uncomment if standards require type hints:
  # if echo "$content" | grep -qE '^def [a-z_]+\([^)]*\)\s*:' && ! echo "$content" | grep -qE '^def [a-z_]+\([^)]*\)\s*->'; then
  #   warning "$file" "typing" "Missing return type hint on function"
  # fi
done
```

---

#### Go

```bash
GO_FILES=$(echo "$STAGED" | grep -E '\.go$' || true)
[ -z "$GO_FILES" ] && exit 0

for file in $GO_FILES; do
  content=$(staged_content "$file")
  CHECKED=$((CHECKED + 1))

  # No fmt.Println in production (skip _test.go)
  if ! echo "$file" | grep -q '_test\.go$'; then
    if echo "$content" | grep -qE 'fmt\.Print(ln|f)?\('; then
      warning "$file" "quality" "fmt.Print in production — use structured logging"
    fi
  fi

  # No panic in library code
  if ! echo "$file" | grep -qE '(main\.go|_test\.go|cmd/)'; then
    if echo "$content" | grep -qE '\bpanic\('; then
      warning "$file" "error-handling" "panic() in library code — return error instead"
    fi
  fi

  # No TODO without issue reference
  if echo "$content" | grep -qE '//\s*TODO[^(]' && ! echo "$content" | grep -qE '//\s*TODO\s*\(#'; then
    warning "$file" "quality" "TODO without issue reference — add ticket number"
  fi
done

# Run go vet on staged files
if command -v go &>/dev/null; then
  go vet ./... 2>&1 | while read -r line; do
    warning "$line" "go-vet" "go vet finding"
  done
fi
```

---

#### Rust

```bash
RS_FILES=$(echo "$STAGED" | grep -E '\.rs$' || true)
[ -z "$RS_FILES" ] && exit 0

for file in $RS_FILES; do
  content=$(staged_content "$file")
  CHECKED=$((CHECKED + 1))

  # No unwrap() in production (skip tests)
  if ! echo "$file" | grep -qE '(test|tests|benches)/'; then
    unwrap_count=$(echo "$content" | grep -cE '\.unwrap\(\)' || true)
    if [ "$unwrap_count" -gt 3 ]; then
      warning "$file" "error-handling" "$unwrap_count unwrap() calls — use ? or expect() with message"
    fi
  fi

  # No println! in library code
  if ! echo "$file" | grep -qE '(main\.rs|bin/|examples/)'; then
    if echo "$content" | grep -qE '\bprintln!\('; then
      warning "$file" "quality" "println! in library — use tracing or log crate"
    fi
  fi

  # Unsafe blocks should have safety comments
  if echo "$content" | grep -qE '^\s*unsafe\s*\{'; then
    unsafe_line=$(echo "$content" | grep -nE '^\s*unsafe\s*\{' | head -1 | cut -d: -f1)
    prev_line=$((unsafe_line - 1))
    if ! echo "$content" | sed -n "${prev_line}p" | grep -qi 'safety'; then
      warning "$file:$unsafe_line" "safety" "unsafe block without SAFETY comment"
    fi
  fi
done
```

---

#### Ruby

```bash
RB_FILES=$(echo "$STAGED" | grep -E '\.rb$' || true)
[ -z "$RB_FILES" ] && exit 0

for file in $RB_FILES; do
  content=$(staged_content "$file")
  CHECKED=$((CHECKED + 1))

  # No puts/p in production (skip spec/)
  if ! echo "$file" | grep -qE '(spec/|test/)'; then
    if echo "$content" | grep -qE '^\s*(puts|p) '; then
      warning "$file" "quality" "puts/p in production — use Rails.logger"
    fi
  fi

  # No binding.pry left in
  if echo "$content" | grep -q 'binding\.pry\|binding\.irb\|byebug'; then
    blocking "$file" "debug" "Debugger statement left in code"
  fi
done
```

---

#### PHP

```bash
PHP_FILES=$(echo "$STAGED" | grep -E '\.php$' || true)
[ -z "$PHP_FILES" ] && exit 0

for file in $PHP_FILES; do
  content=$(staged_content "$file")
  CHECKED=$((CHECKED + 1))

  # No var_dump/dd left in
  if echo "$content" | grep -qE '\b(var_dump|dd|dump)\s*\('; then
    blocking "$file" "debug" "Debug function left in code"
  fi

  # No die/exit in application code
  if ! echo "$file" | grep -qE '(artisan|console)'; then
    if echo "$content" | grep -qE '\b(die|exit)\s*\('; then
      warning "$file" "quality" "die/exit in application code"
    fi
  fi
done
```

---

## Universal Checks (All Languages)

These run regardless of language:

```bash
# No .env files committed
ENV_FILES=$(echo "$STAGED" | grep -E '\.env($|\.)' | grep -v '\.env\.example$\|\.env\.template$' || true)
if [ -n "$ENV_FILES" ]; then
  for file in $ENV_FILES; do
    blocking "$file" "security" ".env file staged — add to .gitignore"
  done
fi

# No large files (>1MB)
for file in $STAGED; do
  if [ -f "$file" ]; then
    size=$(wc -c < "$file" 2>/dev/null || echo 0)
    if [ "$size" -gt 1048576 ]; then
      warning "$file" "size" "File is $(( size / 1024 ))KB — consider git-lfs or .gitignore"
    fi
  fi
done

# No conflict markers
for file in $STAGED; do
  if staged_content "$file" | grep -qE '^(<<<<<<<|=======|>>>>>>>)'; then
    blocking "$file" "git" "Merge conflict markers found"
  fi
done
```

## Step 5: Wire It Up

After generating the script, wire it into the project's hook system:

**Husky (.husky/pre-commit):**
```bash
./scripts/check-coding-standards.sh
```

**pre-commit (.pre-commit-config.yaml):**
```yaml
repos:
  - repo: local
    hooks:
      - id: coding-standards
        name: Coding Standards
        entry: scripts/check-coding-standards.sh
        language: script
        pass_filenames: false
```

**Lefthook (lefthook.yml):**
```yaml
pre-commit:
  commands:
    coding-standards:
      run: ./scripts/check-coding-standards.sh
```

**Raw git hook (.git/hooks/pre-commit):**
```bash
#!/bin/sh
./scripts/check-coding-standards.sh
```

## Step 6: Confirm with Developer

After setup, always confirm:

> "Pre-commit hook is installed. It checks [N] rules on staged files:
> - BLOCKING: [list top 5 blocking rules]
> - WARNING: [list top 3 warning rules]
>
> You can skip with `git commit --no-verify` in emergencies.
> Want to adjust any of these rules or severity levels?"
