# Changelog

## v1.0.0 (2026-03-23)

Initial release.

### Skills included

- `/coding-interview` — 7-phase interview that analyzes your codebase, extracts your coding preferences, and generates personalized standards + pre-commit hook
- `/coding-standards` — 14 rule files + 2 checklists + lint severity config. Covers TypeScript, React, Python, Go, Rust, Ruby, PHP, backend, security, state management
- `/lint` — On-demand code quality audit. Auto-detects stack and applies matching rules
- `/organize` — Domain-driven folder restructuring with import updates

### Features

- Auto-detects stack: TypeScript, Python, Go, Rust, Ruby, PHP, and their frameworks
- Pre-commit hook generation per ecosystem (Husky, pre-commit, Lefthook, raw git)
- `.coding-standards-ignore` for accepted tech debt
- Batch refactoring with one commit per category
- Zero dependencies beyond git + bash + Claude Code
