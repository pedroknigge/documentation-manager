# Skill discovery & upgrade (v1.7 · package v2.2 · polyglot + monorepo)

How agents and humans detect that Documentation Manager is installed, current, and which **stack / layout** to prefer. **No silent auto-patch** of the user’s machine without consent.

## Detect install

| Signal | Meaning |
|--------|---------|
| Skill path exists | e.g. `~/.agents/skills/documentation-manager/SKILL.md`, `~/.claude/skills/…`, `~/.grok/skills/…` |
| Host skill list | `npx skills list` / agent UI shows `documentation-manager` |
| Version in frontmatter | YAML `metadata.version` or `version:` in `SKILL.md`. Glance: `description` starts with `vX.Y.Z —` (same number) |

Announce when relevant:

```text
Documentation Manager: installed | version: <x.y.z> | path: <skill dir>
```

## Detect outdated

1. Read local `version` from installed `SKILL.md`.  
2. Compare to package source (this repo / GitHub `pedroknigge/documentation-manager` / README badge).  
3. If local **&lt;** published: suggest reinstall — do **not** overwrite without user OK.

Upgrade (user-approved). **If you use both: npx first → then `./install.sh`.**

`npx skills add` replaces the whole skill folder with SKILL.md + references only. That **wipes** the helper scripts classic `install.sh` just put in `scripts/` (audit-claims, detect-stack, and friends). Running npx last is the dangerous order.

```bash
# 1) refresh SKILL.md + references
npx skills add pedroknigge/documentation-manager -y
# 2) put the helper scripts back (required after npx)
./install.sh
# same as: curl -fsSL https://raw.githubusercontent.com/pedroknigge/documentation-manager/main/install.sh | bash

# global npx still needs step 2 after
npx skills add pedroknigge/documentation-manager -g -y
./install.sh
```

`install.sh` by itself is idempotent (see `scripts/install-smoke.sh`). Mixing the two is **not** — always finish with `install.sh`.

---

## Skill-runtime scripts

Package-root `scripts/` is the **SSOT**. `install.sh` (local clone **and** raw GitHub curl) copies a **runtime subset** into the installed skill:

`<skill-dir>/scripts/` — e.g. `~/.claude/skills/documentation-manager/scripts/`

| Script | Role | On install |
|--------|------|------------|
| `audit-claims.sh` | Living-claims gate + change-set helpers | **Required** |
| `detect-stack.sh` | Polyglot | Prefer |
| `detect-packages.sh` | Monorepo | Prefer |
| `survey-docs.sh` | Cold-start survey | Prefer |
| `generate-docs-dashboard.sh` | HTML view | Kept |

**Where agents run them:** the **installed skill** `scripts/`. Pass the consumer repo as the root argument.

`./scripts/<name>` in modes is shorthand. Resolve:

1. Installed skill `…/documentation-manager/scripts/<name>` (what `install.sh` ships)
2. Else consumer-repo `./scripts/<name>` if present (opt-in **CI** copy — `docs-audit.yml` needs a local script)
3. Else follow the procedure by hand, or re-run `install.sh`

**Not an install story:** auto-copy into every consumer repo. Maintainer-only scripts (`validate-skill.sh`, hardening, smoke, fixtures) stay at package root.

`npx skills add` copies `skills/documentation-manager/` (SKILL + references) only and **replaces** the skill directory. Always run classic `install.sh` **after** npx (**npx first** → then install). Never treat them as interchangeable.

---

## Polyglot stack detection (v2.1 Slice A)

**When:** any **consumer** project discovery — adopt, integrate, from-zero, audit, feature autopilot inventory.  
**Do not** assume Node/TS. Detect stack from **filesystem signals**, then inventory and layout guidance follow the tables below.

