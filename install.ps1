#Requires -Version 5.1
# ============================================================
#  HANDOFF SYSTEM — Installateur Windows
#  Usage : .\install.ps1
# ============================================================

$ErrorActionPreference = "Stop"

function Write-Info    { param($m) Write-Host "  ▸ $m" -ForegroundColor Cyan }
function Write-Success { param($m) Write-Host "  ✓ $m" -ForegroundColor Green }
function Write-Warn    { param($m) Write-Host "  ⚠ $m" -ForegroundColor Yellow }

Write-Host ""
Write-Host "══════════════════════════════════════════" -ForegroundColor White
Write-Host "   HANDOFF SYSTEM — Installation (Windows)" -ForegroundColor White
Write-Host "══════════════════════════════════════════" -ForegroundColor White
Write-Host ""

$ClaudeDir   = "$HOME\.claude"
$CommandsDir = "$ClaudeDir\commands"
$HooksDir    = "$ClaudeDir\hooks"
$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path

New-Item -ItemType Directory -Force -Path $CommandsDir | Out-Null
New-Item -ItemType Directory -Force -Path $HooksDir    | Out-Null
Write-Info "Dossiers ~/.claude/ créés"

# ── 1. handoff.ps1 ──────────────────────────────────────────
@'
# handoff.ps1 — Génère un CONTEXT.md de handoff
param([string]$ProjectDir = (Get-Location).Path)

$Output = Join-Path $ProjectDir "CONTEXT.md"
$Date   = Get-Date -Format "yyyy-MM-dd HH:mm"

$Branch      = (git -C $ProjectDir rev-parse --abbrev-ref HEAD 2>$null) -join ""
$LastCommits = (git -C $ProjectDir log --oneline -5 2>$null) -join "`n"
$Modified    = (git -C $ProjectDir diff --name-only 2>$null | Select-Object -First 20) -join "`n"
$Staged      = (git -C $ProjectDir diff --cached --name-only 2>$null | Select-Object -First 10) -join "`n"
if (-not $Branch)      { $Branch      = "N/A" }
if (-not $LastCommits) { $LastCommits = "N/A" }
if (-not $Modified)    { $Modified    = "N/A" }
if (-not $Staged)      { $Staged      = "N/A" }

$StackParts = @()
if (Test-Path "$ProjectDir\package.json")     { $StackParts += "Node.js/JS" }
if (Test-Path "$ProjectDir\tsconfig.json")    { $StackParts += "TypeScript" }
if (Test-Path "$ProjectDir\requirements.txt") { $StackParts += "Python" }
if (Test-Path "$ProjectDir\pyproject.toml")   { $StackParts += "Python" }
if (Test-Path "$ProjectDir\Cargo.toml")       { $StackParts += "Rust" }
if (Test-Path "$ProjectDir\go.mod")           { $StackParts += "Go" }
if (Test-Path "$ProjectDir\pom.xml")          { $StackParts += "Java/Maven" }
if (Test-Path "$ProjectDir\Dockerfile")       { $StackParts += "Docker" }
if ($StackParts.Count -eq 0)                  { $StackParts += "Non détectée" }
$Stack = $StackParts -join ", "

@"
# CONTEXT HANDOFF — $Date

> Fichier généré automatiquement. À compléter par Claude avant le switch.
> **Colle ce fichier en début de session Gemini ou autre LLM.**

---

## Projet
- **Chemin** : ``$ProjectDir``
- **Stack** : $Stack
- **Branche git** : ``$Branch``

## Objectif de la session
<!-- Claude complète ici en 1-2 phrases -->
...

## Ce qui a été fait ✅
<!-- Claude liste les tâches terminées -->
- [ ] ...

## Tâche en cours ⚙️
**Fichier(s) concerné(s)** : ``...``
**Étape interrompue** : ...

## Prochaine action immédiate 🎯
...

## Décisions importantes prises
- ...

## Fichiers clés modifiés
``````
$Modified
``````

**Staged (prêts au commit)** :
``````
$Staged
``````

## Derniers commits
``````
$LastCommits
``````

## Contraintes / pièges à éviter ⚠️
- ...

## Prompt d'amorce pour Gemini / autre LLM
``````
Tu reprends une session de développement. Voici le contexte exact :

[COLLE LE CONTENU DE CE FICHIER ICI]

Règles :
- Ne me redemande pas ce qui est déjà décidé
- Commence directement par la "Prochaine action immédiate"
- Si tu as besoin d'un fichier, demande-le moi
- Sois concis, on est en mid-session

Go.
``````

---
*Généré par handoff.ps1 — $Date*
"@ | Out-File -FilePath $Output -Encoding utf8

