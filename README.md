# Documentation Manager

### Living knowledge for codebases — so agents and humans stop guessing.

<p align="center">
  <strong>v1.3.0</strong> · <a href="https://agentskills.io">Agent Skill</a> · MIT · Intent · Audit · Plan · From-zero
</p>

<p align="center">
  <a href="#install"><img src="https://img.shields.io/badge/install-npx%20skills-111827?style=for-the-badge" alt="Install" /></a>
  <a href="./skills/documentation-manager/SKILL.md"><img src="https://img.shields.io/badge/skill-1.3.0-0ea5e9?style=for-the-badge" alt="Skill version" /></a>
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
    │   └── team-invitations/ ← new work before code (v1.3)
    │       └── README.md
    ├── decisions/
    │   └── ADR-001-….md
    └── features/
        └── checkout/
            ├── README.md
            └── design.md
```

Sandbox runs can mirror the same shape under a path like `test/` — marked **non-SSOT**, with a plan to promote later.

---

## New in 1.3 — feature autopilot + plans

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

Installer and validator target **≥ 1.3.0**.

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
scripts/validate-skill.sh
scripts/install-smoke.sh
```

**Developers of the skill**

```bash
./scripts/validate-skill.sh
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
