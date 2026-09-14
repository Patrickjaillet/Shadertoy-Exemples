# Journal des modifications

Toutes les modifications notables de ce projet sont documentées dans ce fichier.

Le format s'inspire de [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/), et ce projet suit le [Versionnage Sémantique](https://semver.org/lang/fr/) (SemVer).

## [0.1.0] - 2026-09-14

Premier jalon fonctionnel du site de visualisation des shaders.

### Ajouté

- Normalisation des 378 fichiers shaders du dépôt : renommage en `NNN-simple.glsl` (numérotation globale continue), dossiers de catégorie en minuscules sans espaces (`divers`, `raymarching`, `retro-synthwave`, `retro-gaming`, `space-cosmos`, `tunnel`, `water`).
- Suppression des shaders multi-passes (Buffer A/B/C/D, Common, Sound) : seuls les shaders mono-pass (`Image` seul) sont conservés.
- Script de build (`scripts/build-index.js`) générant `data/shaders.json` (index léger) et `data/shaders/<NNN>.json` (un fichier par shader, avec titre extrait des commentaires du code, catégorie, source).
- Site statique (`index.html`, `assets/`) avec sidebar de navigation par catégorie et recherche en direct.
- Viewport de rendu WebGL 800×450 (`assets/js/shadertoy-runtime.js`) : uniforms standards Shadertoy (`iResolution`, `iTime`, `iTimeDelta`, `iFrame`, `iMouse`, `iDate`), contrôles Play/Pause/Reset, interaction souris, affichage lisible des erreurs de compilation GLSL.
- Éditeur de code en lecture seule avec coloration syntaxique GLSL (CodeMirror 5, thème `dracula`) et bouton de copie du code source.
- Routing côté client par hash (`#/<NNN>`) pour le lien direct partageable vers un shader précis.
- Détection au build des shaders non affichables (dépendance à des textures externes `iChannel0-3` absentes du dépôt, 19/378 shaders concernés) : badge dans la sidebar et message explicite dans le viewport, code toujours consultable.
- Workflow GitHub Actions (`.github/workflows/deploy.yml`) de déploiement automatique sur GitHub Pages à chaque push sur `main`.
- Modale « À propos » (copyright, e-mail, site web) accessible depuis la sidebar.
- `README.md` avec capture d'écran du site et instructions de contribution.
- `roadmap.md` documentant les étapes de développement, la pile technique et les conventions strictes du projet.
