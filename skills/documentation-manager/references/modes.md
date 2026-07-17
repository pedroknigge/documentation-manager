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
Detect stack (Polyglot stack detection — skill-discovery.md)
  → Detect monorepo (Monorepo hubs — skill-discovery.md) / package index
  → Discover CODE surfaces first (inventory table for that stack; per package if monorepo)
  → if Intent=audit OR (docs exist AND drift suspected AND Intent≠from-zero pure skip):
        Audit / reconciliation pass
  → execute Intent write policy
```

**Code wins:** never invent endpoints/tables/modules to satisfy a doc claim.

### 0.3 Stack detection (polyglot MVP · v2.1)

Before inventory on **from-zero / integrate / audit** (and when exploring for adopt-full):

1. Run **Polyglot stack detection** in [skill-discovery.md](skill-discovery.md) (signals: `package.json`, `pyproject.toml`, `go.mod`, …) or `./scripts/detect-stack.sh <root>` when available.  
2. Record token(s): `node-ts` | `python` | `go` | `unknown`. If the detector prints **two or more** primaries (space-separated), announce **`Stack: mixed`** and inventory each.  
3. Choose **Inventory by stack** and **Docs layout guidance by stack** from that same reference — **do not** default to Node/TS paths when another stack is primary.  
4. Announce `Stack: …` with the project Step 0 line.

Anti-hallucination: no ModuleIds/HTTP routes/framework claims without code evidence for that stack.

### 0.4 Monorepo hubs (v2.2 Slice B)

On **from-zero / integrate / adopt / audit** when multi-package signals exist:

1. Run **Monorepo hubs** procedure in [skill-discovery.md](skill-discovery.md) (signals: `pnpm-workspace.yaml`, `package.json` workspaces, `go.work`, multi-`pyproject` / multi-`go.mod`, `packages/*`) or `./scripts/detect-packages.sh <root>`.  
2. If monorepo: build or update root hub as a **map** + **Package index** (not a narrative dump of every package).  
3. **Multi-package coverage** — one coverage row per package (or major surface); packages without docs = **gap**.  
4. **Default package non-writes** — when indexing the root, do **not** rewrite mature package product-vision / requirements / ADRs / feature packs.  
5. Optional package-level hub only when that package is in scope; never invent product vision for gap packages.  
6. Announce `Monorepo: yes|no | packages: <n>`.

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

1. **Stack detection** (§0.3 / [skill-discovery.md](skill-discovery.md) Polyglot stack detection)  
2. **Monorepo detection** (§0.4 / Monorepo hubs) — package list / `detect-packages.sh`  
3. Tree, README, manifests for the detected stack(s) and packages  
4. **Code surfaces first** using the **Inventory by stack** table (not Node-only assumptions); per package when monorepo  
5. Existing docs / authorities (root + package-local); **do not rewrite** mature package docs on root index-only work  
6. Optional quick audit sample if claims look stale  

When monorepo: ensure root hub has **Package index** and multi-package **Surface coverage** rows (gap allowed).

### 2.2 Adopt-full (thin)

1. Infer architecture, capabilities, tacit decisions.  
2. Targeted questions only.  
3. Core set + hub; ADRs `Accepted — inferred from code`.  
4. **Coverage matrix required**.  
5. Atomic feature packs for key domains.  
6. Summarize inferred vs confirmed.  

### 2.2b Monorepo package non-writes (integrate)

When monorepo detected and work is **root map / package index** only:

| Default non-writes (package trees) |
|------------------------------------|
| Package `product-vision` / requirements / architecture rewrites |
| Package ADRs renumbered or forked into root |
| Full feature packs for every package “because monorepo” |
| Invented ModuleIds / endpoints for gap packages |

Allowed: root hub Package index, coverage **gap** rows, links to existing package docs, one new package hub if user scoped that package.

### 2.3 Adopt-integrate (mature / mixed) — Intent integrate

1. Inventory authorities (what each doc owns).  
2. Do **not** re-create product-vision / requirements / architecture / existing ADRs unless empty or user asked.  
3. Hub: extend existing; second hub only as index.  
4. Write only: coverage matrix, entry feature packs, net-new ADRs (same numbering), thin gaps.  
5. Prefer a **claims audit** first if user mentioned drift or many path claims.  
6. **Team governance** (§11): if user asked for owners/team → create or link `docs/team/`; if not asked, do not force; never rewrite product-vision to “add owners”.  
7. Summary: authorities, created, **non-writes**, gaps, promotion if sandbox.  

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

## 3. Feature autopilot + Plan (v1.3 → v2 / skill v1.5)

**Goal:** User names a feature in plain language. Skill picks **plan vs feature pack**, writes the right files, and **never** requires the user to list non-writes.  
**v2:** finer **Kind** (spike / epic / redesign), optional **Implementation bridge** (placement + stubs **opt-in** only). See [implementation-bridge.md](implementation-bridge.md).

### 3.0 Detect “new feature” phrases

Treat as **feature-scoped work** (not project bootstrap / from-zero):

| Phrase patterns (any language) | Default |
|--------------------------------|---------|
| “nueva feature X”, “new feature X”, “feature X”, “módulo X” | Autopilot (§3.1) |
| “documentá X”, “document module X”, “docs for X” | Autopilot |
| “quiero agregar X”, “vamos a construir X”, “plan for X”, “epic X” | Prefer **plan** if no code |
| “documentá lo que hay en src/X” | Prefer **feature pack** (code-backed) |
| “promové el plan de X” / “promote plan X” | **Promote** plan → feature pack (§3.6) |
| “implementá X”, “generá stubs”, “scaffold X”, “start coding” | Stage A docs if needed **+** Implementation bridge on (§3.8) |
| “spike X”, “epic X”, “redesign X” | Autopilot + Kind refinement (§3.1b) |

**Do not** escalate to project Intent (integrate / from-zero) just because someone said “documentá”. Named surface → feature or plan.

### 3.1 Autopilot decision (plan vs pack)

```text
User names a surface
  → discover code for that name (paths, ModuleId, package, routes)
  → classify Kind (new feature | spike | epic | redesign) — §3.1b
  → IF user said "plan" / "epic" / "vamos a construir" / "spike" OR no meaningful code found
        → Mode: plan  → docs/plans/<slug>/
  → ELSE IF code exists (or pack already exists to refresh)
        → Mode: feature → docs/features/<slug>/
  → ELSE ambiguous name only
        → ask ONCE: "plan (no code yet) or document existing code?"
  → IF implement/stubs language → Stage B Implementation bridge (§3.8) after Stage A
  → ELSE Stage A only; one-line hint for bridge in summary
```

| Signal | Mode | Out path |
|--------|------|----------|
| No code / green idea / “plan” / “epic” / “spike” | **plan** | `docs/plans/<slug>/README.md` |
| Code path or ModuleId found | **feature** | `docs/features/<slug>/README.md` |
| Redesign of existing surface | **plan** (+ link current pack) or **feature** refresh | plan owns migration intent until code moves |
| Both plan + “and start the pack” | plan first; pack only when code real (or Planned pack only if user insists) | plan is authority until promote |
| Audit only on a surface | **audit** (scoped) | claims only; no full rewrite |
| Implement / stubs opt-in | plan or feature **+** bridge | docs first; code only if opted in |

**Slug:** kebab-case from the name (`Team Invitations` → `team-invitations`). One slug ≈ one ModuleId / bounded context. Domain with many ModuleIds → cluster index + children (feature) or one epic plan + child plans.

### 3.1b Kind refinement (v2)

| Kind | Signals | Behavior |
|------|---------|----------|
| **new feature** | default | Full plan or pack MVP |
| **spike** | “spike”, “explore”, “timebox”, “prove” | Thin plan; Open questions heavy; bridge placement-only unless user insists on stubs |
| **epic** | “epic”, multi-team, many ModuleIds | Parent plan + child slugs; forbid one mega-pack for whole epic |
| **redesign** | “redesign”, “replace”, “migrate” | Plan links existing feature pack; statuses may be Dual/Partial after code |

Set `Kind:` on the plan template. Do not ask if obvious from phrasing.

### 3.2 Always-on non-writes (feature & plan)

Unless the user **explicitly** asks to change them, **never write/rewrite**:

- `docs/product-vision.md`, `docs/requirements.md` (project-level)
- Existing ADRs (except **new** ADR when a decision is **locked** and user/context needs it)
- Unrelated feature packs
- Full project bootstrap / parallel knowledge tree

**Allowed writes:** plan folder **or** feature pack; hub link / nav bullet; one Surface coverage row; optional roadmap bullet; optional single new ADR; hybrid minimal hub if none exists.

Announce **non-writes** in the summary even when the user did not list them.

### 3.3 Mode: plan

**When:** Autopilot chose plan, or user said plan/epic/spike.

1. Infer name, slug, **Kind** (§3.1b), problem (from user text + any issue/PR link).  
2. Search code lightly — if something exists, note it and offer pack instead or dual-link.  
3. Write [plan-template.md](plan-template.md) → `docs/plans/<slug>/README.md`.  
4. Fill what is known; **Open questions** for the rest — do **not** invent APIs.  
5. Status: `Planned` (or `In progress` if they are actively designing).  
6. Wire hub: section **Plans** (or Features → Plans) with link + status.  
7. If `docs/roadmap.md` exists, add one bullet linking the plan (do not rewrite the whole roadmap).  
8. If implement/stubs opt-in → §3.8; else summary one-liner for Implementation bridge.  
9. Summary: path, non-writes, open questions count, Kind, how to promote later.

**Anti-bloat:** no empty `design.md` unless content exists. No product-vision suite.

### 3.4 Mode: feature (code-backed pack)

**When:** Autopilot chose feature, or user points at existing code/pack.

1. **Feature sizing:** one ModuleId / package / route family per slug. Cluster → [feature-cluster-template.md](feature-cluster-template.md) + children. Anti-pattern: one README owning three ModuleIds.  
2. Scope code (entry points, routes, permissions, tests).  
3. Write/update [feature-readme-template.md](feature-readme-template.md) under `docs/features/<slug>/` with status taxonomy + **Canonical authority** table.  
4. Status from code ([status-taxonomy.md](status-taxonomy.md)); if only planned stubs, `Planned` / `In progress`.  
5. If a plan exists at `docs/plans/<slug>/`, link it under Related; do not duplicate the whole plan.  
6. Wire hub + coverage row. Hybrid = minimal hub + feature only.  
7. Summary: pack path, code surfaces found, non-writes.

If Intent is **audit** on a feature: claims for that surface only; do not rewrite the module doc unless asked to patch.

### 3.5 Ask policy (v1.3 — minimal)

| Situation | Action |
|-----------|--------|
| Name missing (“documentá la feature”) | Ask once for name |
| Multi-module dump in one sentence | Propose split (cluster or multiple plans) once |
| Plan vs pack still ambiguous after search | Ask once |
| Everything else | **Proceed** with defaults; list assumptions in Open questions |

Do **not** ask the user to specify non-writes, folder layout, or Intent when the phrase is clearly a single new/existing feature.

### 3.6 Promote plan → feature pack

**When:** “promové el plan”, “X ya está en código”, implementation started.

Use the explicit checklist in [implementation-bridge.md](implementation-bridge.md) (Promote checklist). Short form:

1. Read `docs/plans/<slug>/` + **code inventory** for the slug (**code wins**).  
2. Create/update `docs/features/<slug>/` from **code** + plan acceptance criteria (not from stubs alone).  
3. Supersede or trim Implementation bridge stub inventory that diverged from code.  
4. Plan status → `Shipped` or `Superseded` + link to pack.  
5. Hub: feature link becomes primary; plan stays archived/historical.  
6. Coverage row → documented.  
7. Optional: scoped audit on new structural claims.

### 3.7 Layout (plans)

```text
docs/
  plans/
    <slug>/
      README.md          # plan (template; may include Implementation bridge section)
      implementation.md  # optional; only if bridge detail is large
  features/
    <slug>/
      README.md          # implementation pack (after code or promote)
```

### 3.8 Implementation bridge (v2 — Stage B, opt-in)

**When:** User asks to implement / scaffold / generate stubs, **after** Stage A plan or pack.

1. Load [implementation-bridge.md](implementation-bridge.md).  
2. Placement table: Ark layers if detected; else repo conventions; mark hypothesis/TBD.  
3. Engineering checklist from acceptance criteria.  
4. **Stubs:** write product code **only** if user opted in; mark hypotheses; status stays Planned/In progress — never Real from stubs alone.  
5. Default non-writes still apply to vision/requirements/unrelated packs; bridge does **not** unlock full-repo codegen.  
6. Announce `Implementation bridge: on` and list code files touched (if any).

**Anti-hallucination:** no Real endpoints/tables/ModuleIds without code evidence. Public surface rows TBD until code-backed.

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

1. Read hub, roadmap, architecture, features/ADRs, **and `docs/plans/`**.  
2. Clarify goals, MVP, dependencies.  
3. Write at epic vs single-feature level; prefer linking **plans** for net-new work instead of bloating roadmap prose.  
4. Net-new ADRs if decisions lock.  
5. Update hub status.  

---

## 6. Audit (project or feature)

**When:** Mode **audit** or Intent **audit**; also recommended before integrate when drift is suspected.

**Goal:** Structural reconciliation of documentation claims against **code as source of truth**. Not full NLP of every sentence.

### 6.1 Code inventory (always first)

1. **Detect stack** (§0.3) — tokens: `node-ts` | `python` | `go` | `mixed` | `unknown`.  
2. **Detect monorepo** (§0.4) — if yes, inventory per package path from **Package index** / `detect-packages.sh`.  
3. Build inventory from the **Inventory by stack** table in [skill-discovery.md](skill-discovery.md) (Polyglot stack detection).  
4. Summary of common kinds (always prefer stack-specific rows in skill-discovery):

| Kind | How to discover (examples; **stack-aware**) |
|------|-----------------------------------------------|
| Packages / apps | `package.json` workspaces · `pyproject.toml` · `go.mod` / `go.work` |
| ModuleIds / feature flags | permissions maps, enums, nav registries **if present** (often node-ts) |
| Entry / CLI | `src/index.ts` · `__main__.py` / console scripts · `cmd/*/main.go` |
| Feature modules | `src/<area>` · `src/<pkg>` · `internal/<area>` |
| HTTP routes | Only if code exists: `app/api/**`, FastAPI/Flask/Django routes, Go handlers |
| UI surfaces | app router / templates **if present** |
| Data layer | ORM schemas, migrations (names not counts) |
| Kernels / jobs | workers, scripts, `cmd/` workers |
| Tests | `*.test.ts` · `test_*.py` · `*_test.go` |

Do **not** hardcode giant endpoint tables into permanent docs; inventory is for the audit pass.  
Do **not** invent framework surfaces for a stack that is not evidenced.

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

1. **Stack detection first** (§0.3) — then **monorepo detection** (§0.4) — then **code inventory** (same as audit §6.1) using **Inventory by stack** / **Docs layout guidance by stack** in [skill-discovery.md](skill-discovery.md).  
2. Existing productive docs are **hypothesis**, not authority — sample them for vocabulary only; verify every structural claim you reuse.  
3. Produce full core set (hub + vision/requirements/architecture/roadmap/ADRs as needed) + coverage matrix + atomic features for major surfaces; **feature slug sources follow the stack table** (Python packages / Go `cmd`+`internal` / Node routes — not Node-only defaults on a Python/Go repo).  
4. **Monorepo:** root hub = **map + Package index** first; multi-package coverage with **gap** rows; full package KBs only for in-scope packages (or sandbox) — not one mega pack.  
5. **Team governance** (§11): include `docs/team/` only when owners are known (user/code); never invent people; otherwise leave ownership as gap/TBD.  
6. If user named a folder (`test/`, `docs-sandbox/`) → **Out: sandbox:path** with banners + promotion plan.  
7. Do **not** silently overwrite productive `docs/` + `CLAUDE.md` SSOT; if they insist on root from-zero on a mature monorepo, confirm once that overwrite is intended.  
8. Status tokens from taxonomy; process rules stay out of product-vision.  
9. Optional: run audit matrix against *old* docs as appendix (“what the previous docs got wrong”).  
10. Hub + `docs/` shape is **shared** across stacks; only inventory vocabulary and feature boundaries change.  

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

## 9. ArkGate bridge (v1.4)

**When:** ArkGate signals present **or** user just ran a gate / ark skill and wants docs to follow. Full procedure: [arkgate-bridge.md](arkgate-bridge.md).

### 9.1 Detect (opt-in)

| Signal | Example |
|--------|---------|
| Config | `ark.config.json` |
| Tooling | `ark-check` in package scripts / lockfile |
| Artifacts | `.ark/reports/`, `ark-report.html` |
| Skills | host `ark-*` / `/ark-check` / `/ark-loop` / `/ark-adopt` |
| Session | “gate passed”, “ark-check”, residual violations |

No signal → **no-op** (do not require Ark).

### 9.2 Post-gate sync / audit

1. Read gate outcome + optional `.ark/reports/latest.json` (sensor only).  
2. **Pass** + docs → scoped **sync** (blast radius = changed surfaces ∩ layers).  
3. **Residual violations** → claims matrix **Contradicted/Partial**; do **not** rewrite narrative to excuse broken architecture — code/contract first via Ark.  
4. Announce before write; default non-writes include app source and `ark.config.json`.  
5. Map violations / new surfaces → coverage gaps or claim rows (no invented endpoints).

### 9.3 Inventory enrich

When Ark detected during adopt/audit, extend code inventory with layer names/globs and intent prefixes from config — **do not** hardcode violation counts into permanent docs (anti-snapshot).

Announce: `ArkGate: detected | bridge: post-gate-sync | audit-enrich` when active.

---

## 10. Knowledge dashboard (v1.6)

**When:** User asks for a docs dashboard / HTML report, or optionally after audit (offer once).

1. Ensure `docs/features/`, `docs/plans/`, optional `docs/audit/claims-matrix.md` exist as they are — **do not invent** packs to fill the UI.  
2. Run package script when available:

   ```bash
   ./scripts/generate-docs-dashboard.sh [root] [out]
   # default out: docs/audit/generated/dashboard.html
   ```

3. Prefer gitignored output under `docs/audit/generated/`.  
4. Announce path; open browser only if user asks.  
5. Full rules: [knowledge-dashboard.md](knowledge-dashboard.md).

HTML is a **view**. Markdown + code remain authority (**code wins** on claims).

---

## 11. Team governance (v2.3 Slice C)

**When:** User asks for owners / team / governance / “quién es dueño” / approval notes; or from-zero when ownership is known; optional hub link on integrate if team docs already exist.

**Full procedure:** [team-governance.md](team-governance.md)

### 11.1 Create vs link

1. If `docs/team/` missing and team work is in scope → **create** from [team-owners-template.md](team-owners-template.md) and optionally [team-approval-notes-template.md](team-approval-notes-template.md).  
2. If `docs/team/` (or equivalent) exists → **link** from hub; extend owner rows; do not fork a parallel team tree.  
3. Integrate without team request → do **not** force `docs/team/`; may link existing CODEOWNERS/CLAUDE ownership if already authoritative.  
4. from-zero → include team only when owners are known; never invent people.

### 11.2 Integrate-first non-writes

Adding team docs must **not** rewrite mature product-vision, requirements, architecture, or ADRs.  
Default non-writes: product-vision, requirements, architecture, existing ADRs, unrelated feature packs.

### 11.3 Hub + monorepo

- Hub Key Links: Team → `docs/team/OWNERS.md` (and approval-notes if present) — **pointer only**, not an HR wiki.  
- Monorepo: owner rows may use package paths from Package index.  
- Approval notes: “last approved” style only; no BPM.

Announce: `Team: create|link|skip | docs/team | owners | approval-notes`.

---

## 12. Template telemetry (v2.4 Slice D)

**When:** User explicitly opts in to template-gap telemetry, or maintainers dogfood with `DOCS_TELEMETRY_OPT_IN` / opt-in file. **Default: do nothing.**

**Full procedure + privacy:** [template-telemetry.md](template-telemetry.md)

### 12.1 Rules

1. **Default off** — never enable opt-in without user consent.  
2. Record only **template / skill UX gaps** (`gap_kind` allowlist); never product source, secrets, or repo URLs.  
3. Use local ledger only:

   ```bash
   ./scripts/template-telemetry.sh record --gap-kind TEMPLATE_MISSING --template-id plan-template --opt-in
   ```

4. **Air-gapped:** with opt-in off, `record` is no-op; skill remains fully usable; **network: never**.  
5. Do not use telemetry as a substitute for audit/claims matrices.

Announce: `Telemetry: off|local-ledger | opt-in: no|yes | network: never`.

---

## Completion template (all modes)

```
Scope: …
Mode: …
Intent: integrate | audit | from-zero | n/a
Variant: …              # adopt only; arkgate-bridge when bridge sub-flow
Maturity: …
Out: root | sandbox:path
ArkGate: none | detected (<signals>)
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
