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

## Fresh trial follow-up (revision 1)

7. Preserve the existing application fixes and tests. Reconcile the fresh trial
   reporting successful installs/services followed by PostgreSQL 3D000 for
   `plausible_dev`, ClickHouse Code 81 for `plausible_events_db`, and a
   `Plausible.Session.Salts` child startup failure. Document database initialization
   separately from service readiness and propose the missing database setup phase
   outside the repository. Keep publication and validation with the harness.

The report URL on localhost:4000 was unreachable in this implementation session
(connection refused); the operator-supplied recorded diagnostics are the trial
evidence. No preview-server log is available in this checkout. Current ClickHouse
logs are empty and a bounded `/ping` request again returned connection refused;
this is current workspace evidence, not proof of the earlier trial's service state.

Source inspection confirms that `:ecto_repos` includes both repositories and
Ecto's create task invokes each adapter's storage creation and raises on failure.
The ClickHouse adapter creates the configured database through an unscoped
connection. `Session.Salts.init/1` immediately queries the PostgreSQL `salts`
table. Therefore database creation and migrations must precede preview startup,
even when service health checks pass. No runtime startup behavior needs changing.
The contributor instructions now explain that lifecycle and place geolocation
installation before the application-starting seed command.

Focused checks on 2026-10-18: `mix deps.compile file_system` exited 0 in dev;
`MIX_ENV=test mix deps.compile file_system --force` compiled all seven files and
exited 0. The attempt-11 excerpt has no terminal Mix error and does not establish
a current `file_system` defect; neither dependency nor normal checks were removed.
`mix ecto.create --no-compile` created the PostgreSQL database, then exited 1
for ClickHouse with `%Mint.TransportError{reason: :econnrefused}`. This verifies
that the real setup task retains failure reporting when a required service is
unavailable; it does not verify complete database initialization or startup.
`MIX_ENV=dev mix do ecto.create + ecto.migrate` also exited 1 for the unavailable
ClickHouse service after reporting the PostgreSQL database already exists. The
create failure correctly prevents migration from running. No managed service
was replaced and no full validation or precommit suite was run.

The external setup proposal retains the previously proposed managed ClickHouse
installation/service and adds development database creation and migration to
`recipes.db_setup`, after managed services are available. It is a proposal for
fresh verification, not an adopted setup or a claimed passing preview.

## Verification and delivery boundary

Use bounded inspection and focused dependency checks during implementation.
Leave configured deterministic checks, full validation, preview startup, and
publication to the harness. Do not claim runtime acceptance until those steps
are observed. Keep services managed by the harness; propose their configuration
outside the repository. Commit focused source/documentation changes with a clean
working tree; do not push or merge.
