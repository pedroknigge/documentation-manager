# Vercel as a docs-audit surface (v2.5.22)

The gate is still whole-matrix `audit-claims.sh` (no `--list-changed` or other change-set flags). GitHub Actions [`.github/workflows/docs-audit.yml`](../../../.github/workflows/docs-audit.yml) stays. This page is the opt-in Vercel path for a repo that may have **no** Actions workflows.

`install.sh` does not write `vercel.json`. The captain copies the script and the command.

## What to copy

1. Copy `scripts/audit-claims.sh` into the consumer repo (the Vercel builder does not have the installed skill).
2. Keep the real framework build. Put the audit in front of it.

Print the command from the installed skill (pass the framework command the project already runs):

```bash
ci-surface.sh recipe --build 'npm run build:app'
```

That prints:

```bash
root="$(git rev-parse --show-toplevel)" && bash "$root/scripts/audit-claims.sh" "$root" && npm run build:app
```

Paste the line into `vercel.json` `buildCommand`, or into the `build` script Vercel already invokes when `buildCommand` is empty. `&&` is required: a failing audit must not start the framework build, and the failed build is what blocks the preview deployment.

Run it from the repo root even when the Vercel Root Directory is a package subdirectory (`git rev-parse --show-toplevel`). If git metadata is missing, the command fails closed.

Do not point `ignoreCommand` at a skip that bypasses this audit. A skipped, ignored, or canceled build did not run the gate.

## How an agent reads the result

```bash
ci-surface.sh detect [ROOT]
ci-surface.sh read --fixture DIR [ROOT]
ci-surface.sh read --live [ROOT]
```

| Line | Meaning |
|------|---------|
| `surface=github-actions` | `.github/workflows/docs-audit.yml` is present |
| `surface=vercel` | `vercel.json`, `.vercel/project.json`, or `VERCEL=1`, and no docs-audit workflow |
| `surface=both` | Both of the above |
| `surface=none` | Neither |
| `verdict=pass` | Every present surface succeeded |
| `verdict=fail` | A present surface failed |
| `verdict=pending` | A present surface is still running, and none have failed |
| `verdict=absent` | The audit did not run (no surface, skipped, ignored, canceled, or an unrecognized status) |

`read --fixture` is offline. `read --live` uses `gh` against a GitHub `origin` (commit status, check-runs, deployments). It does not call the Vercel API and it does not poll. Exit `0` means a verdict was printed. Exit `2` means the arguments or the live read could not be completed. A `verdict=fail` is still exit `0`.

Matchers live in `ci-surface.sh`, not in this page: commit-status context `Vercel`, deployment creator `vercel[bot]`, check-run app slug `vercel` (the `Vercel Preview Comments` check is not the deployment), and the Actions job name `Structural claims audit` with app slug `github-actions`. An unknown context is `absent`, never `pass`.

GitLab, Bitbucket, and GitHub Enterprise Server are out of scope. Living-claims CI is still not production go/no-go.

## Related

- Procedure: [living-claims.md](living-claims.md) · [modes.md §13](modes.md#13-living-claims--ci-structural-audit-v25)
- Plan: [docs/plans/pedroknigge/vercel-ci/PLAN.md](../../../docs/plans/pedroknigge/vercel-ci/PLAN.md)
