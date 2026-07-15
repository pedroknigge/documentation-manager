# Skill discovery & upgrade (v1.7)

How agents and humans detect that Documentation Manager is installed, current, and which layout to prefer. **No silent auto-patch** of the user’s machine without consent.

## Detect install

| Signal | Meaning |
|--------|---------|
| Skill path exists | e.g. `~/.agents/skills/documentation-manager/SKILL.md`, `~/.claude/skills/…`, `~/.grok/skills/…` |
| Host skill list | `npx skills list` / agent UI shows `documentation-manager` |
| Version in frontmatter | YAML `metadata.version` or `version:` in `SKILL.md` |

Announce when relevant:

```text
Documentation Manager: installed | version: <x.y.z> | path: <skill dir>
```

## Detect outdated

1. Read local `version` from installed `SKILL.md`.  
2. Compare to package source (this repo / GitHub `pedroknigge/documentation-manager` / README badge).  
3. If local **&lt;** published: suggest reinstall — do **not** overwrite without user OK.

Upgrade (user-approved):

```bash
# classic
./install.sh
# or
npx skills add pedroknigge/documentation-manager -y
# global
npx skills add pedroknigge/documentation-manager -g -y
```

Re-run is **idempotent** (see `scripts/install-smoke.sh`).

## Stack / layout hints (adopt & from-zero)

When discovering a **consumer** project (not this skill package), bias layout recommendations:

| Signals | Hint |
|---------|------|
| `package.json` + `app/` or `src/app` (Next) | `docs/features/` by route/ModuleId; plans for net-new |
| `pyproject.toml` / `go.mod` / `Cargo.toml` | Same docs layout; inventory packages/modules by language |
| monorepo `workspaces` / `pnpm-workspace` | Hub at root + optional per-package notes; avoid mega single feature pack |
| `ark.config.json` | Enable [arkgate-bridge.md](arkgate-bridge.md) inventory enrich |
| Existing MkDocs/Docusaurus | **Integrate** — do not replace wholesale |

These are **hints**, not forced scaffolds.

## Pre-release gate (maintainers)

Before tagging a release:

```bash
./scripts/validate-skill.sh
./scripts/test-skill-hardening.sh
./scripts/install-smoke.sh   # optional but recommended
```

All must exit 0. See [PUBLISH.md](../../../PUBLISH.md) in the package root.
