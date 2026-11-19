# QA E2E VALIDATION REPORT-{{REPORT_ID}}

* **RFC / Feature:** `RFC-{{RFC_ID}}`
* **Executed By:** `qa-engineer`
* **Delivered To:** `lead-architect` AND `technical-owner`
* **Overall Verdict:** `PASS` <!-- PASS | FAIL -->

---

## 1. Environment & Stack Verified
* **Command Run:** `{{E2E_COMMAND}}`
* **Viewports Tested:** Mobile (`390x844`), Desktop (`1280x800` if applicable)
* **Downstream Infra Status (`check:infra`):** {{UP | DEGRADED}}

## 2. E2E Scenarios Verified (Playwright)
| Scenario | Acceptance Criterion | Result | Notes / Trace |
| :--- | :--- | :--- | :--- |
| {{SCENARIO_1}} | {{GIVEN_WHEN_THEN}} | `PASS / FAIL` | {{DETAILS}} |

## 3. Visual, Console & Network Observations
* **Console / Unhandled Errors:** {{NONE_OR_ERRORS}}
* **Network / gRPC / WebRTC DataChannel Health:** {{OBSERVATIONS}}
* **Screenshots / Artifacts:** {{PATHS_IF_ANY}}

## 4. Joint Sign-Off Committee & GitHub PR
- [ ] **Lead System Architect:** Global contract integrity & technical E2E pass confirmed.
- [ ] **Technical Owner:** Business acceptance criteria satisfied.
- [ ] **Final Decision:** `APPROVED_FOR_GITHUB_PR` / `REMEDIATION_REQUIRED`
- **GitHub PR URL (`main <- feat/<rfc-slug>`):** `{{GITHUB_PR_URL}}`
