# Claude Code Game Studios (CCGS): agents, skills y rules

Origen: https://github.com/Donchitos/Claude-Code-Game-Studios (MIT, ver LICENSE-CCGS).
Incluye .claude/agents (49), .claude/skills (74) y .claude/rules (13).
No incluye hooks, settings.json, scripts, docs ni CLAUDE.md del original.

Para aplicarlo en la rama de un juego:
  git fetch origin claude/omniroute-repo-setup-379r7i
  git checkout origin/claude/omniroute-repo-setup-379r7i -- .claude
Despues abre una sesion nueva para que cargue los agentes y skills.

## ECC (Everything Claude Code): seleccion curada
Origen: https://github.com/affaan-m/ECC (MIT, ver LICENSE-ECC). Se copiaron 32 skills y 14 agentes elegidos para
estos proyectos (Python/Pygame, web, MCP, Remotion/video, contenido, seguridad, QA). No se copiaron hooks,
reglas ni MCP del original. El resto (293 skills, 68 agentes) esta en el repo original si hace falta algo mas.
Skills: tdd-workflow security-review security-scan python-patterns python-testing backend-patterns api-design
mcp-server-patterns frontend-patterns frontend-design-direction browser-qa e2e-testing remotion-video-creation
video-editing manim-video content-engine social-publisher crosspost seo deep-research verification-loop git-workflow
coding-standards error-handling deployment-patterns docker-patterns search-first context-budget
agent-introspection-debugging click-path-audit codebase-onboarding documentation-lookup
Agentes: code-reviewer python-reviewer typescript-reviewer security-reviewer silent-failure-hunter tdd-guide
build-error-resolver e2e-runner performance-optimizer refactor-cleaner doc-updater planner code-explorer a11y-architect
