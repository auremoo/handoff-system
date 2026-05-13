#Requires -Version 5.1
# ============================================================
#  new-project.ps1 — Crée un repo git avec CLAUDE.md + CONTEXT.md
#  Usage : new-project [nom-du-projet] [--stack auto|node|python|rust|go|generic]
#  Exemple : new-project mon-api --stack node
# ============================================================

param(
    [string]$ProjectName,
    [string]$Stack = "auto"
)

$ErrorActionPreference = "Stop"

function Write-Info    { param($m) Write-Host "  ▸ $m" -ForegroundColor Cyan }
function Write-Success { param($m) Write-Host "  ✓ $m" -ForegroundColor Green }
function Write-Warn    { param($m) Write-Host "  ⚠ $m" -ForegroundColor Yellow }

$TemplateDir = "$HOME\.git-template"

# ── Nom du projet ────────────────────────────────────────────
if (-not $ProjectName) {
    $ProjectName = Read-Host "Nom du projet"
}
$ProjectName = $ProjectName.ToLower() -replace '\s+', '-'

Write-Host ""
Write-Host "══════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  new-project : $ProjectName" -ForegroundColor Magenta
Write-Host "══════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""

# ── Crée le dossier ──────────────────────────────────────────
$ProjectDir = Join-Path (Get-Location).Path $ProjectName
if (Test-Path $ProjectDir) {
    Write-Warn "Le dossier $ProjectDir existe déjà."
    $confirm = Read-Host "Continuer quand même ? (o/N)"
    if ($confirm -notmatch '^[oO]$') { Write-Host "Annulé."; exit 0 }
}
New-Item -ItemType Directory -Force -Path $ProjectDir | Out-Null
Set-Location $ProjectDir
Write-Info "Dossier créé : $ProjectDir"

# ── Git init avec template ───────────────────────────────────
git init --template="$TemplateDir" 2>&1 | Out-Null
Write-Success "git init avec template ~/.git-template"

# ── Copie les fichiers du template ───────────────────────────
$Tmpl = "$TemplateDir\project-files"
Copy-Item "$Tmpl\CONTEXT.md"  ".\CONTEXT.md"  -Force
Copy-Item "$Tmpl\.gitignore"  ".\.gitignore"  -Force
Write-Info "CONTEXT.md et .gitignore copiés"

# ── Détecte ou force la stack ────────────────────────────────
function Detect-Stack {
    if (Test-Path "package.json")     { return "node" }
    if (Test-Path "tsconfig.json")    { return "node" }
    if (Test-Path "requirements.txt") { return "python" }
    if (Test-Path "pyproject.toml")   { return "python" }
    if (Test-Path "Cargo.toml")       { return "rust" }
    if (Test-Path "go.mod")           { return "go" }
    return "generic"
}

if ($Stack -eq "auto") { $Stack = Detect-Stack }
Write-Info "Stack détectée : $Stack"

# ── Stack-specific setup ─────────────────────────────────────
$CmdInstall = "# à définir"
$CmdDev     = "# à définir"
$CmdTest    = "# à définir"
$CmdBuild   = "# à définir"
$StackLabel = ""

switch ($Stack) {
    "node" {
        $StackLabel = "Node.js / TypeScript"
        $CmdInstall = "npm install"
        $CmdDev     = "npm run dev"
        $CmdTest    = "npm test"
        $CmdBuild   = "npm run build"
        @{
            name        = $ProjectName
            version     = "0.1.0"
            description = ""
            scripts     = @{ dev = "node src/index.js"; test = 'echo "No tests yet"'; build = 'echo "No build step"' }
        } | ConvertTo-Json | Out-File "package.json" -Encoding utf8
        New-Item -ItemType Directory -Force -Path "src" | Out-Null
        "console.log(`"Hello from $ProjectName`");" | Out-File "src\index.js" -Encoding utf8
        Write-Success "Scaffold Node.js créé"
    }
    "python" {
        $StackLabel = "Python"
        $CmdInstall = "pip install -r requirements.txt"
        $CmdDev     = "python main.py"
        $CmdTest    = "pytest"
        $CmdBuild   = "# N/A"
        New-Item -ItemType File -Path "requirements.txt" | Out-Null
        @"
def main():
    print("Hello from $ProjectName")

if __name__ == "__main__":
    main()
"@ | Out-File "main.py" -Encoding utf8
        @"
[project]
name = "$ProjectName"
version = "0.1.0"
"@ | Out-File "pyproject.toml" -Encoding utf8
        Write-Success "Scaffold Python créé"
    }
    "rust" {
        $StackLabel = "Rust"
        $CmdInstall = "cargo fetch"
        $CmdDev     = "cargo run"
        $CmdTest    = "cargo test"
        $CmdBuild   = "cargo build --release"
        if (Get-Command cargo -ErrorAction SilentlyContinue) {
            cargo init --quiet . 2>$null
            Write-Success "cargo init exécuté"
        } else {
            Write-Warn "cargo non installé — scaffold minimal"
            New-Item -ItemType Directory -Force -Path "src" | Out-Null
            "fn main() { println!(`"Hello from $ProjectName`"); }" | Out-File "src\main.rs" -Encoding utf8
            @"
