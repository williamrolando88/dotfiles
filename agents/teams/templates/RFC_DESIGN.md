# RFC-{{RFC_ID}}: {{FEATURE_TITLE}}

* **Author:** `lead-architect`
* **Status:** `DRAFT` <!-- DRAFT | DEBATE_ROUND_1 | DEBATE_ROUND_2 | ARBITRATION | CONSENSUS_APPROVED -->
* **Technical Owner Goal:** {{TO_GOAL_SUMMARY}}

---

## 1. Context & Architectural Boundaries
* **Core (`apps/core`):** {{CORE_CHANGES_OR_NONE}}
* **Satellite(s) (`apps/satellite-*`):** {{SATELLITE_CHANGES_OR_NONE}}
* **Frontend PWA (`apps/web`):** {{WEB_CHANGES_OR_NONE}}
* **Infra / DevOps (`docker/`, `Caddyfile`, `livekit`):** {{INFRA_IMPACT_OR_NONE}}

## 2. Explicit Contracts
* **gRPC / Procedures (Path A):**
  * {{RPC_CONTRACTS}}
* **Conversational Tasks / Queries (Path B):**
  * {{TASK_QUERY_CONTRACTS}}
* **WebRTC DataChannel / Client State Events:**
  * {{DATACHANNEL_EVENTS}}
* **Database Schema (`core` vs `<vertical>`):**
  * {{SCHEMA_CHANGES}}

## 3. Acceptance Criteria (Given / When / Then)
1. **Given** ..., **When** ..., **Then** ...

## 4. Layer Adversarial Sign-Off (Mandatory Pre-Implementation)
- [ ] **Backend Architect:** Agrees contracts preserve Hexagonal Architecture, Core Purity, Schema Isolation & performance.
  * *Debate Notes / Concessions:* {{BACKEND_NOTES}}
- [ ] **Frontend Architect:** Agrees event payloads, Mobile-First UX, and state transitions are clean without client hacks.
  * *Debate Notes / Concessions:* {{FRONTEND_NOTES}}
- [ ] **Technical Owner Arbitration (if deadlocked after Round 2):** {{ARBITRATION_DECISION}}
