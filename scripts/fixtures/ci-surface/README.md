# CI surface fixtures

Sanitized GitHub responses used by `scripts/ci-surface.sh` and `scripts/test-ci-surface.sh`.

Pinned from real responses, with owner, repository, URLs, domains, SHAs, user logins, and project names removed:

- Commit status `context` is `Vercel`. Success `state` is `success`. Success `description` is `Deployment has completed`.
- A check-run from app slug `vercel` may be `Vercel Preview Comments`. That check is not the deployment gate.
- Deployments that count are created by `vercel[bot]`. Environments seen: `Preview`, `Production`. Their statuses carry `state` and `description`.
- A head commit whose check-runs are only app slug `github-actions`, with no `Vercel` status and no `vercel[bot]` deployment, is the absent snapshot (`absent-actions-only/`).

`fail`, `pending`, `skipped`, `ignored`, and `canceled` cases in the test reuse this success shape and change `state`, `conclusion`, or `description`. Those variants were not in the captured success responses. A description that contains skipped, ignored, or canceled is `absent` even when `state` is `success`.
