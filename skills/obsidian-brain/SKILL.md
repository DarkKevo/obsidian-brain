---
name: obsidian-brain
description: "Trigger: notetaking, research, learning, capture, vault, obsidian, second brain, Zettelkasten, save note. Enseña al agente a interactuar con un vault de Obsidian usando Segundo Cerebro / Zettelkasten."
version: 1.1.0
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
github_url: https://github.com/{github-username}/mi-segundo-cerebro  # optional remote URL
language: es                                 # "es" or "en"
autopush: true                               # auto-push after user-approved commit (false = commit only)
```

### Vault Path Resolution
- Store the resolved `vault_path` and use it for ALL file operations.
- If `.vaultconfig` is missing → run **Onboarding flow** below.
- If `.vaultconfig` exists but the vault directory doesn't → re-run onboarding.
- After loading vault config → run **Template Sync Protocol** (Section 4) and **Session-Start Review** (Section 8.1).

### Onboarding Flow (when .vaultconfig is missing)

```
STEP 1: Auto-detect vault metadata
  → Check for obsidian.json in common locations:
      1. {session_cwd}/obsidian.json
      2. ~/.config/obsidian/obsidian.json
      3. ~/obsidian/obsidian.json
  → If found, parse: {path} from "vaults" entry → extract vault_name from README.md or dirname
  → If not found, check README.md in {session_cwd} for vault name
  → If auto-detect fails: ask "¿Cómo se llama tu vault?" (or "What's your vault name?")
    → User provides vault name
    → Sanitize: lowercase, spaces → dashes, ASCII transliteration
    → Example: "Mi Segundo Cerebro" → "mi-segundo-cerebro"

STEP 2: Resolve vault path
  → If obsidian.json was found → use its path directly
  → Otherwise: default to ~/{vault-name-slug}/
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
  .vaultconfig
  EOF

STEP 6: Create README.md
  # {vault-name}
  > Segundo cerebro digital creado con Obsidian.

STEP 7: Initialize git
  cd {vault_path}
  git init
  git branch -M main
  git add .
  git commit -m "init: vault structure"

STEP 8: Create GitHub repo (attempt)
  gh repo create {vault-name} --private --push --source .
  
  If gh succeeds:
    → Capture GitHub URL from output
    → Set github_url = "https://github.com/{github-username}/{vault-name}"
  
  If gh fails:
    → Print manual instructions:
      "GitHub CLI no está disponible. Podés crear el repo manualmente:
       1. Ir a https://github.com/new
       2. Crear repo privado llamado '{vault-name}'
       3. Ejecutar: git remote add origin git@github.com:{github-username}/{vault-name}.git
       4. Ejecutar: git push -u origin main"
    → Set github_url = "" (empty)

