#!/usr/bin/env bash
# ==============================================================================
# Claude Code Coding Standards — Installer
# ==============================================================================
# Installs the coding-standards skill suite into your Claude Code environment.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/likeahuman-ai/coding-standards/main/setup.sh | bash
#   # or
#   git clone https://github.com/likeahuman-ai/coding-standards.git && cd coding-standards && ./setup.sh
# ==============================================================================

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
DIM='\033[0;90m'
BOLD='\033[1m'
NC='\033[0m'

SKILLS_DIR="$HOME/.claude/skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo -e "${BOLD}Claude Code Coding Standards${NC}"
echo -e "${DIM}Installing skills to $SKILLS_DIR${NC}"
echo ""

# Check Claude Code exists
if [ ! -d "$HOME/.claude" ]; then
  echo -e "${YELLOW}Warning: ~/.claude not found. Creating it...${NC}"
  mkdir -p "$HOME/.claude/skills"
fi

mkdir -p "$SKILLS_DIR"

# Determine source directory
if [ -d "$SCRIPT_DIR/skills" ]; then
  SOURCE="$SCRIPT_DIR/skills"
else
  echo "Error: skills/ directory not found. Run this from the repo root."
  exit 1
fi

# Install skills
INSTALLED=0

for skill in coding-standards coding-interview lint organize; do
  if [ -d "$SOURCE/$skill" ]; then
    # Backup existing
    if [ -d "$SKILLS_DIR/$skill" ]; then
      echo -e "  ${YELLOW}Backing up${NC} existing $skill -> ${skill}.bak"
      rm -rf "$SKILLS_DIR/${skill}.bak"
      mv "$SKILLS_DIR/$skill" "$SKILLS_DIR/${skill}.bak"
    fi

    cp -r "$SOURCE/$skill" "$SKILLS_DIR/$skill"
    file_count=$(find "$SKILLS_DIR/$skill" -type f | wc -l | tr -d ' ')
    echo -e "  ${GREEN}Installed${NC} $skill ($file_count files)"
    INSTALLED=$((INSTALLED + 1))
  fi
done

echo ""
echo -e "${GREEN}${BOLD}Done!${NC} Installed $INSTALLED skills."
echo ""

# Check if CLAUDE.md references coding-standards
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
if [ -f "$CLAUDE_MD" ]; then
  if ! grep -q "coding-standards" "$CLAUDE_MD"; then
    echo -e "${YELLOW}Tip:${NC} Add coding-standards to your CLAUDE.md auto-loaded skills:"
    echo -e "${DIM}  Auto-loaded skills: coding-standards/SKILL.md${NC}"
    echo ""
  else
    echo -e "${DIM}CLAUDE.md already references coding-standards.${NC}"
  fi
else
  echo -e "${YELLOW}Tip:${NC} Create ~/.claude/CLAUDE.md and add:"
  echo -e "${DIM}  Auto-loaded skills: coding-standards/SKILL.md${NC}"
  echo ""
fi

echo -e "${BOLD}Next steps:${NC}"
echo -e "  1. Run ${CYAN}/coding-interview new${NC} to analyze your codebase and generate personalized rules"
echo -e "  2. Run ${CYAN}/lint${NC} to audit your code against the standards"
echo -e "  3. Run ${CYAN}/organize${NC} to restructure folders into domain-driven layout"
echo ""
echo -e "${DIM}All skills auto-detect your stack (TS, Python, Go, Rust, Ruby, PHP).${NC}"
echo -e "${DIM}No dependencies to install. Works with git + bash only.${NC}"
echo ""
