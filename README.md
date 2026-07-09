# Obsidian Brain — AI Skill para Vaults de Obsidian

**Obsidian Brain** es un skill de IA que entrena a cualquier agente (Pi, Claude Code, OpenCode, Cursor) para interactuar con un vault de Obsidian usando la metodología **Segundo Cerebro / Zettelkasten**. El agente actúa como tu secretario del segundo cerebro: captura ideas, conecta conceptos, mantiene el vault y sincroniza con GitHub.

## Instalación (una línea)

```bash
curl -fsSL https://raw.githubusercontent.com/DarkKevo/obsidian-brain/main/installer/install.sh | bash
```

Si ya tenés un vault y querés copiar los templates:

```bash
curl -fsSL https://raw.githubusercontent.com/DarkKevo/obsidian-brain/main/installer/install.sh | bash -s -- --vault-path ~/mi-vault
```

El installer detecta automáticamente qué plataformas tenés instaladas (Pi, Claude Code, OpenCode, Cursor) y copia los archivos necesarios.

## Features

- **Captura híbrida**: explícita (le pedís guardar algo), implícita (el agente captura cuando te explica un concepto), o con confirmación (pregunta si no está seguro).
- **Tres tipos de nota**: Hub (Mapa de Contenido), Atómica (un concepto), Referencia (fuente externa).
- **Sugerencia de links**: al crear una nota, busca automáticamente conceptos relacionados en el vault y sugiere `[[wikilinks]]`.
- **Preguntas socráticas**: cuando captura implícitamente, profundiza con preguntas para entender mejor el contexto.
- **Git sync con aprobación**: después de cada nota, pregunta si querés commitear. Nunca sube nada sin tu permiso.
- **Mantenimiento**: move notas de Limbo a Areas, sugerí Hubs, validá frontmatter.
- **Onboarding guiado**: crea el vault, la estructura de carpetas y el repo de GitHub en un solo flujo.

## Plataformas Soportadas

| Plataforma | Archivo | Formato |
|------------|---------|---------|
| Pi (gentle-pi) | `skills/obsidian-brain/SKILL.md` | Skill nativo con frontmatter YAML |
| Claude Code | `adapters/claude-code/.claude/rules/obsidian-brain.md` | Regla Claude Code |
| OpenCode | `adapters/opencode/AGENTS.md` | Sección en AGENTS.md |
| Cursor | `adapters/cursor/.cursor/rules/obsidian-brain.mdc` | Regla Cursor con glob `**/*.md` |

Todas las plataformas referencian el mismo `SKILL.md` como fuente canónica.

## Instalación

### Rápida (installer)

```bash
./installer/install.sh
```

### Manual

1. **Pi (gentle-pi)**: Copiá o symlinkeá `skills/obsidian-brain/SKILL.md` a tu directorio de skills de Pi.
2. **Claude Code**: Copiá `adapters/claude-code/.claude/rules/obsidian-brain.md` a `~/.claude/rules/`.
3. **OpenCode**: Copiá la sección `## obsidian-brain` de `adapters/opencode/AGENTS.md` a tu `AGENTS.md`.
4. **Cursor**: Copiá `adapters/cursor/.cursor/rules/obsidian-brain.mdc` a `~/.cursor/rules/`.

Después de instalar, el agente de IA tendrá acceso al protocolo completo. En la primera interacción, te va a preguntar el nombre de tu vault y lo va a configurar solo.

## Mantenerse Actualizado

```bash
# Ver versión instalada y última disponible
curl -fsSL https://raw.githubusercontent.com/DarkKevo/obsidian-brain/main/installer/install.sh --version

# Reinstalar la última versión (reescribe archivos, no toca el vault)
curl -fsSL https://raw.githubusercontent.com/DarkKevo/obsidian-brain/main/installer/install.sh | bash -s -- --vault-path ~/tu-vault
```

También podés checkear el [repositorio en GitHub](https://github.com/DarkKevo/obsidian-brain) para ver los cambios nuevos.

## Protocolo Completo

El skill completo con todos los protocolos (captura, linking, mantenimiento, git sync, búsqueda, preguntas socráticas) está en:

[`skills/obsidian-brain/SKILL.md`](skills/obsidian-brain/SKILL.md)

## Licencia

Apache-2.0 — ver [LICENSE](LICENSE).