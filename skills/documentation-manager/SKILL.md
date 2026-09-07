---
name: documentation-manager
description: >
  v2.5.3 — Use when bootstrapping, completing, updating, or auditing project documentation,
  or documenting a feature/module/epic: AGENTS.md + docs/, ADRs, roadmap,
  docs/features/<slug>/, docs/plans/<slug>/. Triggers: "document this project",
  "bootstrap docs", "sync docs", "audit docs", "docs vs code", "from zero",
  "new feature", "nueva feature", "promové el plan", "after ark-check",
  "arkgate bridge", "knowledge dashboard", /documentation-manager. Intents:
  integrate, audit, from-zero. Feature autopilot v2; Implementation bridge
  opt-in; ArkGate post-gate sync; dashboard HTML; polyglot + monorepo hubs;
  team governance (docs/team); living claims v0 + local CI structural audit
  (Knowledge OS first increment toward 100×). On conflict code wins.
license: MIT
metadata:
  author: pedroknigge
  version: "2.5.3"
---

# Documentation Manager

Living project knowledge for humans and AI agents. **Code is the source of truth for *how* and for whether a claim is true.**  
**AGENTS.md + docs/** capture *what*, *why*, decisions, and plans — but **never override code** when they disagree.

## Core rules

1. Prefer **`AGENTS.md`** as the hub. If `agents.md` already exists, use it. If only `CLAUDE.md` exists, either extend it with a docs index or add `AGENTS.md` and cross-link — do not create three competing hubs.
2. Every generated/updated doc uses relative Markdown links back to the hub and related docs.
3. Never delete durable knowledge without a reason; prefer **Superseded by** notes on ADRs.
4. Do **not** auto-commit or auto-push. Leave git to the user.
5. Write generated content in the **user's language** (or the repo's dominant language). This skill body is English for ecosystem compatibility.
6. Prefer accuracy and usefulness over volume. Core set first; optional docs on demand.
7. **Intent first (project-level).** Classify **Intent**: `integrate` | `audit` | `from-zero` (and optional hybrid). See Step 0. **Not required** for pure feature/plan/sync.
8. **Code wins on conflict.** Doc claims that fail structural verification are marked Contradicted/Missing — do not invent code to match docs; fix or flag the doc.
9. **Integrate-first (when Intent=integrate).** The default tree is a **proposal**. If the repo evolved its layout, **adopt it** — never force the template over the captain ([ADR-0002](../../docs/adr/0002-knowledge-enslavement-captain.md)). Mature docs → index + gaps + canonical links; no parallel rewrite of product-vision/requirements/ADRs. See **adopt-integrate**.
10. **One authority per topic.** Each topic has one canonical doc; everything else links.
11. **Coverage matrix on adopt/from-zero project.** Product surfaces (nav, ModuleId, package) appear as documented / linked / gap.
12. **Feature atomicity.** One slug ≈ one ModuleId or bounded context. Clusters = **index** + **children**.
13. **Status taxonomy.** [references/status-taxonomy.md](references/status-taxonomy.md).
14. **Sandbox opt-in / first-class from-zero.** `Out: sandbox:path` when user asks (`test/`, etc.). Sandbox hubs banner non-SSOT + **promotion plan**.
15. **Feature autopilot (v1.5 / v2).** Plain “new feature X” / “documentá X” → skill chooses **plan** vs **feature pack**, applies default **non-writes**, sets **Kind** (new feature | spike | epic | redesign). **Implementation bridge** (placement / stubs) only on opt-in (“implementá”, “stubs”, “scaffold”) — default is docs-only + one-line hint. See [modes.md §3](references/modes.md#3-feature-autopilot--plan-v13--v2--skill-v15) and [implementation-bridge.md](references/implementation-bridge.md).
16. **Plan mode (v1.3+).** Greenfield feature ideas land in **`docs/plans/<slug>/`**, not a fake implementation pack and not a full project bootstrap. Promote to `docs/features/<slug>/` when **code** is real (not stubs alone).
17. **ArkGate bridge (v1.4).** If ArkGate is detected (`ark.config.json`, `ark-check`, `.ark/`, ark skills) or the user just finished a gate, run the **bridge** sub-flow: enrich inventory from the contract; after gate pass → scoped **sync** / **audit**; residual violations → mark claims Contradicted/Partial — never rewrite docs to excuse broken architecture. No Ark → no-op. Placement hints in Implementation bridge reuse Ark layers when detected. See [arkgate-bridge.md](references/arkgate-bridge.md) and [modes.md §9](references/modes.md#9-arkgate-bridge-v14).
18. **Knowledge dashboard (v1.6).** Optional static HTML view of plans/features/claims (`scripts/generate-docs-dashboard.sh` → `docs/audit/generated/dashboard.html`). Markdown is SSOT; HTML is gitignored view-only. Offer after audit once or on “dashboard” request. See [knowledge-dashboard.md](references/knowledge-dashboard.md) and [modes.md §10](references/modes.md#10-knowledge-dashboard-v16).
19. **Skill hardening (v1.7).** Maintainers: run `validate-skill.sh` + `test-skill-hardening.sh` before release. Agents: detect install/version via [skill-discovery.md](references/skill-discovery.md); suggest reinstall when outdated (no silent auto-patch).
20. **v2.0 package.** Completes the 10× line: capabilities 1.4–1.7 plus [docs/adoption-matrix.md](../../docs/adoption-matrix.md) tracking. Baseline install floor remains **2.0.0**; polyglot **2.1.0**; monorepo **2.2.0**; team **2.3.0**; Bridge complete **2.4.0**; Knowledge OS first increment **2.5.0**; current line is **2.5.3+** (catch-up on that floor — living claims + CI audit; not a second 10×).
21. **Polyglot stack detection (v2.1 Slice A / skill 2.1.0).** On project discover (integrate / audit / from-zero / adopt), detect stack from filesystem (`package.json`, `pyproject.toml`, `go.mod`, …) via [skill-discovery.md](references/skill-discovery.md) **Polyglot stack detection** (or `scripts/detect-stack.sh`). Use **Inventory by stack** and **Docs layout guidance by stack** — do **not** assume Node/TS. Never invent ModuleIds/endpoints for frameworks without code evidence. See [modes.md §0.3](references/modes.md#03-stack-detection-polyglot-mvp--v21).
22. **Monorepo hubs (v2.2 Slice B).** Detect multi-package trees (`pnpm-workspace.yaml`, `package.json` workspaces, `go.work`, multi-package dirs) via [skill-discovery.md](references/skill-discovery.md) **Monorepo hubs** (or `scripts/detect-packages.sh`). Root hub is a **map + Package index**, not a dump; multi-package coverage marks **gap** packages; default **package non-writes** when only indexing root. See [modes.md §0.4](references/modes.md#04-monorepo-hubs-v22-slice-b).
23. **Team governance (v2.3 Slice C).** Optional `docs/team/` with **owners** + **approval notes** (last-approved style). Create vs link per [team-governance.md](references/team-governance.md); hub links Team without becoming an HR wiki; integrate-first — adding team must **not** rewrite product-vision / requirements / ADRs. No CODEOWNERS engine or BPM. See [modes.md §11](references/modes.md#11-team-governance-v23-slice-c).
24. **Living claims + CI structural audit (v2.5 / Knowledge OS first increment).** Audit matrices use **living claims v0**: `anchor.path` / optional `anchor.symbol` / optional `anchor.hash`, `severity` (`critical` \| `normal`), verdicts unchanged. Matrix-first ([audit-template.md](references/audit-template.md)); procedure [living-claims.md](references/living-claims.md); wire [ADR-0001](../../docs/adr/0001-living-claims-wire-format.md). Truth score stays **advisory** (dashboard heuristic); **local air-gapped** `scripts/audit-claims.sh` / example `docs-audit` CI is the **gate** (fail on critical Contradicted). No SaaS. Optional code-comment breadcrumbs (`id` + parent/plane + status) **mirror** the same `id` — [living-claims.md § Code breadcrumbs](references/living-claims.md#code-breadcrumbs-comment-mirror). Four on-demand loops on `audit-claims.sh`: `--list-claims` / `--upsert-claims` / `--record-haken` / `--cascade-recommend` (Haken ≠ DB/daemon; still no graph walker). **Audit / reconcile reads are diff-first** (git change set only; never a full-tree scan unless the user opts in) — [modes.md §6.0](references/modes.md#60-change-set-diff-first). See [modes.md §6](references/modes.md#6-audit-project-or-feature) / [§13](references/modes.md#13-living-claims--ci-structural-audit-v25).

## Step 0 — Detect scope, mode, and Intent

**Scope** (required):

| Scope | When | Output focus |
|-------|------|--------------|
| **project** | Whole product / “docs for the project” | Hub + project docs (per Intent) |
| **feature** | Named feature/module **with code** (or refresh pack) | `docs/features/<slug>/` + hub link |
| **plan** | Named new feature / epic **before or without** solid code | `docs/plans/<slug>/` + hub link |
| **hybrid** | Feature/plan when no hub yet | Pack or plan + minimal hub |

**Mode** (required):

| Mode | Signals |
|------|---------|
| **bootstrap** | Greenfield, no hub/docs, or Intent **from-zero** on empty/thin |
| **adopt** | Code exists; docs thin/missing or Intent **integrate** |
| **audit** | “audit docs”, “docs vs code”, drift, validate claims; **diff-first** (git change set) |
| **plan** | “new feature”, “plan”, “epic”, “vamos a construir X” without code |
| **feature** | Document one feature/module that has (or is) code |
| **sync** | Diff / PR / update docs for a change; **post-gate** when Ark just passed |
| **roadmap** | Plan release / epic list refresh |

**Intent** (required for **project-level** work only):

| Intent | User signals (examples) | Behavior |
|--------|-------------------------|----------|
| **integrate** | “mejorar docs”, “ordenar”, “sync hub”, mature improve | adopt-integrate (or full if thin); **adopt evolved layout**; optional pre-audit if drift suspected |
| **audit** | “auditar”, “¿las docs mienten?”, “docs vs code”, “validar paths” | Code inventory + claim matrix only (or then hand off) |
| **from-zero** | “toda nueva”, “de cero”, “generá docs en test/”, “full KB en carpeta X” | Full knowledge base; prefer **sandbox** if path given; code-inferred; old docs = hypothesis only |

**Inference (do not over-ask):**

- “nueva feature X” / “new feature X” / “quiero agregar X” → **Feature autopilot** (plan if no code, feature if code; Kind from phrasing). Intent = n/a
- “implementá X” / “generá stubs” / “scaffold X” → autopilot Stage A if needed + **Implementation bridge** opt-in (code only if stubs requested)
- “generá toda la documentación en `test/`” → **Intent: from-zero | Out: sandbox:test/**
- Mature repo + “mejorá / integrá / indexá” → **Intent: integrate**
- “auditar docs” / “código vs docs” → **Intent: audit**
- Ambiguous **project** work with existing `docs/` → **ask once**: integrate | audit | from-zero
- Named single surface → **never** require the user to list non-writes or choose folders
- “after ark-check” / “post-gate docs” / gate just ran + docs intent → **sync** or **audit** with **ArkGate bridge**
- “dashboard” / “docs HTML” / “knowledge report” → generate **Knowledge dashboard** ([knowledge-dashboard.md](references/knowledge-dashboard.md))
- “owners” / “quién es dueño” / “team docs” / “approval notes” / “docs/team” → **Team governance** ([team-governance.md](references/team-governance.md); modes §11)
- “living claims” / “truth score” / “docs CI” / “fail on Contradicted” → **Living claims** + local CI gate ([living-claims.md](references/living-claims.md); modes §13)

**Maturity** (when relevant): thin | mixed | mature — see [modes.md](references/modes.md#2-adopt-project).

If scope/mode still ambiguous after inference, ask once. Load procedures from [references/modes.md](references/modes.md).

**Announce before writing:**

```text
Scope: <x> | Mode: <y> | Intent: <integrate|audit|from-zero|n/a> | Variant: <full|integrate|arkgate-bridge|n/a> | Maturity: <…|n/a> | Out: <root|sandbox:path> | Stack: <node-ts|python|go|mixed|unknown|n/a> | Monorepo: <yes|no|n/a> | ArkGate: <none|detected> | Slug: <slug|n/a>
```

When **integrate**, list **non-writes** (include package non-writes when monorepo root-index only) and whether layout was **adopted** (evolved) or **proposed** (thin / from-zero). When **audit**, list matrix path, **Audit-scope** (`diff-first` default, `docs-universe` if the change set was valid-but-unusable, or `full-tree` if the user opted in), change-set size, and top contradictions. When **from-zero** + sandbox, include **promotion plan**. When **plan** or **feature**, list path + **default non-writes**. When **ArkGate bridge**, list signals and post-gate sync vs audit-enrich. When project-level, include **Stack** and **Monorepo** from discovery.

## Recommended layout (proposal)

This tree is a **proposal** (bootstrap / from-zero / adopt-full on thin docs). If the repo already evolved a different layout, **adopt it**. Never force this tree over the captain ([ADR-0002](../../docs/adr/0002-knowledge-enslavement-captain.md); [modes.md §2](references/modes.md#2-adopt-project)).

```
project-root/
├── AGENTS.md
└── docs/
    ├── product-vision.md      # bootstrap / from-zero / adopt-full
    ├── requirements.md
    ├── architecture.md
    ├── roadmap.md
    ├── team/                  # v2.3 team governance (optional)
    │   ├── OWNERS.md
    │   └── approval-notes.md
    ├── audit/                 # Intent audit (optional)
    │   └── claims-matrix.md   # living claims v0 columns
    ├── adr/                   # package / project ADRs (optional)
    ├── plans/<slug>/          # v1.3 plan mode (pre-code / epic)
    │   └── README.md
    ├── decisions/
    └── features/<slug>/       # code-backed feature packs
```

Supporting docs only when justified (except **from-zero**, which may create a full minimal core set).

### Artifact matrix (summary)

| Artifact | from-zero / bootstrap | integrate (mature) | audit | **plan** | feature | sync |
|----------|----------------------|--------------------|-------|----------|---------|------|
| Hub | create | extend / index | update status optional | link Plans | link | if needed |
| Core narrative docs | yes | **no rewrite** | no (read only) | **no** | **no** | if impact |
| Coverage matrix | yes | **required** | part of inventory | row optional | row | update |
| Claims matrix | optional pre | recommended if drift | **required** | n/a | scoped if audit | if drift |
| **Plans** `docs/plans/` | n/a | n/a | n/a | **required** | link if exists | if impact |
| Feature packs | key domains | gaps / entries | no (unless asked) | no (until promote) | **required** | if impact |
| **Team** `docs/team/` | if owners known | create/link if asked | no | n/a | n/a | if impact |
| Parallel full tree | sandbox ok | **forbidden** at root | n/a | n/a | n/a | n/a |

## Workflow (all modes)

1. **Step 0** — scope, mode, **Intent** (if project), maturity/variant, Out, slug; detect **ArkGate** signals when relevant; detect **Stack** and **Monorepo** for project work ([skill-discovery.md](references/skill-discovery.md) Polyglot + Monorepo hubs).
2. **Discover code first** — stack-aware inventory; if monorepo, **Package index** + per-package inventory; tree, manifests, entry points, sample tests. Then docs (if any): **case-insensitive README** (`Readme.md` counts); **real ADR homes** only (never `*adr*` globs); cold-start claim/doc scope is `docs/` + root + `.github` and **excludes** `examples/**` unless opted in ([skill-discovery.md](references/skill-discovery.md) Cold-start survey heuristics). For named features, search that surface first. If Ark detected, enrich inventory per [arkgate-bridge.md](references/arkgate-bridge.md). If mode/Intent is **audit** or this is the **reconciliation** pass: **diff-first** ([modes.md §6.0](references/modes.md#60-change-set-diff-first)) — change set only; do not walk the tree.
3. If **audit** or docs exist and Intent is integrate/from-zero with suspected drift: run **reconciliation** on the **git change set only** ([modes.md § Audit](references/modes.md#6-audit-project), [audit-template.md](references/audit-template.md)). Post-gate → bridge handoff ([modes.md §9](references/modes.md#9-arkgate-bridge-v14)).
4. **Plan files** — creates/updates **and** non-writes (defaults for feature/plan).
5. **Load templates** → write/edit → hub pass.
6. **Summary** — Intent/mode, files, non-writes, matrix stats, ArkGate note, promotion notes. **No auto-commit.**

### Bootstrap / from-zero
Greenfield interview **or** code archaeology for brownfield from-zero. Full core set + hub. Sandbox if Out says so. See [modes.md](references/modes.md#1-bootstrap-project) and [§ from-zero](references/modes.md#7-from-zero).

### Adopt / integrate
Maturity → adopt-full or adopt-integrate. Default layout is a **proposal**; evolved layout wins — adopt it, do not reshape the tree. See [modes.md §2](references/modes.md#2-adopt-project).

### Audit
**Diff-first:** change set from `git diff` / changed files (or `audit-claims.sh --list-changed`). Parse `@claim` breadcrumbs with `--list-claims` (same set only; HITL if malformed; do not invent ids); persist / record / cascade-recommend on demand with `--upsert-claims` / `--record-haken` / `--cascade-recommend` (not a daemon; see [living-claims.md](references/living-claims.md) + [modes.md §6.7](references/modes.md#67-cascade-verdicts-haken)). Never a full-tree read by default. Valid-but-huge set → announce and constrain to the docs universe ([modes.md §6.0](references/modes.md#60-change-set-diff-first)); never a silent full-repo walk. Then structural claims → **living-claims** matrix (anchors + severity) → report. If a parent breadcrumb would require children, apply [modes.md §6.7](references/modes.md#67-cascade-verdicts-haken) (recommend review; no engine). Agent-written plans/MDs in the set: classify per [modes.md §6.8](references/modes.md#68-reconcile-classification-plansmds) (evolution / regime change / orphan / contradiction). **No living contradictions.** **AS-IS** code wins; **TO-BE** one living SSOT (date does not auto-win on either plane). When cascade / reconcile / audit / narrative comments need eyes, recommend review to a **human** or **agent** ([modes.md §6.9](references/modes.md#69-recommend-review-human-vs-agent)) — pointers only; no assign, notify, or merge. Non-`@claim` prose comments in the set that look stale/redundant/snapshot or assert a fact after a symbol change: **report** via [modes.md §6.10](references/modes.md#610-narrative-comments-report-first) — never auto-edit. **Code wins.** CI gate separate from dashboard score. See [modes.md §6.0](references/modes.md#60-change-set-diff-first), [§6](references/modes.md#6-audit-project-or-feature), [§13](references/modes.md#13-living-claims--ci-structural-audit-v25), [living-claims.md](references/living-claims.md).

### Plan / Feature (autopilot v2)
Named surface → **plan** (`docs/plans/<slug>/`) if no code / planning language; **feature** (`docs/features/<slug>/`) if code-backed. Kind spike/epic/redesign when signaled. Default non-writes always. Optional **Implementation bridge** on implement/stubs language. Promote plan → pack when **code** is real. See [modes.md §3](references/modes.md#3-feature-autopilot--plan-v13--v2--skill-v15) and [implementation-bridge.md](references/implementation-bridge.md).

### Sync / Roadmap
Blast-radius sync; report stale/redundant comments in the change set ([modes.md §6.10](references/modes.md#610-narrative-comments-report-first)); never auto-edit. Roadmap links plans for net-new work. See modes §4–5.

### ArkGate bridge (v1.4)
Detect Ark → post-gate **sync**/**audit** or inventory enrich; residual violations become claim debt, not narrative rewrites. See [arkgate-bridge.md](references/arkgate-bridge.md) and modes §9.

