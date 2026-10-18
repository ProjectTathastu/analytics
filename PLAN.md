# Startup repair plan

Scope: restore a real development preview using the application's declared
dependencies, preserving production behavior, geolocation, and normal checks.
Do not add provider-specific provisioning or substitute test data for preview data.

## Existing focused commits

1. Add regression coverage requiring geolocation download before database setup.
2. Include `download_country_database` in `mix setup` before `ecto.setup`.
3. Document the real geolocation database and optional MaxMind credential.
4. Fail the download task on unsuccessful HTTP responses instead of saving errors.
5. Verify geolocation lookup through the application's configured database.

These commits survived in this checkout through `438907a`.

## Current correction

6. Diagnose the database connection failure before changing runtime configuration.
   Document ClickHouse readiness and restore the missing managed service through
   an external portable setup proposal. Keep database creation, migrations, and
   startup failure reporting intact.

Inspection on 2026-10-18 found no ClickHouse executable, process, listener on
8123, or service log in the fresh workspace. A bounded request to
`http://127.0.0.1:8123/ping` failed with connection refused. This corroborates
the reported `Plausible.IngestRepo` creation failure; it does not establish
the state of services during the earlier validation window.

`config/.env.dev` and `config/.env.test` declare local ClickHouse URLs on
8123. `Makefile` starts ClickHouse separately, and `.github/workflows/elixir.yml`
uses ClickHouse 25.11.5.8 and waits for `/ping` before database creation.

Focused implementation checks downloaded the real DB-IP Country Lite database,
loaded it through `Plausible.Geo.load_db/1`, and resolved `216.160.83.56` to
`US`. ClickHouse's official 25.11.5.8 binary reported the expected version and
parsed its local configuration with HTTP port 8123. No ClickHouse server was
started outside the managed lifecycle, so database creation and preview readiness
remain unverified in this implementation stage.

## Verification and delivery boundary

Use bounded inspection and focused dependency checks during implementation.
Leave configured deterministic checks, full validation, preview startup, and
publication to the harness. Do not claim runtime acceptance until those steps
are observed. Keep services managed by the harness; propose their configuration
outside the repository. Commit focused source/documentation changes with a clean
working tree; do not push or merge.
