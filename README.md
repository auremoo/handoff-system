# Handoff System

Deux commandes Claude Code pour ne jamais perdre le contexte quand tu switches vers Gemini (ou n'importe quel autre LLM).

```
/handoff        ← en fin de session : Claude écrit CONTEXT.md + génère le prompt Gemini
/init-context   ← en début de session : Claude relit CONTEXT.md et reprend exactement là où on était
```

---

## Installation

Il s'agit juste de copier deux fichiers dans ton projet :

```
.claude/
└── commands/
    ├── handoff.md        ← à copier
    └── init-context.md   ← à copier
```

**Option A — explorateur de fichiers**
1. Télécharger ou cloner ce repo
2. Dans ton projet, créer le dossier `.claude/commands/` s'il n'existe pas
3. Copier `handoff.md` et `init-context.md` dedans

**Option B — ligne de commande**
```bash
git clone https://github.com/auremoo/handoff-system tmp-handoff
mkdir -p .claude/commands
cp tmp-handoff/.claude/commands/handoff.md .claude/commands/
cp tmp-handoff/.claude/commands/init-context.md .claude/commands/
rm -rf tmp-handoff
```

Ça n'écrase rien d'existant — seul le dossier `commands/` est ajouté. Ton `CLAUDE.md`, `.claude/settings.json`, etc. restent intacts.

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

**Pas encore de `CONTEXT.md` ?** `/init-context` n'aura rien à lire. Décris la situation manuellement en début de session, puis tape `/handoff` en fin de session pour en créer un.

---

## Workflow quotidien

```
claude

/init-context          ← reprend le contexte de la session précédente

# ... tu codes ...

/handoff               ← génère CONTEXT.md + prompt prêt pour Gemini
```

---

## Reprendre sur Gemini / autre IA

Après `/handoff`, Claude t'affiche un prompt d'amorce. Colle-le dans Gemini (ou Copilot, GPT-4, etc.) :

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

Si tu as des fichiers clés à fournir, ajoute-les à la suite :

```
[le prompt d'amorce]

Voici les fichiers pertinents :

--- src/api.ts ---
[contenu]
```

---

## Revenir sur Claude Code depuis Gemini

Avant de quitter Gemini, demande-lui de mettre à jour `CONTEXT.md` :

```
Mets à jour le CONTEXT.md avec ce qu'on vient de faire. Garde la même structure, mets à jour :
- Ce qui a été fait
- Tâche en cours
- Prochaine action immédiate
- Décisions importantes prises
- Pièges à éviter

Affiche le contenu complet du fichier mis à jour.
```

Copie le résultat dans ton `CONTEXT.md`. Ensuite dans Claude Code :

```
/init-context
```

---

## Ce que contient CONTEXT.md

Généré automatiquement par `/handoff` :

| Section | Contenu |
|---|---|
| Stack / branche | Détectés automatiquement |
| Objectif de la session | Résumé par Claude en 1-2 phrases |
| Ce qui a été fait | Liste des tâches terminées |
| Tâche en cours | Fichier exact + étape précise où on s'est arrêté |
| Prochaine action | Une seule action concrète |
| Décisions prises | Choix d'archi, libs, patterns retenus |
| Fichiers modifiés | `git diff --name-only` |
| Derniers commits | `git log --oneline -5` |
| Pièges à éviter | Ce que l'autre LLM ne doit PAS faire |

---

## Conseils

**Avant un `/handoff`** — dis à Claude ce qui reste flou ou non terminé. Plus il a d'infos dans la conversation, meilleur sera le `CONTEXT.md`.

**`CONTEXT.md` dans `.gitignore`** — il contient du contexte local, pas du code. Ajoute-le si besoin :
```bash
echo "CONTEXT.md" >> .gitignore
```
