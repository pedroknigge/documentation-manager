---
name: documentation-manager
description: >
  Use when bootstrapping, completing, or updating project documentation, or when
  documenting a feature, module, or epic: create or maintain AGENTS.md (or agents.md)
  plus a docs/ knowledge base, ADRs, roadmap, and docs/features/<slug>/. Triggers:
  "document this project", "document this feature", "bootstrap docs", "sync docs",
  "write ADRs", "update docs after this change", "document module", /documentation-manager.
  Mature repos: integrate-first (coverage matrix + gaps), never parallel rewrite.
license: MIT
metadata:
  author: pedroknigge
  version: "1.1.0"
---

# Documentation Manager

Living project knowledge for humans and AI agents. **Code is the source of truth for *how*.**  
**AGENTS.md + docs/** is the source of truth for *what*, *why*, architecture, decisions, and plans.

## Core rules

1. Prefer **`AGENTS.md`** as the hub. If `agents.md` already exists, use it. If only `CLAUDE.md` exists, either extend it with a docs index or add `AGENTS.md` and cross-link — do not create three competing hubs.
2. Every generated/updated doc uses relative Markdown links back to the hub and related docs.
3. Never delete durable knowledge without a reason; prefer **Superseded by** notes on ADRs.
4. Do **not** auto-commit or auto-push. Leave git to the user.
5. Write generated content in the **user's language** (or the repo's dominant language). This skill body is English for ecosystem compatibility.
6. Prefer accuracy and usefulness over volume. Core set first; optional docs on demand.
7. **Integrate-first.** If the repo already has mature docs (`docs/`, ADRs, rich agent rules), do **not** clone a second knowledge base. Prefer index + gaps + canonical links. See **adopt-integrate**.
8. **One authority per topic.** Each topic has one canonical doc; everything else links. Do not re-narrate existing modules/ADRs.
9. **Coverage matrix on adopt.** Every product surface discovered (nav, ModuleId, package) appears in a hub matrix: documented / linked / gap.
10. **Feature atomicity.** One slug ≈ one bounded context or primary ModuleId. Domain clusters are **index** packs with **child** feature packs — not a single mega-README.
11. **Stable status taxonomy.** Use labels from [references/status-taxonomy.md](references/status-taxonomy.md) (e.g. `Real`, `Dual`, `Demo`, `Partial`).
12. **Sandbox opt-in.** Write outside the project docs root only when the user asks (`test/`, worktree sandbox). Default: canonical repo paths. Sandbox hubs must banner non-SSOT + include a **promotion plan**.

## Step 0 — Detect scope and mode

**Scope** (required):

| Scope | When | Output focus |
|-------|------|--------------|
| **project** | Whole product, empty/greenfield, "bootstrap/docs for the project" | Hub + core project docs |
| **feature** | Named feature/module/epic/PR surface | `docs/features/<slug>/` + hub link |
| **hybrid** | Feature work but no hub/docs yet | Feature pack + **minimal** hub only |

Rules:
- Feature-first must **not** force a full project bootstrap.
- Project bootstrap must **not** invent empty feature folders.
- Always keep or create a **hub** (full or minimal).

**Mode** (required):

| Mode | Signals |
|------|---------|
| **bootstrap** | No hub / no docs, greenfield |
| **adopt** | Code exists; docs missing, thin, or need integration |
| **feature** | Document or plan a feature/module |
| **sync** | Diff, PR, "update docs for this change" |
| **roadmap** | Plan release, epic, or roadmap update |

For **adopt**, also detect **maturity** and **variant** (see [modes.md](references/modes.md#2-adopt-project)):

| Maturity | Variant |
|----------|---------|
| **thin** | **adopt-full** — create/complete core set |
| **mixed** / **mature** | **adopt-integrate** — index, coverage matrix, gap fill only |

If ambiguous, ask once: project vs feature, and which mode. Then load detail from [references/modes.md](references/modes.md).

**Announce before writing:**

```text
Scope: <x> | Mode: <y> | Variant: <full|integrate|n/a> | Maturity: <thin|mixed|mature|n/a> | Out: <root|sandbox:path>
```

When **integrate**, the plan-files step must list **non-writes** (authority exists → do not rewrite).

## Recommended layout

```
project-root/
├── AGENTS.md                 # hub (index + agent instructions + coverage matrix)
└── docs/
    ├── product-vision.md     # project (bootstrap / adopt-full)
    ├── requirements.md
    ├── architecture.md
    ├── roadmap.md
    ├── decisions/            # ADRs — match existing numbering scheme
    │   └── ADR-001-....md    # or 0001-....md if repo already uses that
    └── features/
        └── <feature-slug>/   # kebab-case; atomic or cluster index
            ├── README.md
            ├── design.md     # if non-trivial and no existing authority
            └── requirements.md
```

Supporting docs (`api.md`, `data-model.md`, `testing-strategy.md`, `operations.md`, `glossary.md`, `changelog.md`) only when justified by the codebase or user request — and only when no existing authority covers the topic.

### Artifact matrix

| Artifact | Bootstrap | Adopt full | Adopt integrate | Feature only | Sync |
|----------|-----------|------------|-----------------|--------------|------|
| Hub `AGENTS.md` | full create | full create/complete | **extend / index only** | link + short entry | if needed |
| product-vision / requirements | yes | yes if missing | **no** (link existing) | no (unless impact) | if impacted |
| architecture | yes | yes if missing | **short map or link** | section or link | if impacted |
| `docs/features/<slug>/` | only if named | key domains | **entry packs for gaps** | **required** | if impacted |
| ADR | foundational | inferred net-new | **net-new only; same scheme** | if decision | if decision |
| Coverage matrix in hub | optional | **required** | **required** | n/a | update rows |
| Parallel docs tree | n/a | avoid | **forbidden** | n/a | n/a |
| roadmap | yes | yes if missing | link / light refresh | feature item | if impacted |

## Workflow (all modes)

1. **Step 0** — scope + mode (+ maturity/variant for adopt) + output location.
2. **Discover** — list tree; read hub, README, package manifests, existing docs; for feature/adopt/sync also sample code and tests for the target surface.
3. **Plan files** — list paths to create/update **and** intentional non-writes (keep minimal).
4. **Load templates** from `references/` as needed (see below).
5. **Write / edit** — precise changes; cross-link; one authority per topic.
6. **Hub pass** — index links, agent instructions, coverage matrix (adopt), status tokens.
7. **Summary** — files created/updated, non-writes, open questions, promotion plan if sandbox. **No auto-commit.**

### Bootstrap (project)
Ask structured questions (problem, users, MVP, stack, constraints). Create hub first, then core docs + initial ADRs. Keep process rules out of product-vision (use NFR/ops/hub). See [modes.md](references/modes.md#1-bootstrap-project).

### Adopt (project)
Maturity probe → **adopt-full** or **adopt-integrate**. Inferred ADRs: `Accepted — inferred from code`. Never renumber or duplicate existing ADRs. See [modes.md](references/modes.md#2-adopt-project).

### Feature
Slug = kebab-case. Prefer one ModuleId per slug; clusters use [feature-cluster-template.md](references/feature-cluster-template.md) + children. Entry packs when module docs already exist. See [modes.md](references/modes.md#3-feature).

### Sync
Blast radius → only impacted files. New ADR only for durable decisions. See [modes.md](references/modes.md#4-sync).

### Roadmap
Plan at project epic vs single feature level. See [modes.md](references/modes.md#5-roadmap).

## Hub requirements

Hub must include:
- Short project overview
- Navigation links to docs (and Features list when any exist)
- **Instructions for AI agents**: read hub + relevant `docs/` before significant work; update docs after significant changes; prefer ADRs for decisions; code wins for implementation detail
- Current status / last updated line
- On **adopt**: **Surface coverage** matrix ([agents-md-template.md](references/agents-md-template.md))

Template: [agents-md-template.md](references/agents-md-template.md)

## Quality bar

Follow [quality-checklist.md](references/quality-checklist.md) before finishing.

Lightweight Diataxis hint (optional, for user-facing features):
- **Reference** — what it is / API surface
- **How-to** — task steps
- **Explanation** — why (often ADR or design.md)
- **Tutorial** — only if onboarding needs it

Do not force all four for every feature.

**Anti-snapshot:** no hardcoded table/route/endpoint counts. `api.md` = conventions + discovery; `data-model.md` = invariants + ownership + links.

## Templates & references

| File | Use |
|------|-----|
| [references/agents-md-template.md](references/agents-md-template.md) | Hub + coverage matrix |
| [references/adr-template.md](references/adr-template.md) | Every ADR (match repo numbering) |
| [references/feature-readme-template.md](references/feature-readme-template.md) | Atomic feature entry |
| [references/feature-cluster-template.md](references/feature-cluster-template.md) | Domain cluster index |
| [references/architecture-template.md](references/architecture-template.md) | Project architecture |
| [references/status-taxonomy.md](references/status-taxonomy.md) | Status tokens |
| [references/modes.md](references/modes.md) | Full mode procedures |
| [references/quality-checklist.md](references/quality-checklist.md) | Done criteria |

## When NOT to use / when to integrate instead

- Pure code implementation with no doc intent
- One-off throwaway notes outside the repo
- **Mature docs systems:** structured `docs/` + ADRs + agent rules already exist → use **adopt-integrate** (coverage matrix, gap fill, feature entry packs, net-new ADRs only). Do **not** generate a full parallel AGENTS+docs tree that rewrites product-vision, requirements, or existing decisions.
- Do not invent product-vision for internal tooling repos that only need ops/architecture notes unless the user asks for product framing
- Replacing a mature external docs site (MkDocs/Docusaurus) wholesale — integrate with it instead of forking a parallel tree

## Activation

Standalone or alongside coding/review skills. When active, proactively suggest doc updates after significant architectural or product changes — ask before large rewrites of narrative docs.
