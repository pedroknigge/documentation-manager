# documentation-manager

> **This repository is the development home of the skill itself** — not an application that *uses* the skill.  
> Source of truth for the package lives under `skills/documentation-manager/` (`SKILL.md` + `references/`).  
> Installers, validation scripts, and publish docs support packaging and distribution.  
> Do not treat this folder as a product codebase to “document with” the skill in consumer mode unless you are dogfooding on purpose.

An [Agent Skill](https://agentskills.io) that keeps a **living knowledge base** next to your code:

- **`AGENTS.md`** (or `agents.md`) as the hub for humans and AI agents  
- **`docs/`** for vision, requirements, architecture, ADRs, roadmap  
- **`docs/features/<slug>/`** for **feature-level** documentation  

Works for **whole projects** and **individual features** without forcing a full bootstrap when you only need a feature pack.

Compatible with Claude Code, Grok Build, Codex, Cursor, and any host that loads `SKILL.md` skills. Install via **`npx skills`**, **`install.sh`**, or git clone.

## Install

### Option A — Skills CLI (recommended)

```bash
npx skills add pedroknigge/documentation-manager
```

Global install for all agents:

```bash
npx skills add pedroknigge/documentation-manager -g -y
```

List skills in the repo:

```bash
npx skills add pedroknigge/documentation-manager -l
```

### Option B — One-liner installer

```bash
curl -fsSL https://raw.githubusercontent.com/pedroknigge/documentation-manager/main/install.sh | bash
```

Idempotent. Updates overwrite the skill tree. Uninstall:

```bash
curl -fsSL https://raw.githubusercontent.com/pedroknigge/documentation-manager/main/install.sh | bash -s -- --uninstall
```

### Option C — Local clone

```bash
git clone https://github.com/pedroknigge/documentation-manager.git
cd documentation-manager
./install.sh
./scripts/validate-skill.sh
```

## Invoke

- Slash: `/documentation-manager`
- Natural language: *“bootstrap docs”*, *“document the checkout feature”*, *“sync docs with this PR”*, *“write an ADR for …”*

## What it does

| Scope | When | Produces |
|-------|------|----------|
| **Project** | Greenfield or “document the whole repo” | Hub + core `docs/` + ADRs |
| **Feature** | “Document billing / this module” | `docs/features/<slug>/` + hub link |
| **Hybrid** | Feature when no docs exist yet | Minimal hub + feature pack (no bloat) |

| Mode | Purpose |
|------|---------|
| **bootstrap** | New project knowledge base |
| **adopt** | Infer docs from existing code — **full** (thin) or **integrate** (mature) |
| **audit** | Code inventory + claims matrix (OK / Partial / Missing / Contradicted); code wins |
| **feature** | Document or plan one feature (atomic packs; clusters = index + children) |
| **sync** | Update only docs impacted by a change |
| **roadmap** | Plan epics / releases at the right level |

| Intent (v1.2) | When |
|---------------|------|
| **integrate** | Improve / index existing docs (default mature “mejorar”) |
| **audit** | Validate docs against code before trusting them |
| **from-zero** | Full new knowledge base (sandbox e.g. `test/` is first-class) |

**v1.2:** Intent selection, code-first audit, from-zero + sandbox first-class; still integrate-first when improving mature docs.

**Philosophy:** code is truth for *how*; `AGENTS.md` + `docs/` are truth for *what* and *why*. No auto-commit or auto-push.

## Example flows

### 1) Greenfield project

```
/documentation-manager
```

> “New SaaS for team standups. Stack TBD. Bootstrap the docs.”

Creates `AGENTS.md`, vision, requirements, architecture, roadmap, and initial ADRs.

### 2) Feature only (existing codebase)

```
/documentation-manager
```

> “Document the checkout feature in src/checkout.”

Creates `docs/features/checkout/README.md` (and design if needed), links it from the hub. Does **not** invent a full product-vision suite.

### 3) Sync after a change

> “We changed the billing webhooks API — update the docs.”

Touches only the billing feature doc and related API/architecture sections.

## Layout it encourages

```
project-root/
├── AGENTS.md
└── docs/
    ├── product-vision.md
    ├── requirements.md
    ├── architecture.md
    ├── roadmap.md
    ├── decisions/
    │   └── ADR-001-....md
    └── features/
        └── checkout/
            ├── README.md
            └── design.md
```

## Repo structure (this package)

```
skills/documentation-manager/
  SKILL.md                 # router + rules (agents load this first)
  references/              # templates + full mode procedures
install.sh
scripts/validate-skill.sh
scripts/install-smoke.sh
```

## Development

```bash
./scripts/validate-skill.sh
./scripts/install-smoke.sh
```

See [PUBLISH.md](./PUBLISH.md) to publish or update the GitHub repo.

## License

MIT — see [LICENSE](./LICENSE).