### Knowledge dashboard (v1.6)
Static HTML from existing docs only (`generate-docs-dashboard.sh`). View-only; markdown SSOT. See [knowledge-dashboard.md](references/knowledge-dashboard.md) and modes §10.

### Team governance (v2.3)
Optional `docs/team/` owners + approval notes; create vs link; integrate-first. See [team-governance.md](references/team-governance.md) and modes §11.

### Living claims + CI audit (v2.5)
Matrix-first living claims; local `audit-claims.sh` / example docs-audit GHA; score advisory. See [living-claims.md](references/living-claims.md) and modes §13.

## Hub requirements

- Overview, nav links, agent instructions (read docs; update after significant work; ADRs; **code wins**), status line.
- Link **Plans** (`docs/plans/`) and **Features** (`docs/features/`) when present.
- Link **Team** (`docs/team/OWNERS.md`) when team docs exist — pointer only, not an HR wiki.
- Adopt / from-zero project: **Surface coverage** matrix (multi-package rows when monorepo).
- Monorepo: **Package index** on root hub (map, not dump).
- After audit: link to claims matrix if written.

Template: [agents-md-template.md](references/agents-md-template.md)

## Quality bar

Follow [quality-checklist.md](references/quality-checklist.md).

**Anti-snapshot:** no hardcoded table/route/endpoint counts.

