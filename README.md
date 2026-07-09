# Obsidian Brain 🧠

**Skill de IA** que entrena a cualquier agente (Pi, Claude Code, OpenCode, Cursor) para actuar como tu **segundo cerebro** sobre un vault de Obsidian usando la metodología Zettelkasten.

El agente captura ideas mientras te enseña, conecta conceptos automáticamente, mantiene tu vault ordenado, y te ayuda a profundizar con preguntas socráticas.

---

## ⚡ Instalación

### Desde GitHub (recomendado)

```bash
curl -fsSL https://raw.githubusercontent.com/DarkKevo/obsidian-brain/main/installer/install.sh | bash
```

Si **ya tenés un vault** y querés copiarle los templates:

```bash
curl -fsSL https://raw.githubusercontent.com/DarkKevo/obsidian-brain/main/installer/install.sh | bash -s -- --vault-path ~/mi-vault
```

### Desde el repo (si lo clonaste)

```bash
cd ~/Proyectos/Skill\ Obsidian-Brain
bash installer/install.sh --vault-path ~/mi-vault
```

### Ver versión instalada

```bash
# Si tenés el repo clonado:
bash installer/install.sh --version

# Via curl (atentiendo al pipe):
curl -fsSL https://raw.githubusercontent.com/DarkKevo/obsidian-brain/main/installer/install.sh | bash -s -- --version
```

> El installer detecta automáticamente qué plataformas tenés instaladas (Pi, Claude Code, OpenCode, Cursor) y copia los archivos donde corresponde.

---

## 🚀 Primeros pasos

Después de instalar, hablá con tu agente IA. En la primera interacción te va a guiar:

```
Vos:    "creá mi vault de obsidian"
Agente: "¿Cómo se llama tu vault?"
Vos:    "segundo-cerebro"
Agente: ✅ Crea la estructura, templates, git init y GitHub privado
```

Después ya podés aprender y el agente captura solo:

```
Vos:    "no entiendo qué es un monad"
Agente: Te explica, crea la nota atómica, y te pregunta:
        "¿Hago commit de esto a GitHub?"
```

---

## ✨ Capacidades

| Capacidad | Cómo funciona |
|-----------|--------------|
| **Captura híbrida** | Decís "guardá esto" → crea nota. Preguntás "no entiendo X" → te explica y la guarda sola. Si duda, pregunta. |
| **3 tipos de nota** | **Hub** (mapa de contenido), **Atómica** (un concepto), **Referencia** (fuente externa) |
| **Links automáticos** | Al crear una nota, busca conceptos relacionados en tu vault y sugiere `[[wikilinks]]` |
| **Preguntas socráticas** | Cuando captura algo que te explicó, hace 1-2 preguntas para profundizar. Si decís "seguí", sigue. |
| **Mantenimiento** | Sugiere mover notas de Limbo a Áreas, crear Hubs cuando hay muchas notas del mismo tema, valida frontmatter |
| **Git sync** | Después de cada nota pregunta "¿Hago commit?". Nunca sube nada sin tu permiso. |
| **Búsqueda** | Usa `rg` (ripgrep) para buscar rápido por contenido, tags o nombre de archivo |

---

## 🔄 Actualizar el skill

Cuando haya cambios nuevos en el repo, actualizás con el mismo comando de instalación:

```bash
curl -fsSL https://raw.githubusercontent.com/DarkKevo/obsidian-brain/main/installer/install.sh | bash -s -- --vault-path ~/tu-vault
```

Eso descarga la última versión y la instala (sobreescribe archivos del skill, **no toca tu vault**).

Para ver si hay una versión más nueva:

```bash
# Mostrar versión actual
bash installer/install.sh --version

# Después checkeá los cambios en GitHub:
# https://github.com/DarkKevo/obsidian-brain
```

---

## 🖥️ Plataformas soportadas

| Plataforma | Archivo que se instala |
|------------|----------------------|
| **Pi** | `~/.pi/agent/skills/obsidian-brain/SKILL.md` |
| **Claude Code** | `~/.claude/rules/obsidian-brain.md` |
| **OpenCode** | `~/.config/opencode/skills/obsidian-brain/SKILL.md` |
| **Cursor** | `~/.cursor/rules/obsidian-brain.mdc` |

Todas las plataformas usan el mismo `SKILL.md` como fuente canónica. Los adapters solo referencian al archivo principal.

---

## 📖 Protocolo completo

Todo el detalle de cómo se comporta el agente está en:

[`skills/obsidian-brain/SKILL.md`](skills/obsidian-brain/SKILL.md)

Incluye: activation contract, configuración del vault, estructura de carpetas, sistema de templates, protocolo de captura (explícita/implícita/duda), linking, preguntas socráticas, mantenimiento, git sync, comandos de búsqueda, hard rules y decision gates.

---

## 📝 Licencia

Apache-2.0 — ver [LICENSE](LICENSE).

---

**Creado por DarkKevo · [GitHub](https://github.com/DarkKevo/obsidian-brain)**
