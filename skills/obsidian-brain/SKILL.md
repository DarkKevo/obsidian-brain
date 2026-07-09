---
name: obsidian-brain
description: "Trigger: notetaking, research, learning, capture, vault, obsidian, second brain, Zettelkasten, save note. Enseña al agente a interactuar con un vault de Obsidian usando Segundo Cerebro / Zettelkasten."
version: 1.0.0
author: DarkKevo
---

# Obsidian Brain — Canonical Skill

Always ON in any session where the user might learn, take notes, or interact with an Obsidian vault. Silent — never asks unless it needs user input.

---

## 1. Activation Contract

- **Scope**: Active in ANY session where the user might learn a new concept, ask the agent to save or capture something, want to organize information, or interact with an Obsidian vault.
- **Priority**: silent — the skill is always ON, never asks unless it needs user input.
- **Trigger keywords**: notetaking, research, learning, capture, vault, obsidian, second brain, Zettelkasten, save note, guardá, creá nota, no entiendo.

---

## 2. Vault Configuration

Read `.vaultconfig` at EVERY session start BEFORE doing any vault operation.

### .vaultconfig Format (YAML)
```yaml
vault_path: /home/user/mi-segundo-cerebro   # absolute path to vault root
vault_name: mi-segundo-cerebro               # user-friendly name
created_at: 2026-07-09                       # ISO date of vault creation
github_url: https://github.com/DarkKevo/mi-segundo-cerebro  # optional remote URL
language: es                                 # "es" or "en"
autocommit: true                             # auto-commit after capture
autopush: true                               # auto-push after commit
```

### Vault Path Resolution
- Store the resolved `vault_path` and use it for ALL file operations.
- If `.vaultconfig` is missing → run **Onboarding flow** below.
- If `.vaultconfig` exists but the vault directory doesn't → re-run onboarding.

### Onboarding Flow (when .vaultconfig is missing)

```
STEP 1: Ask "¿Cómo se llama tu vault?" (or "What's your vault name?" in English)
  → User provides vault name
  → Sanitize: lowercase, spaces → dashes, ASCII transliteration
  → Example: "Mi Segundo Cerebro" → "mi-segundo-cerebro"

STEP 2: Resolve vault path
  Default: ~/{vault-name-slug}/
  Example: /home/darkkevo/mi-segundo-cerebro/

STEP 3: Create directory structure
  mkdir -p {vault_path}/Limbo
  mkdir -p {vault_path}/Areas
  mkdir -p {vault_path}/Templates
  mkdir -p {vault_path}/Files

STEP 4: Copy templates from skill assets to vault Templates/
  cp skills/obsidian-brain/assets/templates/*.md {vault_path}/Templates/

STEP 5: Create .gitignore for the vault
  cat > {vault_path}/.gitignore << 'EOF'
  .obsidian/
  .trash/
  .DS_Store
  Thumbs.db
  EOF

STEP 6: Create README.md
  # {vault-name}
  > Segundo cerebro digital creado con Obsidian.

STEP 7: Initialize git
  cd {vault_path}
  git init
  git add .
  git commit -m "init: vault structure"

STEP 8: Create GitHub repo (attempt)
  gh repo create {vault-name} --private --push --source .
  
  If gh succeeds:
    → Capture GitHub URL from output
    → Set github_url = "https://github.com/DarkKevo/{vault-name}"
  
  If gh fails:
    → Print manual instructions:
      "GitHub CLI no está disponible. Podés crear el repo manualmente:
       1. Ir a https://github.com/new
       2. Crear repo privado llamado '{vault-name}'
       3. Ejecutar: git remote add origin git@github.com:DarkKevo/{vault-name}.git
       4. Ejecutar: git push -u origin main"
    → Set github_url = "" (empty)

STEP 9: Write .vaultconfig
  vault_path: {absolute vault path}
  vault_name: {original user-provided name}
  created_at: {today's date YYYY-MM-DD}
  github_url: {captured URL or ""}
  language: {detected from session: "es" or "en"}
  autocommit: true
  autopush: true

STEP 10: Confirm to user
  "¡Listo! Tu vault '{vault_name}' está creado en {vault_path}."
  If github_url: "Ya está sincronizado en GitHub."
  If no github_url: "Podés configurar GitHub después si querés."
```

---

