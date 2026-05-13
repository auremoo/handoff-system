# Handoff System

Deux commandes Claude Code pour switcher entre Claude Code et Gemini (ou n'importe quel LLM) sans perdre le contexte.

```
/handoff        ← Claude écrit CONTEXT.md + génère le prompt Gemini
/init-context   ← Claude reprend là où on s'était arrêté
```

## Installation

Copier le dossier `.claude/` dans ton projet :

```bash
# Unix
cp -r /chemin/vers/handoff-system/.claude /chemin/vers/mon-projet/

# Windows (PowerShell)
Copy-Item -Recurse /chemin/vers/handoff-system/.claude /chemin/vers/mon-projet/
```

Ou cloner directement dans ton projet :

```bash
cd mon-projet
git clone https://github.com/auremoo/handoff-system tmp-handoff
cp -r tmp-handoff/.claude .
rm -rf tmp-handoff
```

Les commandes `/handoff` et `/init-context` sont disponibles dans Claude Code immédiatement.

---

## Workflow

```
cd mon-projet
claude

/init-context          ← reprend le contexte de la session précédente

# ... tu codes ...

/handoff               ← génère CONTEXT.md + prompt prêt pour Gemini
```

## Ce que fait /handoff

1. Lit l'état git (branche, commits récents, fichiers modifiés)
2. Détecte la stack
3. Écrit `CONTEXT.md` avec tout le contexte
4. Génère un prompt d'amorce à coller dans Gemini :

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
