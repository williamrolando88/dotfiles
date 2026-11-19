# TASK-{{TASK_ID}}: {{TASK_TITLE}}

* **Parent RFC:** `RFC-{{RFC_ID}}`
* **Assigned Layer Architect:** `{{backend-architect | frontend-architect}}`
* **Worker Type:** Ephemeral Zero-Context (`--no-session`)

---

## 1. Objective & Exact Scope
{{CLEAR_OBJECTIVE}}

### Allowed Files (Do NOT edit outside this list)
* `{{FILE_PATH_1}}`
* `{{FILE_PATH_2}}`

### Read-Only Reference Files
* `{{REF_FILE_1}}`

## 2. Technical Contract & Requirements
{{EXACT_INTERFACES_TYPES_AND_EDGE_CASES}}

## 3. Mandatory Unit Tests (Owned by Implementer)
* Test file(s) to create/update: `{{TEST_FILE_PATH}}`
* Required assertions:
  1. {{ASSERTION_1}}
  2. {{ASSERTION_2}}

## 4. Definition of Done
- [ ] Only allowed files modified; zero `AGENTS.md` violations.
- [ ] Unit/component tests authored and passing.
- [ ] `bun run check` (`lint`, `typecheck`, `check:rules`, `test`) passes with 0 errors and 0 warnings.
- [ ] Report completion to `{{backend-architect | frontend-architect}}` via `hc send`.
