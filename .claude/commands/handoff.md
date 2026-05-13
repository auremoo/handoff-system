---
description: Génère un CONTEXT.md de handoff pour switcher vers Gemini ou un autre LLM sans perdre le contexte
---

Génère un fichier CONTEXT.md de handoff complet pour ce projet.

**Étape 1 — Collecte le contexte git**

Exécute ces commandes :
```bash
git rev-parse --abbrev-ref HEAD
git log --oneline -5
git diff --name-only
git diff --cached --name-only
```

**Étape 2 — Détecte la stack**

Vérifie les fichiers à la racine : `package.json` → Node.js, `tsconfig.json` → TypeScript, `requirements.txt` / `pyproject.toml` → Python, `Cargo.toml` → Rust, `go.mod` → Go, `pom.xml` → Java.

**Étape 3 — Écris CONTEXT.md**

Crée ou écrase le fichier `CONTEXT.md` à la racine du projet avec ce contenu (complété avec les vraies informations) :

```
# CONTEXT HANDOFF — [DATE]

> **Colle ce fichier en début de session Gemini ou autre LLM.**

---

## Projet
- **Stack** : [stack détectée]
- **Branche git** : [branche]

## Objectif de la session
[résume en 1-2 phrases ce qu'on essayait d'accomplir]

## Ce qui a été fait ✅
[liste des tâches terminées dans cette session]

## Tâche en cours ⚙️
**Fichier(s) concerné(s)** : [fichiers]
**Étape interrompue** : [description précise]

## Prochaine action immédiate 🎯
[UNE seule action concrète, la plus précise possible]

## Décisions importantes prises
[choix d'architecture, libs, patterns retenus]

## Fichiers clés modifiés
[git diff --name-only]

## Derniers commits
[git log --oneline -5]

## Contraintes / pièges à éviter ⚠️
[ce que l'autre LLM NE doit PAS faire]

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
```

**Étape 4** — Affiche le prompt d'amorce final prêt à copier-coller.

Sois dense et précis — chaque mot compte, l'autre LLM n'aura pas notre historique.
