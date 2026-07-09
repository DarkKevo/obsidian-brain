# Obsidian Brain 🧠

**Skill de IA** que entrena a cualquier agente (Pi, Claude Code, OpenCode, Cursor) para actuar como tu **segundo cerebro** sobre un vault de Obsidian usando la metodología Zettelkasten.

El agente captura ideas mientras te enseña, conecta conceptos automáticamente, mantiene tu vault ordenado, y te ayuda a profundizar con preguntas socráticas.

---

## ⚡ Instalación

### Desde GitHub

Descarga e instala el skill en las plataformas detectadas:

```bash
curl -fsSL https://raw.githubusercontent.com/DarkKevo/obsidian-brain/main/installer/install.sh | bash
```

Si **ya tenés un vault**, copiale los templates de notas (reemplazá por tu ruta):

```bash
curl -fsSL https://raw.githubusercontent.com/DarkKevo/obsidian-brain/main/installer/install.sh | bash -s -- --vault-path ~/ruta/al/vault
```

### Desde el repo (si lo clonaste)

```bash
cd ~/Proyectos/Skill\ Obsidian-Brain
bash installer/install.sh --vault-path ~/ruta/al/vault
```

### Ver versión

```bash
curl -fsSL https://raw.githubusercontent.com/DarkKevo/obsidian-brain/main/installer/install.sh | bash -s -- --version
```

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
| **Preguntas socráticas** | Cuando captura algo que te explicó, hace preguntas para profundizar. |
| **Mantenimiento** | Sugiere mover notas de Limbo a Áreas, crear Hubs cuando hay muchas notas del mismo tema, valida frontmatter. |
| **Git sync** | Después de cada nota pregunta "¿Hago commit?". Antes de commitear, organiza Limbo (mueve notas maduras, sugiere hubs). Nunca sube nada sin tu permiso. |
| **Búsqueda** | Busca rápido por contenido, tags o nombre de archivo. |

---

## 🔄 Actualizar el skill

Cuando haya cambios nuevos, corré el mismo comando que para instalar. Descarga la última versión y actualiza los archivos del skill (no toca tu vault):

```bash
curl -fsSL https://raw.githubusercontent.com/DarkKevo/obsidian-brain/main/installer/install.sh | bash -s -- --vault-path ~/ruta/al/vault
```

Para ver la versión instalada:

```bash
curl -fsSL https://raw.githubusercontent.com/DarkKevo/obsidian-brain/main/installer/install.sh | bash -s -- --version
```

---

## 🖥️ Plataformas soportadas

| Plataforma | Archivo que se instala |
|------------|----------------------|
| **Pi** | `~/.pi/agent/skills/obsidian-brain/SKILL.md` |
| **Claude Code** | `~/.claude/rules/obsidian-brain.md` |
| **OpenCode** | `~/.config/opencode/skills/obsidian-brain/SKILL.md` |
| **Cursor** | `~/.cursor/rules/obsidian-brain.mdc` |

---

## 📖 Protocolo completo

Todo el detalle de cómo se comporta el agente (captura, linking, mantenimiento, git sync, búsqueda, preguntas socráticas, hard rules) está en:

[`skills/obsidian-brain/SKILL.md`](skills/obsidian-brain/SKILL.md)

---

## 📝 Licencia

Apache-2.0 — ver [LICENSE](LICENSE).

---

**Creado por DarkKevo · [GitHub](https://github.com/DarkKevo/obsidian-brain)**