## 3. Vault Structure Rules

### Folder Layout
```
{vault_path}/
├── Limbo/           ← ALL new notes go here (Obsidian: "New notes folder")
├── Areas/{topic}/   ← classified notes by topic after maturity
├── Templates/       ← copied from skill assets during onboarding
├── Files/           ← attachments (Obsidian: "Attachment folder")
├── .vaultconfig     ← vault configuration (YAML)
├── .gitignore       ← vault-level gitignore
└── README.md
```

### Naming Convention
- Filenames: **kebab-case** from concept title.
  - "Test Driven Development" → `test-driven-development.md`
- ASCII transliteration for non-ASCII characters.
  - "Programación Funcional" → `programacion-funcional.md`

### Frontmatter (REQUIRED on ALL notes)
| Field      | Required | Format                          |
|------------|----------|---------------------------------|
| `id`       | Yes      | YYYYMMDD-HHMM (timestamp)       |
| `alias`    | Yes      | Human-readable name             |
| `tags`     | Yes      | Array: at least one type + area |
| `created`  | Auto     | YYYY-MM-DD                      |
| `modified` | Auto     | YYYY-MM-DD                      |

### Tag Conventions
- `hub` — serves as Map of Content
- `atomic` — single-concept note
- `reference` — external source capture
- Tag by topic area: `architecture`, `languages`, `testing`, etc.

---

## 4. Template System

### Decision Tree
```
What type of note?
├── Multiple notes on same topic needing connection → Hub (hub.md)
├── Single concept, learning, explanation          → Atomic Note (atomic-note.md)
└── External source (article, video, book)         → Reference (reference.md)
```

### Template Variables
| Variable     | Description              | Source                    |
|-------------|--------------------------|---------------------------|
| `{{id}}`    | Timestamp-based ID       | Current time YYYYMMDD-HHMM |
| `{{title}}` | Note title               | Concept name              |
| `{{alias}}` | Human-readable alias     | Same as title             |
| `{{date}}`  | Creation date            | Current date YYYY-MM-DD   |
| `{{topic}}` | Topic area tag           | From context or user      |
| `{{source}}`| Source name (references) | e.g., "youtube", "article" |

### Note Creation Flow
1. Agent reads the template file from the vault's `Templates/` folder (copied during onboarding).
2. Replaces `{{variables}}` with computed values via string substitution.
3. Writes the rendered note to `Limbo/{concept-slug}.md`.

---

## 5. Capture Protocol (3-Way Hybrid)

### EXPLICIT Capture
**Trigger**: User says "guardá esto" / "save this" / "creá nota sobre X"
1. Agent picks the correct template based on context.
2. Agent generates frontmatter: `id` (YYYYMMDD-HHMM), `alias`, `tags`.
3. Agent writes the note to `Limbo/{concept-slug}.md`.
4. Agent confirms: "Listo, guardé la nota sobre {concept} en Limbo."

### IMPLICIT Capture
**Trigger**: User says "no entiendo X" / "I don't understand X"
1. Agent explains the concept.
2. Agent auto-creates an atomic note about X from the explanation.
3. Agent runs **Socratic Question Protocol** (Section 7).
4. Agent saves note with both explanation and Socratic content.

### UNSURE Capture
**Trigger**: Agent detects a concept but isn't sure about relevance.
1. Agent asks: "¿Querés que guarde esto como nota?"
2. Based on user response, create or skip.

### ALL Captures (common rules)
- **Land in Limbo/ first** — never directly in Areas/.
- **After content written**: search vault with `rg -i "{concept}" {vault_path} --type md -n` → suggest `[[wikilinks]]` in "Véase también" section.
- **Before creating**: check if `{concept}.md` exists in vault to avoid duplicates.

---

## 6. Link & Connection Protocol

### On Capture
1. Run `rg -i "{concept}" {vault_path} --type md -n`
2. If matches found → add `[[suggestions]]` in `## Véase también` section of the new note.
3. If no matches → proceed without links.

### On Maintenance (user request or periodic)
- **Orphan check**: find atomic notes tagged `{topic}` not linked from their topic Hub.
- **Cross-area**: detect conceptual overlap across `Areas/` via `rg` search.
- **Report**: "Encontré una conexión entre [[A]] y [[B]]..." with a brief explanation.

---