## Templates & references

| File | Use |
|------|-----|
| [references/agents-md-template.md](references/agents-md-template.md) | Hub + coverage |
| [references/adr-template.md](references/adr-template.md) | ADRs |
| [references/plan-template.md](references/plan-template.md) | **Plan mode** (`docs/plans/<slug>/`) |
| [references/implementation-bridge.md](references/implementation-bridge.md) | **Implementation bridge** (Stage B, stubs opt-in) |
| [references/feature-readme-template.md](references/feature-readme-template.md) | Feature entry |
| [references/feature-cluster-template.md](references/feature-cluster-template.md) | Cluster index |
| [references/architecture-template.md](references/architecture-template.md) | Architecture |
| [references/status-taxonomy.md](references/status-taxonomy.md) | Status tokens |
| [references/audit-template.md](references/audit-template.md) | Claims matrix + living-claims columns |
| [references/living-claims.md](references/living-claims.md) | **Living claims v0** (anchors, severity, truth score vs CI) |
| [references/modes.md](references/modes.md) | Full procedures |
| [references/arkgate-bridge.md](references/arkgate-bridge.md) | **ArkGate bridge** (detect, post-gate, violation→claim) |
| [references/knowledge-dashboard.md](references/knowledge-dashboard.md) | **Knowledge dashboard** (static HTML view; score advisory) |
| [references/skill-discovery.md](references/skill-discovery.md) | **Discovery / upgrade** + **Polyglot** + **Monorepo hubs** + **Cold-start survey heuristics** |
| [references/team-governance.md](references/team-governance.md) | **Team governance** (create/link, non-writes) |
| [references/team-owners-template.md](references/team-owners-template.md) | Consumer `docs/team/OWNERS.md` |
| [references/team-approval-notes-template.md](references/team-approval-notes-template.md) | Consumer `docs/team/approval-notes.md` |
| [references/quality-checklist.md](references/quality-checklist.md) | Done criteria |

## When NOT to use / defaults

- Pure code with no doc intent
- Throwaway notes outside the repo
- **Silent overwrite** of productive SSOT without Intent from-zero or explicit user order
- **Silent structure rewrite** of an evolved layout to match the recommended tree (captain decides; HITL)
- Mature improve without audit request → **integrate** (not full parallel tree)
- Replacing MkDocs/Docusaurus wholesale — integrate with it
- **New feature request** → do **not** run full project from-zero; use plan/feature autopilot

## Activation

Standalone or with coding skills (including **ArkGate** / `ark-*` when present). Suggest doc updates after significant architecture/product changes; after a gate pass, offer bridge sync/audit once. Ask before large narrative rewrites unless Intent is from-zero or audit-driven patch.

After shipping a coded feature that only had a plan, suggest **promote plan → feature pack**.
