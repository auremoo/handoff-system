> Créé par Aurélien Moote - Moo - 2026. Logiciel libre (licence MIT) :
> réutilisable à condition de conserver la mention de l'auteur.

# Handoff System

Deux commandes Claude Code pour ne jamais perdre le contexte quand tu switches vers Gemini (ou n'importe quel autre LLM).

```
/handoff        ← en fin de session : Claude écrit CONTEXT.md, prêt à coller dans Gemini
/init-context   ← en début de session : Claude relit CONTEXT.md et reprend exactement là où on était
```

---

## Installation

Il s'agit juste de copier deux fichiers, `handoff.md` et `init-context.md`.

**Option A — une fois pour tous tes projets (recommandé)**

Copie les deux fichiers dans ton dossier personnel :

- macOS / Linux : `~/.claude/commands/`
- Windows : `%USERPROFILE%\.claude\commands\`

**Option B — dans un seul projet, à la main**
1. Télécharger ou cloner ce repo
2. Dans ton projet, créer le dossier `.claude/commands/` s'il n'existe pas
3. Copier `handoff.md` et `init-context.md` dedans

**Option C — dans un seul projet, en ligne de commande** (bash / Git Bash)
```bash
git clone --depth 1 https://github.com/auremoo/handoff-system tmp-handoff
mkdir -p .claude/commands
cp tmp-handoff/.claude/commands/*.md .claude/commands/
rm -rf tmp-handoff
```

Ça n'écrase rien d'existant — seuls deux fichiers sont ajoutés dans `commands/`. Ton `CLAUDE.md`, `.claude/settings.json`, etc. restent intacts.

---

## Cas 1 — Nouveau projet

Après l'installation, ouvre Claude Code et décris ton projet :

```
Je démarre un projet [description]. Stack : [stack].
Voici ce que je veux construire : [objectif].
```

Code ta session. Quand tu approches la limite de contexte, tape `/handoff`.

---

## Cas 2 — Projet déjà commencé

Après l'installation, ouvre Claude Code directement.

**Tu as déjà un `CLAUDE.md` ?** Garde-le tel quel — Claude s'en servira pour mieux remplir `CONTEXT.md`.

**Pas encore de `CONTEXT.md` ?** `/init-context` te le dira et te demandera de décrire la situation. Tape `/handoff` en fin de session pour en créer un.

---

## Workflow quotidien

```
claude

/init-context          ← reprend le contexte de la session précédente

# ... tu codes ...

/handoff               ← écrit CONTEXT.md
```

---

## Reprendre sur Gemini / autre IA

`CONTEXT.md` est autonome : il contient déjà les règles de reprise (commencer par la prochaine action, ne rien redemander, rester concis). Colle son contenu, ou joins le fichier, comme premier message dans Gemini, Copilot, GPT, etc.

Avec un outil qui a accès au repo (Gemini CLI, par exemple), une ligne suffit :

```
Lis CONTEXT.md et reprends.
```

Si l'autre LLM n'a pas accès au repo, ajoute les fichiers clés à la suite :

```
[contenu de CONTEXT.md]

Voici les fichiers pertinents :

--- src/api.ts ---
[contenu]
```

---

## Revenir sur Claude Code depuis Gemini

Avant de quitter Gemini, demande-lui de mettre à jour `CONTEXT.md` :

```
Mets à jour le CONTEXT.md avec ce qu'on vient de faire. Garde la même structure, mets à jour :
- TL;DR
- Ce qui a été fait
- Tâche en cours
- Prochaine action immédiate
- Décisions importantes prises
- Pièges à éviter

Affiche le contenu complet du fichier mis à jour.
```

Copie le résultat dans ton `CONTEXT.md` (inutile si Gemini a écrit le fichier lui-même). Ensuite dans Claude Code :

```
/init-context
```

Si la branche a changé ou si des commits ont eu lieu depuis le handoff, `/init-context` le signale : c'est le signe que `CONTEXT.md` n'a peut-être pas été mis à jour.

---

## Ce que contient CONTEXT.md

Généré automatiquement par `/handoff` :

| Section | Contenu |
|---|---|
| TL;DR + règles de reprise | État actuel en 1 phrase, consignes pour le LLM qui reprend |
| Stack / branche | Tirés de la session et de git |
| Objectif de la session | Résumé par Claude en 1-2 phrases |
| Ce qui a été fait | Liste des tâches terminées |
| Tâche en cours | Fichier exact + étape précise où on s'est arrêté |
| Prochaine action | Une seule action concrète |
| Décisions prises | Choix d'archi, libs, patterns retenus |
| Fichiers modifiés non commités | `git status` — modifiés, indexés et nouveaux fichiers |
| Derniers commits | `git log --oneline -5` |
| Pièges à éviter | Ce que l'autre LLM ne doit PAS faire |

Une section sans contenu est omise. D'un handoff au suivant, les décisions et pièges encore valides sont conservés.

---

## Conseils

**Précise ce qui reste flou** — directement dans la commande :

```
/handoff le bug de cache n'est pas résolu, la piste Redis est à abandonner
```

**`CONTEXT.md` dans `.gitignore`** — il contient du contexte local, pas du code. Ajoute la ligne `CONTEXT.md` à ton `.gitignore` si tu ne veux pas le versionner.

---

## Auteur & licence

Créé par **Aurélien Moote - Moo - 2026**.
Distribué sous licence [MIT](LICENSE) — réutilisable à condition de conserver la mention de l'auteur.
