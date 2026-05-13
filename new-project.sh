#!/usr/bin/env bash
# ============================================================
#  new-project — Crée un repo git avec CLAUDE.md + CONTEXT.md
#  Usage : new-project [nom-du-projet] [--stack auto|node|python|rust|go|generic]
#  Exemple : new-project mon-api --stack node
# ============================================================
set -e

BOLD='\033[1m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
MAGENTA='\033[0;35m'; RESET='\033[0m'

info()    { echo -e "${CYAN}▸ $*${RESET}"; }
success() { echo -e "${GREEN}✓ $*${RESET}"; }
warn()    { echo -e "${YELLOW}⚠ $*${RESET}"; }
header()  { echo -e "\n${BOLD}${MAGENTA}$*${RESET}"; }

TEMPLATE_DIR="$HOME/.git-template"

# ── Parse args ──────────────────────────────────────────────
PROJECT_NAME="${1:-}"
STACK_FLAG="${2:-}"
STACK_ARG="${3:-auto}"

if [[ "$STACK_FLAG" == "--stack" ]]; then
    FORCED_STACK="$STACK_ARG"
else
    FORCED_STACK="auto"
fi

# ── Nom du projet ────────────────────────────────────────────
if [ -z "$PROJECT_NAME" ]; then
    echo -e "${BOLD}Nom du projet :${RESET} \c"
    read -r PROJECT_NAME
fi
PROJECT_NAME="${PROJECT_NAME// /-}"   # remplace espaces par tirets
PROJECT_NAME="${PROJECT_NAME,,}"      # lowercase

header "══════════════════════════════════════════"
header "  new-project : $PROJECT_NAME"
header "══════════════════════════════════════════"

# ── Crée le dossier ─────────────────────────────────────────
PROJECT_DIR="$PWD/$PROJECT_NAME"
if [ -d "$PROJECT_DIR" ]; then
    warn "Le dossier $PROJECT_DIR existe déjà."
    echo -e "Continuer quand même ? (o/N) \c"; read -r CONFIRM
    [[ "$CONFIRM" =~ ^[oO]$ ]] || { echo "Annulé."; exit 0; }
fi
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"
info "Dossier créé : $PROJECT_DIR"

# ── Git init avec template ───────────────────────────────────
git init --template="$TEMPLATE_DIR" > /dev/null 2>&1
success "git init avec template ~/.git-template"

# ── Copie les fichiers du template ──────────────────────────
TMPL="$TEMPLATE_DIR/project-files"
cp "$TMPL/CONTEXT.md"  ./CONTEXT.md
cp "$TMPL/.gitignore"  ./.gitignore
info "CONTEXT.md et .gitignore copiés"

# ── Détecte ou force la stack ────────────────────────────────
detect_stack() {
    local s=""
    [ -f "package.json" ]     && s="node"
    [ -f "tsconfig.json" ]    && s="node"   # TS → on reste dans node
    [ -f "requirements.txt" ] && s="python"
    [ -f "pyproject.toml" ]   && s="python"
    [ -f "Cargo.toml" ]       && s="rust"
    [ -f "go.mod" ]           && s="go"
    echo "${s:-generic}"
}

STACK="$FORCED_STACK"
[ "$STACK" = "auto" ] && STACK=$(detect_stack)
info "Stack détectée : $STACK"

# ── Stack-specific setup ─────────────────────────────────────
CMD_INSTALL="# à définir"; CMD_DEV="# à définir"
CMD_TEST="# à définir"; CMD_BUILD="# à définir"
STACK_LABEL=""

case "$STACK" in
node)
    STACK_LABEL="Node.js / TypeScript"
    CMD_INSTALL="npm install"
    CMD_DEV="npm run dev"
    CMD_TEST="npm test"
    CMD_BUILD="npm run build"

    # .gitignore spécifique node déjà dans le template générique
    # package.json minimal
    cat > package.json << PKGJSON
{
  "name": "$PROJECT_NAME",
  "version": "0.1.0",
  "description": "",
  "scripts": {
    "dev": "node src/index.js",
    "test": "echo \"No tests yet\"",
    "build": "echo \"No build step\""
  }
}
PKGJSON
    mkdir -p src
    echo 'console.log("Hello from '"$PROJECT_NAME"'");' > src/index.js
    success "Scaffold Node.js créé"
    ;;

python)
    STACK_LABEL="Python"
    CMD_INSTALL="pip install -r requirements.txt"
    CMD_DEV="python main.py"
    CMD_TEST="pytest"
    CMD_BUILD="# N/A"

    touch requirements.txt
    cat > main.py << PYMAIN
def main():
    print("Hello from $PROJECT_NAME")

if __name__ == "__main__":
    main()
PYMAIN
    cat > pyproject.toml << PYPROJ
