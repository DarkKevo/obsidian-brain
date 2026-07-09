# Vault Structure Reference

## Folder Hierarchy

```
{vault_root}/
├── Limbo/              # Inbox for ALL new notes (default landing zone)
│   ├── atomic-note.md
│   └── reference.md
├── Areas/               # Classified notes by topic
│   └── {topic}/
│       ├── hub-{topic}.md
│       ├── atomic-note.md
│       └── ...
├── Templates/           # Copies of the 3 template files
│   ├── hub.md
│   ├── atomic-note.md
│   └── reference.md
├── Files/               # Default attachment folder for Obsidian
├── .vaultconfig         # Vault configuration (YAML)
├── .gitignore
└── README.md
```

## Naming Convention

- **Filenames**: kebab-case from concept title
  - "Test Driven Development" → `test-driven-development.md`
  - Non-ASCII transliterated: "Programación Funcional" → `programacion-funcional.md`

## Frontmatter Standards

| Field      | Required | Format                          |
|------------|----------|---------------------------------|
| `id`       | Yes      | YYYYMMDD-HHMM (timestamp)       |
| `alias`    | Yes      | Human-readable name             |
| `tags`     | Yes      | Array: at least one type + area |
| `created`  | Auto     | YYYY-MM-DD                      |
| `modified` | Auto     | YYYY-MM-DD                      |

## Tag Conventions

- `hub` — serves as Map of Content
- `atomic` — single-concept note
- `reference` — external source capture
- Tag by topic area: `architecture`, `languages`, `testing`, etc.