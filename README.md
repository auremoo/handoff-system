# Handoff System + Git Template

Workflow complet : création de projet → sessions Claude Code → switch vers Gemini.

## Structure des fichiers

```
handoff-system/
├── install.sh              ← script d'installation global (tout-en-un)
├── new-project.sh          ← créer un repo avec Claude prêt
├── git-template/
│   ├── CLAUDE.md           ← template CLAUDE.md (rempli automatiquement)
│   ├── CONTEXT.md          ← context handoff initial vide
│   └── .gitignore          ← gitignore multi-stack
└── README.md
```

## Installation (une seule fois)

```bash
bash install.sh
source ~/.zshrc   # ou ~/.bashrc
```

Ce qui s'installe :
| Élément | Emplacement | Rôle |
|---|---|---|
| git template | `~/.git-template/` | Copié dans chaque `git init` |
| `new-project` | `~/.local/bin/new-project` | Commande globale |
| `/handoff` | `~/.claude/commands/handoff.md` | Commande Claude Code |
| `/init-context` | `~/.claude/commands/init-context.md` | Commande Claude Code |
| `handoff.sh` | `~/.claude/handoff.sh` | Script de génération |
| Hook Stop | `~/.claude/settings.json` | Rappel automatique |
| `handoff` alias | `~/.zshrc` | Depuis le terminal |

---

## Créer un nouveau projet

```bash
new-project mon-api --stack node      # Node.js / TypeScript
new-project mon-script --stack python # Python
new-project ma-lib --stack rust       # Rust
new-project mon-service --stack go    # Go
new-project mon-projet                # Détection automatique
```

Chaque projet créé contient :
- `CLAUDE.md` pré-rempli (stack, commandes, conventions)
- `CONTEXT.md` vide prêt pour le handoff
- `.gitignore` adapté à la stack
- `.claude/settings.json` local
- Premier commit automatique

---

## Workflow quotidien

```
new-project mon-api --stack node
cd mon-api
claude

# Dans Claude Code :
/init-context          ← Claude lit CLAUDE.md + CONTEXT.md

# ... tu codes ...

# Quand tu approches la limite :
/handoff               ← Claude complète CONTEXT.md + donne le prompt Gemini
                       ← Colle le prompt dans Gemini → continue sans rien réexpliquer
```

---

## Prompt d'amorce Gemini (généré automatiquement dans CONTEXT.md)

```
Tu reprends une session de développement. Voici le contexte exact :

[CONTENU DU CONTEXT.md]

Règles :
- Ne me redemande pas ce qui est déjà décidé
- Commence directement par la "Prochaine action immédiate"
- Si tu as besoin d'un fichier, demande-le moi
- Sois concis, on est en mid-session

Go.
```
