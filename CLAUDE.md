# CLAUDE.md — Trade Tools Store (refresher project)

## Who you're working with
Mosin is an experienced backend developer (PHP/Laravel, Node/Express, MySQL, AWS) who is
new to TypeScript and automated CI/CD, and refreshing PostgreSQL and cloud after a year away.
He is preparing for a developer trial at a company running Elixir/Phoenix, PostgreSQL and Google Cloud.

## Tutor mode (always on)
- Before writing code that introduces a new concept (a TypeScript feature, a Postgres feature,
  a Docker or CI/CD idea), explain the concept in 2-4 plain sentences first.
- Work in small steps. One file or one logical change at a time, then stop and summarise:
  what changed, why, and how to verify it.
- When a TypeScript type, SQL clause or YAML key is non-obvious, add a short comment explaining it.
- For query performance work, ask Mosin to predict the EXPLAIN result before running it.
- Never push to git, open PRs, deploy, or run terraform apply/destroy without asking first.
- Never run destructive SQL (DROP, TRUNCATE, DELETE without WHERE) without asking first.

## Project goal
A thin HTTP API over a PostgreSQL database for a multi-store trade-tools retailer.
The database and the cloud pipeline are the focus; the API stays thin.

## Stack
- Node.js 22 LTS + TypeScript in strict mode (module NodeNext: relative imports end in .js)
- Express 5 + zod for request validation
- PostgreSQL 16 via the pg driver: raw, parameterised SQL only, no ORM
- Migrations: dbmate, plain .sql files with -- migrate:up / -- migrate:down
- Tests: vitest, run against a real Postgres (tradetools_test), never mocked
- Local runtime: Docker Compose (service name: db)
- CI/CD: GitHub Actions (.github/workflows/ci.yml and deploy.yml)
- Cloud: Google Cloud in australia-southeast1. Cloud Run, Cloud SQL (PostgreSQL),
  Artifact Registry, Secret Manager, Workload Identity Federation, all in Terraform (infra/)

## Folder layout
- db/migrations/      dbmate SQL migrations
- db/seed/            seed.sql that generates millions of realistic rows
- src/                TypeScript API: app.ts (routes) -> src/sql/*.ts (queries) -> db.ts (pool)
- tests/              vitest integration tests
- infra/              Terraform for GCP
- .github/workflows/  CI and CD pipelines
- .claude/            subagents, hooks, custom commands

## SQL rules
- Always use parameters ($1, $2...). Never build SQL with string concatenation.
- Money is stored as integer cents (bigint), never float.
- Timestamps are timestamptz.
- pg returns bigint as a string; convert with Number() only where values are known to be small.
- Every foreign key gets an index. Every new index gets a one-line comment saying which query
  it serves, plus EXPLAIN (ANALYZE, BUFFERS) before and after when added for performance.
- Use keyset pagination for large lists, not OFFSET.
- Stock changes happen in a transaction using a conditional UPDATE (on_hand >= qty),
  rows are locked in sku_id order, and every change is recorded in stock_movements.
- Migrations must be reversible and safe for zero-downtime deploys: CREATE INDEX CONCURRENTLY
  (with -- migrate:up transaction:false), expand/contract for column changes.

## Commands
- npm run dev          start the API with reload (tsx)
- npm run typecheck    tsc --noEmit
- npm run lint         eslint
- npm run migrate      dbmate up (local database)
- npm run test:db      migrate the test database
- npm test             vitest
- npm run db:reset     drop, migrate and reseed the local database
- docker compose up -d                                   start Postgres
- docker compose exec -T db psql -U app -d tradetools    run SQL (use this for EXPLAIN)

## Git
- Small branches, one topic each. Conventional commits (feat:, fix:, chore:, docs:, ci:).
- main is protected: merge only through a PR with green CI.