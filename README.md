# Handoff System + Git Template

Workflow complet : création de projet → sessions Claude Code → switch vers Gemini.

## Structure des fichiers

```
handoff-system/
├── install.sh              ← installateur macOS / Linux / Git Bash
├── install.ps1             ← installateur Windows (PowerShell natif)
├── new-project.sh          ← créer un repo avec Claude prêt (Unix)
├── new-project.ps1         ← créer un repo avec Claude prêt (Windows)
├── git-template/
│   ├── CLAUDE.md           ← template CLAUDE.md (rempli automatiquement)
│   ├── CONTEXT.md          ← context handoff initial vide
│   └── .gitignore          ← gitignore multi-stack
└── README.md
```

---

## Installation (une seule fois)

### macOS / Linux / Git Bash
```bash
bash install.sh
source ~/.zshrc   # ou ~/.bashrc
```

### Windows (PowerShell)
```powershell
.\install.ps1
```
> Si le script est bloqué par la politique d'exécution :
> `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

Ce qui s'installe :
| Élément | Emplacement | Rôle |
|---|---|---|
| git template | `~/.git-template/` | Copié dans chaque `git init` |
| `new-project` | `~/.local/bin/new-project` | Commande globale |
| `/handoff` | `~/.claude/commands/handoff.md` | Commande Claude Code |
| `/init-context` | `~/.claude/commands/init-context.md` | Commande Claude Code |
| `handoff.sh` / `handoff.ps1` | `~/.claude/` | Script de génération |
| Hook Stop | `~/.claude/settings.json` | Rappel automatique |
| `handoff` alias | shell profile | Depuis le terminal |

---

## Créer un nouveau projet

### macOS / Linux / Git Bash
```bash
new-project mon-api --stack node      # Node.js / TypeScript
new-project mon-script --stack python # Python
new-project ma-lib --stack rust       # Rust
new-project mon-service --stack go    # Go
new-project mon-projet                # Détection automatique
```

### Windows (PowerShell)
```powershell
new-project mon-api -Stack node
new-project mon-script -Stack python
new-project mon-projet               # Détection automatique
```

Chaque projet créé contient :
- `CLAUDE.md` pré-rempli (stack, commandes, conventions)
- `CONTEXT.md` vide prêt pour le handoff
- `.gitignore` adapté à la stack
- `.claude/settings.json` local
- Premier commit automatique

---

## Intégrer sur un projet existant

Les commandes `/handoff` et `/init-context` sont globales (installées une fois via l'installateur). Il suffit d'ajouter les deux fichiers au projet :

### macOS / Linux / Git Bash
```bash
cd mon-projet-existant
cp ~/.git-template/project-files/CLAUDE.md .
cp ~/.git-template/project-files/CONTEXT.md .
git add CLAUDE.md CONTEXT.md
git commit -m "chore: add handoff system"
```

### Windows (PowerShell)
```powershell
cd mon-projet-existant
Copy-Item "$HOME\.git-template\project-files\CLAUDE.md" .
Copy-Item "$HOME\.git-template\project-files\CONTEXT.md" .
git add CLAUDE.md CONTEXT.md
git commit -m "chore: add handoff system"
```

Puis dans Claude Code :
```
/init-context   ← Claude lit le code existant et remplit CLAUDE.md avec le vrai contexte du projet
```

C'est tout. Le workflow `/handoff` est immédiatement disponible.

> `.gitignore` : optionnel, à merger manuellement si tu as déjà le tien.

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
