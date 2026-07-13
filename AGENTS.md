# AGENTS.md — documentation-manager (skill package)

**Status:** skill development repo · last updated 2026-07-12 · skill version **1.1.0**

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

## Navigation

- Skill behavior: [skills/documentation-manager/SKILL.md](skills/documentation-manager/SKILL.md)
- Modes detail: [skills/documentation-manager/references/modes.md](skills/documentation-manager/references/modes.md)
- Quality bar: [skills/documentation-manager/references/quality-checklist.md](skills/documentation-manager/references/quality-checklist.md)
- Install for users: [README.md](README.md)
- Publish: [PUBLISH.md](PUBLISH.md)

## Scope reminder

| Context | Correct focus |
|---------|----------------|
| Editing this repo | Skill authoring, packaging, validation, release |
| User invokes skill **in another project** | That project’s `AGENTS.md` + `docs/` (see SKILL.md modes) |