STEP 9: Write .vaultconfig
  vault_path: {absolute vault path}
  vault_name: {original user-provided name}
  created_at: {today's date YYYY-MM-DD}
  github_url: {captured URL or ""}
  language: {detected from session: "es" or "en"}
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

### Template Sync Protocol

Keeps vault Templates/ in sync with skill assets.

**Trigger**: At session start, after vault config is loaded, OR on user request.

```
STEP 1: Compare checksums
  → For each template in skill assets (assets/templates/*.md):
      → Compute sha256sum of asset file
      → Compare with {vault_path}/Templates/{same_name}
      
STEP 2: Report drift
  → If any template differs or doesn't exist in vault:
      "Hay {N} templates desactualizados: [lista]. ¿Sincronizo?"

STEP 3: Sync
  → If user approves:
      cp -r skills/obsidian-brain/assets/templates/*.md {vault_path}/Templates/
      git add .
      git commit -m "vault: sync templates"
  → If user declines: skip, ask again next session

STEP 4: Template version tracking
  → Store template version file: {vault_path}/.template-version
    template_version: "1.0"
    last_sync: 2026-07-09
  → On sync, update version + date
  → On mismatch, flag for sync
```

**Skip rules**:
- If vault has templates that skill assets don't → they're custom, never touch
- If skill assets have templates that vault doesn't → ask to add
- If both exist but differ → ask to overwrite
- Never delete vault templates that have no asset counterpart

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
- **After content written**: run 3-Tier Search (Section 10) to find connections → suggest `[[wikilinks]]` in "Véase también" section.
- **Before creating**: slugify the concept name and check if `{slug}.md` exists in vault to avoid duplicates.

---

## 6. Link & Connection Protocol

### On Capture
1. Run **3-Tier Search** (Section 10) against `{vault_path}`.
2. If matches found → add `[[suggestions]]` in `## Véase también` section of the new note.
3. If no matches → proceed without links.

### On Maintenance (user request or periodic)
- **Orphan check**: find atomic notes tagged `{topic}` not linked from their topic Hub.
- **Cross-area**: run 3-Tier Search across `Areas/` for conceptual overlap.
- **Cross-language**: if `language=es`, also search English terms from the built-in mapping (Section 10).
- **Indirect links**: use Tier 3 search to detect A→B→C relationships.
- **Report**: "Encontré una conexión entre [[A]] y [[B]]..." with a brief explanation and the relationship path.

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

### Triggers
1. **At user request**: "revisá el vault" / "check the vault"
2. **At session start**: Automatic check (Section 8.1) — runs silently, only reports if action needed
3. **Periodic**: Every ~5 interactions without maintenance, or if 3+ days since last check

### Operations
1. **Move mature notes**: If a Limbo note has incoming `[[links]]` or sufficient content, suggest moving to `Areas/{topic}/`. Ask before moving.
2. **Suggest Hubs**: When 3+ atomic notes on the same topic without a Hub, suggest creating one.
3. **Validate frontmatter**: Check ALL notes for valid `id`, `alias`, `tags`. Report missing fields, offer to fix.
4. **Suggest tags**: From content analysis — ask before adding.

### 8.1 Session-Start Review

Runs automatically when the skill activates (silently).

```
Check 1: Limbo aging
  → Find notes older than 3 days in Limbo/
  → If any: "Hay {N} notas en Limbo sin revisar desde {fecha}. ¿Las revisamos?"

Check 2: Hubs missing
  → Group atomic notes by tag
  → If 3+ atomic notes share a tag without a Hub → "Hay {N} notas sobre {tema} sin Hub. ¿Creo uno?"

Check 3: Orphan links
  → Find [[wikilinks]] in Limbo/ that don't resolve to any .md file
  → If any: "Hay {N} wikilinks rotos en tus notas. ¿Los revisamos?"

Check 4: Last maintenance age
  → Check modified date of last Areas/ change
  → If >7 days: "Pasó una semana desde la última organización del vault. ¿Revisamos?"

→ If ALL checks pass: stay silent (no output)
→ If ANY check fails: report only the most impactful finding (max 1 prompt per session)
```

### 8.2 Periodic Check (every ~5 interactions)

Every 5th tool call or interaction where a note was created, re-run Section 8.1 checks.
Only report if a NEW issue appeared since the last review.

### Decision Gate
```
Session starts → run Maintenance Protocol checks
  ├── Nothing to report → stay silent, continue
  └── Issues found → report the single most relevant finding + ask
       ├── User acts → done
       └── User says skip/después → don't ask again this session

---

## 9. Git Sync Protocol

### Scope
- **New content**: first creation of a `.md` file in Limbo/.
- **Moves**: from Limbo/ to Areas/ when a note matures.
- **Hubs**: newly created hubs for related notes.
- **Frontmatter**: validation fixes.
- Adds and modifications are included.

### Trigger
After EVERY note creation, ASK the user before committing:

> "¿Hago commit y push de `{note}`?"

- If user says **no / después / skip** → skip git entirely. Next time, ask again.
- If user says **yes / dale / ok** → proceed to **Organize Limbo** first, then commit everything.

### Organize Limbo (runs BEFORE commit)

Once the user approves the commit, **before touching git**, run Maintenance Protocol (Section 8) on Limbo/:

1. **Check for mature notes**: For each note in Limbo/, check if it has incoming `[[links]]` or sufficient content → ask "¿Muevo `{note}` a `Areas/{topic}/`?"
2. **Check for hubs**: If 3+ atomic notes share a topic without a Hub → suggest creating one.
3. **Validate frontmatter**: Scan all notes being committed for valid `id`, `alias`, `tags`.

If the user accepts moves or hub creation, those changes are included in the commit.

### Commit Flow
```bash
# 1. User approved → run Organize Limbo (above) first
# 2. Then stage everything and commit

git add -A                              # stage all changes
git commit -m "capture: {concept-slug}"  # for atomic/reference
# OR
git commit -m "hub: {topic}"             # for hubs
git push                                 # if autopush=true
```

### Batch Commit at Session End
If multiple notes were created during the session, the agent MAY ask at the end:

> "Hay {N} notas nuevas sin commitear. ¿Hago commit de todas?"

Same flow: user approves → organize Limbo → commit all → push.

### Commit Message Format
- Atomic/Reference notes: `capture: {concept-slug}`
- Hubs: `hub: {topic}`
- Maintenance: `vault: organize Limbo`

### Rules
- **Always ask before committing** — never commit without explicit user approval.
- **Organize Limbo first** — antes de commitear, preguntá si mover notas maduras o crear hubs.
- **Inform after**: "Listo, ya lo subí a GitHub."
- If `autopush` is false, commit only, skip push.

---

## 10. Search & Connection Protocol

### Search Levels (3-Tier)

Every search runs **up to 3 tiers**, escalating automatically if no results are found.

```
TIER 1 — Direct match (exact concept)
  → rg -i "{concept}" {vault_path} --type md -n | grep -v "Templates/"
  → If match: extract [[wikilinks]] from matching note → suggest as relations
  → HIT → done, add [[links]] to new note
  → NO HIT → escalate to Tier 2

TIER 2 — Semantic / variant match
  Run 3 parallel searches:
    a) rg -i "{concept}" {vault_path} --type md -n | grep -v "Templates/"
       (retry without case sensitivity, fuzzy-like)
    b) Cross-language lookups:
       if language=es: also search English terms via built-in mapping
       if language=en: also search Spanish terms via built-in mapping
       → es↔en pairs: { "arquitectura": "architecture", "puerto": "port",
         "adaptador": "adapter", "microservicio": "microservice",
         "dominio": "domain", "testing": "test", "base de datos": "database",
         "dependencia": "dependency", "interfaz": "interface",
         "implementacion": "implementation" }
    c) Stemmed / truncated:
       rg -i "{shortened_query}" {vault_path} --type md -n
       → e.g. "implementacion" also matches "implementar", "implementado"
  → If any match: suggest [[link]] with note that concept is mentioned in [[context]]
  → NO HIT → escalate to Tier 3

