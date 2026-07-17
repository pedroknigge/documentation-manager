# AGENTS.md — documentation-manager (skill package)

**Status:** skill development repo · last updated 2026-07-17 · skill version **2.1.0**

## What this folder is

This workspace is the **source repository for the `documentation-manager` Agent Skill**.

| This repo **is** | This repo **is not** |
|------------------|----------------------|
| Development + packaging of the skill | A product app that consumes the skill as its main purpose |
| `SKILL.md`, templates, install/publish tooling | A greenfield app whose docs should be bootstrapped by default |
| What gets published to GitHub / installed via `npx skills` or `install.sh` | A substitute for a user’s project knowledge base |

When working here, assume you are **authoring or shipping the skill**, not running adopt/bootstrap on an unrelated product unless the user explicitly asks to dogfood.

## Layout (skill package)

```
documentation-manager/          ← this git root (skill development)
├── AGENTS.md                   ← this hub (for agents working ON the skill)
├── README.md                   ← human-facing install & overview
├── PUBLISH.md                  ← how to publish the package
├── install.sh                  ← classic installer
├── docs/                       ← meta knowledge (roadmap + plans for the skill itself)
│   ├── roadmap.md
│   └── plans/<slug>/
├── scripts/                    ← validate / smoke
└── skills/documentation-manager/
    ├── SKILL.md                ← skill entry (source of truth for behavior)
    └── references/             ← templates + mode procedures
```

`.agents/` is a **local host copy** (gitignored). Prefer editing `skills/documentation-manager/`, then reinstall/sync if hosts need the local copy.

## Instructions for AI agents

1. Read this hub and `skills/documentation-manager/SKILL.md` before changing skill behavior.
2. Edit the skill under **`skills/documentation-manager/`** (not a random consumer `docs/` tree).
3. Keep install paths, `PUBLISH.md`, and `README.md` aligned when the package surface changes.
4. Run `./scripts/validate-skill.sh` after structural or content changes to the skill tree.
5. Do **not** auto-commit or auto-push.
6. Write skill body / ecosystem-facing docs in **English** (ecosystem compatibility). User-facing generated content from the skill follows the **user’s language** when the skill runs on a target project.
7. If asked to “document this project” **inside this repo**, clarify first: document the **skill package** (meta), or only change skill templates — do not invent a fake product vision for an app that does not exist.
8. Strategic direction for *this* package lives in [docs/roadmap.md](docs/roadmap.md) and [docs/plans/](docs/plans/). Do not invent a fake product roadmap for a consumer app.

## Navigation

- Skill behavior: [skills/documentation-manager/SKILL.md](skills/documentation-manager/SKILL.md)
- Modes detail: [skills/documentation-manager/references/modes.md](skills/documentation-manager/references/modes.md)
- Quality bar: [skills/documentation-manager/references/quality-checklist.md](skills/documentation-manager/references/quality-checklist.md)
- **Roadmap (meta):** [docs/roadmap.md](docs/roadmap.md)
- Install for users: [README.md](README.md)
- Publish: [PUBLISH.md](PUBLISH.md)

## Features (shipped skill behavior)

| Feature | Path | Status |
|---------|------|--------|
| ArkGate bridge | [docs/features/arkgate-bridge/README.md](docs/features/arkgate-bridge/README.md) | Shipped (v1.4.0) |
| Feature autopilot 2.0 | [docs/features/feature-autopilot-v2/README.md](docs/features/feature-autopilot-v2/README.md) | Shipped (v1.5.0) |
| Knowledge dashboard | [docs/features/knowledge-dashboard/README.md](docs/features/knowledge-dashboard/README.md) | Shipped (v1.6.0) |
| Skill hardening | [docs/features/skill-hardening/README.md](docs/features/skill-hardening/README.md) | Shipped (v1.7.0) |
| 10× v2.0 release | [docs/features/tenx-v2-release/README.md](docs/features/tenx-v2-release/README.md) | Shipped (v2.0.0) |
| Polyglot MVP | [docs/features/polyglot-mvp/README.md](docs/features/polyglot-mvp/README.md) | Shipped (v2.1.0) |

## Navigation (meta)

- Roadmap: [docs/roadmap.md](docs/roadmap.md)
- **Adoption matrix:** [docs/adoption-matrix.md](docs/adoption-matrix.md)
- Changelog: [CHANGELOG.md](CHANGELOG.md)

## Plans (skill evolution)

| Plan | Path | Status | Horizon |
|------|------|--------|---------|
| ArkGate bridge | [docs/plans/arkgate-bridge/README.md](docs/plans/arkgate-bridge/README.md) | Shipped → feature pack | 10× / v2 |
| Feature autopilot 2.0 | [docs/plans/feature-autopilot-v2/README.md](docs/plans/feature-autopilot-v2/README.md) | Shipped → feature pack | 10× / v2 |
| Knowledge dashboard | [docs/plans/knowledge-dashboard/README.md](docs/plans/knowledge-dashboard/README.md) | Shipped → feature pack | 10× / v2 |
| Skill hardening | [docs/plans/skill-hardening/README.md](docs/plans/skill-hardening/README.md) | Shipped → feature pack | 10× / v2 |
| **Phase 2 Bridge** | [docs/plans/phase-2-bridge/README.md](docs/plans/phase-2-bridge/README.md) | In progress (A shipped) | Bridge (post-v2) |
| Knowledge OS | [docs/plans/knowledge-os/README.md](docs/plans/knowledge-os/README.md) | Planned | 100× (post-Bridge) |

*(Pre-code epics under `docs/plans/`. Promote to `docs/features/<slug>/` when behavior lands in the skill tree.)*

## Scope reminder

| Context | Correct focus |
|---------|----------------|
| Editing this repo | Skill authoring, packaging, validation, release |
| User invokes skill **in another project** | That project’s `AGENTS.md` + `docs/` (see SKILL.md modes) |
