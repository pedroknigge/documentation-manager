# documentation-manager

**Skill version:** [1.2.0](./skills/documentation-manager/SKILL.md)

> **This repository is the development home of the skill itself** — not an application that *uses* the skill.  
> Source of truth for the package lives under `skills/documentation-manager/` (`SKILL.md` + `references/`).  
> Installers, validation scripts, and publish docs support packaging and distribution.  
> Do not treat this folder as a product codebase to “document with” the skill in consumer mode unless you are dogfooding on purpose.

An [Agent Skill](https://agentskills.io) that keeps a **living knowledge base** next to your code:

- **`AGENTS.md`** (or `agents.md`) as the hub for humans and AI agents  
- **`docs/`** for vision, requirements, architecture, ADRs, roadmap  
- **`docs/features/<slug>/`** for **feature-level** documentation  
- **`docs/audit/`** (optional) for code-vs-docs **claims matrices**  

Works for **whole projects** and **individual features** without forcing a full bootstrap when you only need a feature pack.

Compatible with Claude Code, Grok Build, Codex, Cursor, and any host that loads `SKILL.md` skills. Install via **`npx skills`**, **`install.sh`**, or git clone.

## What's new in 1.2

| Capability | What it means |
|------------|----------------|
| **Intent first** | Every project-level run classifies **integrate** \| **audit** \| **from-zero** before writing |
| **Code wins** | Doc claims that fail structural checks are marked Contradicted / Missing — never invent code to match docs |
| **Code-first audit** | Inventory surfaces from code, then reconcile claims (OK / Partial / Missing / Contradicted) |
| **from-zero + sandbox** | Full new knowledge base is first-class; paths like `test/` get a non-SSOT banner + **promotion plan** |
| **Integrate-first (mature)** | Improving existing docs indexes and fills gaps — no parallel rewrite of product-vision / requirements / ADRs |

Installer and validator target **≥ 1.2.0** (requires `references/audit-template.md` and Intent/audit/from-zero concepts in `SKILL.md`).

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
- Natural language examples:
  - *“bootstrap docs”* / *“from zero”* / *“generate docs in test/”*
  - *“document the checkout feature”* / *“document this module”*
  - *“sync docs with this PR”* / *“write an ADR for …”*
  - *“audit docs”* / *“docs vs code”* / *“do our docs lie?”*
  - *“improve / index / integrate the existing docs”* (mature repos → **integrate**)

## What it does

| Scope | When | Produces |
|-------|------|----------|
| **Project** | Greenfield or “document the whole repo” | Hub + core `docs/` + ADRs (per Intent) |
| **Feature** | “Document billing / this module” | `docs/features/<slug>/` + hub link |
| **Hybrid** | Feature when no docs exist yet | Minimal hub + feature pack (no bloat) |

| Mode | Purpose |
|------|---------|
| **bootstrap** | New project knowledge base (or from-zero on thin/empty) |
| **adopt** | Infer docs from existing code — **full** (thin) or **integrate** (mature) |
| **audit** | Code inventory + claims matrix; code wins on conflict |
| **feature** | Document or plan one feature (atomic packs; clusters = index + children) |
| **sync** | Update only docs impacted by a change |
| **roadmap** | Plan epics / releases at the right level |

| Intent (v1.2) | When | Writing policy |
|---------------|------|----------------|
| **integrate** | Improve / index mature docs (default when “mejorar / ordenar”) | Index + gaps + coverage; **no** parallel SSOT rewrite at root |
| **audit** | Validate docs against code before trusting them | Claims matrix only (or hand off to integrate / patch) |
| **from-zero** | Full new knowledge base; sandbox e.g. `test/` is first-class | Full core set from **code** (+ interview if greenfield); old docs = hypothesis only |

Before writing, the skill announces:

```text
Scope: <x> | Mode: <y> | Intent: <integrate|audit|from-zero|n/a> | Variant: <full|integrate|n/a> | Maturity: <thin|mixed|mature|n/a> | Out: <root|sandbox:path>
```

**Philosophy:** code is truth for *how* and for whether a claim is true; `AGENTS.md` + `docs/` capture *what*, *why*, and plans — but **never override code** when they disagree. No auto-commit or auto-push.

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

### 4) Audit docs vs code (v1.2)

> “Audit our docs against the codebase — do paths and modules still match?”

Runs a code-first inventory and a claims matrix (`OK` / `Partial` / `Missing` / `Contradicted`). Optionally writes `docs/audit/claims-matrix.md`. Does not rewrite narrative docs unless you ask for a follow-on Intent.

### 5) From-zero in a sandbox (v1.2)

> “Generate a full knowledge base under `test/` without touching productive docs.”

**Intent: from-zero | Out: sandbox:test/** — full hub + core set under the sandbox, non-SSOT banner, and a **promotion plan** for later merge into the real tree.

### 6) Integrate mature docs (v1.2)

> “Improve and index the existing docs — don’t rewrite everything.”

**Intent: integrate** — hub coverage matrix, gap feature packs, canonical links; **non-writes** for existing product-vision / requirements / ADRs unless empty or explicitly requested.

## Layout it encourages

```
project-root/
├── AGENTS.md
└── docs/
    ├── product-vision.md      # bootstrap / from-zero / adopt-full
    ├── requirements.md
    ├── architecture.md
    ├── roadmap.md
    ├── audit/                 # Intent audit (optional)
    │   └── claims-matrix.md
    ├── decisions/
    │   └── ADR-001-....md
    └── features/
        └── checkout/
            ├── README.md
            └── design.md
```

Sandbox runs may mirror this under a path such as `test/` instead of the productive root.

## Repo structure (this package)

```
skills/documentation-manager/
  SKILL.md                      # router + rules (agents load this first)
  references/
    modes.md                    # full mode + Intent procedures
    audit-template.md           # claims matrix (v1.2)
    agents-md-template.md
    quality-checklist.md
    …                           # ADR, feature, architecture, status taxonomy
install.sh                      # classic installer (v1.2)
scripts/validate-skill.sh       # structure + ≥1.2.0 concept checks
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
