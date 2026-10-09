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

## agent-skills (Addy Osmani) y Ponytail
Origen: https://github.com/addyosmani/agent-skills (ver LICENSE-agent-skills) y https://github.com/DietrichGebert/ponytail (MIT, ver LICENSE-ponytail).
agent-skills: 25 skills, 3 agentes (security-auditor, test-engineer, web-performance-auditor; se omitio code-reviewer porque ya existe el de ECC) y los comandos de .claude/commands (/build /plan /review /spec /test /ship...).
Ponytail: solo las 6 skills (ponytail, ponytail-audit, -debt, -gain, -help, -review). NO se copiaron sus hooks (activate, mode-tracker, subagent),
que son los que activan el modo de forma automatica; para eso hay que instalar el plugin completo en Claude Code:
  /plugin marketplace add DietrichGebert/ponytail
  /plugin install ponytail@ponytail   (dos mensajes separados)

## Replica (Jake Schincariol)
Origen: https://github.com/Jakeschincariol/replica-skill (MIT, ver LICENSE-replica), commit 77c9436.
Las 11 skills tal cual: replica-recon, -architect, -design, -build, -backend, -test, -diff, -entrepreneur, -brand, -launch, -deploy.
Rehacen una app o web por sus funciones (no su codigo, logo, textos ni contenido), en orden recon -> ... -> deploy; cada una
deja su trabajo en una carpeta replica/ del proyecto. Sus herramientas son Python 3.8+ sin dependencias ni red. No se copiaron
la carpeta tests/ ni .claude-plugin/ del original.
