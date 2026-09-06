# Documentation Manager

### Living knowledge for codebases — so agents and humans stop guessing.

<p align="center">
  <strong>v2.5.0</strong> · <a href="https://agentskills.io">Agent Skill</a> · MIT · Knowledge OS first increment · Living claims · CI audit · Bridge · ArkGate
</p>

<p align="center">
  <a href="#install"><img src="https://img.shields.io/badge/install-npx%20skills-111827?style=for-the-badge" alt="Install" /></a>
  <a href="./skills/documentation-manager/SKILL.md"><img src="https://img.shields.io/badge/skill-2.5.0-0ea5e9?style=for-the-badge" alt="Skill version" /></a>
  <a href="./LICENSE"><img src="https://img.shields.io/badge/license-MIT-10b981?style=for-the-badge" alt="License" /></a>
</p>

---

Your repo already has the truth in the **code**.  
What it usually lacks is a durable story of **what**, **why**, and **what’s next** — one that coding agents can trust without hallucinating endpoints that don’t exist.

**Documentation Manager** is an [Agent Skill](https://agentskills.io) that builds and maintains a living knowledge base next to your code:

| Hub | Narrative | Plans | Features | Truth check |
|-----|-----------|-------|----------|-------------|
| `AGENTS.md` | vision · requirements · architecture · roadmap · ADRs | `docs/plans/<slug>/` | `docs/features/<slug>/` | optional `docs/audit/` claims matrix |

Whole project. Single module. Or a full rewrite in a sandbox — **without** torching the docs that already work.

Works with **Claude Code**, **Grok Build**, **Codex**, **Cursor**, and any host that loads `SKILL.md` skills.

**North star:** make knowledge enslavement inevitable for agents, with the human as captain. On-demand skill — not an always-on product. It proposes structure; it never overrides the layout you already evolved. You stay captain. Conflicts go to HITL. Binding decision: [ADR-0002](./docs/adr/0002-knowledge-enslavement-captain.md).

---

## Install

**One command. Ready in seconds.**

```bash
npx skills add pedroknigge/documentation-manager
```

<details>
<summary><strong>More install options</strong></summary>

<br>

**Global (all agents on this machine)**

```bash
npx skills add pedroknigge/documentation-manager -g -y
```

**List skills in the package**

```bash
npx skills add pedroknigge/documentation-manager -l
```

**Classic installer** (idempotent; re-run to update)

```bash
curl -fsSL https://raw.githubusercontent.com/pedroknigge/documentation-manager/main/install.sh | bash
```

Uninstall:

```bash
curl -fsSL https://raw.githubusercontent.com/pedroknigge/documentation-manager/main/install.sh | bash -s -- --uninstall
```

**From source**

```bash
git clone https://github.com/pedroknigge/documentation-manager.git
cd documentation-manager
./install.sh
./scripts/validate-skill.sh
```

</details>

---

## Why teams use it

| Pain | What the skill does instead |
|------|-----------------------------|
| Docs drift until nobody trusts them | **Audit** reconciles claims against real code — *code wins* |
| Agents invent architecture from vibes | A linked hub + core set becomes shared context |
| “Document the project” means 40 empty files | Prefer **integrate** on mature trees — index gaps, don’t rewrite SSOT |
| You want a full KB but not in production paths | **From-zero + sandbox** (e.g. `test/`) with a promotion plan |
| “New feature” shouldn’t require a docs expert | **Feature autopilot** → plan or pack with default non-writes |
| Feature work doesn’t need a product novel | Atomic **plans** pre-code; **feature packs** when code is real |

**No auto-commit. No auto-push.** You stay in control of git.

---

## Three project intents. Feature work is simpler.

For **whole-project** work, the skill picks **how hard** it should write:

| | Intent | Best when you want… | Writing style |
|---|--------|---------------------|---------------|
| **1** | **integrate** | Better navigation on docs that already exist | Index · coverage · gaps · links — *no parallel vision/requirements rewrite* |
| **2** | **audit** | To know if the docs still match the code | Read-first claims matrix: `OK` · `Partial` · `Missing` · `Contradicted` |
| **3** | **from-zero** | A full knowledge base from scratch | Core set inferred from **code** (or a short greenfield interview); old docs = hypothesis only |

For a **named feature**, you don’t need Intent at all — **feature autopilot** chooses:

| | Mode | Lands in | When |
|---|------|----------|------|
| **A** | **plan** | `docs/plans/<slug>/` | New idea / epic / no solid code yet |
| **B** | **feature** | `docs/features/<slug>/` | Code exists (or pack refresh) |
| **C** | **promote** | plan → feature pack | Implementation landed |

Lifecycle modes:

`bootstrap` · `adopt` · `audit` · `plan` · `feature` · `sync` · `roadmap`

Before it writes a byte, the skill announces scope so you can course-correct:

```text
Scope · Mode · Intent · Variant · Maturity · Out · Slug
```

Default **non-writes** on plan/feature: no product-vision/requirements rewrite, no unrelated ADRs — even if you never listed them.

---

## Say it in plain language

Slash command: **`/documentation-manager`**

Or just talk — no expert prompt required:

| You say | It leans toward |
|---------|-----------------|
| *“Bootstrap docs for this greenfield SaaS.”* | bootstrap / from-zero |
| *“Nueva feature: team invitations.”* | **plan** → `docs/plans/team-invitations/` |
| *“Documentá el módulo checkout en src/checkout.”* | **feature pack** + hub link |
| *“Promové el plan de team invitations.”* | plan → `docs/features/…` |
| *“We changed billing webhooks — sync the docs.”* | surgical sync |
| *“Audit docs vs code — do we still tell the truth?”* | audit + claims matrix |
| *“Full knowledge base under `test/`, don’t touch prod docs.”* | from-zero · sandbox |
| *“Improve and index what we already have.”* | integrate (mature default) |
| *“Gate passed — sync the docs.”* / *“after ark-check”* | **ArkGate bridge** → scoped audit/sync |
| *“Implementá team invitations”* / *“generá stubs”* | plan/pack + **Implementation bridge** (stubs opt-in) |
| *“Spike: rate-limit exploration”* | plan **Kind: spike** (thin + open questions) |
| *“Generate the knowledge dashboard”* | static HTML view of docs (markdown SSOT) |
| *“This is a pnpm monorepo — index packages.”* | **Monorepo hubs** → root map + package index |
| *“Python / Go stack — don’t assume Node.”* | **Polyglot** stack detection + layout tables |
| *“Add docs/team owners for this module.”* | **Team governance** (optional OWNERS + notes) |

---

## Pair with ArkGate

**ArkGate** keeps **code** inside the architecture contract. **Documentation Manager** keeps the **narrative** honest against that code.

| | ArkGate | Documentation Manager |
|--|---------|------------------------|
| Owns | layers, gates, violations | hub, plans, features, claims matrix |
| Truth | contract + source | code wins on doc claims |
| After a change | `ark-check` / `/ark-loop` | bridge: post-gate **sync** or **audit** |

When the skill sees `ark.config.json`, `ark-check`, `.ark/`, or ark host skills, it **enriches** inventory and, after a gate, offers a scoped docs pass. **No Ark → no-op** (never required). Residual violations become claim debt — docs are not rewritten to excuse broken architecture.

Procedure: [skills/documentation-manager/references/arkgate-bridge.md](./skills/documentation-manager/references/arkgate-bridge.md)

---

## What lands in your tree

```text
project-root/
├── AGENTS.md                 ← single hub for humans + agents
└── docs/
    ├── product-vision.md
    ├── requirements.md
    ├── architecture.md
    ├── roadmap.md
    ├── audit/
    │   └── claims-matrix.md  ← when you ask for truth
    ├── plans/
    │   └── team-invitations/ ← new work before code
    │       └── README.md
    ├── team/                 ← optional (v2.3): OWNERS + approval notes
    │   ├── OWNERS.md
    │   └── approval-notes.md
    ├── decisions/
    │   └── ADR-001-….md
    └── features/
        └── checkout/
            ├── README.md
            └── design.md
```

Monorepos (v2.2): root hub stays a **map + package index**; optional hub/docs per package.  
Sandbox runs can mirror the same shape under a path like `test/` — marked **non-SSOT**, with a plan to promote later.

---

## New in 2.5 — Knowledge OS first increment (toward 100×)

| | |
|--|--|
| **Version** | **2.5.0** — first Knowledge OS slice (living claims v0 + local CI structural audit) |
| **Not a leap** | 10× already shipped at **v2.0**; this is **not** a second 10× or a full 100× OS |
| **Procedure** | [living-claims.md](./skills/documentation-manager/references/living-claims.md) |
| **CI (local/air-gapped)** | `scripts/audit-claims.sh` · example [`.github/workflows/docs-audit.yml`](./.github/workflows/docs-audit.yml) |
| **Feature pack** | [docs/features/living-claims/](./docs/features/living-claims/README.md) |
| **Plan** | [docs/plans/knowledge-os/](./docs/plans/knowledge-os/README.md) |
| **Changelog** | [CHANGELOG.md](./CHANGELOG.md) |

### Also in 2.4 — Template telemetry (Fase 2 complete)

| | |
|--|--|
| **Version** | **2.4.0** — Fase 2 Slice D (opt-in local template-gap ledger) |
| **Procedure** | [template-telemetry.md](./skills/documentation-manager/references/template-telemetry.md) |
| **CLI** | `scripts/template-telemetry.sh` — default off, network never |
| **Feature pack** | [docs/features/template-telemetry/](./docs/features/template-telemetry/README.md) |

### Also in 2.3 — Team governance

| | |
|--|--|
| **Version** | **2.3.0** — Fase 2 Slice C (`docs/team/` owners + approval notes) |
| **Procedure** | [team-governance.md](./skills/documentation-manager/references/team-governance.md) |
| **Templates** | OWNERS + approval-notes under `docs/team/` |
| **Feature pack** | [docs/features/team-governance/](./docs/features/team-governance/README.md) |

### Also in 2.2 — Monorepo hubs

| | |
|--|--|
| **Version** | **2.2.0** — Fase 2 Slice B (package index + root hub map) |
| **Procedure** | Monorepo hubs in skill-discovery |
| **Detector** | `scripts/detect-packages.sh` |
| **Feature pack** | [docs/features/monorepo-hubs/](./docs/features/monorepo-hubs/README.md) |

### Also in 2.1 — Polyglot MVP

| | |
|--|--|
| **Version** | **2.1.0** — Fase 2 Slice A (Python / Go / Node-TS stack detection) |
| **Stack tables** | Inventory + layout by stack |
| **Detector** | `scripts/detect-stack.sh` |
| **Feature pack** | [docs/features/polyglot-mvp/](./docs/features/polyglot-mvp/README.md) |

### Also in 2.0 — 10× release package

| | |
|--|--|
| **Version** | **2.0.0** — Fase 1 roadmap complete |
| **Adoption matrix** | [docs/adoption-matrix.md](./docs/adoption-matrix.md) — honest install + ArkGate pairing tracker |
| **Rolled up** | ArkGate bridge · autopilot v2 · dashboard · hardening · discovery |

### Also in 1.7 — Skill hardening

| | |
|--|--|
| **Fixtures** | `scripts/fixtures/` thin · mature · no-docs |
| **Golden modes** | `golden/autopilot-cases.tsv` anchors in SKILL/modes |
| **Version sync** | SKILL ↔ README badge ↔ AGENTS |
| **Discovery** | [skill-discovery.md](./skills/documentation-manager/references/skill-discovery.md) install/upgrade/stack hints |
| **Gate** | `validate-skill.sh` runs hardening tests; PUBLISH pre-release checklist |

```bash
./scripts/validate-skill.sh
./scripts/test-skill-hardening.sh
./scripts/install-smoke.sh
```

### Also in 1.6 — Knowledge dashboard

| | |
|--|--|
| **Static HTML** | `./scripts/generate-docs-dashboard.sh` → `docs/audit/generated/dashboard.html` |
| **SSOT** | Markdown remains authority; HTML is a **view** (gitignored by default) |
| **Offline** | Single file, no CDN |
| **Honest** | Features/plans/status from existing packs; claims only if matrix exists |

```bash
./scripts/generate-docs-dashboard.sh
# open file://…/docs/audit/generated/dashboard.html
```

### Also in 1.5 — Feature autopilot v2

| | |
|--|--|
| **Kind** | `new feature` · `spike` · `epic` · `redesign` from plain language |
| **Implementation bridge** | Placement + engineering checklist; **stubs only if you ask** |
| **Anti-hallucination** | No Real APIs from stubs; promote uses **code** inventory |
| **Ark placement** | When ArkGate is present, bridge maps dirs to contract layers |

### Also in 1.4 — ArkGate bridge

| | |
|--|--|
| **Detect** | `ark.config.json`, `ark-check`, `.ark/`, ark skills — opt-in only |
| **Post-gate** | Pass → scoped **sync**/**audit**; residual violations → Contradicted/Partial claims |
| **Sensor, not fusion** | Reads Ark artifacts; never rewrites `ark.config.json` or app source |
| **Pairing** | code change → Ark gate → Documentation Manager bridge → you commit |

### Also in 1.3 — plans + autopilot base

| | |
|--|--|
| **Plan mode** | Greenfield feature ideas → `docs/plans/<slug>/` — not a fake implementation pack, not a full bootstrap |
| **Feature autopilot** | “nueva feature X” is enough; skill picks plan vs pack and applies default **non-writes** |
| **Promote** | When code lands → `docs/features/<slug>/` + hub + coverage; plan marked Shipped/Superseded |
| **Minimal asks** | At most once (name / plan-vs-pack / multi-module split) — never “tell me what not to touch” |

```text
"nueva feature X"
        │
        ├─ no code ──► docs/plans/X/
        │
        └─ has code ─► docs/features/X/
                              ▲
                              │ promote
                        docs/plans/X/
```

### Also since 1.2

- **Intent-first routing** — integrate · audit · from-zero before project writes  
- **Code wins on conflict** — never invent modules to satisfy a stale paragraph  
- **Code-first audit** — inventory surfaces, then score every structural claim  
- **Sandbox from-zero** — full KB in a safe folder when you need a clean slate  
- **Integrate-first maturity** — respect the docs that already own a topic  

**Current package: 2.5.0** — Knowledge OS **first increment** (living claims v0 + local CI audit) toward 100×; Fase 2 Bridge remains complete at 2.4. Installer/validator baseline remains **≥ 2.0.0** (10× at v2.0), plus polyglot · monorepo · team · telemetry on 2.1–2.4, plus living-claims/CI on 2.5.

**Upgrade:** re-run `./install.sh` or `npx skills add pedroknigge/documentation-manager -y` (idempotent). See [skill-discovery.md](./skills/documentation-manager/references/skill-discovery.md) · [adoption-matrix.md](./docs/adoption-matrix.md) · [CHANGELOG.md](./CHANGELOG.md).

---

## Built for multi-agent reality

| Host | How you use it |
|------|----------------|
| Claude Code · Grok · Codex · Cursor | Load skill → slash or natural language |
| Skills CLI | `npx skills add pedroknigge/documentation-manager` |
| Classic | `install.sh` into your agent skills dirs |

Philosophy in one line:

> **Code owns *how* and whether a claim is true.  
> Docs own *what*, *why*, and *what’s next* — and never override the code.**

---

## This repository

> This folder is the **skill package** (source of truth under `skills/documentation-manager/`), not a product app that *consumes* the skill. Install it into other projects; only dogfood bootstrap here on purpose.

```text
skills/documentation-manager/
  SKILL.md                 ← agents load this first
  references/              ← modes, templates, audit, quality bar
install.sh
scripts/
  validate-skill.sh
  install-smoke.sh
  detect-stack.sh          ← polyglot (v2.1)
  detect-packages.sh       ← monorepo (v2.2)
  template-telemetry.sh    ← opt-in local ledger (v2.4)
  audit-claims.sh          ← living-claims CI (v2.5, air-gapped)
  generate-docs-dashboard.sh
```

**Developers of the skill**

```bash
./scripts/validate-skill.sh
./scripts/test-skill-hardening.sh
./scripts/install-smoke.sh
```

Publishing notes → [PUBLISH.md](./PUBLISH.md) · Behavior source → [SKILL.md](./skills/documentation-manager/SKILL.md)

---

<p align="center">
  <strong>Stop documenting for the archive.</strong><br />
  Start documenting for the agents that ship with you.
</p>

<p align="center">
  <a href="#install">Install</a> ·
  <a href="./skills/documentation-manager/SKILL.md">Skill source</a> ·
  <a href="./LICENSE">MIT License</a>
</p>
