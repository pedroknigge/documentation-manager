# Documentation Manager

### Living knowledge for codebases — so agents and humans stop guessing.

<p align="center">
  <strong>v2.5.0</strong> · <a href="https://agentskills.io">Agent Skill</a> · MIT
</p>

<p align="center">
  <a href="#install"><img src="https://img.shields.io/badge/install-npx%20skills-111827?style=for-the-badge" alt="Install" /></a>
  <a href="./skills/documentation-manager/SKILL.md"><img src="https://img.shields.io/badge/skill-2.5.0-0ea5e9?style=for-the-badge" alt="Skill version" /></a>
  <a href="./LICENSE"><img src="https://img.shields.io/badge/license-MIT-10b981?style=for-the-badge" alt="License" /></a>
</p>

---

Your repo already has the truth in the **code**.  
What it usually lacks is a durable story of **what**, **why**, and **what’s next** — one that coding agents can trust without hallucinating endpoints that don’t exist.

**Documentation Manager** is an [Agent Skill](https://agentskills.io) that builds and maintains a living knowledge base next to your code. **On-demand** — not an always-on product.

<a id="north-star"></a>

> **Make knowledge enslavement inevitable for agents, with the human as captain.**

| | Why this shape |
|--|--|
| **Enslavement** | Claims stay bound to code and parent knowledge. Agents stop inventing architecture from vibes. |
| **Diff-first** | Audit and reconcile **reads** default to the **git change set**. The merge **CI gate** still parses the **whole** claims matrix (existing critical Contradicted cannot hide). |
| **Captain** | The skill **proposes**. It never overrides the layout you already evolved. No auto-commit. Conflicts go to you (HITL). |

Binding decision: [ADR-0002](./docs/adr/0002-knowledge-enslavement-captain.md). Audit procedure: [modes.md §6.0](./skills/documentation-manager/references/modes.md#60-change-set-diff-first). CI example (whole-matrix gate): [`.github/workflows/docs-audit.yml`](./.github/workflows/docs-audit.yml).

| Hub | Narrative | Plans | Features | Truth check |
|-----|-----------|-------|----------|-------------|
| `AGENTS.md` | vision · requirements · architecture · roadmap · ADRs | `docs/plans/<slug>/` | `docs/features/<slug>/` | optional `docs/audit/` claims matrix |

Whole project. Single module. Or a full rewrite in a sandbox — **without** torching the docs that already work.

Works with **Claude Code**, **Grok Build**, **Codex**, **Cursor**, and any host that loads `SKILL.md` skills.

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

**No auto-commit. No auto-push.** You stay captain of git.

---

## How it writes (when you ask)

For **whole-project** work, the skill picks **how hard** it should write:

| | Intent | Best when you want… | Writing style |
|---|--------|---------------------|---------------|
| **1** | **integrate** | Better navigation on docs that already exist | Index · coverage · gaps · links — *no parallel vision/requirements rewrite* |
| **2** | **audit** | To know if the docs still match the **change set** | Diff-first claims matrix: `OK` · `Partial` · `Missing` · `Contradicted` |
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

Slash command: **`/documentation-manager`**. Or just talk:

<details>
<summary><strong>Plain-language examples</strong></summary>

| You say | It leans toward |
|---------|-----------------|
| *“Bootstrap docs for this greenfield SaaS.”* | bootstrap / from-zero |
| *“Nueva feature: team invitations.”* | **plan** → `docs/plans/team-invitations/` |
| *“Documentá el módulo checkout en src/checkout.”* | **feature pack** + hub link |
| *“Promové el plan de team invitations.”* | plan → `docs/features/…` |
| *“We changed billing webhooks — sync the docs.”* | surgical sync |
| *“Audit docs vs code — do we still tell the truth?”* | audit + claims matrix (**diff-first**) |
| *“Full knowledge base under `test/`, don’t touch prod docs.”* | from-zero · sandbox |
| *“Improve and index what we already have.”* | integrate (mature default) |
| *“Gate passed — sync the docs.”* / *“after ark-check”* | **ArkGate bridge** → scoped audit/sync |
| *“Implementá team invitations”* / *“generá stubs”* | plan/pack + **Implementation bridge** (stubs opt-in) |
| *“Spike: rate-limit exploration”* | plan **Kind: spike** (thin + open questions) |
| *“Generate the knowledge dashboard”* | static HTML view of docs (markdown SSOT) |
| *“This is a pnpm monorepo — index packages.”* | **Monorepo hubs** → root map + package index |
| *“Python / Go stack — don’t assume Node.”* | **Polyglot** stack detection + layout tables |
| *“Add docs/team owners for this module.”* | **Team governance** (optional OWNERS + notes) |

</details>

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
  survey-docs.sh           ← finds Readme.md, real ADRs only, skips examples unless you ask
  audit-claims.sh          ← living-claims CI + --list-changed / --list-claims (v2.5, air-gapped)
  generate-docs-dashboard.sh
```

**Developers of the skill**

```bash
./scripts/validate-skill.sh
./scripts/test-skill-hardening.sh
./scripts/install-smoke.sh
```

Publishing notes → [PUBLISH.md](./PUBLISH.md) · Behavior source → [SKILL.md](./skills/documentation-manager/SKILL.md)

Philosophy in one line:

> **Code owns *how* and whether a claim is true.  
> Docs own *what*, *why*, and *what’s next* — and never override the code.**

---

## History

Version notes, shipped packs, and epics live **off** this page:

| | |
|--|--|
| **Releases** | [CHANGELOG.md](./CHANGELOG.md) |
| **Shipped packs** | [AGENTS.md](./AGENTS.md#features-shipped-skill-behavior) |
| **Roadmap / plans** | [docs/roadmap.md](./docs/roadmap.md) · [docs/plans/](./docs/plans/) |
| **Adoption** | [docs/adoption-matrix.md](./docs/adoption-matrix.md) |
| **Upgrade** | re-run `./install.sh` or `npx skills add pedroknigge/documentation-manager -y` (idempotent) · [skill-discovery.md](./skills/documentation-manager/references/skill-discovery.md) |

---

<p align="center">
  <strong>Stop documenting for the archive.</strong><br />
  Start documenting for the agents that ship with you.
</p>

<p align="center">
  <a href="#install">Install</a> ·
  <a href="#north-star">North star</a> ·
  <a href="./docs/adr/0002-knowledge-enslavement-captain.md">ADR-0002</a> ·
  <a href="./skills/documentation-manager/SKILL.md">Skill source</a> ·
  <a href="./LICENSE">MIT License</a>
</p>
