# Mode procedures

Load this file after Step 0 when you need detailed steps for the active mode.

## 0. Intent selection (v1.2)

**Intent** is orthogonal to Mode but drives writing policy:

| Intent | Default Mode | Writing policy |
|--------|--------------|----------------|
| **integrate** | adopt | Improve/index existing; no parallel SSOT rewrite when mature |
| **audit** | audit | Read-only reconciliation matrix; optional follow-on Intent |
| **from-zero** | bootstrap or adopt-full | Full knowledge base from **code** (+ user answers if greenfield); old docs = hypothesis only |

### 0.1 Infer Intent from phrases

| Phrase pattern | Intent | Out |
|----------------|--------|-----|
| “toda nueva”, “de cero”, “generá toda la documentación” | from-zero | root unless path given |
| “en test/”, “carpeta test”, “sandbox”, “sin tocar docs productivos” | from-zero (or integrate if only index) | **sandbox:path** |
| “mejorar docs”, “ordenar”, “integrar hub”, “coverage matrix” | integrate | root |
| “auditar”, “docs vs code”, “¿las docs mienten?”, “validar que exista” | audit | root (matrix may live under `docs/audit/` or sandbox) |
| “audit then fix” / “auditar y corregir” | audit → then integrate or selective patch | root |

If docs exist and user intent is unclear → **ask once**: integrate | audit | from-zero.

### 0.2 Pipeline order

```text
Discover CODE surfaces first
  → if Intent=audit OR (docs exist AND drift suspected AND Intent≠from-zero pure skip):
        Audit / reconciliation pass
  → execute Intent write policy
```

**Code wins:** never invent endpoints/tables/modules to satisfy a doc claim.

---

## 1. Bootstrap (project)

**When:** No hub and no meaningful `docs/`, greenfield, **or** Intent **from-zero** on thin/empty docs (see also §7).

1. Explain you will build a living, interlinked documentation system.
2. Ask (batch or sequential, keep it tight) — skip product interview when brownfield from-zero and code is enough:
   - Problem, users, elevator pitch
   - MVP features vs later phases
   - Stack, constraints
   - Existing hard decisions
3. Create **hub first** (`AGENTS.md` preferred).
4. Create core set:
   - `docs/product-vision.md` — product outcomes only (not process)
   - `docs/requirements.md` (RF-IDs + evidence when possible)
   - `docs/architecture.md`
   - `docs/roadmap.md`
   - `docs/decisions/` ADRs for stack / major trade-offs
5. Supporting docs only if needed.
6. Cross-link; Mermaid only when valuable.
7. Present file list. No auto-commit.

**Anti-bloat:** No empty feature folders.

### Narrative separation

| Doc | Owns |
|-----|------|
| product-vision | Problem, users, promise, product outcomes |
| requirements NFR / operations / hub | Process, ownership, gates |
| architecture | Technical form, boundaries |

---

## 2. Adopt (project)

**When:** Code exists; docs missing, incomplete, drifted, or Intent **integrate**.

### 2.0 Detect doc maturity

| Signal | Weight |
|--------|--------|
| Hub / rich `CLAUDE.md` with hard rules | high |
| `docs/` with index + architecture or modules | high |
| Existing ADRs | high |
| Module/feature docs | medium |
| Only thin README | low |

| Maturity | Variant | Behavior |
|----------|---------|----------|
| **thin** | **adopt-full** | Create/complete core set from code |
| **mixed** / **mature** | **adopt-integrate** | Index + gaps; no parallel full tree at productive root |

If Intent is **from-zero**, do **not** force adopt-integrate even when mature — use §7 (often sandbox).

### 2.1 Explore

1. Tree, README, manifests  
2. **Code surfaces first** (ModuleIds, routes, packages, schemas)  
3. Existing docs / authorities  
4. Optional quick audit sample if claims look stale  

### 2.2 Adopt-full (thin)

