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
   - `docs/product-vision.md` — problem, users, promise, **product** success metrics, out of scope  
     (**not** team process, CODEOWNERS, or git workflow — those go in NFR / ops / hub)
   - `docs/requirements.md` (functional + non-functional, prioritized; RF-IDs + evidence when possible)
   - `docs/architecture.md`
   - `docs/roadmap.md` (phased)
   - `docs/decisions/` with ADRs for stack / major trade-offs
5. Add supporting docs only if clearly needed.
6. Cross-link everything; Mermaid only when it adds value.
7. Present file list + ask for review. No auto-commit.

**Anti-bloat:** Do not create empty feature folders or unused operational docs.

### Narrative separation

| Doc | Owns |
|-----|------|
| product-vision | Problem, users, promise, product outcomes |
| requirements NFR / operations / hub | Process, ownership, gates, tooling |
| architecture | Technical form, boundaries, patterns |

---

## 2. Adopt (project)

**When:** Code exists; docs missing, incomplete, drifted, or need agent-ready integration.

### 2.0 Detect doc maturity

Score the repo (read only):

| Signal | Weight |
|--------|--------|
| Existing hub (`AGENTS.md` / `agents.md` / rich `CLAUDE.md` with hard rules) | high |
| `docs/` with index + architecture or modules | high |
| Existing ADRs (`docs/**/decisions/`, `docs/**/adr/`) | high |
| Module/feature docs already present | medium |
| Only thin README | low |

**Classify:**

| Maturity | Variant | Behavior |
|----------|---------|----------|
| **thin** | **adopt-full** | Create/complete core set (similar to bootstrap, inferred from code) |
| **mixed** | **adopt-integrate** | Extend hub; fill gaps; do not rewrite strong authorities |
| **mature** | **adopt-integrate** | Index + coverage matrix + gap fill only; parallel full tree **forbidden** |

Announce:

```text
Scope: project | Mode: adopt | Variant: full|integrate | Maturity: thin|mixed|mature | Out: root|sandbox:path
```

### 2.1 Explore (both variants)

1. Tree, README, manifests (`package.json`, `pyproject.toml`, `go.mod`, etc.)
2. Entry points, config, **existing docs** (inventory authorities)
3. Sample core modules, data models, APIs, tests
4. Product surfaces: nav, ModuleIds, packages, major routes

### 2.2 Adopt-full (thin)

1. Infer architecture, tech choices, capabilities, tacit decisions.
2. Map gaps; ask **targeted** confirmation questions only.
3. Generate or complete the core set; hub is the index.
4. ADRs for significant discovered decisions: `Status: Accepted — inferred from code`.
5. **Coverage matrix required** in the hub (all discovered surfaces).
6. Feature packs for key domains — **atomic** slugs (see §3.0); clusters only as index + children.
7. Cross-link; summarize inferred vs confirmed.
8. Requirements (if written): RF-IDs + evidence; optional traceability to feature packs.

### 2.3 Adopt-integrate (mature / mixed)

1. **Inventory authorities** — table of existing docs and what they own  
   (e.g. `CLAUDE.md` = ops rules; `docs/modules/contracts.md` = contracts business).
2. **Do not re-create** product-vision / requirements / architecture / ADRs that already exist unless empty or the user asks to rewrite.
3. **Hub strategy:**
   - Prefer extending the existing hub (`AGENTS.md` or a docs-index section in `CLAUDE.md`).
   - A second hub is allowed only as **index + agent rules** and must not claim to replace ops docs.
4. **Write only:**
   - Coverage matrix (surface → canonical doc → feature pack → status → gap)
   - Missing feature **entry** packs that point at existing module/canonical docs
   - Missing ADRs that are **not** already filed (continue repo numbering)
   - Thin synthesis only when **no** authority exists (e.g. glossary gap)
5. **ADR placement** — see §2.5.
6. Session summary **must** include:
   - authorities found
   - files created (minimal)
   - intentional **non-writes** (why)
   - remaining gaps
   - if sandbox: **promotion plan**

### 2.4 Output location (sandbox)