[project]
name = "$PROJECT_NAME"
version = "0.1.0"
PYPROJ
    success "Scaffold Python créé"
    ;;

rust)
    STACK_LABEL="Rust"
    CMD_INSTALL="cargo fetch"
    CMD_DEV="cargo run"
    CMD_TEST="cargo test"
    CMD_BUILD="cargo build --release"

    if command -v cargo &>/dev/null; then
        cargo init --quiet . 2>/dev/null || true
        success "cargo init exécuté"
    else
        warn "cargo non installé — scaffold Rust ignoré"
        mkdir -p src
        echo 'fn main() { println!("Hello from '"$PROJECT_NAME"'"); }' > src/main.rs
        cat > Cargo.toml << CARGOTOML
[package]
name = "$PROJECT_NAME"
version = "0.1.0"
edition = "2021"
CARGOTOML
    fi
    ;;

go)
    STACK_LABEL="Go"
    CMD_INSTALL="go mod tidy"
    CMD_DEV="go run ."
    CMD_TEST="go test ./..."
    CMD_BUILD="go build -o bin/$PROJECT_NAME ."

    if command -v go &>/dev/null; then
        go mod init "$PROJECT_NAME" > /dev/null 2>&1 || true
    else
        cat > go.mod << GOMOD
module $PROJECT_NAME

go 1.21
GOMOD
    fi
    mkdir -p cmd
    cat > main.go << GOMAIN
package main

import "fmt"

func main() {
    fmt.Println("Hello from $PROJECT_NAME")
}
GOMAIN
    success "Scaffold Go créé"
    ;;

*)
    STACK_LABEL="Générique"
    CMD_INSTALL="# à définir selon la stack"
    CMD_DEV="# à définir"
    CMD_TEST="# à définir"
    CMD_BUILD="# à définir"
    ;;
esac

# ── Génère CLAUDE.md à partir du template ───────────────────
TREE=$(find . -maxdepth 2 -not -path './.git*' -not -name '*.md' \
    | sort | head -20 | sed 's|^\./||' | sed 's|^|  |' || echo "  .")

CLAUDE_CONTENT=$(cat "$TMPL/CLAUDE.md")
CLAUDE_CONTENT="${CLAUDE_CONTENT//\{\{PROJECT_NAME\}\}/$PROJECT_NAME}"
CLAUDE_CONTENT="${CLAUDE_CONTENT//\{\{STACK\}\}/$STACK_LABEL}"
CLAUDE_CONTENT="${CLAUDE_CONTENT//\{\{DESCRIPTION\}\}/À définir}"
CLAUDE_CONTENT="${CLAUDE_CONTENT//\{\{TREE\}\}/$TREE}"
CLAUDE_CONTENT="${CLAUDE_CONTENT//\{\{CMD_INSTALL\}\}/$CMD_INSTALL}"
CLAUDE_CONTENT="${CLAUDE_CONTENT//\{\{CMD_DEV\}\}/$CMD_DEV}"
CLAUDE_CONTENT="${CLAUDE_CONTENT//\{\{CMD_TEST\}\}/$CMD_TEST}"
CLAUDE_CONTENT="${CLAUDE_CONTENT//\{\{CMD_BUILD\}\}/$CMD_BUILD}"
echo "$CLAUDE_CONTENT" > CLAUDE.md
success "CLAUDE.md généré pour stack $STACK_LABEL"

# ── .claude/ local du projet ─────────────────────────────────
mkdir -p .claude
cat > .claude/settings.json << CLSETTINGS
{
  "projectName": "$PROJECT_NAME",
  "stack": "$STACK_LABEL"
}
CLSETTINGS
success ".claude/settings.json créé"

# ── Premier commit ───────────────────────────────────────────
git add .
git commit -m "chore: init project $PROJECT_NAME

- CLAUDE.md : contexte Claude Code
- CONTEXT.md : handoff LLM (ignoré par git)
- .gitignore : stack $STACK_LABEL
- scaffold $STACK_LABEL de base" > /dev/null 2>&1
success "Premier commit créé"

# ── Résumé ───────────────────────────────────────────────────
echo ""
echo -e "${BOLD}══════════════════════════════════════════${RESET}"
echo -e "${GREEN}${BOLD}  $PROJECT_NAME prêt ! 🚀${RESET}"
echo -e "${BOLD}══════════════════════════════════════════${RESET}"
echo ""
echo -e "  ${CYAN}Dossier${RESET}  : $PROJECT_DIR"
echo -e "  ${CYAN}Stack${RESET}    : $STACK_LABEL"
echo ""
echo -e "${BOLD}  Prochaines étapes :${RESET}"
echo    "  1. cd $PROJECT_NAME"
echo    "  2. claude          → ouvre Claude Code"
echo    "  3. /init-context   → Claude lit le CLAUDE.md"
echo    "  4. Commence à coder !"
echo ""
