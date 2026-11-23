---
description: Génère un CONTEXT.md de handoff pour switcher vers Gemini ou un autre LLM sans perdre le contexte
argument-hint: [précisions optionnelles]
---
<!-- Handoff System — Auteur : Aurélien Moote - Moo - 2026 — Licence MIT -->

Écris `CONTEXT.md` à la racine du projet : un handoff autonome pour un LLM qui n'aura pas notre historique.

Précisions de l'utilisateur (prioritaires ; peut être vide) : $ARGUMENTS

**Règles**

- Ta source est cette conversation. N'explore pas le code et ne relis aucun fichier : `/handoff` est souvent lancé en limite de contexte.
- Une seule commande à lancer (saute-la si le projet n'est pas un dépôt git) :
  ```
  git status -sb; git log --oneline -5
  ```
- Stack : celle connue par la session ou `CLAUDE.md`. Ne regarde les fichiers racine (`package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `pom.xml`…) que si elle est inconnue.
- Si `CONTEXT.md` existe déjà : garde ses décisions et pièges encore valides, remplace tout le reste.
- Dense et précis : chemins exacts, noms de fonctions, messages d'erreur tels quels. N'invente rien ; une section sans contenu réel est omise (sauf TL;DR et Prochaine action).

**Contenu de CONTEXT.md**

```
# CONTEXT HANDOFF — [date et heure]

> **TL;DR** : [1 phrase — état actuel + prochaine action]
>
> **Pour le LLM qui reprend** : commence directement par la « Prochaine action immédiate ». Ne redemande pas ce qui est déjà décidé ici. Si tu n'as pas accès à un fichier dont tu as besoin, demande-le. Sois concis.

## Projet
- **Stack** : [stack]
- **Branche git** : [branche]

## Objectif de la session
[1-2 phrases]

## Ce qui a été fait ✅
[tâches terminées dans cette session]

## Tâche en cours ⚙️
**Fichier(s) concerné(s)** : [fichiers]
**Étape interrompue** : [description précise]

## Prochaine action immédiate 🎯
[UNE seule action concrète, la plus précise possible]

## Décisions importantes prises
[choix d'architecture, libs, patterns retenus — et pourquoi]

## Fichiers modifiés non commités
[sortie de git status : modifiés, indexés et nouveaux fichiers]

## Derniers commits
[git log --oneline -5]

## Contraintes / pièges à éviter ⚠️
[ce que l'autre LLM NE doit PAS faire]
```

**Pour finir** — ne réaffiche pas le contenu du fichier. Réponds en deux lignes maximum : le fichier est écrit, il suffit de le coller ou de le joindre tel quel dans l'autre LLM.
