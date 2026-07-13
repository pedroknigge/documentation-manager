---
name: documentation-manager
description: >
  Use when bootstrapping, completing, or updating project documentation, or when
  documenting a feature, module, or epic: create or maintain AGENTS.md (or agents.md)
  plus a docs/ knowledge base, ADRs, roadmap, and docs/features/<slug>/. Triggers:
  "document this project", "document this feature", "bootstrap docs", "sync docs",
  "write ADRs", "update docs after this change", "document module", /documentation-manager.
license: MIT
metadata:
  author: pedroknigge
  version: "1.0.0"
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
| **adopt** | Code exists; docs missing or thin |
| **feature** | Document or plan a feature/module |
| **sync** | Diff, PR, "update docs for this change" |
| **roadmap** | Plan release, epic, or roadmap update |

If ambiguous, ask once: project vs feature, and which mode. Then load detail from [references/modes.md](references/modes.md).

Announce: `Scope: <x> | Mode: <y>` before writing files.

## Recommended layout

```
project-root/
├── AGENTS.md                 # hub (index + agent instructions)
└── docs/
    ├── product-vision.md     # project
    ├── requirements.md       # project
    ├── architecture.md       # project
    ├── roadmap.md
    ├── decisions/            # ADRs (global)
    │   └── ADR-001-....md
    └── features/
        └── <feature-slug>/   # kebab-case
            ├── README.md     # feature entry (required)
            ├── design.md     # if non-trivial
            └── requirements.md  # if acceptance criteria need space
```

Supporting docs (`api.md`, `data-model.md`, `testing-strategy.md`, `operations.md`, `glossary.md`, `changelog.md`) only when justified by the codebase or user request.

### Artifact matrix

| Artifact | Project bootstrap | Feature only | Sync |
|----------|-------------------|--------------|------|
| Hub `AGENTS.md` | full | link + short entry | update if needed |
| product-vision / requirements | yes | no (unless impact) | if impacted |
| architecture | yes | section or link | if impacted |
| `docs/features/<slug>/` | only if features named | **required** | if impacted |
| ADR | foundational decisions | only real decisions | if decision made |
| roadmap | yes | feature item | if impacted |

## Workflow (all modes)

1. **Step 0** — scope + mode.
2. **Discover** — list tree; read hub, README, package manifests, existing docs; for feature/adopt/sync also sample code and tests for the target surface.
3. **Plan files** — list paths to create/update (keep minimal).
4. **Load templates** from `references/` as needed (see below).
5. **Write / edit** — precise changes; cross-link.
6. **Hub pass** — ensure index links and agent instructions exist.
7. **Summary** — files created/updated, open questions, next steps. **No auto-commit.**

Quick mode summaries:

### Bootstrap (project)
Ask structured questions (problem, users, MVP, stack, constraints). Create hub first, then core docs + initial ADRs for major choices. See [modes.md](references/modes.md#1-bootstrap-project).

### Adopt (project)
Code archaeology → infer architecture and tacit decisions → confirm gaps with short questions → fill core docs; mark inferred ADRs `Accepted — inferred from code`. See [modes.md](references/modes.md#2-adopt-project).

### Feature
Slug = kebab-case name. Research code paths/tests/API for that feature. Short clarifying questions. Write `docs/features/<slug>/README.md` (+ design/requirements if needed). Update hub Features section; roadmap/architecture only if impact. ADR only for non-trivial decisions. See [modes.md](references/modes.md#3-feature).

### Sync
Map change blast radius to docs (project and/or feature). Update only impacted files. Always consider hub status line. New ADR if a durable decision landed. See [modes.md](references/modes.md#4-sync).

### Roadmap
Read hub + roadmap + architecture + relevant feature docs. Plan at the correct level (project epic vs single feature). See [modes.md](references/modes.md#5-roadmap).

## Hub requirements

Hub must include:
- Short project overview
- Navigation links to docs (and Features list when any exist)
- **Instructions for AI agents**: read hub + relevant `docs/` before significant work; update docs after significant changes; prefer ADRs for decisions; code wins for implementation detail
- Current status / last updated line

Template: [agents-md-template.md](references/agents-md-template.md)

## Quality bar

Follow [quality-checklist.md](references/quality-checklist.md) before finishing.

Lightweight Diataxis hint (optional, for user-facing features):
- **Reference** — what it is / API surface
- **How-to** — task steps
- **Explanation** — why (often ADR or design.md)
- **Tutorial** — only if onboarding needs it

Do not force all four for every feature.

## Templates & references

| File | Use |
|------|-----|
| [references/agents-md-template.md](references/agents-md-template.md) | Hub structure |
| [references/adr-template.md](references/adr-template.md) | Every ADR |
| [references/feature-readme-template.md](references/feature-readme-template.md) | Feature entry |
| [references/architecture-template.md](references/architecture-template.md) | Project architecture |
| [references/modes.md](references/modes.md) | Full mode procedures |
| [references/quality-checklist.md](references/quality-checklist.md) | Done criteria |

## When NOT to use

- Pure code implementation with no doc intent
- One-off throwaway notes outside the repo
- Replacing a mature docs system (MkDocs/Docusaurus site) wholesale — integrate with it instead of forking a parallel tree

## Activation

Standalone or alongside coding/review skills. When active, proactively suggest doc updates after significant architectural or product changes — ask before large rewrites of narrative docs.
