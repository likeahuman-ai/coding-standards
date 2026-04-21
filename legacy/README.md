# Legacy installer

This directory preserves the original pre-plugin installation flow for Claude Code.

**You probably don't need this.** The recommended install is now:

```bash
/plugin marketplace add likeahuman-ai/claude-plugins
/plugin install coding-standards
```

Or, directly:

```bash
/plugin install likeahuman-ai/coding-standards
```

The `/plugin` flow handles everything `setup.sh` did, plus auto-updates, uninstall, and proper isolation from other Claude Code skills.

## When to use `setup.sh`

- You're on an older Claude Code version without plugin support
- You're running a self-hosted or forked Claude Code build
- You want the raw skills copied to `~/.claude/skills/` instead of going through the plugin loader

Otherwise: use `/plugin install`.

## How the legacy installer works

```bash
git clone https://github.com/likeahuman-ai/coding-standards.git
cd coding-standards
./legacy/setup.sh
```

It copies the `skills/` directory into `~/.claude/skills/`. Then add this line to your `~/.claude/CLAUDE.md`:

```
Auto-loaded skills: coding-standards/SKILL.md
```