Write-Host ""
Write-Host "✅ CONTEXT.md généré : $Output"
Write-Host ""
Write-Host "📋 Prochaines étapes :"
Write-Host "   1. Demande à Claude de compléter les sections '...'"
Write-Host "   2. Copie le bloc 'Prompt d'amorce' dans Gemini"
Write-Host "   3. Colle le contenu du CONTEXT.md à la suite"
Write-Host ""
'@ | Out-File -FilePath "$ClaudeDir\handoff.ps1" -Encoding utf8
Write-Success "Script ~/.claude/handoff.ps1 installé"

# ── 2. Commande /handoff ─────────────────────────────────────
@'
---
description: Génère un fichier CONTEXT.md de handoff pour switcher vers un autre LLM (Gemini, etc.) sans perdre le contexte
---

Génère un fichier de handoff complet pour continuer cette session sur un autre LLM sans perdre de contexte.

1. Lance d'abord le script selon le système :
   - **Windows** : `powershell -NoProfile -File "$HOME\.claude\handoff.ps1" "$PWD"`
   - **macOS / Linux** : `bash ~/.claude/handoff.sh "$PWD"`

2. Ensuite, **complète le fichier CONTEXT.md généré** en remplissant précisément :
   - **Objectif de la session** : résume en 1-2 phrases ce qu'on essaie d'accomplir
   - **Ce qui a été fait** : liste les tâches terminées dans cette session
   - **Tâche en cours** : décris exactement où on s'est arrêté, quel fichier, quelle étape
   - **Prochaine action immédiate** : une seule action concrète, la plus précise possible
   - **Décisions importantes** : les choix techniques retenus (libs, patterns, architecture)
   - **Contraintes / pièges** : ce que l'autre LLM ne doit surtout pas faire

3. Affiche le **prompt d'amorce final** prêt à copier-coller dans Gemini.

Sois dense et précis — chaque mot compte, l'autre LLM n'aura pas notre historique.
'@ | Out-File -FilePath "$CommandsDir\handoff.md" -Encoding utf8
Write-Success "Commande ~/.claude/commands/handoff.md installée"

# ── 3. Commande /init-context ────────────────────────────────
@'
---
description: Charge le CONTEXT.md du projet pour reprendre une session précédente
---

Lis le fichier CONTEXT.md à la racine du projet courant et reprends exactement là où la session précédente s'est arrêtée.

- **Windows** : `Get-Content "$PWD\CONTEXT.md"`
- **macOS / Linux** : `cat "$PWD/CONTEXT.md"`

Après lecture :
1. Confirme en une phrase ce que tu as compris de la situation
2. Identifie la "Prochaine action immédiate" et propose de la commencer
3. Ne redemande pas ce qui est déjà décidé dans le fichier
'@ | Out-File -FilePath "$CommandsDir\init-context.md" -Encoding utf8
Write-Success "Commande ~/.claude/commands/init-context.md installée"

# ── 4. Hook Stop ─────────────────────────────────────────────
@'
# check-handoff.ps1 — Hook Stop : vérifie si CONTEXT.md est récent
$ProjectDir   = if ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR } else { (Get-Location).Path }
$ContextFile  = Join-Path $ProjectDir "CONTEXT.md"

if (-not (Test-Path $ContextFile)) {
    '{"additionalContext": "RAPPEL : Aucun CONTEXT.md dans ce projet. Lance /handoff avant de te déconnecter."}'
} elseif ((Get-Date) - (Get-Item $ContextFile).LastWriteTime -gt [TimeSpan]::FromHours(2)) {
    '{"additionalContext": "RAPPEL : Le CONTEXT.md date de plus de 2h. Pense à relancer /handoff pour le mettre à jour."}'
}
'@ | Out-File -FilePath "$HooksDir\check-handoff.ps1" -Encoding utf8
Write-Success "Hook ~/.claude/hooks/check-handoff.ps1 installé"

# ── 5. settings.json ─────────────────────────────────────────
$SettingsPath = "$ClaudeDir\settings.json"
if (Test-Path $SettingsPath) {
    Copy-Item $SettingsPath "$SettingsPath.backup"
    Write-Info "Backup settings.json → settings.json.backup"
    $raw      = Get-Content $SettingsPath -Raw
    $settings = $raw | ConvertFrom-Json
} else {
    $settings = [PSCustomObject]@{}
}

