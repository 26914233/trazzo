# Guía para Claude en este repo

Este repo tiene la web de Curtzz y los juegos (RONIN en Pygame y la campaña de Curtzz). La carpeta `.claude/` trae skills, agentes y comandos compartidos (ver `.claude/CCGS-README.md`). Úsalos cuando encajen, sin forzarlos:

- Antes de implementar algo no trivial: `planning-and-task-breakdown` o `/plan`; luego `incremental-implementation` (cambios pequeños y verificables).
- Al corregir bugs: `debugging-and-error-recovery`, y `bug-report` / `bug-triage`. Escribe primero la prueba que falla (`test-driven-development`, `python-testing`).
- Al revisar código: `code-review-and-quality` o `/review`; agentes `python-reviewer`, `silent-failure-hunter`.
- Balance, dificultad y jefes: `balance-check`, `playtest-report`, `economy-designer`, `systems-designer`.
- Rendimiento: `performance-optimization`, `perf-profile`. Antes de entregar: `smoke-check`, `verification-loop`.
- Para no sobreingeniar: `ponytail-review`. Para no bajar el listón (no silenciar pruebas ni checks para dar verde): `constraint-driven-development`.
- Web: `frontend-patterns`, `frontend-ui-engineering`, `seo`, `browser-qa`.

Reglas: no inventes datos ni resultados de pruebas; di lo que no pudiste verificar. Si una skill pide aprobación humana, pídela al dueño en vez de saltarla. Responde en español.