1. Infer architecture, capabilities, tacit decisions.  
2. Targeted questions only.  
3. Core set + hub; ADRs `Accepted — inferred from code`.  
4. **Coverage matrix required**.  
5. Atomic feature packs for key domains.  
6. Summarize inferred vs confirmed.  

### 2.3 Adopt-integrate (mature / mixed) — Intent integrate

1. Inventory authorities (what each doc owns).  
2. Do **not** re-create product-vision / requirements / architecture / existing ADRs unless empty or user asked.  
3. Hub: extend existing; second hub only as index.  
4. Write only: coverage matrix, entry feature packs, net-new ADRs (same numbering), thin gaps.  
5. Prefer a **claims audit** first if user mentioned drift or many path claims.  
6. Summary: authorities, created, **non-writes**, gaps, promotion if sandbox.  

### 2.4 Output location (sandbox)

Default: project docs root.

**Sandbox** when user asks (`test/`, `docs-sandbox/`, …) **or** Intent from-zero with explicit sandbox path.

Sandbox rules:

1. Banner: not productive SSOT.  
2. Links to productive docs must resolve.  
3. Under **Intent integrate** + mature: do not clone ADR 0001–N as a parallel renumbered series — link; net-new only.  
4. Under **Intent from-zero**: full core set allowed inside sandbox; still prefer linking productive ADRs rather than forking conflicting decision history.  
5. Summary includes **Promotion plan**.  

### 2.5 ADR placement

1. Detect scheme (`0001-…`, `ADR-001-…`).  
2. Continue scheme; no parallel series for the same decision.  
3. Existing decision → link only.  
4. Net-new only when filing new decisions.  

### 2.6 Snapshots (anti-rot)

No hardcoded table/route/endpoint counts. `api.md` / `data-model.md` = conventions + invariants + discovery, not inventories.

---

## 3. Feature

**When:** User names a feature, module, epic, or PR surface.

### 3.0 Feature sizing

- One primary ModuleId / package / route family per slug.  
- Domain cluster → index ([feature-cluster-template.md](feature-cluster-template.md)) + **child** packs.  
- Anti-pattern: one README owning three ModuleIds.  

### 3.1–3.5

Scope code → short clarify → write pack ([feature-readme-template.md](feature-readme-template.md)) with status taxonomy + canonical authority table → wire hub / coverage row. Hybrid = minimal hub + feature only.

If Intent is **audit** on a feature: produce claims for that surface only; do not rewrite the module doc unless asked to patch.

---

## 4. Sync

**When:** Code changed; docs should follow.

1. Change set (`git diff` / description).  
2. Blast radius: project docs, features, coverage rows, ADRs.  
3. Edit only impacted files.  
4. Prefer Superseded ADR notes over deletion.  
5. List file → change; flag debt without inventing pages.  

If sync reveals many Contradicted claims → suggest full **audit**.

---

## 5. Roadmap

**When:** Plan release, epic, or refresh roadmap.

1. Read hub, roadmap, architecture, features/ADRs.  
2. Clarify goals, MVP, dependencies.  
3. Write at epic vs single-feature level.  
4. Net-new ADRs if decisions lock.  
5. Update hub status.  

---

## 6. Audit (project or feature)

**When:** Mode **audit** or Intent **audit**; also recommended before integrate when drift is suspected.

**Goal:** Structural reconciliation of documentation claims against **code as source of truth**. Not full NLP of every sentence.

### 6.1 Code inventory (always first)

Build a list from the repo (adapt to stack):

| Kind | How to discover (examples) |
|------|----------------------------|
| Packages / apps | manifests, workspaces |
| ModuleIds / feature flags | permissions maps, enums, nav registries |
| HTTP routes | `app/api/**`, routers, OpenAPI if generated |
| UI surfaces | app router pages, major nav |
| Data layer | ORM schemas, migrations (names not counts) |
| Kernels / jobs | `src/kernel`, workers, scripts |
| Tests | test dirs touching domain |