$HookCmd = "powershell -NoProfile -File `"$HooksDir\check-handoff.ps1`""

if (-not ($settings.PSObject.Properties.Name -contains 'hooks')) {
    $settings | Add-Member -MemberType NoteProperty -Name 'hooks' -Value ([PSCustomObject]@{})
}
if (-not ($settings.hooks.PSObject.Properties.Name -contains 'Stop')) {
    $settings.hooks | Add-Member -MemberType NoteProperty -Name 'Stop' -Value @()
}

$alreadyThere = $settings.hooks.Stop | Where-Object {
    $_.hooks | Where-Object { $_.command -like "*check-handoff*" }
}
if (-not $alreadyThere) {
    $hookEntry = [PSCustomObject]@{
        hooks = @([PSCustomObject]@{ type = "command"; command = $HookCmd; async = $true })
    }
    $settings.hooks.Stop = @($settings.hooks.Stop) + $hookEntry
}

$settings | ConvertTo-Json -Depth 10 | Out-File -FilePath $SettingsPath -Encoding utf8
Write-Success "Hook ajouté dans ~/.claude/settings.json"

# ── 6. Git template ──────────────────────────────────────────
$GitTmpl = "$HOME\.git-template"
New-Item -ItemType Directory -Force -Path "$GitTmpl\hooks"        | Out-Null
New-Item -ItemType Directory -Force -Path "$GitTmpl\project-files" | Out-Null
git config --global init.templateDir "$GitTmpl"
Write-Success "git config --global init.templateDir ~/.git-template"

# ── 7. Fichiers du template ──────────────────────────────────
$TmplSrc = Join-Path $ScriptDir "git-template"
if (Test-Path $TmplSrc) {
    Copy-Item "$TmplSrc\CLAUDE.md"  "$GitTmpl\project-files\CLAUDE.md"  -Force
    Copy-Item "$TmplSrc\CONTEXT.md" "$GitTmpl\project-files\CONTEXT.md" -Force
    Copy-Item "$TmplSrc\.gitignore" "$GitTmpl\project-files\.gitignore" -Force
    Write-Success "Templates CLAUDE.md / CONTEXT.md / .gitignore copiés"
} else {
    Write-Warn "Dossier git-template\ non trouvé à côté de install.ps1 — skip"
}

# ── 8. new-project.ps1 ──────────────────────────────────────
$BinDir = "$HOME\.local\bin"
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
$NewProjectSrc = Join-Path $ScriptDir "new-project.ps1"
if (Test-Path $NewProjectSrc) {
    Copy-Item $NewProjectSrc "$BinDir\new-project.ps1" -Force
    Write-Success "new-project.ps1 installé dans ~/.local\bin\"
} else {
    Write-Warn "new-project.ps1 non trouvé — skip"
}

# ── 9. PowerShell profile ────────────────────────────────────
$ProfileDir = Split-Path -Parent $PROFILE
New-Item -ItemType Directory -Force -Path $ProfileDir | Out-Null
if (-not (Test-Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE | Out-Null }

$profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ($profileContent -notlike "*HANDOFF SYSTEM*") {
    @"

# HANDOFF SYSTEM — Switch Claude Code → Gemini
function Invoke-Handoff {
    powershell -NoProfile -File "`$HOME\.claude\handoff.ps1" "`$PWD"
    Write-Host "→ Tape /handoff dans Claude Code pour que Claude complète le fichier"
}
Set-Alias -Name handoff -Value Invoke-Handoff
function Get-HandoffContext { Get-Content "`$PWD\CONTEXT.md" -ErrorAction SilentlyContinue }
Set-Alias -Name load-context -Value Get-HandoffContext
`$env:PATH = "`$HOME\.local\bin;`$env:PATH"
"@ | Add-Content -Path $PROFILE
    Write-Success "Alias 'handoff' et 'load-context' ajoutés dans $PROFILE"
} else {
    Write-Warn "Alias déjà présents dans $PROFILE"
}

# ── 10. .gitignore global ────────────────────────────────────
$GitIgnoreGlobal = "$HOME\.gitignore_global"
if (-not (Test-Path $GitIgnoreGlobal)) { New-Item -ItemType File -Path $GitIgnoreGlobal | Out-Null }
$giContent = Get-Content $GitIgnoreGlobal -Raw -ErrorAction SilentlyContinue
if ($giContent -notlike "*CONTEXT.md*") {
    "`n# Handoff context files`nCONTEXT.md" | Add-Content -Path $GitIgnoreGlobal
    git config --global core.excludesfile "$GitIgnoreGlobal" 2>$null
    Write-Success "CONTEXT.md ajouté au .gitignore global"
}

Write-Host ""
Write-Host "══════════════════════════════════════════" -ForegroundColor White
Write-Host "   Tout est installé !" -ForegroundColor Green
Write-Host "══════════════════════════════════════════" -ForegroundColor White
Write-Host ""
Write-Host "  Créer un nouveau projet :" -ForegroundColor White
Write-Host "  new-project mon-api --stack node"
Write-Host "  new-project mon-script --stack python"
Write-Host "  new-project mon-projet          ← détection auto"
Write-Host ""
Write-Host "  Workflow en session Claude Code :" -ForegroundColor White
Write-Host "  /init-context   ← début de session"
Write-Host "  /handoff        ← avant de switcher sur Gemini"
Write-Host ""
Write-Host "  Ouvre un nouveau terminal pour activer les alias." -ForegroundColor Yellow
Write-Host ""