TIER 3 — Indirect relationship (A→B→C)
  → Find notes whose [[wikilinks]] reference a concept that is itself linked to our query
  → Example:
      Query: "clean architecture"
      Nota-1 mentions [[arquitectura-hexagonal]]
      Nota-2 (arquitectura-hexagonal) links to [[clean-architecture]]
      → Found: Nota-1 is indirectly related through Nota-2
  → Algorithm:
      1. Find notes that contain [[wikilinks]] pointing to any note in our vault
      2. Of those linked notes, do any contain our search term?
      3. → Suggest: "[[Nota-1]] menciona [[nota-intermediaria]] que está relacionado con {concept}"
  → If still NO matches: proceed without links (suggest user to create note)
```

### Cross-Language Mapping Table

Built-in bilingual pairs for es↔en detection. Expandable by user.

```yaml
es_en_pairs:
  arquitectura: architecture
  puerto: port
  adaptador: adapter
  microservicio: microservice
  dominio: domain
  testing: test
  base de datos: database
  dependencia: dependency
  interfaz: interface
  implementacion: implementation
  algoritmo: algorithm
  seguridad: security
  prueba: test/assertion
  despliegue: deployment
  escalabilidad: scalability
  mantenimiento: maintenance
  rendimiento: performance
  event: evento
  mensaje: message
  flujo: flow
  capa: layer
  notificacion: notification
  patron: pattern
  repositorio: repository
  servicio: service
  autenticacion: authentication
  autorizacion: authorization
  excepcion: exception
  error: error
  configuracion: configuration
```

### Commands Reference

```bash
# ── Content search (primary) ──
rg -i "{query}" {vault_path} --type md -n | grep -v "Templates/"