[package]
name = "$ProjectName"
version = "0.1.0"
edition = "2021"
"@ | Out-File "Cargo.toml" -Encoding utf8
        }
    }
    "go" {
        $StackLabel = "Go"
        $CmdInstall = "go mod tidy"
        $CmdDev     = "go run ."
        $CmdTest    = "go test ./..."
        $CmdBuild   = "go build -o bin/$ProjectName ."
        if (Get-Command go -ErrorAction SilentlyContinue) {
            go mod init $ProjectName 2>$null
        } else {
            "module $ProjectName`n`ngo 1.21" | Out-File "go.mod" -Encoding utf8
        }
        New-Item -ItemType Directory -Force -Path "cmd" | Out-Null
        @"
package main

import "fmt"

func main() {
    fmt.Println("Hello from $ProjectName")
}
"@ | Out-File "main.go" -Encoding utf8
        Write-Success "Scaffold Go créé"
    }
    default {
        $StackLabel = "Générique"
        $CmdInstall = "# à définir selon la stack"
        $CmdDev     = "# à définir"
        $CmdTest    = "# à définir"
        $CmdBuild   = "# à définir"
    }
}

# ── Génère CLAUDE.md ─────────────────────────────────────────
$Tree = Get-ChildItem -Recurse -Depth 2 |
    Where-Object { $_.FullName -notmatch '\.git' } |
    Select-Object -First 20 |
    ForEach-Object { "  " + $_.FullName.Replace($ProjectDir, "").TrimStart('\') }

$ClaudeTmplPath = "$TemplateDir\project-files\CLAUDE.md"
if (Test-Path $ClaudeTmplPath) {
    $claudeContent = Get-Content $ClaudeTmplPath -Raw
    $claudeContent = $claudeContent `
        -replace '\{\{PROJECT_NAME\}\}', $ProjectName `
        -replace '\{\{STACK\}\}',        $StackLabel `
        -replace '\{\{DESCRIPTION\}\}',  "À définir" `
        -replace '\{\{TREE\}\}',         ($Tree -join "`n") `
        -replace '\{\{CMD_INSTALL\}\}',  $CmdInstall `
        -replace '\{\{CMD_DEV\}\}',      $CmdDev `
        -replace '\{\{CMD_TEST\}\}',     $CmdTest `
        -replace '\{\{CMD_BUILD\}\}',    $CmdBuild
    $claudeContent | Out-File "CLAUDE.md" -Encoding utf8
    Write-Success "CLAUDE.md généré pour stack $StackLabel"
} else {
    Write-Warn "Template CLAUDE.md non trouvé — fichier vide créé"
    "# $ProjectName`n`nStack : $StackLabel" | Out-File "CLAUDE.md" -Encoding utf8
}

# ── .claude/settings.json ────────────────────────────────────
New-Item -ItemType Directory -Force -Path ".claude" | Out-Null
@{ projectName = $ProjectName; stack = $StackLabel } |
    ConvertTo-Json | Out-File ".claude\settings.json" -Encoding utf8
Write-Success ".claude/settings.json créé"

# ── Premier commit ───────────────────────────────────────────
git add . 2>&1 | Out-Null
git commit -m "chore: init project $ProjectName

- CLAUDE.md : contexte Claude Code
- CONTEXT.md : handoff LLM (ignoré par git)
- .gitignore : stack $StackLabel
- scaffold $StackLabel de base" 2>&1 | Out-Null
Write-Success "Premier commit créé"

# ── Résumé ───────────────────────────────────────────────────
Write-Host ""
Write-Host "══════════════════════════════════════════" -ForegroundColor Green
Write-Host "  $ProjectName prêt !" -ForegroundColor Green
Write-Host "══════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "  Dossier  : $ProjectDir" -ForegroundColor Cyan
Write-Host "  Stack    : $StackLabel" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Prochaines étapes :" -ForegroundColor White
Write-Host "  1. cd $ProjectName"
Write-Host "  2. claude          → ouvre Claude Code"
Write-Host "  3. /init-context   → Claude lit le CLAUDE.md"
Write-Host "  4. Commence à coder !"
Write-Host ""
