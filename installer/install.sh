#!/usr/bin/env bash
set -euo pipefail

# Obsidian Brain — Installer
# Installs the skill for supported AI platforms and optionally copies templates to a vault.

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_FILE="$SCRIPT_DIR/skills/obsidian-brain/SKILL.md"
TEMPLATES_DIR="$SCRIPT_DIR/skills/obsidian-brain/assets/templates"

# ── Help ──
show_help() {
  cat <<'EOF'
obsidian-brain installer — v1.0.0

Usage: install.sh [OPTIONS]

Options:
  --vault-path PATH    Copy templates to the specified vault Templates/ directory
  --help          Show this help and exit

Installs the Obsidian Brain skill to detected AI platforms:
  - Pi (gentle-pi):    ~/.pi/agent/skills/
  - Claude Code:       ~/.claude/skills/
  - OpenCode:          ~/.config/opencode/skills/
  - Cursor:            ~/.cursor/rules/

For each detected platform, a symlink or copy is created.
Templates are always available from the skill repository.
EOF
}

# ── Logging ──
info()  { echo -e "  [INFO]  $*"; }
ok()    { echo -e "  [OK]    $*"; }
warn()  { echo -e "  [WARN]  $*"; }
fail()  { echo -e "  [FAIL]  $*"; exit 1; }

# ── Platform detection and installation ──
install_pi() {
    local target_dir="$HOME/.pi/agent/skills/obsidian-brain"
    if [[ -d "$HOME/.pi/agent/skills" ]]; then
        mkdir -p "$target_dir"
        if [[ -L "$target_dir/SKILL.md" ]] || [[ ! -f "$target_dir/SKILL.md" ]]; then
            ln -sf "$SKILL_FILE" "$target_dir/SKILL.md"
            ok "Pi: symlinked to $target_dir/SKILL.md"
        else
            warn "Pi: $target_dir/SKILL.md already exists (not a symlink). Skipping."
        fi
    else
        warn "Pi: ~/.pi/agent/skills/ not found. Skipping."
    fi
}

install_claude() {
    local target_dir="$HOME/.claude/skills/obsidian-brain"
    if [[ -d "$HOME/.claude" ]]; then
        mkdir -p "$target_dir"
        if [[ -L "$target_dir/SKILL.md" ]] || [[ ! -f "$target_dir/SKILL.md" ]]; then
            ln -sf "$SKILL_FILE" "$target_dir/SKILL.md"
            ok "Claude Code: symlinked to $target_dir/SKILL.md"
        else
            warn "Claude Code: $target_dir/SKILL.md already exists (not a symlink). Skipping."
        fi
        # Also install the Claude Code adapter
        local claude_rules="$HOME/.claude/rules"
        mkdir -p "$claude_rules"
        cp "$SCRIPT_DIR/adapters/claude-code/.claude/rules/obsidian-brain.md" "$claude_rules/obsidian-brain.md"
        ok "Claude Code: rules installed to $claude_rules/obsidian-brain.md"
    else
        warn "Claude Code: ~/.claude/ not found. Skipping."
    fi
}

install_opencode() {
    local target_dir="$HOME/.config/opencode/skills/obsidian-brain"
    if [[ -d "$HOME/.config/opencode" ]]; then
        mkdir -p "$target_dir"
        if [[ -L "$target_dir/SKILL.md" ]] || [[ ! -f "$target_dir/SKILL.md" ]]; then
            ln -sf "$SKILL_FILE" "$target_dir/SKILL.md"
            ok "OpenCode: symlinked to $target_dir/SKILL.md"
        else
            warn "OpenCode: $target_dir/SKILL.md already exists (not a symlink). Skipping."
        fi
        # Append to AGENTS.md if not already present
        local agents_file="$HOME/.config/opencode/AGENTS.md"
        if [[ -f "$agents_file" ]] && ! grep -q "obsidian-brain" "$agents_file" 2>/dev/null; then
            cat >> "$agents_file" << 'EOF'

## obsidian-brain

You have access to the Obsidian Brain skill for vault workflows.

See `skills/obsidian-brain/SKILL.md` for the full vault operation protocol.
Follow the Capture Protocol, Link & Connection Protocol, and Git Sync Protocol defined there.
EOF
            ok "OpenCode: appended section to AGENTS.md"
        elif [[ ! -f "$agents_file" ]]; then
            cp "$SCRIPT_DIR/adapters/opencode/AGENTS.md" "$agents_file"
            ok "OpenCode: created AGENTS.md"
        else
            warn "OpenCode: AGENTS.md already contains obsidian-brain. Skipping append."
        fi
    else
        warn "OpenCode: ~/.config/opencode/ not found. Skipping."
    fi
}

install_cursor() {
    local cursor_rules="$HOME/.cursor/rules"
    if [[ -d "$HOME/.cursor" ]]; then
        mkdir -p "$cursor_rules"
        cp "$SCRIPT_DIR/adapters/cursor/.cursor/rules/obsidian-brain.mdc" "$cursor_rules/obsidian-brain.mdc"
        ok "Cursor: rules installed to $cursor_rules/obsidian-brain.mdc"
    else
        warn "Cursor: ~/.cursor/ not found. Skipping."
    fi
}

# ── Template installation ──
install_templates() {
    local vault_path="${1:-}"

    if [[ -z "$vault_path" ]]; then
        info "No --vault-path provided. Skipping template installation."
        info "To copy templates: install.sh --vault-path /path/to/your/vault"
        return
    fi

    local templates_target="$vault_path/Templates"
    if [[ ! -d "$templates_target" ]]; then
        warn "Templates/ directory not found at $vault_path. Creating it."
        mkdir -p "$templates_target"
    fi

    cp "$TEMPLATES_DIR"/*.md "$templates_target/"
    ok "Templates copied to $templates_target/"
}

# ── Main ──
main() {
    local vault_path=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help) show_help; exit 0 ;;
            --vault-path) vault_path="$2"; shift 2 ;;
            *) warn "Unknown option: $1"; show_help; exit 1 ;;
        esac
    done

    echo ""
    echo "  Obsidian Brain — Installer v$VERSION"
    echo "  ====================================="
    echo ""

    if [[ ! -f "$SKILL_FILE" ]]; then
        fail "SKILL.md not found at $SKILL_FILE. Run install.sh from the skill repository root."
    fi

    info "Installing skill to detected platforms..."
    echo ""

    install_pi
    install_claude
    install_opencode
    install_cursor

    echo ""
    install_templates "$vault_path"

    echo ""
    echo "  ── Installation Summary ──"
    echo ""
    echo "  Skill source: $SKILL_FILE"
    if [[ -n "$vault_path" ]]; then
        echo "  Templates:    $vault_path/Templates/"
    fi
    echo ""
    echo "  Done. The Obsidian Brain skill is now available to your AI agents."
    echo "  On first usage, the agent will guide you through vault setup."
    echo ""
}

main "$@"