# ── Tag search (frontmatter) ──
rg -i "tags:.*{tag}.*" {vault_path} --type md -n

# ── Filename search ──
find {vault_path} -name "*{query}*.md" -type f

# ── Wikilink search (find what links TO a note) ──
rg -i "\[\[{query}\]\]" {vault_path} --type md -n

# ── Indirect relationship search ──
# Find notes that link to our linked-notes
LINKED=$(rg -oP '\[\[[^\]]+\]\]' "{vault_path}/Limbo/query-note.md" | tr -d '[]')
for l in $LINKED; do
  rg -l "\[\[$l\]\]" {vault_path} --type md | grep -v "query-note.md"
done

# ── Cross-language search (automatic) ──
# If no results in es, try the english equivalent
# rg -i "architecture" {vault_path} --type md -n

# ── Orphan check ──
# Find [[links]] that don't resolve to any file
for f in {vault_path}/Limbo/*.md; do
  rg -oP '\[\[[^\]]+\]\]' "$f" | tr -d '[]' | while read link; do
    [ -f "{vault_path}/Limbo/$link.md" ] || [ -f "{vault_path}/Areas/*/$link.md" ] || echo "$f -> [[$link]] sin resolver"
  done
done

# ── Fallback (no rg) ──
grep -r -i "{query}" {vault_path} --include="*.md" -n

# ── Fallback filename ──
find {vault_path} -name "*{query}*" -type f
```

### Search Decision Gate
```
Need to find notes about "{concept}"?
  → Run Tier 1: Direct match
    ├── HIT → suggest [[links]], done
    └── MISS → escalate to Tier 2
  → Run Tier 2: Semantic / cross-language
    ├── HIT → suggest [[links]], done
    └── MISS → escalate to Tier 3
  → Run Tier 3: Indirect (A→B→C)
    ├── HIT → suggest indirect connection
    └── MISS → proceed without links

Need to find notes tagged "{tag}"?
  rg available?
    ├── Yes → rg -i "tags:.*{tag}.*" {vault_path} --type md -n
    └── No  → grep -r -i "tags:.*{tag}" {vault_path} --include="*.md" -n

Need to find note file by name "{name}"?
  → find {vault_path} -name "*{name}*" -type f

Need to know what links TO a note?
  → rg -i "\[\[{note-name}\]\]" {vault_path} --type md -n

Need to find bilingual matches?
  → If concept in es, also search en pair
  → If concept in en, also search es pair
  → Use built-in es_en_pairs mapping
```

---

## 11. Hard Rules (DO NOT)

1. **Do NOT** commit moves, renames, or frontmatter-only edits as standalone operations — only as part of a content capture commit after user approval.
   
   > Exception: Organize Limbo flow (Section 9) may include moves and frontmatter fixes.
2. **Do NOT** commit without explicit user approval.
3. **Do NOT** modify existing notes during capture (only the new note).
4. **Do NOT** add tags automatically without user approval.
5. **Do NOT** create notes outside Limbo/.
6. **Do NOT** hardcode vault paths — always use `.vaultconfig`.
7. **Do NOT** create duplicate notes — always check existence first.
8. **Do NOT** create notes outside the vault directory.

---

## 12. Decision Gates

```
Gate 0: Session start
  ├── Is .vaultconfig present?
  │     ├── Yes → load vault_path, run Template Sync (Section 4), run Session-Start Review (Section 8.1)
  │     └── No  → run Onboarding flow (Section 2)
  └── Continue to Gate 1

Gate 1: User says "no entiendo X" / "I don't understand X"?
  ├── Yes → implicit capture (explain + capture + Socratic Protocol)
  └── No  → Gate 2

Gate 2: User wants to capture explicitly?
  ├── Yes → explicit capture flow (Section 5)
  └── No  → Gate 3

Gate 3: Should I capture anyway?
  ├── Yes (confident) → capture + inform
  └── No (unsure) → ask "¿Querés que guarde esto como nota?"

Gate 4: Periodic maintenance due?
  ├── ~5 interactions since last check or 3+ days → run Session-Start Review (Section 8.1)
  └── No → stay silent
```