# Mode procedures

Load this file after Step 0 when you need detailed steps for the active mode.

---

## 1. Bootstrap (project)

**When:** No hub and no meaningful `docs/` (or empty project).

1. Explain you will build a living, interlinked documentation system.
2. Ask (batch or sequential, keep it tight):
   - Problem, users, elevator pitch
   - MVP features vs later phases
   - Stack, constraints (perf, security, compliance, scale, team)
   - Existing hard decisions
   - Process preferences if relevant
3. Create **hub first** (`AGENTS.md` preferred).
4. Create core set:
   - `docs/product-vision.md`
   - `docs/requirements.md` (functional + non-functional, prioritized)
   - `docs/architecture.md`
   - `docs/roadmap.md` (phased)
   - `docs/decisions/` with ADRs for stack / major trade-offs
5. Add supporting docs only if clearly needed.
6. Cross-link everything; Mermaid only when it adds value.
7. Present file list + ask for review. No auto-commit.

**Anti-bloat:** Do not create empty feature folders or unused operational docs.

---

## 2. Adopt (project)

**When:** Code exists; docs missing, incomplete, or drifted.

1. Explore thoroughly:
   - Tree, README, manifests (`package.json`, `pyproject.toml`, `go.mod`, etc.)
   - Entry points, config, existing docs
   - Sample core modules, data models, APIs, tests
2. Infer architecture, tech choices, implemented capabilities, tacit decisions.
3. Map gaps and inconsistencies.
4. Ask **targeted** confirmation questions only (not a full product interview).
5. Generate or complete the core set; update hub as the index.
6. ADRs for significant discovered decisions: `Status: Accepted — inferred from code`.
7. Cross-link; summarize what was inferred vs confirmed.

---

## 3. Feature

**When:** User names a feature, module, epic, or PR surface to document or plan.

### 3.1 Scope the surface

1. Derive `slug` = kebab-case of the feature name (e.g. `billing-webhooks`).
2. Find code: directories, packages, routes, components, tests related to the feature.
3. Read implementation + tests for intended behavior and edge cases.
4. Note public surface (API, CLI, UI, events) and dependencies.

### 3.2 Clarify (keep short)

Ask only what code cannot answer:
- Goals and success metrics
- In-scope vs out-of-scope for this slice
- Acceptance criteria
- Risks / open product questions
- Priority relative to roadmap (if unknown)

### 3.3 Write feature pack

Required:
- `docs/features/<slug>/README.md` from [feature-readme-template.md](feature-readme-template.md)

Add if needed:
- `design.md` — flows, boundaries, sequence diagrams
- `requirements.md` — long acceptance criteria
- Global ADR if a durable technical choice is made

### 3.4 Wire into project

1. Hub: Features section link to `docs/features/<slug>/README.md`.
2. If architecture impact is real: short section or link in `docs/architecture.md`.
3. If planned work: item in `docs/roadmap.md`.
4. If no hub exists → **hybrid**: minimal hub + feature pack (do not invent full product-vision unless user wants it).

### 3.5 Hybrid (feature without project docs)

Minimal hub contents:
- Overview one-liner (from README or inference)
- Link to this feature
- Standard agent instructions
- Status line

Defer full project bootstrap unless the user asks.

---

## 4. Sync

**When:** Code changed and docs should follow (diff, PR, explicit "update docs").

1. Determine change set (user description and/or `git diff` / changed files).
2. Blast radius:
   - Project docs (architecture, API, data model, requirements, roadmap)
   - Feature packs under `docs/features/`
   - ADRs (new decision? supersede?)
3. Edit **only** impacted files with precise updates.
4. Update hub status / links if structure changed.
5. Prefer "superseded by ADR-N" over deleting history.
6. Output a clear list: file → what changed. Flag remaining doc debt without inventing pages unless asked.

---

## 5. Roadmap

**When:** Plan a release, epic, feature phase, or refresh roadmap.

1. Read hub, `docs/roadmap.md`, architecture, requirements, relevant feature docs/ADRs.
2. Clarify goals, success metrics, MVP slice vs full, dependencies, risks, rough priority.
3. Write at the right level:
   - **Project epic** → roadmap entry + maybe new feature folder stubs only if work is committed
   - **Single feature** → update `docs/features/<slug>/` + roadmap line
4. Create ADRs if planning locks a decision.
5. Optional: high-level implementation task list linked from the feature or roadmap doc.
6. Update hub status.

---

## Completion template (all modes)

```
Scope: …
Mode: …
Created: …
Updated: …
ADRs: …
Open questions: …
Suggested next: …
```
