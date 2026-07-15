# Changelog

All notable changes to the **documentation-manager** skill package.

Format: keep entries scannable. Versions follow semver for the skill package (`SKILL.md` metadata).

## [2.0.0] — 2026-07-15

### Added

- **Adoption matrix** (`docs/adoption-matrix.md`) for tracking installs and ArkGate pairing honestly  
- **10× release pack** docs (`docs/features/tenx-v2-release/`)  
- Package marked **v2.0.0**: completes Fase 1 roadmap (bridge · autopilot v2 · dashboard · hardening · adoption)

### Included from 1.4–1.7 (rolled into the 10× line)

- ArkGate bridge (post-gate audit/sync, sensor not fusion)  
- Feature autopilot v2 (Kind spike/epic/redesign, Implementation bridge opt-in)  
- Knowledge dashboard (`scripts/generate-docs-dashboard.sh`)  
- Skill hardening (fixtures, golden mode anchors, version sync, discovery)

### Notes

- Markdown remains SSOT; generated HTML is gitignored  
- No auto-commit / auto-push  
- Pre-release: `./scripts/validate-skill.sh` (includes hardening)

## [1.7.0] — 2026-07-15

- Fixtures thin/mature/no-docs  
- `scripts/test-skill-hardening.sh` + golden autopilot anchors  
- `references/skill-discovery.md`  
- PUBLISH pre-release gate  

## [1.6.0] — 2026-07-15

- Static knowledge dashboard generator  
- modes §10 + `references/knowledge-dashboard.md`  

## [1.5.0] — 2026-07-15

- Feature autopilot v2  
- Implementation bridge (stubs opt-in)  

## [1.4.0] — 2026-07-15

- ArkGate bridge procedure  

## [1.3.0] — prior

- Plan mode + feature autopilot base  
- Intent integrate / audit / from-zero  
- Code wins audit matrix  
