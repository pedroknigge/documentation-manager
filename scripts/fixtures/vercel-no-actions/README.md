# Vercel-style docs-audit fixture

No `.github/workflows`. `vercel.json` `buildCommand` is the `ci-surface.sh recipe` line: whole-matrix `audit-claims.sh` from the git root, then `build-app.sh`.

`scripts/test-ci-surface.sh` copies `audit-claims.sh` and a claims matrix in at run time, runs the build from `packages/web` (a Root Directory), and points `ci-surface.sh read --fixture` at the directory `simulate-control-plane.sh` fills from `scripts/fixtures/ci-surface/pass-vercel/`.
