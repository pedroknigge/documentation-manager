# Skill discovery & upgrade (v1.7 · package v2.1 · polyglot MVP)

How agents and humans detect that Documentation Manager is installed, current, and which **stack / layout** to prefer. **No silent auto-patch** of the user’s machine without consent.

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

---

## Polyglot stack detection (v2.1 Slice A)

**When:** any **consumer** project discovery — adopt, integrate, from-zero, audit, feature autopilot inventory.  
**Do not** assume Node/TS. Detect stack from **filesystem signals**, then inventory and layout guidance follow the tables below.

Optional helper (package repo / installed package scripts):

```bash
# From documentation-manager package root (or copy):
./scripts/detect-stack.sh <consumer-repo-root>
# stdout examples:
#   node-ts
#   python
#   go
#   node-ts python    ← multi-stack; announce Stack: mixed, inventory each
#   unknown
```

Agents may also detect manually using the signal table (required path when the script is unavailable).

### Stack detection signals

| Primary stack token | Positive signals (any strong match) | Notes |
|---------------------|-------------------------------------|--------|
| **node-ts** | `package.json`; also `tsconfig.json`, `pnpm-workspace.yaml`, `yarn.lock`, `package-lock.json`, `src/app/**`, `app/**` (Next) | Baseline since v1.x |
| **python** | `pyproject.toml`, `setup.py`, `setup.cfg`, `requirements.txt`, `Pipfile`, `poetry.lock`; package dirs under `src/<pkg>/` with `__init__.py` | Prefer `src/` layout when present |
| **go** | **`go.mod` required** (module line = module path). `cmd/`, `internal/`, `pkg/` are inventory hints after detection, not standalone signals | Orphan `go.sum` alone is **not** enough |
| **unknown** | None of the above | Generic tree walk; still no invented APIs |

**Mixed:** two or more of node-ts / python / go fire → announce **`Stack: mixed`** and list each primary (`detect-stack.sh` prints them space-separated; it does not print the word `mixed`). Inventory **per stack present**; do not force a single language narrative.

**Conflict / weak signals:** ask once only if product entrypoint is ambiguous; otherwise pick the stack with the strongest root-level manifest.

### Inventory by stack (what to list first)

Use this table in **audit §6.1**, **from-zero**, and **integrate** code discovery. Names and paths only — **no** invented ModuleIds, HTTP routes, or framework endpoints without code evidence.

| Kind | **node-ts** | **python** | **go** |
|------|-------------|------------|--------|
| Packages / apps | workspaces, `package.json` name | `pyproject.toml` projects, setup packages | `go.mod` module; multi-module `go.work` (note only; full monorepo hubs = Slice B) |
| Entry / CLI | `src/index.ts`, `app/`, `bin/` | `__main__.py`, `src/<pkg>/`, console scripts in pyproject | `cmd/<name>/main.go` |
| Feature modules | dirs under `src/`, route folders | packages under `src/`, submodules | `internal/<area>/`, `pkg/<lib>/` |
| HTTP / API | `app/api/**`, routers, OpenAPI if generated | FastAPI/Flask/Django **only if** those files exist | `chi`/`echo`/net/http handlers **only if** present |
| UI surfaces | app router pages, major nav | templates/static **if** present | rare; note only if present |
| Data layer | ORM schemas, migrations (names) | models/migrations (Alembic, Django, …) if present | sql/store packages if present |
| Tests | `**/*.{test,spec}.*`, `__tests__` | `tests/`, `test_*.py`, `*_test.py` | `*_test.go` |
| Jobs / workers | `scripts/`, workers | celery/tasks/scripts if present | `cmd/` workers, scripts |

### Docs layout guidance by stack

Same **hub + `docs/`** contract for all stacks (AGENTS.md, plans, features). Bias **feature slug sources** and **architecture vocabulary**:

| Stack | Hub + docs layout | Feature / plan slug sources | Architecture notes |
|-------|-------------------|----------------------------|--------------------|
| **node-ts** | Root `AGENTS.md` + `docs/` | routes, ModuleIds, `src/<area>`, package names | Note Next/Nest/etc. only if manifests/code prove it |
| **python** | Root `AGENTS.md` + `docs/` | importable packages (`src/<pkg>`), console script names, Django apps **if** present | Prefer package boundaries over inventing “services” |
| **go** | Root `AGENTS.md` + `docs/` | `cmd/<name>`, `internal/<area>`, exported packages | cmd vs internal boundary; no fake REST surface |
| **mixed** | One root hub; coverage rows per stack/package | Per-stack inventory rows | Separate architecture subsections per language if needed |
| **unknown** | Same docs layout | Directory names with real code only | Stay minimal |

**Shared rules (all stacks):**

- Docs tree shape stays agent-first: hub, `docs/plans/`, `docs/features/`, optional audit — **not** language-specific wiki roots.  
- Integrate-first: mature docs are not rewritten just because stack is non-TS.  
- **Anti-hallucination:** never invent ModuleIds/endpoints/tables for frameworks not evidenced in code.  
- Monorepo multi-package **hub index** is Slice B; here only detect stack and inventory honestly.

### Other layout signals (orthogonal)

| Signals | Hint |
|---------|------|
| monorepo `workspaces` / `pnpm-workspace` / `go.work` / multi-package | Root hub + package notes; avoid mega single feature pack (full monorepo hubs → Slice B) |
| `ark.config.json` | Enable [arkgate-bridge.md](arkgate-bridge.md) inventory enrich |
| Existing MkDocs/Docusaurus | **Integrate** — do not replace wholesale |

These are **hints**, not forced scaffolds.

### Announce stack

When doing project-level work, include stack in the pre-write announce:

```text
Stack: <node-ts|python|go|mixed|unknown> | signals: <short list>
```

---

## Pre-release gate (maintainers)

Before tagging a release:

```bash
./scripts/validate-skill.sh
./scripts/test-skill-hardening.sh
./scripts/install-smoke.sh   # optional but recommended
```

All must exit 0. See [PUBLISH.md](../../../PUBLISH.md) in the package root.

Target install version for the 10× line: **≥ 2.0.0**. Polyglot MVP ships in **≥ 2.1.0**. Track targets in [docs/adoption-matrix.md](../../../docs/adoption-matrix.md).
