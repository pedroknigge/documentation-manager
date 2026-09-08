# Mode procedures

Load this file after Step 0 when you need detailed steps for the active mode.

## 0. Intent selection (v1.2)

**Intent** is orthogonal to Mode but drives writing policy:

| Intent | Default Mode | Writing policy |
|--------|--------------|----------------|
| **integrate** | adopt | Improve/index existing; **adopt evolved layout**; no parallel SSOT rewrite when mature; never force the recommended tree |
| **audit** | audit | Read-only reconciliation matrix; optional follow-on Intent |
| **from-zero** | bootstrap or adopt-full | Full knowledge base from **code** (+ user answers if greenfield); old docs = hypothesis only |
| **production-harden** | sync + scoped audit | **DoD overlay** (not a fourth write-policy). Domain-changing PRs update claims/matrix; do not drop §2 / invent §20 Sí. See [§17](#17-production-harden-dod). |

### 0.1 Infer Intent from phrases

| Phrase pattern | Intent | Out |
|----------------|--------|-----|
| “toda nueva”, “de cero”, “generá toda la documentación” | from-zero | root unless path given |
| “en test/”, “carpeta test”, “sandbox”, “sin tocar docs productivos” | from-zero (or integrate if only index) | **sandbox:path** |
| “mejorar docs”, “ordenar”, “integrar hub”, “coverage matrix” | integrate | root |
| “auditar”, “docs vs code”, “¿las docs mienten?”, “validar que exista” | audit | root (matrix may live under `docs/audit/` or sandbox) |
| “provenance”, “group-by owner”, “group-by provenance”, “quién escribió” | audit + [§6.11](#611-provenance-grouping-opt-in-report) opt-in | root (change set only) |
| “audit then fix” / “auditar y corregir” | audit → then integrate or selective patch | root |
| “production-harden”, “no volver a prototipo”, “endurecer a producción” | **production-harden** (DoD overlay on sync/audit) | root (change set only) |

If docs exist and user intent is unclear → **ask once**: integrate | audit | from-zero. Do **not** add production-harden to that fork — infer it from the phrases above.

### 0.2 Pipeline order

```text
Detect stack (Polyglot stack detection — skill-discovery.md)
  → Detect monorepo (Monorepo hubs — skill-discovery.md) / package index
  → Discover CODE surfaces first (inventory table for that stack; per package if monorepo)
  → if Intent=audit OR (docs exist AND drift suspected AND Intent≠from-zero pure skip):
        Audit / reconciliation pass (**diff-first** — §6.0; never a full-tree read by default)
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
   - `docs/product-vision.md` — product outcomes only (not process); include the **§16** Mínimo pack (problem·user·JTBD, MVP + non-goals, critical flows, 1–2 metrics, killer assumptions). **Never invent product facts** — ask, mark Inferred from code, or leave gap/TBD.
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
| product-vision | Problem, users, JTBD, promise, product outcomes — plus the rest of the [§16](#16-product-domain-minimo) Mínimo pack (or one linked authority each) |
| requirements NFR / operations / hub | Process, ownership, gates |
| architecture | Technical form, boundaries |

---

## 2. Adopt (project)

**When:** Code exists; docs missing, incomplete, drifted, or Intent **integrate**.

**Layout:** the SKILL recommended tree is a **proposal**. If `docs/` (or the hub) already evolved, **adopt that layout**. Never force templates over the captain ([ADR-0002](../../../docs/adr/0002-knowledge-enslavement-captain.md)). HITL before any reshape.

### 2.0 Detect doc maturity

| Signal | Weight |
|--------|--------|
| Hub / rich `CLAUDE.md` with hard rules | high |
| `docs/` with index + architecture or modules | high |
| Existing ADRs | high |
| Module/feature docs | medium |
| Only thin README (any case: `README.md` / `Readme.md`) | low |

| Maturity | Variant | Behavior |
|----------|---------|----------|
| **thin** | **adopt-full** | Create/complete core set from code |
| **mixed** / **mature** | **adopt-integrate** | Index + gaps; **adopt evolved layout**; no parallel full tree at productive root |

If Intent is **from-zero**, do **not** force adopt-integrate even when mature — use §7 (often sandbox).

### 2.1 Explore

1. **Stack detection** (§0.3 / [skill-discovery.md](skill-discovery.md) Polyglot stack detection)  
2. **Monorepo detection** (§0.4 / Monorepo hubs) — package list / `detect-packages.sh`  
3. Tree, **README (case-insensitive)** (`Readme.md` counts — do not report “no README”), manifests for the detected stack(s) and packages. Optional: `./scripts/survey-docs.sh --readme <root>` ([skill-discovery.md](skill-discovery.md) **Cold-start survey heuristics**).  
4. **Code surfaces first** using the **Inventory by stack** table (not Node-only assumptions); per package when monorepo  
5. Existing docs / authorities (root + package-local); **do not rewrite** mature package docs on root index-only work. If folder names or hub paths diverged from the SKILL proposal — including **flat CapCase** `docs/*.md` — **adopt them** — do not rename into the template tree.  
6. Optional quick audit sample if claims look stale. Cold-start / full-tree claim universe: `docs/` + root markdown + `.github` contributor docs; **exclude** `examples/**` unless opted in (`survey-docs.sh --claim-scope`).  

When monorepo: ensure root hub has **Package index** and multi-package **Surface coverage** rows (gap allowed).

### 2.2 Adopt-full (thin)

1. Infer architecture, capabilities, tacit decisions.  
2. Targeted questions only.  
3. Core set + hub from the **proposed** layout (thin — nothing evolved to adopt); ADRs `Accepted — inferred from code`.  
4. **Coverage matrix required**.  
5. **§2 Mínimo** ([§16](#16-product-domain-minimo)): propose the closed pack; inferred vs confirmed; never invent product facts.  
6. **Sólido states/transitions** ([§18](#18-solido-statestransitions)): propose a short table or link for core entities; never invent domain states.  
7. Atomic feature packs for key domains.  
8. Summarize inferred vs confirmed.  

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

1. Detect the **evolved layout** (hub path, `docs/` shape, existing authorities). The recommended tree is a **proposal** only. Adopt existing folders; never force templates over the captain ([ADR-0002](../../../docs/adr/0002-knowledge-enslavement-captain.md)). Tempted to reshape → **HITL**.  
2. Inventory authorities (what each doc owns).  
3. Do **not** re-create product-vision / requirements / architecture / existing ADRs unless empty or user asked.  
4. Hub: extend existing; second hub only as index.  
5. Write only: coverage matrix, entry feature packs, net-new ADRs (same numbering), thin gaps — **into the evolved tree**, not a parallel template tree.  
6. Prefer a **claims audit** first if user mentioned drift or many path claims.  
7. **Team governance** (§11): if user asked for owners/team → create or link `docs/team/`; if not asked, do not force; never rewrite product-vision to “add owners”.  
8. **§2 Mínimo** ([§16](#16-product-domain-minimo)): **map** the closed pack onto the evolved product-domain home; write gap notes — do **not** force `product-vision.md` or rewrite the captain’s vision.  
9. **Sólido states/transitions** ([§18](#18-solido-statestransitions)): **map** onto the evolved home; gap notes; never force a filename.  
10. Summary: authorities, created, **non-writes**, **layout: adopted**, gaps, **§2 Mínimo** mapped/gaps, **Sólido states/transitions** mapped/gaps, promotion if sandbox.  

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

1. Detect scheme (`0001-…`, `ADR-001-…`) in **real ADR homes** only: `docs/adr/`, `docs/adrs/`, `docs/decisions/`, `docs/architecture/decisions/`, `adr/`, `.adr/`, plus root `ADR-<n>-*.md`. Optional: `./scripts/survey-docs.sh --adrs <root>`.  
2. Do **not** glob `*adr*` (false positive: `TableHeadRenderer.tsx`). Source files are never ADRs.  
3. Continue scheme; no parallel series for the same decision.  
4. Existing decision → link only.  
5. Net-new only when filing new decisions.  

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
        → Mode: plan  → docs/plans/<github-login>/<slug>/   # new writes; §20. Adopt evolved flat trees.
  → ELSE IF code exists (or pack already exists to refresh)
        → Mode: feature → docs/features/<slug>/
  → ELSE ambiguous name only
        → ask ONCE: "plan (no code yet) or document existing code?"
  → IF implement/stubs language → Stage B Implementation bridge (§3.8) after Stage A
  → ELSE Stage A only; one-line hint for bridge in summary
```

| Signal | Mode | Out path |
|--------|------|----------|
| No code / green idea / “plan” / “epic” / “spike” | **plan** | `docs/plans/<github-login>/<slug>/README.md` (new writes; [§20](#20-plans-layout)) |
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
3. Write [plan-template.md](plan-template.md) → `docs/plans/<github-login>/<slug>/README.md` ([§20](#20-plans-layout); adopt an existing flat tree — do not force-migrate).  
4. Fill what is known so [§19](#19-cold-agent-readable) is recoverable from the file alone (intent, success criteria, non-goals, next actions); **Open questions** for the rest — do **not** invent APIs or product intent.  
5. Status: `Planned` (or `In progress` if they are actively designing).  
6. Wire hub: section **Plans** (or Features → Plans) with link + status.  
7. If `docs/roadmap.md` exists, add one bullet linking the plan (do not rewrite the whole roadmap).  
8. If implement/stubs opt-in → §3.8; else summary one-liner for Implementation bridge.  
9. Summary: path, non-writes, open questions count, Kind, how to promote later, **Cold-agent readable** (`applied` | `gap` | `HITL`).

**Anti-bloat:** no empty `design.md` unless content exists. No product-vision suite.

### 3.4 Mode: feature (code-backed pack)

**When:** Autopilot chose feature, or user points at existing code/pack.

1. **Feature sizing:** one ModuleId / package / route family per slug. Cluster → [feature-cluster-template.md](feature-cluster-template.md) + children. Anti-pattern: one README owning three ModuleIds.  
2. Scope code (entry points, routes, permissions, tests).  
3. Write/update [feature-readme-template.md](feature-readme-template.md) under `docs/features/<slug>/` with status taxonomy + **Canonical authority** table. Apply [§19](#19-cold-agent-readable).  
4. Status from code ([status-taxonomy.md](status-taxonomy.md)); if only planned stubs, `Planned` / `In progress`.  
5. If a plan exists at `docs/plans/<github-login>/<slug>/` (or an adopted `docs/plans/<slug>/`), link it under Related; do not duplicate the whole plan.  
6. Wire hub + coverage row. Hybrid = minimal hub + feature only.  
7. Summary: pack path, code surfaces found, non-writes, **Cold-agent readable** (`applied` | `gap` | `HITL`).

If Intent is **audit** on a feature: claims for that surface **intersected with the §6.0 change set**; do not walk the feature tree; do not rewrite the module doc unless asked to patch.

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

1. Read `docs/plans/<github-login>/<slug>/` (or adopted evolved path) + **code inventory** for the slug (**code wins**).  
2. Create/update `docs/features/<slug>/` from **code** + plan acceptance criteria (not from stubs alone). Apply [§19](#19-cold-agent-readable) — the pack must recover the same intent the plan had (or name the regime change).  
3. Supersede or trim Implementation bridge stub inventory that diverged from code.  
4. Plan status → `Shipped` or `Superseded` + link to pack.  
5. Hub: feature link becomes primary; **archive-on-finish** ([§20.3](#203-archive-on-finish)) — move the slug folder to `docs/plans/<github-login>/_archive/<slug>/` when possible.  
6. Coverage row → documented.  
7. Optional: scoped audit on new structural claims.  
8. Do not drop success / non-goals / next actions into chat-only notes.

### 3.7 Layout (plans)

New writes ([§20](#20-plans-layout)). Do **not** force-migrate existing `docs/plans/<slug>/` trees without HITL.

```text
docs/
  plans/
    <github-login>/
      <slug>/
        README.md          # plan index (template; may include Implementation bridge)
        implementation.md  # optional companion; stay in this folder
      _archive/
        <slug>/            # finished home (Shipped | Cancelled | Superseded | promoted)
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

1. Change set (`git diff` / description) — same **§6.0** rules.  
2. Blast radius: project docs, features, coverage rows, ADRs.  
3. Edit only impacted files.  
4. Prefer Superseded ADR notes over deletion.  
5. List file → change; flag debt without inventing pages.  
6. **Narrative comments:** on files in this change set, apply [§6.10](#610-narrative-comments-report-first) — **report** stale / redundant / snapshot / fact-vs-changed-symbol via [§6.9](#69-recommend-review-human-vs-agent). Never auto-edit comments. Never a full-tree comment pass.

If sync reveals many Contradicted claims → suggest **audit** (still **diff-first** on that change set; not a full-tree scan).

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

**Default scope: diff-first** ([ADR-0002](../../../docs/adr/0002-knowledge-enslavement-captain.md)). Inventory, claim reads, and the SKILL.md **reconciliation** pass use the **git change set** only. Never a full-tree scan unless the user explicitly opts in (`full audit`, `whole tree`, `--full-tree`). ADR-0002 **reconcile classification** of agent-written plans/MDs is [§6.8](#68-reconcile-classification-plansmds) — still read only the change set.

### 6.0 Change set (diff-first)

1. Resolve paths (first that applies):
   - User named a range / PR / `--base` → `git diff --name-only <base>...HEAD`
   - Else dirty worktree or untracked → `git diff --name-only HEAD` plus `git ls-files --others --exclude-standard`
   - Same rules, one helper: `./scripts/audit-claims.sh --list-changed [--base REF] [ROOT]`
   - Breadcrumbs in that set: `./scripts/audit-claims.sh --list-claims [--base REF] [ROOT]` (path + `id` / `parent` / `plane` / `status`; malformed → HITL stderr + exit 1; never invent)
   - Persist touched ids: `./scripts/audit-claims.sh --upsert-claims [--base REF] [ROOT]` (matrix SSOT write-back; HITL if supersede is unclear; **not** date-wins; not the CI gate)
   - Record §6.7 Haken verdicts: `./scripts/audit-claims.sh --record-haken [--base REF] [ROOT]` (Action / existing Haken column; never Verdict; HITL if escalate vs break; not the CI gate)
   - Cascade recommend (read-only): `./scripts/audit-claims.sh --cascade-recommend [--base REF] [ROOT]` (parent released in the set → for-review children already in the set + §6.9; no write; no walker)
   - Provenance report (opt-in, read-only): `./scripts/audit-claims.sh --group-by provenance [--base REF] [ROOT]` ([§6.11](#611-provenance-grouping-opt-in-report); explicit owner first; git = AS-IS buckets only; no write)
   - `./scripts/…` is shorthand: resolve the **installed skill** `scripts/` first (what `install.sh` ships), then an optional consumer-repo copy for CI. See [skill-discovery.md — Skill-runtime scripts](skill-discovery.md#skill-runtime-scripts).
2. Empty set, not a git repo, or unclear base → **HITL** (ask once: name a base, give a file list, or confirm full-tree opt-in). **Do not** fall back to reading the tree.
3. **Valid-but-huge (docs-universe escape):** the base resolved (real commit / named ref) but the change set is too large to inventory and extract claims in this pass (thousands of files, or thousands of commits vs that base). This is **not** empty/unclear (step 2) and **not** a full-tree opt-in.
   - **Announce** (required): `Audit-scope: docs-universe (change set unusable) | files: <n> | commits: <n> | base: <ref> | universe: <hub-docs|sandbox:path> | reason: huge`
   - **Remeasure** `<n>` this session — do not inherit a prior session’s or another doc’s counts: `git diff --name-only <base>...HEAD | wc -l` · `git rev-list --count <base>..HEAD`.
   - **Constrain** later steps (§6.1–§6.11) to the **docs universe** only: hub + `docs/` (or the evolved hub docs tree already adopted), or `Out: sandbox:path`. Prefer the named-base diff intersected with those paths. Do **not** walk `src/` or the rest of the repo. Do **not** treat this as `full-tree`.
   - **HITL is optional** (ask once: tighter base, a file list, or confirm this constraint). Do **not** block forever. If the captain is silent, proceed on the announced docs universe.
4. Inventory (§6.1) and claim extraction (§6.2) **only** those paths, plus a specific `anchor.path` a changed doc cites. Do not glob `docs/**` or walk `src/`. **Exception:** if step 3 applied, the path list **is** the announced docs universe (hub + `docs/` or sandbox) — still never `src/` / the repo. If the user **did** opt into full-tree / cold-start: default claim/doc universe is `docs/` + root markdown + `.github` contributor docs; **exclude** `examples/**` unless they opted those in ([skill-discovery.md](skill-discovery.md) **Cold-start survey heuristics**; `./scripts/survey-docs.sh --claim-scope`).
5. Named feature + change set → **intersect**. Empty intersection → HITL, not a feature-tree walk.
6. **Cascade pointer:** if a changed file has a breadcrumb `parent=` ([living-claims.md § Code breadcrumbs](living-claims.md#code-breadcrumbs-comment-mirror)) or a matrix row whose `id` is named as `parent` on a changed breadcrumb, **recommend review** of children ([§6.9](#69-recommend-review-human-vs-agent)) and apply [§6.7](#67-cascade-verdicts-haken) (hold / escalate / break / for-review). Do not run a cascade engine. Do not grep the repo for children.
7. **Reconcile pointer:** if the change set includes agent-written plans/MDs that share a topic with a living doc (or with each other), apply [§6.8](#68-reconcile-classification-plansmds). Do not walk `docs/**` for a second tree.
8. **Narrative-comment pointer:** if a changed file has non-`@claim` prose comments (JSDoc, block, AI TODOs that assert facts) that look stale, redundant, snapshot, or fact-vs-changed-symbol, apply [§6.10](#610-narrative-comments-report-first) and emit [§6.9](#69-recommend-review-human-vs-agent). Report only; never auto-edit. Do not walk the tree.
9. **Provenance pointer (opt-in):** if the user asked for provenance / group-by owner / `--group-by provenance`, apply [§6.11](#611-provenance-grouping-opt-in-report). Report only; never invent owner from git; never write `owner:`. Do not walk the tree.
10. Human is captain. Propose matrix updates; HITL when who-wins is unclear. When cascade / reconcile / audit / narrative comments need eyes, [§6.9](#69-recommend-review-human-vs-agent) — recommend, do not assign or merge.
11. **§2 Mínimo presence:** if a product-domain doc is already in the path list / announced docs-universe, apply [§16.5](#165-audit-presence). Do **not** walk the tree to find vision. Diff-first / docs-universe stay unchanged.
12. **Sólido states/transitions presence:** if a product-domain / domain-model doc is already in the path list / announced docs-universe, apply [§18.4](#184-audit-presence). Do **not** walk the tree to find vision/domain. Diff-first / docs-universe stay unchanged.

Announce: `Audit-scope: diff-first | files: <n> | base: <HEAD|ref|n/a>` · `Audit-scope: docs-universe (change set unusable) | files: <n> | commits: <n> | base: <ref> | universe: <hub-docs|sandbox:path> | reason: huge` · or `Audit-scope: full-tree (user opt-in)`. When provenance was asked: `Provenance: grouped | orphans: <n>`.

**Anti-snapshot (counts):** any count written into docs must carry its remeasure command beside it, or omit the number. Do not inherit a count from a prior session or another doc.

### 6.1 Code inventory (change set only)

1. Take the §6.0 path list — that **is** the inventory universe.  
2. **Detect stack** (§0.3) from **root manifests already in hand** (`package.json`, `pyproject.toml`, `go.mod`) — do not walk packages to inventory everything. Tokens: `node-ts` | `python` | `go` | `mixed` | `unknown`.  
3. Classify **only changed files** with the **Inventory by stack** table in [skill-discovery.md](skill-discovery.md).  
4. Summary of common kinds (prefer stack-specific rows; **only if the path is in the change set**):

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

From **changed docs in the §6.0 set** (and existing matrix rows whose `anchor.path` is in the set) — extract checkable claims. Do not read all of `docs/**`.

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

Use [audit-template.md](audit-template.md) (**living claims v0** columns). Prefer:

- `docs/audit/claims-matrix.md` at root, or  
- sandbox path if user asked not to touch productive docs  

Include: summary counts, severity counts, top Contradicted/Missing, recommended next Intent (`integrate` patch vs `from-zero` sandbox).

For each structural claim set:

- **Anchor path** (`anchor.path`) when path-backed  
- optional **Anchor symbol** / **Anchor hash**  
- **Severity** `critical` \| `normal` (omit → `normal`)  

Verdict enum unchanged. Full wire: [living-claims.md](living-claims.md) · [ADR-0001](../../../docs/adr/0001-living-claims-wire-format.md).

### 6.5 Standalone vs follow-on

| After audit | Action |
|-------------|--------|
| Standalone | Stop after matrix + summary |
| → integrate | Patch only Contradicted/Missing entries user prioritizes; coverage matrix |
| → selective rewrite | Rewrite only failed claim docs |
| → from-zero | Full KB (usually sandbox) treating old docs as hypothesis |

Do **not** auto-start from-zero after audit without user Intent.

### 6.6 Living claims + local CI (pointer)

After writing the matrix, remind: dashboard truth score is **advisory**; **CI / `scripts/audit-claims.sh` is the gate** (fail on **critical Contradicted**). The gate parses the **whole matrix** (do not hide existing critical Contradicted). Agent **reads** stay **diff-first** ([§6.0](#60-change-set-diff-first)); `--list-changed` / `--list-claims` / `--upsert-claims` / `--record-haken` / `--cascade-recommend` / `--group-by provenance` are not the gate. Procedure: [§13](#13-living-claims--ci-structural-audit-v25) and [living-claims.md](living-claims.md).

### 6.7 Cascade verdicts (Haken)

**Procedure for the regime. On-demand recorder (`--record-haken`) and lister (`--cascade-recommend`) exist. Not a graph walker, not a daemon.** Binding: [ADR-0002](../../../docs/adr/0002-knowledge-enslavement-captain.md) cascade row. The LLM does **not** invent the regime. **Haken** here is a comment + matrix Action note — not a persistence DB.

Breadcrumb wire is already specified ([living-claims.md § Code breadcrumbs](living-claims.md#code-breadcrumbs-comment-mirror)); do not reopen it.

Stay on the **§6.0 change set**. Do not grep the repo for children.

#### Vocabulary (closed)

These tokens are **not** [§6.3](#63-verdicts) matrix verdicts and **not** breadcrumb `status=` (`changed` / `adjusted`).

| Verdict | Meaning |
|---------|---------|
| **hold** | Child still enslaved to parent (`s≈f(q)`). Stay on the current plane. |
| **escalate** | Child no longer enslaved. Raise toward the parent / next plane. |
| **break** | Parent insufficient as order parameter. Break upward. |
| **for-review** | Parent released. Mark children downward for review against the new `q`. |

#### Enslavement test

**Haken Versklavungsprinzip:** hold if still enslaved (`s≈f(q)`); escalate or break when not.

1. From the change set only — same trigger as the §6.0 pointer: a changed breadcrumb with `parent=`, or a changed `id` that is named as `parent` on a changed breadcrumb.
2. Ask: does `s≈f(q)` still hold for that child vs its named parent?
   - **Yes** → **hold**.
   - **No** → **escalate** (no longer enslaved) or **break** (parent insufficient).
3. If the **parent released** → **for-review** downward for children visible in the set; for children not in the set, **recommend review** only ([§6.9](#69-recommend-review-human-vs-agent); do not search).
4. Ambiguous whether `s≈f(q)` holds, or escalate vs break is a tie → **HITL**. Captain decides. Do not pick a token to look decisive.

#### Apply

1. Trigger from the §6.0 pointer.
2. Propose one closed-set verdict (or HITL).
3. If the verdict needs eyes, recommend review per [§6.9](#69-recommend-review-human-vs-agent).
4. Human is captain. Do not override evolved layout. Do not auto-commit. Do not run an engine.
5. **Recorder:** `./scripts/audit-claims.sh --record-haken [--base REF] [ROOT]` applies this test on the §6.0 set and writes a captain-visible trace. **Where:** matrix **Action** (`haken=<token> parent=<id> evidence=<path:line>`), or a **Haken** column if that header already exists. **Never** write these tokens into [§6.3](#63-verdicts) Verdict. hold when `status=adjusted` and the parent is not released in the set; for-review when the parent is in the set with `status=changed`. escalate vs break, or unclear `s≈f(q)` → **HITL** (stderr; no invent). Existing Action/Haken token that disagrees → HITL (captain supersedes; not date-wins). No graph walker.
6. **Cascade recommend:** `./scripts/audit-claims.sh --cascade-recommend [--base REF] [ROOT]` lists those **for-review** recommends for children already in the set that name a released parent ([§6.9](#69-recommend-review-human-vs-agent); evidence pointers). Does not write. Children not in the set are not listed (no repo-wide `parent=` grep).

**Non-goals:** cascade graph walker · repo-wide child grep · reconcile classification ([§6.8](#68-reconcile-classification-plansmds)) · recommend-review audience ([§6.9](#69-recommend-review-human-vs-agent)) · new breadcrumb keys or planes · new verdict tokens.

### 6.8 Reconcile classification (plans/MDs)

**Procedure only** — not an auto-merge engine and not a date-wins rule. Binding: [ADR-0002](../../../docs/adr/0002-knowledge-enslavement-captain.md) reconcile row.

Stay on the **§6.0 change set** (plus the living SSOT a changed plan/MD already cites). Do not walk `docs/**` for a second tree.

Cascade verdicts stay in [§6.7](#67-cascade-verdicts-haken). Breadcrumb wire stays locked.

#### Vocabulary (closed)

These tokens are **not** [§6.3](#63-verdicts) matrix verdicts, **not** [§6.7](#67-cascade-verdicts-haken) cascade verdicts, and **not** breadcrumb `status=` (`changed` / `adjusted`).

| Class | Meaning |
|-------|---------|
| **evolution** | Same regime. The new plan/MD extends or refines the living SSOT. Patch the living doc; do not fork a second living truth. |
| **regime change** | New order. The living SSOT is no longer the regime. Mark it **Superseded**; one living SSOT remains. |
| **orphan** | No living topic authority (no parent, no canonical doc). Propose a home (link as first SSOT) or HITL. Do not invent a parallel authority. |
| **contradiction** | Two living docs assert incompatible facts on the same topic. **Forbidden to leave living.** Propose which is **Superseded**. |

**No living contradictions.** Never leave two parallel contradicting SSOTs.

#### Who wins (AS-IS vs TO-BE)

Name the **reconcile plane** first (not breadcrumb `plane=` P3–P0). Closed classes and **no living contradictions** stay. **Raw date-wins / mtime auto-win is forbidden on both planes.** Date is **evidence** for which TO-BE regime is current, not a silent winner. Do not invent a recency engine.

| Plane | What it is | Who wins |
|-------|------------|----------|
| **AS-IS** | Facts about the live system | **Code** (and matrix claims anchored to code). Docs that fight code → Contradicted/Partial; never “fix” by rewriting code identity. |
| **TO-BE** | Intent / future plans / design claims | **One living SSOT per topic.** Among many partial/evolved plans, keep one living; mark others **Superseded**. |

Domain invariants (sentences the code must preserve) use this same table — encode as `@claim` + matrix; cookbook: [living-claims.md § Domain invariants](living-claims.md#domain-invariants-dual-plane-cookbook). No third plane.

“Latest wins” for **TO-BE** means the **latest living regime after classification** (regime change → supersede old; evolution → patch living) — not “touched yesterday wins.”

1. From the change set — agent-written `docs/plans/**` and MDs that share a topic with a living doc (or with each other), or that cite a living authority. Name the plane.
2. Classify with the closed set. Tool **proposes**.
3. **Latest-by-date does not auto-win.** Date is evidence, not a verdict. Do not invent a recency rule.
4. Apply the plane winner. **AS-IS:** code / anchored matrix (do not rewrite code identity). **TO-BE:** one living SSOT. The **supersede / enslavement** verdict still maps: still enslaved to the living SSOT → **evolution**; new order → **regime change** and supersede the old; no authority → **orphan**; two living truths → **contradiction**.
5. Unclear who wins, or a tie (which doc is superseded; evolution vs regime change; which plane) → **HITL**. Captain (dev) decides. Do not pick a class to look decisive.

#### Apply

AS-IS uses [§6.3](#63-verdicts) (code wins). TO-BE uses supersede marking below. Same closed classes on both planes.

1. Trigger from the §6.0 pointer (or when this session writes a plan/MD on an existing topic).
2. Propose one closed-set class (or HITL).
3. On **regime change** or **contradiction**: mark the loser **Superseded** / **Superseded by** (existing ADR and plan status). Do not delete durable knowledge. Do not keep both living.
4. On **evolution**: edit the living SSOT; do not promote the draft as a second living authority.
5. On **orphan**: propose a single home; do not create a second SSOT for the same topic.
6. If the class needs eyes, recommend review per [§6.9](#69-recommend-review-human-vs-agent).
7. Human is captain. Never override evolved layout. Do not auto-commit. Do not run a classifier engine.
8. Living TO-BE SSOT must stay [§19](#19-cold-agent-readable) cold-agent readable. Chat-only / dual-reading living plans → **orphan** or HITL — do not keep them as the living SSOT.

**Non-goals:** date-wins rules · auto-merge / reconcile engine · graph walker · cascade verdicts (stay in §6.7) · recommend-review audience (stay in §6.9) · breadcrumb format · new class tokens.

### 6.9 Recommend review (human vs agent)

**Procedure only** — not an engine, not auto-assign, not a notification system, not auto-merge. Binding: [ADR-0002](../../../docs/adr/0002-knowledge-enslavement-captain.md) captain rule. Human is captain. The skill **proposes** that someone look; it never overrides an evolved layout or a developer decision.

Stay on the **§6.0 change set**. Do not walk the tree to find reviewers or children.

This is **not** a new verdict enum. Cascade stays in [§6.7](#67-cascade-verdicts-haken). Reconcile stays in [§6.8](#68-reconcile-classification-plansmds). Audit verdicts stay in [§6.3](#63-verdicts). Narrative-comment classes stay in [§6.10](#610-narrative-comments-report-first). **HITL** still means stop and ask the captain once.

#### When (needs eyes)

Emit a recommendation only when cascade, reconcile, audit, or a §6.10 comment report already surfaced something that needs eyes. Do **not** recommend review for **hold**, **OK**, or a clean **evolution** this session is already applying.

| Trigger | Source | Needs eyes |
|---------|--------|------------|
| **for-review** | §6.7 | Children vs the new `q` |
| **escalate** / **break** | §6.7 | Order change |
| Cascade HITL | §6.7 | Ambiguous `s≈f(q)` |
| **contradiction** / **regime change** / **orphan** | §6.8 | Living SSOT at risk |
| Reconcile HITL | §6.8 | Who-wins unclear |
| **critical** + **Contradicted** | §6.3 | Shipping a lie |
| **Unverifiable** | §6.3 | Not structural |
| Empty / unclear change set | §6.0 | Already HITL |
| Valid-but-huge change set | §6.0 | Announce `docs-universe`; HITL optional — do not block forever |
| **stale** / **redundant** / **snapshot** / **fact-vs-changed-symbol** | §6.10 | Narrative comment in the change set |
| Comment HITL | §6.10 | Class unclear |

#### Audience (closed)

| Audience | When |
|----------|------|
| **human** | HITL already required; the ask would supersede a living SSOT, change layout, or override a developer decision (`escalate`, `break`, `regime change`, `contradiction`, `orphan` home); `Unverifiable`; `critical` + `Contradicted`; children **not** in the change set (do not search — only the captain may expand the set); §6.10 class unclear or a local “why” that might still be true; audience unclear → **human** (captain-first). |
| **agent** | Follow-up is mechanical on paths **already in the set** and a closed-set class/verdict is already proposed: `for-review` children **in the set**; clear **evolution** not yet patched; **normal**-severity `Partial` / `Missing` / `Contradicted` (mark the matrix / propose a doc fix); clear §6.10 `redundant` / `snapshot` / obvious `stale` or `fact-vs-changed-symbol` (**report** a delete/fix — this session still does not auto-edit). |

Do **not** invent a third audience. Do **not** auto-assign a person or agent. Do **not** notify anyone.

#### What to include (required)

One short recommendation, friendly, captain-first:

```text
Recommend review: <human|agent>
Trigger: <cascade|reconcile|audit|comment>
Class: <§6.7 verdict | §6.8 class | §6.3 verdict | §6.10 class>
Pointers: <paths in the change set> · <path:line for §6.10> · <claim id(s)> · <parent= if visible>
Ask: <one question if human / HITL; else the mechanical next step>
```

Pointers stay inside the change set (plus a living SSOT a changed plan already cites). No new files, no child grep, no reviewer roster.

#### Apply

1. Trigger from §6.7 / §6.8 / the audit matrix / §6.10 — not a second pass over the tree.
2. Pick **human** or **agent** from the closed table. Unclear → **human**.
3. Emit the block. Do not merge, assign, or notify.
4. If audience is **human** and the case is HITL: **stop**. Wait for the captain.
5. If audience is **agent**: this session or a later one may continue on those pointers only.
6. **Lister:** `./scripts/audit-claims.sh --cascade-recommend [--base REF] [ROOT]` emits this block for §6.7 **for-review** when the parent is released in the §6.0 set and the child is already in that set. Pointers + evidence only. Does not assign, notify, merge, or write. Children not in the set are not listed (no walker).

**Non-goals:** review engine · auto-assign · notification system · auto-merge · graph walker · new CLI · new verdict/class tokens · reviewer roster / CODEOWNERS · version bump

### 6.10 Narrative comments (report-first)

**Procedure only** — not an auto-edit engine, not a full-tree comment campaign, not a CI gate. Binding: [ADR-0002](../../../docs/adr/0002-knowledge-enslavement-captain.md) captain rule. Human is captain. The skill **reports**. It never rewrites comments and never invents a second SSOT outside the matrix.

Stay on the **§6.0 change set**. Do not walk the tree for comments. Do not grep for missing narrative comments.

This path is **non-`@claim` prose** (JSDoc, block comments, AI TODOs that assert facts). `@claim` breadcrumbs stay in [living-claims.md § Code breadcrumbs](living-claims.md#code-breadcrumbs-comment-mirror). Do not reopen that wire. Do not treat free prose as a matrix row.

#### Policy (closed)

| Kind | Practice | Skill |
|------|----------|-------|
| Durable fact / contract | → `@claim` + matrix row | Already (do not reopen wire) |
| Local “why” (unverified) | May stay; if symbol/code changed and the comment asserts a **fact** → **report** | This section |
| Narrative the code already says | Prefer delete / don’t write | Flag **redundant** |
| Snapshot (counts, version stamps) | Same anti-snapshot as permanent docs — count + remeasure command, or omit the number ([§6.0](#60-change-set-diff-first)) | Flag **snapshot** |

#### Vocabulary (closed)

These tokens are **not** [§6.3](#63-verdicts) matrix verdicts, **not** [§6.7](#67-cascade-verdicts-haken) cascade verdicts, **not** [§6.8](#68-reconcile-classification-plansmds) classes, and **not** breadcrumb `status=` (`changed` / `adjusted`).

| Class | Meaning |
|-------|---------|
| **stale** | Comment asserts something the current code in this file no longer matches (name, behavior, constraint). |
| **redundant** | Narrative the adjacent code already says (restates the obvious). Prefer delete / don’t write. |
| **snapshot** | Hardcoded counts, version stamps, or inventory totals — same anti-snapshot as permanent docs. A published count without its remeasure command beside it is a snapshot ([§6.0](#60-change-set-diff-first)). |
| **fact-vs-changed-symbol** | Adjacent symbol/code in the change set changed, and the comment asserts a **fact** (not a local unverified “why”). |

Local “why” that does not assert a checkable fact may stay. Do not flag every comment.

#### Apply (audit + sync)

1. Take the §6.0 path list. Scan **only** those files for non-`@claim` prose comments (JSDoc / block / line / AI TODOs that assert facts). Skip `@claim` lines (already parsed by `--list-claims`). Prefer comments the diff touched or that sit next to a changed symbol; do not campaign every comment in a large changed file.
2. Classify report candidates with the closed set. Tool **proposes**. Unclear → **HITL**.
3. Emit one [§6.9](#69-recommend-review-human-vs-agent) block per candidate (or one block listing pointers). Required pointer shape: `path:line` + class.
4. **Never** auto-edit, auto-delete, or rewrite the comment. Captain (or a later agent, if audience=agent) decides.
5. Do **not** insert a matrix row for free prose. If the comment is actually a durable contract, **recommend** promoting it to `@claim` + matrix — do not invent the row here.
6. Human is captain. Do not auto-commit.

#### What to include

Reuse the §6.9 block (`Trigger: comment`):

```text
Recommend review: <human|agent>
Trigger: comment
Class: <stale | redundant | snapshot | fact-vs-changed-symbol>
Pointers: <path:line> · <path:line>
Ask: <one question if human / HITL; else "review then delete or rewrite — do not auto-edit">
```

**Non-goals:** auto-delete · auto-edit engine · full-tree comment scan · CI gate on narrative comments / missing comments · treating free prose as matrix rows · second SSOT · new CLI · reopening `@claim` wire · graph walker · C-055 / C-056 / C-059 · Orderfield / ArkGate ports

### 6.11 Provenance grouping (opt-in report)

**Procedure + one opt-in helper** — not a second truth-owner regime, not a second reconcile plane, not a write. Binding: [ADR-0002](../../../docs/adr/0002-knowledge-enslavement-captain.md) captain rule. Human is captain. The skill **reports**. It never copies git into `owner:` and never auto-rewrites ownership.

Stay on the **§6.0 change set**. Do not walk the tree for authors or CODEOWNERS campaigns.

This is **not** [§6.8](#68-reconcile-classification-plansmds) (plans/MDs stay there). **Not** a new [§6.3](#63-verdicts) verdict. **Missing stays Missing.**

#### Dual-plane (closed — do not invent a third)

| Plane | What | Must not |
|-------|------|----------|
| **TO-BE owner** | Explicit order parameter, first hit: frontmatter `owner:` · claim steward · CODEOWNERS | Invent a person; treat git as owner |
| **AS-IS git** | First author (`git log --diff-filter=A`) and/or last author, **only** because `--group-by provenance` (or the user asked) | Copy that identity into `owner:` |

#### Honest buckets (git only)

`human` · `bot/agent` · `unknown` — **not** raw email alone. Empty / untracked / no A-commit → `unknown`. Do not invent a bucket to look complete.

#### Action (report only)

| Finding | Action token | Write? |
|---------|--------------|--------|
| Explicit owner present | `keep` | no |
| Orphan (no owner) | `propose-owner-or-archive` | **no** — propose `owner:` or archive; captain decides |
| Matrix **Missing** | unchanged | **no** — Missing stays Missing; no greenwash |

#### Apply

1. Take the §6.0 path list. Helper: `./scripts/audit-claims.sh --group-by provenance [--base REF] [--matrix PATH] [ROOT]`.
2. Resolve **TO-BE owner** per path (frontmatter → steward → CODEOWNERS). No hit → `owner=-`.
3. Resolve **AS-IS** first/last buckets. Never promote them to owner.
4. Emit grouped stdout (owner groups first, then git bucket counts). One machine line per path:
   `provenance  path=<p>  owner=<name\|->  owner_src=<frontmatter\|steward\|codeowners\|->  first=<human\|bot/agent\|unknown>  last=…  action=<keep\|propose-owner-or-archive>`
5. **Never** write `owner:` / CODEOWNERS / matrix Owner. Never change Verdict.
6. Human is captain. First explicit hit is the order parameter — do not break a tie with git.

Announce when asked: `Provenance: grouped | orphans: <n>`.

**Non-goals:** second truth-owner SSOT · second reconcile regime · auto-write of `owner:` · inventing owner from git · new matrix verdicts · dashboard rewrite · full-tree author census · CODEOWNERS enforcement engine · CI gate on missing owner.

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
9. **§2 Mínimo** ([§16](#16-product-domain-minimo)): **propose** the closed pack into the proposed or adopted product-domain home. Never invent JTBD, metrics, flows, or assumptions.  
10. **Sólido states/transitions** ([§18](#18-solido-statestransitions)): **propose** a short table or link; never invent domain states.  
11. Optional: run audit matrix against *old* docs as appendix (“what the previous docs got wrong”).  
12. Hub + `docs/` shape is **shared** across stacks; only inventory vocabulary and feature boundaries change.  

### 7.2 Difference from adopt-integrate

| | integrate | from-zero |
|--|-----------|-----------|
| Mature parallel tree at root | forbidden | only with explicit overwrite confirm |
| Evolved layout | **adopt** (never force template) | may propose the default tree (sandbox / confirm overwrite) |
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

## 13. Living claims + CI structural audit (v2.5)

**When:** Mode/Intent **audit**; user asks for living claims, truth score, docs CI, or fail-on-Contradicted; maintainers shipping Knowledge OS first increment.

**Full procedure:** [living-claims.md](living-claims.md) · Wire ADR: [docs/adr/0001-living-claims-wire-format.md](../../../docs/adr/0001-living-claims-wire-format.md)

### 13.1 Rules

1. **Matrix-first** — extend claims matrix; no parallel claims wiki.  
2. Anchors: `anchor.path` (+ optional `symbol` / `hash`); severity `critical` \| `normal`.  
3. Verdicts unchanged; **code wins**.  
4. **Truth score** formula matches dashboard heuristic; score is **advisory**.  
5. **CI is the gate:** `critical` + `Contradicted` → non-zero from local air-gapped `scripts/audit-claims.sh` (example `.github/workflows/docs-audit.yml`). **No network** required. The gate parses the **whole matrix** (do not hide existing critical Contradicted). Agent **audit/reconcile reads** stay **diff-first** (§6.0); `--list-changed` / `--list-claims` / `--upsert-claims` / `--record-haken` / `--cascade-recommend` / `--group-by provenance` are change-set helpers, not the gate.  
6. Graceful v0: no matrix → skip/warn; missing severity → `normal`.  
7. Do not invent code to match docs; do not auto-commit.  
8. **Diff-first** — never a full-tree read by default; cascade = [§6.7](#67-cascade-verdicts-haken) (recommend review; no engine); reconcile classification = [§6.8](#68-reconcile-classification-plansmds) (no living contradictions; AS-IS code / TO-BE one living SSOT; no date-wins); recommend review = [§6.9](#69-recommend-review-human-vs-agent) (human vs agent; no assign); narrative comments = [§6.10](#610-narrative-comments-report-first) (report-first; no auto-edit); provenance grouping = [§6.11](#611-provenance-grouping-opt-in-report) (opt-in report; never invent owner from git).

Announce: `Living-claims: v0 | matrix: path|none | CI-gate: audit-claims | score: advisory | Audit-scope: diff-first`.

---

## 14. Go/no-go decision trail (v2.5.4)

**When:** User asks for go/no-go, Gate A/B, production gate, “de prototipo a producción”, or a signed production decision; or a project already has §20 / Apéndice A **Gate A/B firmado** tables.

**Home:** create or refresh **`docs/ops/go-nogo.md`** from [go-nogo-template.md](go-nogo-template.md). If the repo already evolved an equivalent ops/decision path, **adopt it** — do not fork a second trail. Optional: one ADR that **links** the signed file (the trail is the SSOT; do not hide answers only in chat).

This is an **ops / TO-BE** decision record (dual-plane). It is **not** a living-claims matrix row and **not** a code claim. **living-claims CI ≠ production go/no-go** — never auto-fill Gate answers from `audit-claims.sh` or a green claims job.

### 14.1 Write the trail

1. Find the project’s **§20** Gate A/B tables (Apéndice A **Gate A/B firmado**, or `de-prototipo-a-produccion` / equivalent). **Copy criteria verbatim.** Do not invent a parallel product checklist. No §20 in-repo → leave criterion cells as `_paste from project §20_` and **HITL** the captain; do not invent product facts.  
2. For each row, answer **Sí** / **No** / **N/A justificado** / **unanswered**.  
3. **Sí** requires a pointer to code or runnable evidence. **Never invent a Sí.** No pointer → **unanswered** or **No**, not Sí.  
4. **N/A justificado** needs one-line why (not a back-door Sí).  
5. Unclear → **HITL** (human captain). Do not guess.  
6. Write **one residual-risk sentence**. Empty → trail incomplete.

### 14.2 Decision rules (locked)

| Block | Rule |
|-------|------|
| **Gate A** (Block A) | Any **No** → Decision **cannot be Go**. |
| **Gate B** (Block B) | **No** only with **owner + due date**. Missing either → incomplete; cannot sign Go. |

- Agents may propose the tables and may record **No-Go** when Gate A has a **No**.  
- **Go** requires the **human captain** to sign. Agents never auto-sign Go.  
- **No greenwash:** do not rewrite a No into Sí to look ready.

### 14.3 Hub + non-writes

- Hub Key Links: optional pointer to `docs/ops/go-nogo.md` when the file exists.  
- Adding the trail must **not** rewrite product-vision, requirements, architecture, or ADRs.  
- Default non-writes: those narrative docs + app source + claims-matrix verdicts (do not flip claim verdicts to “justify” a Sí).

Announce: `Go-nogo: create|link|skip | path | Decision: unanswered|Go|No-Go | residual-risk: yes|no | captain: HITL|signed`.

---

## 15. Prototype → production coverage (Apéndice A)

**When:** User mentions Apéndice A, production checklist, SEV runbooks, threat model, or the honesty map. For a signed Gate A/B decision, use **§14** (do not steal it). For Intent=`production-harden` / “no volver a prototipo”, use **[§17](#17-production-harden-dod)** (do not invent a second Appendix A table).

**SSOT:** [prototype-to-production.md](prototype-to-production.md) — honesty matrix only. Do not copy the table here.

1. Load the map. For each Appendix A artifact follow **generates** | **audits** | **out-of-scope (captain)**.
2. Human is captain. Tool proposes. Never claim **generate** for audit/out rows.
3. Do not invent missing artifacts (threat model, SEV runbooks, data inventory).
4. Gate A/B *signing* is captain. The trail proposal is **§14** / [go-nogo-template.md](go-nogo-template.md) — never auto-sign Go.

Announce: `P2P-coverage: loaded | generate: … | audit: … | captain: …`

---

<a id="16-product-domain-minimo"></a>

## 16. Product domain Mínimo (v2.5.6 · Pedro norte §2)

**When:** Project-level **from-zero** / **bootstrap** / **adopt-full**; **integrate** (map + gaps); **audit** when a product-domain doc is already in the [§6.0](#60-change-set-diff-first) set or the announced docs-universe.

**Not when:** named feature/plan only (that slug’s MVP lives on the plan/pack template); **Sólido** edges/states (other increment); writing a real product’s JTBD inside **this** skill-package repo; go/no-go / Gate A/B (that is [§14](#14-gono-go-decision-trail-v254)); Appendix A honesty map (that is [§15](#15-prototype--production-coverage-apendice-a)).

Parent: Pedro norte **§2 Producto y dominio** (Mínimo). Captain: [ADR-0002](../../../docs/adr/0002-knowledge-enslavement-captain.md). **[§6.0](#60-change-set-diff-first) diff-first / docs-universe unchanged** — this section does not authorize a tree walk. **Does not reuse §14 or §15.**

### 16.1 Closed checklist (Mínimo)

Presence items — **closed**. Do not add Sólido items here.

| # | Item | What counts as present |
|---|------|------------------------|
| 1 | Problem · user · JTBD | One page (or one authority) names the problem, the user, and the job-to-be-done |
| 2 | MVP scope + non-goals | In vs later/out — **both** listed |
| 3 | Critical flows | **alta** · **login** · **valor** · **pago** · **baja/export** — each Present, Partial, Missing, or N/A-with-evidence |
| 4 | Success metrics | **1–2** metrics (not a dashboard dump) |
| 5 | Killer assumptions | Named assumptions that would kill the bet if false |

**Home (proposal):** `docs/product-vision.md` (or the evolved equivalent). Other items may live on that page or on **one** linked authority each. Never a parallel vision tree.

**Adopt evolved layout.** If the repo already has `VISION.md`, a README product section, `docs/domain.md`, CapCase vision, etc. — **that** is the home. Do **not** force `product-vision.md` over the captain.

<a id="162-presence-tokens-closed"></a>

### 16.2 Presence tokens (closed)

These tokens are **not** [§6.3](#63-verdicts) matrix verdicts. Do not insert matrix rows for product narrative unless the user asked for living claims on those sentences.

| Token | Meaning |
|-------|---------|
| **Present** | Named section or page with real content (not an empty heading) |
| **Partial** | Topic mentioned but incomplete (users without JTBD; a metric with no definition) |
| **Missing** | Not found in the in-scope docs |
| **N/A** | Only for a **critical flow** when code or the user shows that flow does not apply. Requires a one-line evidence note. **Not** a synonym for Missing. |

**Missing stays Missing.** Do not mark Missing as OK, Present, or N/A to look complete. Empty headings / leftover “TBD” after a propose pass = **Partial** (gap), not Present. **Never greenwash.**

### 16.3 Propose (from-zero / bootstrap / adopt-full)

1. Use the existing product interview (§1). Do **not** invent answers.  
2. Write the checklist into the **adopted or proposed** home. Label each fact **Confirmed** / **Inferred** (code) / **gap/TBD**.  
3. Never invent JTBD, metrics, flows, or assumptions. Unknown → gap + ask once.  
4. Critical flows: list all five. **N/A** only with evidence (e.g. no auth in a library → login N/A). Do not invent a payment flow.  
5. Thin repo, nothing evolved → proposed path `docs/product-vision.md`.  
6. Announce: `§2 Mínimo: proposed | home: <path> | gaps: <n>`

### 16.4 Propose (integrate / adopt-integrate)

1. Detect the evolved product-domain authority. **Adopt it.**  
2. Map the five items. Write **gap** notes / coverage — do **not** rewrite the captain’s vision.  
3. Do not create `docs/product-vision.md` beside an existing authority.  
4. HITL before any reshape.  
5. Announce: `§2 Mínimo: mapped | home: <evolved path> | layout: adopted | gaps: <ids>`

<a id="165-audit-presence"></a>

### 16.5 Audit presence

1. Stay on the **§6.0** path list (diff-first default; docs-universe if announced; full-tree only on user opt-in). Do **not** walk the tree to find vision.  
2. If no product-domain doc is in scope → skip §2 presence. Announce `§2 Mínimo: n/a (not in audit scope)`. Do not escalate to full-tree.  
3. If in scope → score each checklist item with [§16.2](#162-presence-tokens-closed) tokens. Flows are **five** rows.  
4. **Missing stays Missing.** Never OK. Never invent product facts to fill a hole.  
5. Emit the presence table in the audit summary. Optional: one [§6.9](#69-recommend-review-human-vs-agent) block if the captain should fill gaps (`Audience: human`). No auto-write of JTBD.  
6. Announce: `§2 Mínimo: presence | Present/Partial/Missing/N/A | home: <path|n/a>`

```text
§2 Mínimo presence
  problem-user-JTBD: Present|Partial|Missing
  mvp-non-goals:     Present|Partial|Missing
  flow/alta:         Present|Partial|Missing|N/A (<evidence>)
  flow/login:        Present|Partial|Missing|N/A (<evidence>)
  flow/valor:        Present|Partial|Missing|N/A (<evidence>)
  flow/pago:         Present|Partial|Missing|N/A (<evidence>)
  flow/baja-export:  Present|Partial|Missing|N/A (<evidence>)
  success-metrics:   Present|Partial|Missing
  killer-assumptions: Present|Partial|Missing
  home: <path|n/a>
```

### 16.6 Non-goals

- Writing a real product’s JTBD in **this** skill repo (meta)  
- Sólido edges/states (other P1/P2)  
- Greenwashing Missing as OK  
- Forcing `product-vision.md` over an evolved home  
- Reusing or rewriting [§14](#14-gono-go-decision-trail-v254) go/no-go  
- Reusing or rewriting [§15](#15-prototype--production-coverage-apendice-a) Appendix A  
- New CLI · new matrix verdicts · living-claims wire change  
- Changing §6.0 diff-first / docs-universe  

---

<a id="17-production-harden-dod"></a>

## 17. Production-harden DoD (v2.5.8 · Pedro norte §2 / §20)

**When:** User says production-harden, “no volver a prototipo”, “endurecer a producción”, or Intent=`production-harden`. Typical after a **domain-changing** PR.

**Not when:** named feature/plan only with no domain change; inventing entity state machines (propose/map/presence is [§18](#18-solido-statestransitions)); signing Gate A/B **Go** (that is [§14](#14-gono-go-decision-trail-v254)); proposing a new product-domain pack (that is [§16](#16-product-domain-minimo)).

This is a **DoD overlay**, not a fourth write-policy that replaces integrate / audit / from-zero. Default mode is **sync** + scoped **audit**. **[§6.0](#60-change-set-diff-first) stays locked** — no tree walk. Quality-checklist SSOT: [quality-checklist.md](quality-checklist.md) **Production-harden DoD**. Appendix A honesty: [prototype-to-production.md](prototype-to-production.md) Definition of Done row.

### 17.1 DoD (closed)

1. Classify Intent=`production-harden`. Stay on the §6.0 change set.  
2. If the set changes **domain** (invariants, critical flows, product-domain home, money / auth / slot rules) → **update living claims / matrix**. Do not skip. Missing / Contradicted stay honest — **no greenwash OK**.  
3. Re-check **§2** Mínimo presence if a product-domain doc is already in the set or announced docs-universe — do not walk the tree. Do not drop the pack so the product looks like a prototype again.  
4. If a product-domain / domain-model doc is already in the set, score [§18](#18-solido-statestransitions) presence. A critical entity with no transition map is **Missing**.  
5. If a **§20** / go-nogo trail is in scope → copy criteria; **never invent a Sí**; do not auto-sign Go. Point at [§14](#14-gono-go-decision-trail-v254). living-claims CI ≠ production go/no-go.  
6. Tick the quality-checklist **Production-harden DoD** rows before reporting done.  
7. **Human captain** signs. HITL when unclear. No auto-merge.

Announce: `Production-harden DoD: applied|n/a | domain-changed: yes|no | claims: updated|unchanged|gap | §2: … | §20: … | captain: HITL`

### 17.2 Non-goals

- Inventing entity states or flag soup (propose/map/presence is [§18](#18-solido-statestransitions))  
- New CLI · new matrix verdicts · living-claims wire change · new CI product  
- Orderfield / ArkGate ports  
- Inventing a Sí or auto-signing Go  
- Forcing `product-vision.md` over an evolved home  

---

<a id="18-solido-statestransitions"></a>

## 18. Sólido states/transitions (v2.5.9 · Pedro norte §2)

**When:** Project-level **from-zero** / **bootstrap** / **adopt-full**; **integrate** (map + gaps); **audit** when a product-domain / domain-model doc is already in the [§6.0](#60-change-set-diff-first) set or the announced docs-universe; Intent=`production-harden` / shipping language when those docs are already in scope.

**Not when:** named feature/plan only; inventing a real product’s entity state machine; go/no-go / Gate A/B ([§14](#14-gono-go-decision-trail-v254)); Appendix A honesty map ([§15](#15-prototype--production-coverage-apendice-a)); writing the §2 Mínimo pack ([§16](#16-product-domain-minimo)); signing a production Go ([§17](#17-production-harden-dod) is the DoD overlay — this section only scores the transition map).

Parent: Pedro norte **§2 Producto y dominio** (Sólido — estados y transiciones; Apéndice A). Captain: [ADR-0002](../../../docs/adr/0002-knowledge-enslavement-captain.md). **[§6.0](#60-change-set-diff-first) diff-first / docs-universe unchanged** — this section does not authorize a tree walk. **Does not renumber or replace §14–§17.**

### 18.1 Closed artifact (no flag soup)

One short table **or** one link to the captain’s existing authority. Do not invent a parallel state wiki. Do not invent domain states.

| Column | Meaning |
|--------|---------|
| **entity** | A core entity already named in the product-domain / domain-model doc (or confirmed by the captain / code). |
| **states** | Closed vocabulary for that entity. Names from code or the captain — never invented. |
| **allowed transitions** | From → to (and who/what may fire them), only if known. Unknown → gap. |
| **notes** | Evidence, N/A-with-evidence, or a link to the captain’s authority. |

**No flag soup:** booleans / feature flags are not states. Prefer the table or a single link.

**Home (proposal):** the adopted product-domain / domain-model / architecture authority (often `docs/architecture.md` or `docs/data-model.md`). Never a second domain tree. **Adopt evolved layout.** If the captain already has `docs/domain.md`, a README states section, etc. — **that** is the home. Do **not** force a filename.

**Critical entity:** an entity the in-scope domain doc (or code evidence in the change set) treats as core to the product bet (money, auth, lifecycle, slot). Do not invent a roster by walking the tree.

Presence tokens: reuse [§16.2](#162-presence-tokens-closed). **Missing stays Missing.** Never OK. Never greenwash.

### 18.2 Propose (from-zero / bootstrap / adopt-full)

1. List only entities already named (interview, code, or the §16 home). Do **not** invent entities or states.  
2. Write the table **or** link the captain’s existing map into the **adopted or proposed** home. Label Confirmed / Inferred (code) / gap/TBD.  
3. Unknown transitions → gap + ask once. Empty table of invented rows is worse than a gap.  
4. Thin repo, nothing evolved → propose the table on the product-domain / architecture home — do not create `docs/states.md` beside an existing authority.  
5. Announce: `Sólido states/transitions: proposed | home: <path> | entities: <n> | gaps: <n>`

### 18.3 Map (integrate / adopt-integrate)

1. Detect the evolved home for states/transitions. **Adopt it.**  
2. Map core entities → table or link. Write **gap** notes — do **not** rewrite the captain’s domain model.  
3. Do not force a filename over the captain.  
4. HITL before any reshape.  
5. Announce: `Sólido states/transitions: mapped | home: <evolved path> | layout: adopted | gaps: <ids>`

<a id="184-audit-presence"></a>

### 18.4 Audit presence

1. Stay on the **§6.0** path list. Do **not** walk the tree to find vision/domain.  
2. If no product-domain / domain-model doc is in scope → skip. Announce `Sólido states/transitions: n/a (not in audit scope)`.  
3. If in scope → for each **critical entity** named there, score the transition map with [§16.2](#162-presence-tokens-closed) tokens.  
4. **Missing stays Missing.** A heading “States” with no table or link = **Partial**. Flags-as-states = **Partial** (flag soup). Never invent states to fill a hole. Never OK.  
5. When Intent=`production-harden` or shipping language (“no volver a prototipo”) — a critical entity with no transition map is **Missing** (DoD tie: [§17](#17-production-harden-dod)).  
6. Emit the presence table. Optional [§6.9](#69-recommend-review-human-vs-agent) if the captain should fill gaps (`Audience: human`). No auto-write of state machines.  
7. Announce: `Sólido states/transitions: presence | Present/Partial/Missing/N/A | home: <path|n/a>`

```text
Sólido states/transitions presence
  home: <path|n/a>
  <entity>: Present|Partial|Missing|N/A (<evidence>)
```

### 18.5 Non-goals

- Inventing product entity state machines or flag soup  
- Forcing a filename over an evolved home  
- Greenwashing Missing as OK  
- Rewriting or renumbering [§14](#14-gono-go-decision-trail-v254)–[§17](#17-production-harden-dod)  
- New CLI · new matrix verdicts · living-claims wire change · cascade engine  
- Orderfield / ArkGate ports  
- Changing §6.0 diff-first / docs-universe  
- Walking the tree to find vision/domain docs  

---

<a id="19-cold-agent-readable"></a>

## 19. Cold-agent readable (v2.5.10)

**When:** Writing or promoting **plan** / **feature** packs ([§3](#3-feature-autopilot--plan-v13--v2--skill-v15)); **ideally every** artifact this skill writes or audits.

**Binding:** A cold agent with no prior chat must recover the **same intent** the file was created with — **no dual / ambiguous interpretation**. Complements the golden rule: if you cannot point to where it is, it does not exist.

**Not when:** inventing product intent to fill a hole; rewriting all existing consumer plans; treating chat as a second SSOT.

Parent: captain [ADR-0002](../../../docs/adr/0002-knowledge-enslavement-captain.md). Reuses [plan-template.md](plan-template.md), [feature-readme-template.md](feature-readme-template.md), [quality-checklist.md](quality-checklist.md). **Does not renumber or replace §14–§18.** No new CLI.

### 19.1 Recoverable from the file alone (closed)

Required on **plan / feature / promote**. Reuse existing template sections — do **not** invent a second SSOT.

| Recoverable | Lives in (reuse) | Fail if |
|-------------|------------------|---------|
| **Intent** | Problem / Purpose / Outcome | “as we discussed”; chat-only; two equally plausible readings |
| **Success criteria** | Acceptance criteria / Users & success | empty or only implied |
| **Non-goals** | Users & success / Out of scope | omitted when the scope could be read two ways |
| **Next actions** | Next actions / Promotion | no one can see what to do next without chat |

**Forbidden phrases:** “as we discussed”, “per the chat”, “you know what I mean”, and any pointer that exists only in conversation.

**Missing intent / dual interpretation:** mark **gap** (or HITL). Never invent product intent to fill the hole. **Missing stays Missing.** No greenwash. Human captain.

### 19.2 Plan / feature / promote

1. Fill the plan or feature template so §19.1 is recoverable without chat.  
2. Promote ([§3.6](#36-promote-plan--feature-pack) + [implementation-bridge.md](implementation-bridge.md) Promote checklist): the pack must recover the **same intent** the plan had (or name the regime change). Do not drop success / non-goals / next actions into chat.  
3. Cluster indexes: Purpose + child links enough to recover why the cluster exists; children carry the rest.

### 19.3 Writes / audits (ideally all)

Quality-checklist **Cold-agent readable**. On audit of a plan/feature (or any written artifact already in the [§6.0](#60-change-set-diff-first) set): dual interpretation or missing intent → **gap** / HITL — never OK. Do not walk the tree to find chat leftovers.

### 19.4 Reconcile / dual-plane

When a TO-BE plan is marked **living** ([§6.8](#68-reconcile-classification-plansmds)): it must stay cold-agent readable. Chat-only notes, “as we discussed” drafts, or dual-reading living plans → classify **orphan** (no recoverable authority) or HITL — do **not** keep them as the living SSOT.

Does **not** change who-wins. **AS-IS** still code. **TO-BE** still one living SSOT.

### 19.5 Non-goals

- Rewriting all existing consumer plans  
- Inventing product intent  
- New CLI · second SSOT · new matrix verdicts  
- Orderfield / ArkGate ports · P3 Ports  
- Rewriting or renumbering [§14](#14-gono-go-decision-trail-v254)–[§18](#18-solido-statestransitions)  
- Changing §6.0 diff-first / docs-universe  

---

<a id="20-plans-layout"></a>

## 20. Plans layout (creator folder + archive-on-finish · v2.5.11)

**When:** Writing a **new** plan; promoting; or any skill pass (**plan** / **promote** / **sync** / **audit**) that has plan folders in the [§6.0](#60-change-set-diff-first) change set.

**Binding:** New plans live under `docs/plans/<github-login>/<slug>/`. Every companion document for one plan stays inside that slug folder. Finished plans move to `docs/plans/<github-login>/_archive/<slug>/`.

**Not when:** inventing a GitHub login; force-migrating an existing consumer `docs/plans/<slug>/` tree without HITL; deleting history; rewriting all historical plans.

Parent: captain [ADR-0002](../../../docs/adr/0002-knowledge-enslavement-captain.md). Reuses [plan-template.md](plan-template.md) Status enum (`Planned` | `In progress` | `Shipped` | `Cancelled` | `Superseded`). Complements [§19](#19-cold-agent-readable). **Does not renumber or replace §14–§19.** No new CLI.

### 20.1 Creator path + multi-doc (new writes)

```text
docs/plans/<github-login>/<slug>/
  README.md              # index (plan-template)
  <companion>.md         # optional siblings — stay in this folder
```

| Rule | Detail |
|------|--------|
| **Creator segment** | `<github-login>` is the GitHub user who **creates** the plan (detect §20.2). Never invent. |
| **Slug folder** | kebab-case surface name. One plan ≈ one slug. |
| **Index** | `README.md` is the ordered index. Companions are siblings in the same folder (clear tree; link from the README). |
| **Forbidden (new writes)** | Loose files at `docs/plans/` root. Folders at `docs/plans/<slug>/` **without** the creator segment. |

**Existing consumer trees** at `docs/plans/<slug>/` (no creator segment): **adopt** — do **not** force-migrate without HITL. Reads and updates may stay on the evolved path until the captain asks to move.

This skill-package repo’s historical `docs/plans/<slug>/` packs stay put unless HITL asks to migrate.

### 20.2 Detect `<github-login>` (never invent)

Try in order. Stop at the first **unambiguous** GitHub login. If none → **HITL**. Never invent `unknown` / `user` / `local` / a teammate you guessed.

| Order | Source | Use when |
|-------|--------|----------|
| 1 | `gh api user -q .login` | `gh` is authenticated and prints a single login |
| 2 | Git author mapped to GitHub | Unambiguous only: `git config github.user`; or author email `login@users.noreply.github.com` / `id+login@users.noreply.github.com`; or a single-token `user.name` that `gh api users/<name> -q .login` returns as that same login |
| 3 | HITL | Anything else — ask once: “Which GitHub login owns this plan?” |

Ambiguous author (display name with spaces, multiple candidates, `gh` missing, API miss) → HITL. Do not pick the repo owner by default.

Announce `Plans creator: <login> | HITL` with the plan path.

### 20.3 Archive-on-finish

On **plan / promote / sync / audit** when a plan folder is in the change set (do **not** walk the tree to find finished plans):

| Trigger | Archive? |
|---------|----------|
| Plan **Status** is `Shipped` | **Yes** — move the whole slug folder |
| Plan **Status** is `Cancelled` | **Yes** |
| Plan **Status** is `Superseded` | **Yes** |
| Plan was **promoted** to a feature pack | **Yes** (promote already sets Shipped or Superseded) |
| Status is `Planned` or `In progress` | **No** |
| Finished plan **not** in the change set | **No** — do not hunt |

**Destination:** `docs/plans/<github-login>/_archive/<slug>/` when the creator segment is known (from the path, or §20.2).

**Legacy flat** `docs/plans/<slug>/` that is finished: do **not** invent a login to archive under. HITL: migrate under a creator `_archive/` **or** leave in place. Prefer leave if the captain does not name a login.

**Move vs stub:**

| Situation | Action |
|-----------|--------|
| Default | **Move** the whole folder; update hub / roadmap / feature-pack links to the archive path |
| Links would break **and** HITL says keep a pointer | Leave a **stub** README at the old path (Status + one link to the archive). Prefer move + update links. |
| History | **Do not delete.** Archive is the finished home. Git keeps earlier commits. |

Archive folders stay cold-agent readable ([§19](#19-cold-agent-readable)): the moved files still recover intent / success / non-goals / next actions.

### 20.4 Reads / updates

- New writes → §20.1 path.
- Updates to an existing plan → write where it already lives (creator folder, archive, or adopted flat tree).
- After a finish trigger → §20.3.
- Multi-doc: never scatter companions outside the slug folder.

### 20.5 Non-goals

- Force-migrating all consumer `docs/plans/<slug>/` trees
- Bulk-rewriting this repo’s historical plans into creator folders
- Changing `docs/features/<slug>/`
- New Status tokens · new CLI · second SSOT
- Inventing a GitHub login
- Orderfield / ArkGate ports · P3 Ports
- Rewriting or renumbering [§14](#14-gono-go-decision-trail-v254)–[§19](#19-cold-agent-readable)
- Changing §6.0 diff-first / docs-universe

---

## Completion template (all modes)

```
Scope: …
Mode: …
Intent: integrate | audit | from-zero | production-harden | n/a
Variant: …              # adopt only; arkgate-bridge when bridge sub-flow
Maturity: …
Out: root | sandbox:path
ArkGate: none | detected (<signals>)
Code inventory: yes/no
Claims matrix: path or n/a | OK/Partial/Missing/Contradicted counts
Audit-scope: diff-first | docs-universe (change set unusable) | full-tree (opt-in) | n/a
Created: …
Updated: …
Non-writes: …
ADRs: …
Coverage matrix: yes/no
Promotion plan: …       # sandbox
Open questions: …
Recommend review: n/a | human | agent  # trigger / class / pointers — §6.9
§2 Mínimo: n/a | proposed | mapped | presence   # §16; Missing ≠ OK
Production-harden DoD: n/a | applied            # §17; domain change → claims/matrix
Sólido states/transitions: n/a | proposed | mapped | presence   # §18; Missing ≠ OK
Cold-agent readable: n/a | applied | gap | HITL   # §19; plan/feature/promote required
Plans layout: n/a | creator:<login> | HITL | archived   # §20; new writes under <github-login>/<slug>/
Suggested next Intent: …
```
