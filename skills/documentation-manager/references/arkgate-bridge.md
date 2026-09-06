# ArkGate bridge (v1.4)

**Sensor, not fusion.** Documentation Manager reads ArkGate signals and drives **audit** / **sync**. It does **not** embed Ark’s runtime, rewrite `ark.config.json`, or invent code to match docs.

Shared axiom: **code wins** (same as Ark: a green gate over a false contract is worthless; a polished doc over missing code is debt).

## 1. Detection (opt-in)

Run at Step 0 / code inventory when mode is adopt, audit, sync, or user mentions Ark / architecture gate.

| Signal | How to detect | Confidence |
|--------|---------------|------------|
| Config | `ark.config.json` (repo root or documented path) | high |
| CLI / package | `ark-check` / `arkgate` in `package.json` scripts or `node_modules` | high |
| Snapshots | `.ark/` (e.g. `.ark/reports/latest.json`, `history/`) | high |
| HTML report | `ark-report.html` or paths under `.ark/reports/` | medium |
| Skills present | Host skills named `ark-*` / `/ark-check` / `/ark-adopt` / `/ark-loop` / `/ark-explain` / `/ark-autopilot` | medium |
| User signal | “after ark”, “gate passed”, “ark-check”, “violations” | high (session) |

**If no signal:** bridge is a **no-op**. Do not install Ark, do not mention it as required.

**Announce when active:**

```text
ArkGate: detected | signals: <list> | bridge: post-gate-sync | audit-enrich
```

## 2. Modes / triggers

| Trigger | Prefer mode | Behavior |
|---------|-------------|----------|
| User finished `/ark-check`, `/ark-loop`, gate CI, or reports pass/fail | **sync** (scoped) or **audit** | See §3 handoff |
| Adopt / audit while Ark detected | **audit** inventory enriched | §4 inventory extensions |
| “docs after ark” / “sync narrative post-gate” | **sync** or **audit** | Explicit bridge path |
| Ark skills only, no config yet | note “Ark skills present, no contract” | optional adopt hint — **do not** run full Ark onboarding |

Bridge is a **sub-flow** of audit/sync (not a replacement for Intent). Announce Mode as `audit` or `sync` with `Variant: arkgate-bridge` (or note in announce line).

## 3. Post-gate handoff

### 3.1 Inputs (read-only sensors)

Prefer machine-readable when present; fall back to user paste / skill transcript:

1. Exit / summary of `ark-check` (pass vs residual violations)
2. `.ark/reports/latest.json` if present (layers, coverage, violation counts — **do not** hardcode counts into permanent narrative docs)
3. List of touched layers/paths from the change set (`git diff`) ∩ Ark layer globs if known
4. Residual violation kinds (concentrated edges, forbidden imports) — as **doc debt** candidates only

### 3.2 Decision table

| Gate outcome | Doc action |
|--------------|------------|
| **Pass** + docs exist | Offer **scoped sync**: blast radius = changed surfaces + architecture boundaries touched |
| **Pass** + thin/missing docs | Suggest **integrate** or plan/feature for new surfaces — not full from-zero unless Intent says so |
| **Residual violations** | **Do not** rewrite architecture/docs to “match” the broken structure. Mark related claims **Contradicted** / **Partial**; recommend fixing code/contract via Ark skills first |
| **False green suspected** (user or ark-adopt language) | Prefer **audit** matrix; treat contract claims as hypothesis until code inventory agrees |
| User declines doc pass | Stop after one offer; no silent writes |

### 3.3 Writes (always announce first)

Allowed under bridge:

- `docs/audit/claims-matrix.md` (create/update rows for Ark-touched surfaces)
- Scoped feature/plan rows and hub links for **new** real surfaces
- Surgical sync of architecture/feature packs when code **and** gate agree
- Roadmap bullet only if net-new planned work appears

Default **non-writes**:

- Productive docs that are already correct (integrate-first)
- Mass rewrite of vision/requirements
- Auto-edit of `ark.config.json` or application source
- Auto-commit / auto-push

## 4. Inventory extensions (when Ark detected)

Add to code inventory (§6.1 modes) **without** dumping full layer tables into permanent docs:

| Kind | Source |
|------|--------|
| Layers / globs | `ark.config.json` `layers` (names + path patterns) |
| Forbidden edges | rules / `forbiddenGlobals` if present |
| Intent prefixes | manifest / config if present |
| Coverage hotspots | `.ark/reports/latest.json` governed vs ungoverned dirs (names, not vanity %) |

Map each **layer or high-traffic package** to:

- existing `docs/features/<slug>/` or module doc, or  
- **gap** in Surface coverage, or  
- plan under `docs/plans/` if only planned

## 5. Violation → claim mapping

| Ark-ish finding | Claims-matrix handling |
|-----------------|------------------------|
| New governed surface with no docs | Claim “documented” → **Missing** (doc debt) or coverage gap row |
| Doc claims layer X owns path Y; code/contract disagree | **Contradicted** — code/contract win; fix doc or open Ark contract work |
| Residual architecture violation on path documented as “clean” | **Partial** / **Contradicted**; note “blocked on Ark fix” in Open questions |
| Doc describes module Ark freezes as debt | **OK** if labeled debt; else **Partial** (honesty gap) |

Never invent endpoints, ModuleIds, or layers absent from code/config.

## 6. Pairing guidance (for agents)

Recommended order when both skills are available:

```text
code change
  → Ark skills / ark-check (architecture truth)
  → Documentation Manager bridge (narrative truth)
  → user commits
```

- After `/ark-explain` or a fresh HTML report: optional link from hub to `ark-report.html` / `.ark/reports/latest.html` as **external architecture view** (not a second SSOT for product vision).
- After `/ark-adopt` contract stabilizes: refresh architecture.md only if Intent integrate/audit and claims fail.

## 7. Dogfood note (origin vs host)

This file ships with the skill and is often **copied into a host repo**. Judge the **working tree**, not the origin-package story.

| Where you are | What is true |
|---------------|----------------|
| **Origin package** (`pedroknigge/documentation-manager`) | Ships Documentation Manager. That tree typically does **not** self-host ArkGate (skill package, not an app). |
| **Host / consumer** (this copy inside another repo) | If that tree **is** ArkGate — or any app with Ark signals (§1) — the bridge **does** apply. Documentation Manager is a host skill, not the app’s npm name. Do not claim “this repo does not run ArkGate.” |

Code and detection (§1) win. Do not rewrite the host’s identity to match origin-package prose.
