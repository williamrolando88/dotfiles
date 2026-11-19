# Plan de Ejecución: `herdr-team` (Multi-Agent Team Scaffolder & Runner)

## 1. Visión y Propósito
Herramienta CLI integrada en dotfiles para generar, personalizar y orquestar equipos de agentes autónomos en cualquier proyecto usando **Herdr Core (`hc`)** y **Herdr GUI (`herdr-app`)**, con mantenimiento centralizado y cero contaminación en los repositorios de trabajo.

---

## 2. Arquitectura de Triangulación y Almacenamiento

```
[dotfiles/agents/teams/]             <-- Fuente de verdad (controlada por git)
        │
        │ (symlink via install.sh)
        ▼
   ~/.agents/                        <-- Puente canónico de usuario
   ├── roles/                        (catálogo global de prompts .md)
   ├── templates/                    (plantillas RFC, handover, etc.)
   └── presets/                      (topologías de referencia)
        ▲
        │ (symlinks via herdr-team init)
[<repo>/.agents/]                    <-- Local en cada repo (100% en .gitignore)
   ├── roles/       -> ~/.agents/roles/
   ├── templates/   -> ~/.agents/templates/
   ├── team.json    (específico del proyecto: nombres, scopes, roles)
   └── .runtime/    (efímero: PIDs, sockets, worktrees)
```

---

## 3. Decisiones de Diseño Acordadas

1. **Aislamiento Total del Repo (KISS / DRY):**
   - La carpeta `.agents/` en los proyectos de trabajo es estrictamente local y privada.
   - Se ignora globalmente vía `~/.config/git/ignore` (gestionado por dotfiles).
   - Ningún secreto, prompt o artefacto de agentes se commitea en repos de proyectos.

2. **Idempotencia y Reinstalación Limpia (`rm -rf`):**
   - `herdr-team init` elimina completamente cualquier `.agents/` preexistente en el repo antes de regenerar.
   - Cero drift y cero configuraciones huérfanas.

3. **Propagación Instantánea vía Symlinks:**
   - Prompts (`roles/`) y plantillas (`templates/`) se enlazan simbólicamente desde `~/.agents/`.
   - Modificar un rol en dotfiles actualiza inmediatamente el comportamiento en todos los proyectos sin reinstalación.

4. **Runner Centralizado (Sin scripts shell duplicados en repos):**
   - El repo solo contiene `team.json` y los symlinks a roles/templates.
   - El ejecutor es el CLI global: `herdr-team start` lee el `team.json` local e interactúa directamente con `hc` y `herdr-app`.

5. **Entorno y Plataforma:**
   - Optimizado para **Linux**.
   - Integración nativa con `hc` (backend de procesos) y `herdr-app` (GUI con spaces y tabs por rol).

6. **Especialista UI/UX Efímero y Protocolo Tripartito:**
   - Rol `ui-ux-designer` (`agy` / `gemini-3.8-flash-high`, multimodal).
   - Invocado a demanda por `lead-architect` al detectar impacto frontend.
   - **Detección autónoma:** Si existe Storybook (`@storybook/*`), genera o extiende contratos visuales en `*.stories.tsx` con mocks JSX/Tailwind. Si no existe Storybook, genera especificación `.agents/specs/ui-<ticket>.md` usando la plantilla `UI_SPEC.md`.
   - **Acuerdo Tripartito:** Debate entre `lead-architect`, `frontend-architect` y `ui-ux-designer`. Firmado el acuerdo, `frontend-architect` delega a `implementer-frontend` y `lead-architect` termina al especialista de UI/UX.

---

## 4. Subcomandos del CLI (`herdr-team`)

- `herdr-team init`:
  - Checklist interactivo en terminal para seleccionar roles activos.
  - Selección de scopes del proyecto (backend, frontend, apps, packages).
  - Limpieza de `.agents/` previo (`rm -rf`).
  - Creación de symlinks hacia `~/.agents/`.
  - Generación de `team.json` a la medida.
- `herdr-team start [OPTIONS]`:
  - Lee `.agents/team.json` del directorio actual.
  - Opciones:
    - `--ui`: Abre/monta tabs en Herdr GUI (`herdr-app`).
    - `--task "<texto>"`: Envía directiva inicial al Technical Owner.
    - `--attach`: Conecta la terminal actual al Technical Owner.
    - `--restart`: Soft-reset de especialistas persistentes.
    - `--status`: Estado en vivo de terminales `hc`.
- `herdr-team status`: Inspecciona agentes del proyecto actual.

---

## 5. Pendiente de Diseño: Matriz de Interacción Dinámica
- Definir algoritmo/reglas para mapear dinámicamente:
  - Quién reporta a quién (`reports_to`).
  - Quién puede spawnear/matar a quién (`can_spawn`, `can_kill`).
  - Matriz de comunicación entre roles (`communicates_with`).
  - Protocolos de debate (árbitro de empates cuando no hay Lead Architect o TO).