Default: repository root (or the project's existing docs root).

**Sandbox** (`test/`, `docs-sandbox/`, worktree subfolder): only when the user explicitly asks to generate without touching productive docs.

If sandbox:

1. Banner on hub + `docs/README`: sandbox; does **not** replace productive docs.
2. Relative links to productive docs must resolve from the sandbox path.
3. Do **not** renumber or duplicate productive ADRs inside the sandbox as a parallel series when maturity is mature — **link** them; only draft **net-new** ADRs (or clearly mark drafts as promotion candidates with target productive path).
4. Session summary includes **Promotion plan**: safe to merge / do not merge / path rewrites.

### 2.5 ADR placement rules

1. Detect existing ADR dirs and numbering (`0001-slug.md`, `ADR-001-slug.md`, `NNNN-…`).
2. **Continue that scheme**; never invent a parallel ADR series in another folder for the same decisions.
3. If a decision already exists: **link it**; do not copy into a new file.
4. Net-new only (e.g. kernel choice not yet filed).
5. Archaeology status: `Accepted — inferred from code` when appropriate.

### 2.6 Snapshots (anti-rot)

- No hardcoded table/route/endpoint counts.
- `api.md` (if needed) = conventions + discovery commands + authZ pattern — not a full endpoint inventory unless the user asks.
- `data-model.md` (if needed) = invariants + ownership map + links — not a full schema dump.

---

## 3. Feature

**When:** User names a feature, module, epic, or PR surface to document or plan.

### 3.0 Feature sizing

- Prefer **one primary ModuleId / package / route family per slug**.
- If the user names a **domain cluster** (e.g. "precon", "D2D + budget + SCM"):
  1. Create `docs/features/<cluster-slug>/README.md` as an **index only** ([feature-cluster-template.md](feature-cluster-template.md)).
  2. Create **child** feature packs for each bounded surface.
  3. Hub lists children; optional cluster row with status note `Index`.
- Anti-pattern: one README that owns three ModuleIds with different owners and roadmaps.

### 3.1 Scope the surface

1. Derive `slug` = kebab-case of the feature name (e.g. `billing-webhooks`).
2. Find code: directories, packages, routes, components, tests related to the feature.
3. Read implementation + tests for intended behavior and edge cases.
4. Note public surface (API, CLI, UI, events) and dependencies.
5. Find **canonical authority** docs if they already exist (modules/, CLAUDE.md sections).

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
- Status from [status-taxonomy.md](status-taxonomy.md)
- **Canonical authority** table when existing docs own the business rules

If an authority already exists: **entry point only** (purpose, public surface, open questions, links) — do not re-dump the module doc.

Add if needed and **no** authority covers it:
- `design.md` — flows, boundaries, sequence diagrams
- `requirements.md` — long acceptance criteria
- Global ADR if a durable technical choice is made (net-new; correct numbering)

### 3.4 Wire into project

1. Hub: Features section + update coverage matrix row if present.
2. If architecture impact is real: short section or link in `docs/architecture.md` (or productive arch docs).
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
   - Coverage matrix rows
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
4. Create ADRs if planning locks a decision (net-new; correct scheme).
5. Optional: high-level implementation task list linked from the feature or roadmap doc.
6. Update hub status.

---

## 6. Requirements conventions (when writing requirements.md)

- Prefer RF-IDs with an **evidence** column (path, module, test).
- Add **Traceability** when feature packs or module docs exist:

| ID | Feature pack | Canonical module doc |
|----|--------------|----------------------|
| RF-… | `features/…` or — | path or — |

- RF without feature pack **and** without module doc → list under **Doc debt**.
- On adopt-integrate: skip full requirements.md if CLAUDE + modules already encode the same — link instead.

---

## Completion template (all modes)

```
Scope: …
Mode: …
Variant: …          # adopt only
Maturity: …         # adopt only
Out: root | sandbox:path
Created: …
Updated: …
Non-writes: …       # integrate / mature
ADRs: …             # net-new only; scheme used
Coverage matrix: yes/no
Promotion plan: …   # sandbox only
Open questions: …
Suggested next: …
```
