#!/usr/bin/env bash
set -euo pipefail

# Obsidian Brain — Installer v1.0.0
# Installs the skill for supported AI platforms.
# Works both locally (from repo) and remotely (curl | bash).
#
# One-liner:
#   curl -fsSL https://raw.githubusercontent.com/DarkKevo/obsidian-brain/main/installer/install.sh | bash
#
# Options:
#   --vault-path PATH    Copy templates to vault Templates/ directory
#   --help               Show this message

VERSION="1.0.0"
REPO="DarkKevo/obsidian-brain"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/$REPO/$BRANCH"
GH_BASE="https://github.com/$REPO"

# ── Self-discovery: are we local or remote? ──
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
  # Running from a file on disk — resolve the repo root
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd 2>/dev/null || echo "")"
else
  SCRIPT_DIR=""
fi

# ── Resolve source of truth ──
resolve_source() {
  if [[ -n "$SCRIPT_DIR" && -f "$SCRIPT_DIR/skills/obsidian-brain/SKILL.md" ]]; then
    # Running locally — use files from disk
    SKILL_SOURCE="$SCRIPT_DIR/skills/obsidian-brain/SKILL.md"
    TEMPLATES_SOURCE="$SCRIPT_DIR/skills/obsidian-brain/assets/templates"
    ADAPTERS_SOURCE="$SCRIPT_DIR/adapters"
    MODE="local"
  else
    # Running via curl pipe — will clone to temp
    SKILL_SOURCE=""
    TEMPLATES_SOURCE=""
    ADAPTERS_SOURCE=""
    MODE="remote"
  fi
}

# ── Temp workspace for remote mode ──
TEMP_DIR=""
cleanup() {
  if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
    rm -rf "$TEMP_DIR"
  fi
}
trap cleanup EXIT

fetch_remote() {
  info "Descargando skill desde $GH_BASE ..."

  # Try git clone first (fast, gets everything)
  if command -v git &>/dev/null; then
    TEMP_DIR="$(mktemp -d)"
    git clone --depth 1 --branch "$BRANCH" "https://github.com/$REPO.git" "$TEMP_DIR" 2>/dev/null || {
      warn "git clone falló. Intentando descarga directa de archivos..."
      rm -rf "$TEMP_DIR"
      TEMP_DIR=""
    }
  fi

  # Fallback: download individual files with curl
  if [[ -z "$TEMP_DIR" || ! -d "$TEMP_DIR" ]]; then
    TEMP_DIR="$(mktemp -d)"
    local files=(
      "skills/obsidian-brain/SKILL.md"
      "skills/obsidian-brain/assets/templates/hub.md"
      "skills/obsidian-brain/assets/templates/atomic-note.md"
      "skills/obsidian-brain/assets/templates/reference.md"
      "adapters/claude-code/.claude/rules/obsidian-brain.md"
      "adapters/opencode/AGENTS.md"
      "adapters/cursor/.cursor/rules/obsidian-brain.mdc"
    )

    for f in "${files[@]}"; do
      mkdir -p "$(dirname "$TEMP_DIR/$f")"
      curl -fsSL "$RAW_BASE/$f" -o "$TEMP_DIR/$f" || {
        warn "No se pudo descargar $f"
      }
    done
  fi

  SKILL_SOURCE="$TEMP_DIR/skills/obsidian-brain/SKILL.md"
  TEMPLATES_SOURCE="$TEMP_DIR/skills/obsidian-brain/assets/templates"
  ADAPTERS_SOURCE="$TEMP_DIR/adapters"
}

# ── Help ──
show_help() {
  cat <<EOF
obsidian-brain installer — v$VERSION

One-liner:
  curl -fsSL $RAW_BASE/installer/install.sh | bash

Usage:
  install.sh [OPTIONS]

Options:
  --vault-path PATH    Copy templates to vault Templates/ directory
  --help               Show this message

Installs to detected platforms:
  • Pi (gentle-pi):    ~/.pi/agent/skills/
  • Claude Code:       ~/.claude/rules/
  • OpenCode:          ~/.config/opencode/skills/ + AGENTS.md
  • Cursor:            ~/.cursor/rules/

Without --vault-path, templates are not copied. Run again with
--vault-path /path/to/your/vault to install templates.

After install, start an AI session — the agent will guide you
through vault setup the first time you interact.
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
    if [[ ! -f "$target_dir/SKILL.md" ]]; then
      cp "$SKILL_SOURCE" "$target_dir/SKILL.md"
      ok "Pi: instalado en $target_dir/SKILL.md"
    else
      warn "Pi: $target_dir/SKILL.md ya existe. Saltando (borrálo manualmente si querés reinstalar)."
    fi
  else
    warn "Pi: ~/.pi/agent/skills/ no encontrado. Saltando."
  fi
}