Do **not** hardcode giant endpoint tables into permanent docs; inventory is for the audit pass.

### 6.2 Claim extraction (structural)

From hub, `docs/**`, CLAUDE/AGENTS, module docs, ADRs — extract checkable claims:

- Path references (`src/…`, `docs/…`)  
- Module / feature names and status (`Real`, `Dual`, “shipped”)  
- Named tables/schemas (existence, not row counts)  
- “Uses X library/pattern” if central  
- ADR decisions that imply structure  

Skip pure opinion, future hopes without paths, and marketing fluff unless they cite concrete artifacts.

### 6.3 Verdicts

| Verdict | Meaning |
|---------|---------|
| **OK** | Claim matches code evidence |
| **Partial** | Something exists but incomplete vs claim |
| **Missing** | Claimed artifact not found in code |
| **Contradicted** | Code shows the opposite or incompatible design |
| **Unverifiable** | Not structural; leave open or ask human |

**Code wins:** Contradicted/Missing → trust code; mark doc debt; do not change code to match docs in this skill.

### 6.4 Write the matrix

Use [audit-template.md](audit-template.md). Prefer:

- `docs/audit/claims-matrix.md` at root, or  
- sandbox path if user asked not to touch productive docs  

Include: summary counts, top Contradicted/Missing, recommended next Intent (`integrate` patch vs `from-zero` sandbox).

### 6.5 Standalone vs follow-on

| After audit | Action |
|-------------|--------|
| Standalone | Stop after matrix + summary |
| → integrate | Patch only Contradicted/Missing entries user prioritizes; coverage matrix |
| → selective rewrite | Rewrite only failed claim docs |
| → from-zero | Full KB (usually sandbox) treating old docs as hypothesis |

Do **not** auto-start from-zero after audit without user Intent.

---

## 7. From-zero

**When:** Intent **from-zero** — user wants a full knowledge base, not an integrate-only pass.

### 7.1 Rules

1. **Code inventory first** (same as audit §6.1).  
2. Existing productive docs are **hypothesis**, not authority — sample them for vocabulary only; verify every structural claim you reuse.  
3. Produce full core set (hub + vision/requirements/architecture/roadmap/ADRs as needed) + coverage matrix + atomic features for major surfaces.  
4. If user named a folder (`test/`, `docs-sandbox/`) → **Out: sandbox:path** with banners + promotion plan.  
5. Do **not** silently overwrite productive `docs/` + `CLAUDE.md` SSOT; if they insist on root from-zero on a mature monorepo, confirm once that overwrite is intended.  
6. Status tokens from taxonomy; process rules stay out of product-vision.  
7. Optional: run audit matrix against *old* docs as appendix (“what the previous docs got wrong”).  

### 7.2 Difference from adopt-integrate

| | integrate | from-zero |
|--|-----------|-----------|
| Mature parallel tree at root | forbidden | only with explicit overwrite confirm |
| Sandbox full tree | rare | **first-class** |
| Old module docs | authority (link) | hypothesis |
| Goal | index + gaps | complete agent-ready KB |

---

## 8. Requirements conventions

- RF-IDs + **evidence** column.  
- Traceability to feature pack / module doc when present.  
- RF without pack and without module doc → **Doc debt**.  
- adopt-integrate: skip full requirements if authorities already encode them.  

---

## Completion template (all modes)

```
Scope: …
Mode: …
Intent: integrate | audit | from-zero | n/a
Variant: …              # adopt only
Maturity: …
Out: root | sandbox:path
Code inventory: yes/no
Claims matrix: path or n/a | OK/Partial/Missing/Contradicted counts
Created: …
Updated: …
Non-writes: …
ADRs: …
Coverage matrix: yes/no
Promotion plan: …       # sandbox
Open questions: …
Suggested next Intent: …
```