## 7. Socratic Question Protocol

**Trigger**: Implicit capture only (user didn't understand → agent explained).

### Flow
1. Agent explains the concept.
2. Agent asks 1-2 questions to deepen understanding (e.g., "¿En qué contexto te encontraste con esto?", "¿Cómo imaginás que se aplica?").
3. Wait for user answers.
4. Save note with:
   ```
   ## Preguntas
   1. ...
   2. ...
   
   ## Respuestas
   1. ...
   2. ...
   ```
5. If user says "seguí" → continue asking (max 5 total questions).

---

## 8. Maintenance Protocol

**Frequency**: At user request ("revisá el vault" / "check the vault") or periodically.

### Operations
1. **Move mature notes**: If a Limbo note has incoming `[[links]]` or sufficient content, suggest moving to `Areas/{topic}/`. Ask before moving.
2. **Suggest Hubs**: When 3+ atomic notes on the same topic without a Hub, suggest creating one.
3. **Validate frontmatter**: Check ALL notes for valid `id`, `alias`, `tags`. Report missing fields, offer to fix.
4. **Suggest tags**: From content analysis — ask before adding.

---

## 9. Git Sync Protocol

### Scope
- **ONLY NEW content**: first creation of a `.md` file (untracked).
- **EXCLUDED**: moves, renames, frontmatter edits, deletions.

### Detection
```bash
git status --porcelain "{filepath}"
# "?? file.md" → untracked/new → commit
# " M file.md" → modified → skip
# "A  file.md" → already staged → skip
```

### Trigger
After EVERY note creation:
```bash
git add {path/to/new-note.md}
git commit -m "capture: {concept-slug}"    # for atomic/reference
# OR
git commit -m "hub: {topic}"               # for hubs
git push                                    # if autopush=true
```

### Commit Message Format
- Atomic/Reference notes: `capture: {concept-slug}`
- Hubs: `hub: {topic}`

### Rules
- **No user approval required** — commit and push automatically.
- **Inform after**: "Listo, ya lo subí a GitHub."
- If `autopush` is false, commit only, skip push.

---

## 10. Search Commands Reference

```bash
# ── Content search (primary) ──
rg -i "{query}" {vault_path} --type md -n

# ── Tag search (frontmatter) ──
rg -i "tags:.*{tag}" {vault_path} --type md -n

# ── Filename search ──
find {vault_path} -name "*{query}*.md" -type f

# ── Fallback (no rg) ──
grep -r -i "{query}" {vault_path} --include="*.md" -n

# ── Fallback filename ──
find {vault_path} -name "*{query}*" -type f
```

### Search Decision Gate
```
Need to find notes about "{concept}"?
  rg available?
    ├── Yes → rg -i "{concept}" {vault_path} --type md -n
    └── No  → grep -r -i "{concept}" {vault_path} --include="*.md" -n

Need to find notes tagged "{tag}"?
  rg available?
    ├── Yes → rg -i "tags:.*{tag}" {vault_path} --type md -n
    └── No  → grep -r -i "tags:.*{tag}" {vault_path} --include="*.md" -n

Need to find note file by name "{name}"?
  → find {vault_path} -name "*{name}*" -type f
```

---

## 11. Hard Rules (DO NOT)

1. **Do NOT** commit moves, renames, or frontmatter-only edits.
2. **Do NOT** ask for commit permission.
3. **Do NOT** modify existing notes during capture (only the new note).
4. **Do NOT** add tags automatically without user approval.
5. **Do NOT** create notes outside Limbo/.
6. **Do NOT** hardcode vault paths — always use `.vaultconfig`.
7. **Do NOT** create duplicate notes — always check existence first.

---

## 12. Decision Gates

```
Gate 1: Is .vaultconfig present?
  ├── Yes → load vault_path, proceed
  └── No  → run Onboarding flow (Section 2)

Gate 2: User says "no entiendo X" / "I don't understand X"?
  ├── Yes → implicit capture (explain + capture + Socratic Protocol)
  └── No  → Gate 3

Gate 3: User wants to capture explicitly?
  ├── Yes → explicit capture flow (Section 5)
  └── No  → Gate 4

Gate 4: Should I capture anyway?
  ├── Yes (confident) → capture + inform
  └── No (unsure) → ask "¿Querés que guarde esto como nota?"
```