#!/usr/bin/env bash
# ============================================================
#  HANDOFF SYSTEM — Installateur global
#  Usage : bash install.sh
# ============================================================
set -e

BOLD='\033[1m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RESET='\033[0m'
info()    { echo -e "${CYAN}▸ $*${RESET}"; }
success() { echo -e "${GREEN}✓ $*${RESET}"; }
warn()    { echo -e "${YELLOW}⚠ $*${RESET}"; }

echo -e "\n${BOLD}══════════════════════════════════════════${RESET}"
echo -e "${BOLD}   HANDOFF SYSTEM — Installation${RESET}"
echo -e "${BOLD}══════════════════════════════════════════${RESET}\n"

# 1. Dossier global Claude Code
CLAUDE_DIR="$HOME/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands"
mkdir -p "$COMMANDS_DIR"
info "Dossier ~/.claude/commands créé"

# 2. Script principal handoff
cat > "$CLAUDE_DIR/handoff.sh" << 'EOF'
#!/usr/bin/env bash
# ============================================================
#  handoff.sh — Génère un CONTEXT.md de handoff
#  Appelé par la commande /handoff dans Claude Code
# ============================================================

PROJECT_DIR="${1:-$(pwd)}"
OUTPUT="$PROJECT_DIR/CONTEXT.md"
DATE=$(date '+%Y-%m-%d %H:%M')
BRANCH=$(git -C "$PROJECT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "N/A")
LAST_COMMITS=$(git -C "$PROJECT_DIR" log --oneline -5 2>/dev/null || echo "N/A")
MODIFIED=$(git -C "$PROJECT_DIR" diff --name-only 2>/dev/null | head -20 || echo "N/A")
STAGED=$(git -C "$PROJECT_DIR" diff --cached --name-only 2>/dev/null | head -10 || echo "N/A")

# Détecte la stack
STACK=""
[ -f "$PROJECT_DIR/package.json" ]     && STACK="$STACK Node.js/JS"
[ -f "$PROJECT_DIR/tsconfig.json" ]    && STACK="$STACK TypeScript"
[ -f "$PROJECT_DIR/requirements.txt" ] && STACK="$STACK Python"
[ -f "$PROJECT_DIR/pyproject.toml" ]   && STACK="$STACK Python"
[ -f "$PROJECT_DIR/Cargo.toml" ]       && STACK="$STACK Rust"
[ -f "$PROJECT_DIR/go.mod" ]           && STACK="$STACK Go"
[ -f "$PROJECT_DIR/pom.xml" ]          && STACK="$STACK Java/Maven"
[ -f "$PROJECT_DIR/Dockerfile" ]       && STACK="$STACK Docker"
[ -z "$STACK" ]                        && STACK="Non détectée"

cat > "$OUTPUT" << TEMPLATE
# CONTEXT HANDOFF — $DATE

> Fichier généré automatiquement. À compléter par Claude avant le switch.
> **Colle ce fichier en début de session Gemini ou autre LLM.**

---

## Projet
- **Chemin** : \`$PROJECT_DIR\`
- **Stack** : $STACK
- **Branche git** : \`$BRANCH\`

## Objectif de la session
<!-- Claude complète ici en 1-2 phrases -->
...

## Ce qui a été fait ✅
<!-- Claude liste les tâches terminées -->
- [ ] ...

## Tâche en cours ⚙️
<!-- Claude décrit précisément où on en est -->
**Fichier(s) concerné(s)** : \`...\`
**Étape interrompue** : ...

## Prochaine action immédiate 🎯
<!-- UNE seule action concrète à faire en premier -->
...

## Décisions importantes prises
<!-- Les choix d'architecture, libs, patterns retenus -->
- ...

## Fichiers clés modifiés
<!-- Git diff résumé -->
\`\`\`
$MODIFIED
\`\`\`

**Staged (prêts au commit)** :
\`\`\`
$STAGED
\`\`\`

## Derniers commits
\`\`\`
$LAST_COMMITS
\`\`\`

## Contraintes / pièges à éviter ⚠️
<!-- Ce que l'autre LLM NE doit PAS faire -->
- ...

## Prompt d'amorce pour Gemini / autre LLM
\`\`\`
Tu reprends une session de développement. Voici le contexte exact :

[COLLE LE CONTENU DE CE FICHIER ICI]

Règles :
- Ne me redemande pas ce qui est déjà décidé
- Commence directement par la "Prochaine action immédiate"
- Si tu as besoin d'un fichier, demande-le moi
- Sois concis, on est en mid-session

Go.
\`\`\`

---
*Généré par handoff.sh — $(date)*
TEMPLATE

echo ""
echo "✅ CONTEXT.md généré : $OUTPUT"
echo ""
echo "📋 Prochaines étapes :"
echo "   1. Demande à Claude de compléter les sections '...'"
echo "   2. Copie le bloc 'Prompt d\'amorce' dans Gemini"
echo "   3. Colle le contenu du CONTEXT.md à la suite"
echo ""
EOF
chmod +x "$CLAUDE_DIR/handoff.sh"
success "Script ~/.claude/handoff.sh installé"

# 3. Commande Claude Code /handoff
cat > "$COMMANDS_DIR/handoff.md" << 'EOF'
---
description: Génère un fichier CONTEXT.md de handoff pour switcher vers un autre LLM (Gemini, etc.) sans perdre le contexte
---

Génère un fichier de handoff complet pour continuer cette session sur un autre LLM sans perdre de contexte.

Voici ce que tu dois faire :

1. Lance d'abord le script selon le système :
   - **macOS / Linux** : `bash ~/.claude/handoff.sh "$PWD"`
   - **Windows** : `powershell -NoProfile -File "$HOME\.claude\handoff.ps1" "$PWD"`

2. Ensuite, **complète le fichier CONTEXT.md généré** en remplissant précisément :
   - **Objectif de la session** : résume en 1-2 phrases ce qu'on essaie d'accomplir
   - **Ce qui a été fait** : liste les tâches terminées dans cette session
   - **Tâche en cours** : décris exactement où on s'est arrêté, quel fichier, quelle étape
   - **Prochaine action immédiate** : une seule action concrète, la plus précise possible
   - **Décisions importantes** : les choix techniques retenus (libs, patterns, architecture)
   - **Contraintes / pièges** : ce que l'autre LLM ne doit surtout pas faire

3. Affiche le **prompt d'amorce final** prêt à copier-coller dans Gemini.

Sois dense et précis — chaque mot compte, l'autre LLM n'aura pas notre historique.
EOF
success "Commande ~/.claude/commands/handoff.md installée"

# 4. Commande /init-context pour démarrer une session depuis un CONTEXT.md
cat > "$COMMANDS_DIR/init-context.md" << 'EOF'
---
description: Charge le CONTEXT.md du projet pour reprendre une session précédente
---

Lis le fichier CONTEXT.md à la racine du projet courant et reprends exactement là où la session précédente s'est arrêtée.

- **macOS / Linux** : `cat "$PWD/CONTEXT.md" 2>/dev/null || echo "Aucun CONTEXT.md trouvé"`
- **Windows** : `Get-Content "$PWD\CONTEXT.md"`

Après lecture :
1. Confirme en une phrase ce que tu as compris de la situation
2. Identifie la "Prochaine action immédiate" et propose de la commencer
3. Ne redemande pas ce qui est déjà décidé dans le fichier
EOF
success "Commande ~/.claude/commands/init-context.md installée"

# 5. Hook global Stop — rappel si pas de CONTEXT.md récent
mkdir -p "$HOME/.claude"
SETTINGS="$HOME/.claude/settings.json"

# Merge propre avec le settings.json existant
if [ -f "$SETTINGS" ]; then
    cp "$SETTINGS" "$SETTINGS.backup"
    info "Backup de settings.json existant → settings.json.backup"
fi

# Script hook stop
cat > "$CLAUDE_DIR/hooks/check-handoff.sh" << 'HOOK_EOF'
#!/usr/bin/env bash
# Hook Stop — vérifie si un CONTEXT.md existe et est récent
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
CONTEXT_FILE="$PROJECT_DIR/CONTEXT.md"

if [ ! -f "$CONTEXT_FILE" ]; then
    echo '{"additionalContext": "💡 RAPPEL : Aucun CONTEXT.md dans ce projet. Lance /handoff avant de te déconnecter pour sauvegarder le contexte."}'
else
    # Vérifie si le fichier date de plus de 2h
    if [ "$(find "$CONTEXT_FILE" -mmin +120 2>/dev/null)" ]; then
        echo '{"additionalContext": "💡 RAPPEL : Le CONTEXT.md date de plus de 2h. Pense à relancer /handoff pour le mettre à jour."}'
    fi
fi
HOOK_EOF
mkdir -p "$CLAUDE_DIR/hooks"
chmod +x "$CLAUDE_DIR/hooks/check-handoff.sh"
success "Hook Stop ~/.claude/hooks/check-handoff.sh installé"

# 6. Merge le hook dans settings.json
python3 << 'PYEOF'
import json, os

settings_path = os.path.expanduser("~/.claude/settings.json")

if os.path.exists(settings_path):
    with open(settings_path) as f:
        settings = json.load(f)
else:
    settings = {}

hooks = settings.get("hooks", {})

stop_hooks = hooks.get("Stop", [])
hook_entry = {
    "hooks": [{
        "type": "command",
        "command": "bash ~/.claude/hooks/check-handoff.sh",
        "async": True
    }]
}

# Evite les doublons
already_there = any(
    any(h.get("command", "").endswith("check-handoff.sh") for h in entry.get("hooks", []))
    for entry in stop_hooks
)
if not already_there:
    stop_hooks.append(hook_entry)

hooks["Stop"] = stop_hooks
settings["hooks"] = hooks

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)

print("✓ Hook ajouté dans ~/.claude/settings.json")
PYEOF

# 7. Alias shell
SHELL_RC=""
if [ -f "$HOME/.zshrc" ]; then SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then SHELL_RC="$HOME/.bashrc"
fi

if [ -n "$SHELL_RC" ]; then
    if ! grep -q "# HANDOFF SYSTEM" "$SHELL_RC"; then
        cat >> "$SHELL_RC" << 'ALIAS_EOF'

# HANDOFF SYSTEM — Switch Claude Code → Gemini
alias handoff='bash ~/.claude/handoff.sh "$PWD" && echo "→ Maintenant tape /handoff dans Claude Code pour que Claude complète le fichier"'
alias load-context='cat "$PWD/CONTEXT.md" 2>/dev/null || echo "Aucun CONTEXT.md ici"'
ALIAS_EOF
        success "Alias 'handoff' et 'load-context' ajoutés dans $SHELL_RC"
    else
        warn "Alias déjà présents dans $SHELL_RC"
    fi
fi

# 8. .gitignore global — exclure CONTEXT.md des commits par défaut
GITIGNORE_GLOBAL="$HOME/.gitignore_global"
if ! grep -q "CONTEXT.md" "$GITIGNORE_GLOBAL" 2>/dev/null; then
    echo "# Handoff context files" >> "$GITIGNORE_GLOBAL"
    echo "CONTEXT.md" >> "$GITIGNORE_GLOBAL"
    git config --global core.excludesfile "$GITIGNORE_GLOBAL" 2>/dev/null || true
    success "CONTEXT.md ajouté au .gitignore global"
fi

echo ""
echo -e "${BOLD}══════════════════════════════════════════${RESET}"
echo -e "${GREEN}${BOLD}   Installation terminée ! 🎉${RESET}"
echo -e "${BOLD}══════════════════════════════════════════${RESET}"
echo ""
echo -e "${BOLD}Workflow quotidien :${RESET}"
echo ""
echo -e "  ${CYAN}Début de session${RESET}"
echo    "  → Dans Claude Code : /init-context"
echo    "    (charge le CONTEXT.md si il existe)"
echo ""
echo -e "  ${CYAN}Quand tu approches la limite${RESET}"
echo    "  → Dans Claude Code : /handoff"
echo    "    (Claude génère + complète le CONTEXT.md)"
echo    "  → Copie le prompt d'amorce dans Gemini"
echo    "  → Colle le CONTEXT.md à la suite"
echo ""
echo -e "  ${CYAN}Depuis le terminal${RESET}"
echo    "  → handoff         (génère le squelette)"
echo    "  → load-context    (affiche le contexte actuel)"
echo ""
echo -e "  ${YELLOW}Recharge ton shell :${RESET} source $SHELL_RC"
echo ""

# ════════════════════════════════════════════════════════════
#  PARTIE 2 — GIT TEMPLATE + new-project
# ════════════════════════════════════════════════════════════

header() { echo -e "\n${BOLD}${CYAN}$*${RESET}"; }
header "── Git Template & new-project ──────────────────"

# A. Crée la structure du git template global
GIT_TMPL="$HOME/.git-template"
mkdir -p "$GIT_TMPL/hooks"
mkdir -p "$GIT_TMPL/project-files"
info "Structure ~/.git-template créée"

# B. Enregistre le template globalement dans git
git config --global init.templateDir "$GIT_TMPL"
success "git config --global init.templateDir ~/.git-template"

# C. Copie les fichiers projet dans le template
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$SCRIPT_DIR/git-template/CLAUDE.md" ]; then
    cp "$SCRIPT_DIR/git-template/CLAUDE.md"   "$GIT_TMPL/project-files/CLAUDE.md"
    cp "$SCRIPT_DIR/git-template/CONTEXT.md"  "$GIT_TMPL/project-files/CONTEXT.md"
    cp "$SCRIPT_DIR/git-template/.gitignore"  "$GIT_TMPL/project-files/.gitignore"
    success "Templates CLAUDE.md / CONTEXT.md / .gitignore copiés"
else
    warn "Dossier git-template/ non trouvé à côté de install.sh — skip"
fi

# D. Installe new-project.sh globalement
if [ -f "$SCRIPT_DIR/new-project.sh" ]; then
    mkdir -p "$HOME/.local/bin"
    cp "$SCRIPT_DIR/new-project.sh" "$HOME/.local/bin/new-project"
    chmod +x "$HOME/.local/bin/new-project"
    success "new-project installé dans ~/.local/bin/"

    # Ajoute ~/.local/bin au PATH si absent
    SHELL_RC2=""
    [ -f "$HOME/.zshrc" ]  && SHELL_RC2="$HOME/.zshrc"
    [ -f "$HOME/.bashrc" ] && SHELL_RC2="${SHELL_RC2:-$HOME/.bashrc}"

    if [ -n "$SHELL_RC2" ]; then
        if ! grep -q 'local/bin' "$SHELL_RC2"; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC2"
            success "~/.local/bin ajouté au PATH dans $SHELL_RC2"
        fi
    fi
else
    warn "new-project.sh non trouvé — skip"
fi

# E. Résumé final mis à jour
echo ""
echo -e "${BOLD}══════════════════════════════════════════${RESET}"
echo -e "${GREEN}${BOLD}   Tout est installé ! 🎉${RESET}"
echo -e "${BOLD}══════════════════════════════════════════${RESET}"
echo ""
echo -e "${BOLD}  Créer un nouveau projet :${RESET}"
echo    "  new-project mon-api --stack node"
echo    "  new-project mon-script --stack python"
echo    "  new-project ma-lib --stack rust"
echo    "  new-project mon-service --stack go"
echo    "  new-project mon-projet          ← détection auto"
echo ""
echo -e "${BOLD}  Workflow en session Claude Code :${RESET}"
echo    "  /init-context   ← début de session"
echo    "  /handoff        ← avant de switcher sur Gemini"
echo ""
echo -e "  ${YELLOW}Recharge ton shell :${RESET} source ~/.zshrc"
echo ""
