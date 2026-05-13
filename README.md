# Handoff System

Deux commandes Claude Code pour ne jamais perdre le contexte quand tu switches vers Gemini (ou n'importe quel autre LLM).

```
/handoff        ← en fin de session : Claude écrit CONTEXT.md + génère le prompt Gemini
/init-context   ← en début de session : Claude relit CONTEXT.md et reprend exactement là où on était
```

---

## Installation

Copier `.claude/` dans ton projet (une seule fois par projet) :

```bash
# Cloner et copier
git clone https://github.com/auremoo/handoff-system tmp-handoff
cp -r tmp-handoff/.claude .
rm -rf tmp-handoff
```

C'est tout. Les commandes sont disponibles dans Claude Code immédiatement.

---

## Cas 1 — Nouveau projet

```bash
mkdir mon-projet && cd mon-projet
git init
git clone https://github.com/auremoo/handoff-system tmp-handoff
cp -r tmp-handoff/.claude .
rm -rf tmp-handoff
claude
```

Dans Claude Code, commence par décrire ton projet :

```
Je démarre un projet [description]. Stack : [stack].
Voici ce que je veux construire : [objectif].
```

Code ta session. Quand tu approches la limite de contexte :

```
/handoff
```

Claude va :
1. Lire l'état git (branche, fichiers modifiés, derniers commits)
2. Résumer ce qui a été fait, où on en est, et la prochaine action
3. Écrire `CONTEXT.md` à la racine du projet
4. T'afficher un **prompt d'amorce prêt à coller dans Gemini**

---

## Cas 2 — Projet déjà commencé

```bash
cd mon-projet-existant
git clone https://github.com/auremoo/handoff-system tmp-handoff
cp -r tmp-handoff/.claude .
rm -rf tmp-handoff
claude
```

Dans Claude Code, donne le contexte une première fois :

```
/init-context
```

S'il n'y a pas encore de `CONTEXT.md`, Claude n'aura rien à lire — dans ce cas, décris manuellement la situation :

```
Voici où on en est : [description].
Fichiers clés : [liste].
Prochaine action : [action].
```

Ensuite le workflow est identique : code → `/handoff` en fin de session.

---

## Reprendre une session (Claude Code → Claude Code)

En début de session suivante dans Claude Code :

```
/init-context
```

Claude lit `CONTEXT.md` et répond en une phrase ce qu'il a compris, puis propose de commencer la prochaine action. Tu n'as rien à réexpliquer.

---

## Reprendre une session (Claude Code → Gemini / autre IA)

Après `/handoff`, Claude t'affiche un bloc comme ça :

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

**Colle ce bloc dans Gemini** (ou Copilot, GPT-4, etc.). L'IA reprend directement à la prochaine action sans poser de questions sur ce qui est déjà décidé.

Si tu as des fichiers clés à fournir, colle-les après le prompt :

```
[le prompt d'amorce]

Voici les fichiers pertinents :

--- src/api.ts ---
[contenu]

--- prisma/schema.prisma ---
[contenu]
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

**`CONTEXT.md` est ignoré par git par défaut** — ajoute-le à ton `.gitignore` si ce n'est pas déjà le cas :
```
echo "CONTEXT.md" >> .gitignore
```

**Avant un `/handoff`**, dis à Claude ce qui reste flou ou non terminé. Plus il a d'infos dans le contexte conversationnel, meilleur sera le `CONTEXT.md` généré.

**En début de nouvelle session**, `/init-context` fonctionne même si tu reviens plusieurs jours plus tard — tant que `CONTEXT.md` est à jour.