Optional helper (installed skill `scripts/` first — [Skill-runtime scripts](#skill-runtime-scripts)):

```bash
# Installed skill (after install.sh); pass the consumer root:
~/.agents/skills/documentation-manager/scripts/detect-stack.sh <consumer-repo-root>
# Shorthand if a copy exists in the consumer or package repo:
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

- Docs tree shape stays agent-first: hub, `docs/plans/`, `docs/features/`, optional audit — **not** language-specific wiki roots. **Proposal only** — if the repo evolved a different layout, adopt it ([modes.md §2](modes.md#2-adopt-project)).  
- Integrate-first: mature docs are not rewritten just because stack is non-TS.  
- **Anti-hallucination:** never invent ModuleIds/endpoints/tables for frameworks not evidenced in code.  
- Monorepo multi-package **hub index** is Slice B (next section).

### Other layout signals (orthogonal)

| Signals | Hint |
|---------|------|
| monorepo (see **Monorepo hubs** below) | Root hub = map + package index; avoid mega single feature pack |
| `ark.config.json` | Enable [arkgate-bridge.md](arkgate-bridge.md) inventory enrich |
| Existing MkDocs/Docusaurus | **Integrate** — do not replace wholesale |

These are **hints**, not forced scaffolds.

### Announce stack

When doing project-level work, include stack in the pre-write announce:

```text
Stack: <node-ts|python|go|mixed|unknown> | signals: <short list>
```

---

## Monorepo hubs (v2.2 Slice B)

**When:** project-level adopt / integrate / from-zero / audit on a multi-package tree.  
**Orthogonal to stack:** run polyglot detection at root **and** (when useful) per package; monorepo rules govern hub shape.

### Monorepo detection signals

| Signal | Ecosystem | Notes |
|--------|-----------|--------|
| `pnpm-workspace.yaml` | Node | `packages:` globs (e.g. `packages/*`) |
| `package.json` `"workspaces"` | Node (npm/yarn) | Array or `{ "packages": [...] }` |
| `lerna.json` / `nx.json` / `turbo.json` | Node tooling | Hint only; still resolve package dirs from workspaces/globs |
| `go.work` | Go | Lists `use` module dirs |
| Multiple `go.mod` under subdirs | Go | Multi-module tree without go.work |
| Multiple `pyproject.toml` under subdirs | Python | Multi-package / workspace layout |
| `packages/*`, `apps/*`, `libs/*` with manifests | Common | Directory convention + package.json / pyproject / go.mod inside |

Optional helper (installed skill `scripts/` first — [Skill-runtime scripts](#skill-runtime-scripts)):

```bash
~/.agents/skills/documentation-manager/scripts/detect-packages.sh <consumer-repo-root>
# or ./scripts/detect-packages.sh <consumer-repo-root>
# stdout: one package path per line (relative to root), e.g.
# packages/api
# packages/web
# (empty stdout + exit 0 if single-package / no monorepo signals)
```

**What `detect-packages.sh` actually resolves (v2.2):**

| Source | Resolved |
|--------|----------|
| `pnpm-workspace.yaml` globs / concrete dirs | Yes |
| `package.json` `workspaces` (via `node` JSON parse) | Yes |
| `go.work` `use ./path` (incl. multi-line `use (` blocks) | Yes |
| Convention `packages/*`, `apps/*`, `libs/*` with manifests | Yes (when nothing else found) |
| Arbitrary multi-`go.mod` / multi-`pyproject.toml` outside those | **No** — agent walks tree manually from the signal table |

If the script is unavailable or returns empty while signals suggest monorepo, detect manually from the signal table, then list package roots that contain a package manifest (`package.json`, `pyproject.toml`, or `go.mod`).

**Not a monorepo:** single root manifest only, no workspace file, no multi-package globs / multi-module layout → single-repo flow (Slice A stack tables only).

### Root hub = map (not a dump)

| Do | Do not |
|----|--------|
| Root `AGENTS.md` = **map**: overview, links, **Package index**, multi-package **Surface coverage** | Paste full product vision / architecture of every package into root |
| One **Package index** table listing each package path + docs status | One mega feature pack that swallows all packages |
| Link package hubs / package docs when they exist | Duplicate package SSOT into root `docs/features/` |
| Mark packages **without** docs as **gap** in coverage | Invent product vision / ModuleIds for undocumented packages |

### Package index (required when monorepo detected)

In the **root hub** (or root `docs/` index linked from hub):

| Package path | Role (short) | Hub / docs | Docs status |
|--------------|--------------|------------|-------------|
| `packages/api` | … from README/code only | [path or —] | documented / linked / **gap** |
| `packages/web` | … | … | … |

Rules:

1. **One authority per topic** — claims for a package live in that package’s hub/docs or a single linked canonical doc; root only indexes.  
2. **Optional package hub** — create/update `packages/<name>/AGENTS.md` (or package-local docs) only when the package is a real work surface and the user scope needs it; not mandatory for every package on first integrate.  
3. **Default non-writes** when indexing root: do **not** rewrite mature package product-vision / requirements / ADRs / feature packs just to build the root map.  
4. **Coverage matrix multi-package** — each package (or major surface inside it) is a row; empty hub + empty feature pack = **gap**.  
5. **from-zero** on monorepo: root map + index first; full package KBs only for packages in scope (or sandbox); never invent APIs.

### Procedure (adopt / integrate / from-zero / audit)

1. Detect monorepo (signals above or `detect-packages.sh`).  
2. If **no** monorepo → single-repo flow.  
3. If monorepo → list packages → build/update **Package index** on root hub.  
4. Multi-package **Surface coverage** rows (package path as surface key when ModuleId unknown).  
5. Stack-aware inventory **per package** when stacks differ (polyglot Slice A).  
6. Announce:

```text
Monorepo: yes | packages: <n> | root hub: map+index | package non-writes: default
```

### Anti-patterns

- Collapsing monorepo into one giant `docs/features/everything` pack  
- Rewriting every package’s narrative on root-only “sync hub”  
- Inventing package purposes not evidenced in README/code  

---

## Cold-start survey heuristics (README / ADR / claim-scope)

**When:** first contact on adopt / integrate / from-zero, or a **full-tree** audit the user opted into.  
**Not** the default audit read — that stays **diff-first** ([modes.md §6.0](modes.md#60-change-set-diff-first)).

These three checks stop false “empty repo” / false ADR / demo-markdown thrash. They do **not** invent a second inventory engine.

Optional helper (installed skill `scripts/` first — [Skill-runtime scripts](#skill-runtime-scripts)):

```bash
~/.agents/skills/documentation-manager/scripts/survey-docs.sh [--readme|--adrs|--claim-scope|--include-examples] <consumer-repo-root>
# or ./scripts/survey-docs.sh …
```

Agents may also apply the tables by hand when the script is unavailable.

### README (case-insensitive)

| Do | Do not |
|----|--------|
| Treat root `README.md`, `Readme.md`, `readme.md` (and `.markdown`) as the project README | Report “no README” when only CapCase `Readme.md` exists |
| Adopt the filename as-is | Rename it to `README.md` to match a template |

Optional: `./scripts/survey-docs.sh --readme <root>` — prints the relative path(s), or nothing if truly absent.

### ADR paths (tight)

Look only in **real ADR homes** and **ADR-shaped names**:

| Homes (dirs) | Names (files) |
|--------------|---------------|
| `docs/adr/`, `docs/adrs/`, `docs/decisions/`, `docs/architecture/decisions/`, `docs/architecture-decisions/`, `adr/`, `adrs/`, `doc/adr/`, `.adr/` | `ADR-001-….md`, `adr-0001-….md`, `ADR001-….md` |
| Repo root | `ADR-<n>-*.md` only |
| Inside an ADR home | Numbered `0001-title.md` / `0001-title.mdx` |

**Forbidden:** substring globs like `*adr*`. That matches `TableHeadRenderer.tsx` (`adR`) and other source files. Source is never an ADR.

Optional: `./scripts/survey-docs.sh --adrs <root>`.

### Claim / doc scope (cold-start)

Default universe when first surveying docs or when the user opted into **full-tree** claim extraction:

| Include | Exclude unless opted in |
|---------|-------------------------|
| Root `*.md` | `examples/**` (demo / component markdown) |
| `docs/**/*.md` — **adopt** CapCase / flat trees (`docs/Architecture.md`); never rewrite them to the skill template | Named example trees the user did not ask to audit |
| `.github/**/*.md` (contributor docs) | |

Opt-in signals: “include examples”, “audit examples too”, or `--include-examples`.

Human is captain. Propose this default. Never override an evolved layout or a developer decision.

---

## Pre-release gate (maintainers)

Before tagging a release:

```bash
./scripts/validate-skill.sh
./scripts/test-skill-hardening.sh
./scripts/install-smoke.sh   # optional but recommended
```

All must exit 0. See [PUBLISH.md](../../../PUBLISH.md) in the package root.

Target install version for the 10× line: **≥ 2.0.0**. Polyglot MVP **≥ 2.1.0**. Monorepo hubs **≥ 2.2.0**. Team governance **≥ 2.3.0**. Bridge line **≥ 2.4.0**. **Living claims + CI structural audit (Knowledge OS first increment) ≥ 2.5.0**. Track targets in [docs/adoption-matrix.md](../../../docs/adoption-matrix.md).