install_claude() {
  if [[ ! -d "$HOME/.claude" ]]; then
    warn "Claude Code: ~/.claude/ no encontrado. Saltando."
    return
  fi

  local rules_dir="$HOME/.claude/rules"
  mkdir -p "$rules_dir"
  cp "$ADAPTERS_SOURCE/claude-code/.claude/rules/obsidian-brain.md" "$rules_dir/obsidian-brain.md"
  ok "Claude Code: instalado en $rules_dir/obsidian-brain.md"

  # Also copy SKILL.md so Claude can read it as a reference
  local skill_target="$HOME/.claude/skills/obsidian-brain"
  mkdir -p "$skill_target"
  cp "$SKILL_SOURCE" "$skill_target/SKILL.md"
  ok "Claude Code: skill referenciado en $skill_target/SKILL.md"
}

install_opencode() {
  if [[ ! -d "$HOME/.config/opencode" ]]; then
    warn "OpenCode: ~/.config/opencode/ no encontrado. Saltando."
    return
  fi

  local target_dir="$HOME/.config/opencode/skills/obsidian-brain"
  mkdir -p "$target_dir"
  if [[ ! -f "$target_dir/SKILL.md" ]]; then
    cp "$SKILL_SOURCE" "$target_dir/SKILL.md"
    ok "OpenCode: instalado en $target_dir/SKILL.md"
  else
    warn "OpenCode: $target_dir/SKILL.md ya existe. Saltando."
  fi

  local agents_file="$HOME/.config/opencode/AGENTS.md"
  if [[ ! -f "$agents_file" ]]; then
    cp "$ADAPTERS_SOURCE/opencode/AGENTS.md" "$agents_file"
    ok "OpenCode: creado AGENTS.md"
  elif ! grep -q "obsidian-brain" "$agents_file" 2>/dev/null; then
    cat >> "$agents_file" << 'EOF'

## obsidian-brain

You have access to the Obsidian Brain skill for vault workflows.
See `skills/obsidian-brain/SKILL.md` for the full vault operation protocol.
EOF
    ok "OpenCode: sección agregada a AGENTS.md"
  else
    warn "OpenCode: AGENTS.md ya contiene obsidian-brain. Saltando."
  fi
}

install_cursor() {
  if [[ ! -d "$HOME/.cursor" ]]; then
    warn "Cursor: ~/.cursor/ no encontrado. Saltando."
    return
  fi

  local rules_dir="$HOME/.cursor/rules"
  mkdir -p "$rules_dir"
  cp "$ADAPTERS_SOURCE/cursor/.cursor/rules/obsidian-brain.mdc" "$rules_dir/obsidian-brain.mdc"
  ok "Cursor: instalado en $rules_dir/obsidian-brain.mdc"
}

# ── Template installation ──
install_templates() {
  local vault_path="${1:-}"

  if [[ -z "$vault_path" ]]; then
    info "Sin --vault-path. Para copiar templates: install.sh --vault-path /ruta/a/tu/vault"
    return
  fi

  local templates_target="$vault_path/Templates"
  if [[ ! -d "$templates_target" ]]; then
    warn "No existe $templates_target. Creándolo."
    mkdir -p "$templates_target"
  fi

  cp "$TEMPLATES_SOURCE"/*.md "$templates_target/"
  ok "Templates copiados a $templates_target/"
}

# ── Summary ──
print_summary() {
  echo ""
  echo "  ════════════════════════════════════════"
  echo "   Obsidian Brain v$VERSION — Instalación Completa"
  echo "  ════════════════════════════════════════"
  echo ""
  if [[ "$MODE" == "remote" ]]; then
    echo "   Fuente:      $GH_BASE"
  else
    echo "   Fuente:      local ($SCRIPT_DIR)"
  fi
  echo "   Skill:        $SKILL_SOURCE"
  echo ""
  echo "   ¿Qué sigue?"
  echo "   1. Abrí una terminal donde uses tu agente IA"
  echo "   2. El agente ya tiene el skill cargado"
  echo "   3. Decí: 'creá mi vault de Obsidian' o 'guardá esto en mi segundo cerebro'"
  echo "   4. El agente te va a guiar en la configuración inicial"
  echo ""
  echo "   Si ya tenés un vault, pasále --vault-path al installer:"
  echo "     curl -fsSL $RAW_BASE/installer/install.sh | bash -s -- --vault-path ~/mi-vault"
  echo ""
}

# ── Main ──
main() {
  local vault_path=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --help) show_help; exit 0 ;;
      --vault-path) vault_path="$2"; shift 2 ;;
      *) warn "Opción desconocida: $1"; show_help; exit 1 ;;
    esac
  done

  resolve_source

  echo ""
  echo "  ╔═══════════════════════════════════════╗"
  echo "  ║   Obsidian Brain — Installer v$VERSION  ║"
  echo "  ╚═══════════════════════════════════════╝"
  echo ""

  if [[ "$MODE" == "remote" ]]; then
    fetch_remote
  fi

  if [[ ! -f "$SKILL_SOURCE" ]]; then
    fail "No se encontró SKILL.md en $SKILL_SOURCE"
  fi

  info "Instalando skill en plataformas detectadas..."
  echo ""

  install_pi
  install_claude
  install_opencode
  install_cursor

  echo ""
  install_templates "$vault_path"

  print_summary
}

main "$@"
