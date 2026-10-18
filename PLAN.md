# Preview startup repair plan — revision 2

## Scope and preserved work

This is a plan only. Implementation, setup adoption, runtime verification, and
publication belong to later stages. Do not merge the application PR. Preserve
branch `fix/diagnose-failed-startup-shown-6zng` at `ca45221` and the untracked
`TRIAGE.md`; do not reset or replace unpublished work.

The checkout contains eight repair commits after `d44e104`, rather than the seven
mentioned in TRIAGE.md: `ab5ca29`, `5ab1b4a`, `03e139a`, `dfb1b35`, `438907a`,
`9bb8fd8`, `652ed24`, and `ca45221`. They cover geolocation setup and lookup,
download failure reporting, service/database initialization documentation, and
the tracker compiler dependency readiness regression. Retain these changes and
the normal checks. No FEATURE.md was found; inspect the existing setup, Geo,
download-task, and tracker startup regression tests during implementation.

## Evidence and diagnosis

The latest operator-reported trial is
`a030eac0-bfa6-4c4e-888a-af61dd4fb6cd`, lasting 781 seconds. Installs and required
settings passed; supporting services passed in 6 seconds; application startup
failed its healthcheck after 2m30s; normal checks never ran. Output showed both
application databases created and migration activity, followed by repeated
Phoenix tracker watcher failures: `ERR_MODULE_NOT_FOUND` importing `@swc/core`
from `tracker/compiler/index.js` on Node 24.17.0. Five consecutive log polls
failed and 1,501,571 middle bytes were not retained. This differs from the older
geolocation failure and subsequent missing-database report. Neither watcher
errors nor partial migration output proves the cause of the HTTP healthcheck
failure or complete database initialization.

A bounded request to the exact report URL on localhost:4000 returned connection
refused during this planning stage. Report details above are supplied evidence,
not independently retrieved logs. Current workspace inspection found no tracker
SWC directory and no assets installed lockfile; this does not establish the
filesystem state of the trial.

`config/dev.exs` runs `npm run deploy` with `tracker` as its working directory.
The compiler statically imports `@swc/core`, already a required dependency locked
at 1.11.24 in `tracker/package-lock.json`. `.tool-versions` and tracker CI require
Node 24.17.0. No new dependency declaration, Node downgrade, or watcher bypass is
justified. `CONTRIBUTING.md`, Makefile, Dockerfile, and CI install assets and
tracker separately and build the tracker. `mix setup` downloads Geo data and
initializes databases but does not install these npm packages; `assets.setup`
installs Tailwind and Esbuild only.

Runtime configuration defaults to a real DB-IP Country Lite download, which
requires network access but no MaxMind license. An explicitly configured local
Geo database must exist and load; MaxMind selection requires a genuine license
and access to that service. PostgreSQL and ClickHouse must be available and both
application databases migrated before startup. Existing documentation and CI
identify these services; CI pins PostgreSQL 18 and ClickHouse 25.11.5.8. Do not
substitute fake Geo data, invented credentials, mocks, or disabled features.

## Logically sequenced implementation commits

### Commit 1 — Document tracker dependency readiness before Phoenix startup

Rationale: retain the existing application repairs and make the remaining setup
boundary explicit for all developers. A successful install phase cannot prove
that tracker dependencies exist in the later startup workspace. The repository
already declares the dependency and contains the regression probe; documentation
should explain how to verify that requirement without changing runtime behavior
or adding provider-specific provisioning.

Files to touch:
- `CONTRIBUTING.md`: add a concise tracker startup troubleshooting paragraph near
  the existing setup sequence. Explain that both npm projects need installation,
  that `mix setup` alone does not install them, and that a missing SWC package
  should be investigated as an installation/persistence failure.
- No package manifest, lockfile, Phoenix watcher, Geo configuration, or existing
  test changes are planned on present evidence.

Verification:
- Follow the documented commands in a fresh implementation workspace using the
  declared toolchain: `npm ci --prefix assets`, `npm ci --prefix tracker`,
  `node --test tracker/compiler/startup.test.js`, then
  `npm run deploy --prefix tracker`.
- The existing regression exercises the actual npm entry point and static
  imports without writing generated assets. Full deploy must also complete and
  produce usable tracker artifacts; the help probe alone is insufficient.
- Review the diff for provider-specific configuration, feature bypasses, changed
  lockfiles, and accidental generated artifacts. Preserve existing failures and
  nonzero exit statuses.

Do not manufacture another application commit to compensate for an external
recipe failure. If the following runtime investigation identifies an additional
repository defect, define a focused follow-up commit with its demonstrated
trigger, exact affected files, regression, and verification before implementing
it. Current evidence does not justify changes to unrelated installation
verification modules suggested by the path hints.

## External setup and runtime verification sequence

These steps are validation and setup work for the later implementation stage,
not repository provisioning commits and not work performed by this plan.

1. Reconcile the actual saved setup recipe and fresh-trial commands through the
   owning setup interface. Check installation prefix, working directory,
   command exit status, toolchain, and persistence from install to startup.
   Inspect only non-secret installation options relevant to omitted packages,
   optional native bindings, or cleanup. Do not inspect credential contents or
   infer missing prerequisites from absent `.sahr/setup.yml` or home metadata.
   Keep any proposed recipe correction outside this repository; the suggestion
   remains unadopted until the external workflow adopts it.
2. Install both lockfiles in the workspace used for startup, retaining npm
   failure output and exit status. Run the existing startup probe and real
   tracker deployment there before Phoenix. Distinguish a missing `@swc/core`
   package from a missing platform binding; investigate the observed error,
   without speculative lockfile edits or suppressed failures.
3. Confirm real PostgreSQL and ClickHouse readiness, then run
   `MIX_ENV=dev mix do ecto.create + ecto.migrate` with the same connection
   settings as startup. Retain terminal results for both repositories. Download
   the default Geo database with `mix download_country_database`, or supply the
   genuinely configured local file/MaxMind prerequisite. Install declared asset
   build tools with `mix assets.setup`. Stop on failures rather than marking
   the phase ready.
4. Run the normal preview startup command with its intended environment and
   capture complete stdout/stderr outside the checkout, command exit status,
   elapsed time, listener address, and HTTP healthcheck response. Retain logs
   independently of a polling receipt so truncation cannot hide the first
   failure. Confirm the tracker watcher builds successfully and representative
   dashboard/tracker resources load. If the healthcheck still fails, diagnose
   the first actual application or HTTP failure before proposing another fix;
   merely extending a timeout is not proof of readiness.
5. Observe Geo loading through the application's configured real data source and
   a representative lookup (the existing test uses `216.160.83.56` -> `US`).
   Verify the preview configuration as well as the test environment: a test
   fixture or passing test in isolation does not prove preview Geo readiness.
6. After preview startup succeeds, let the owning validation workflow execute
   its unchanged normal deterministic checks and record their exact commands,
   results, and report. Run the repository's relevant setup/download/Geo tests
   and normal applicable Elixir and JavaScript checks; do not replace the saved
   checks with the focused tracker probe. Provision any additional services
   required by the actual selected checks from their declared configuration.
   Report failures honestly and retain diagnostics.

## Acceptance and later delivery

- R1: record successful real preview startup and HTTP readiness, with startup
  logs showing no Geo database not-found error or Geo.load_db timeout/MatchError.
- R2: record a successful lookup against the preview's configured real Geo
  source and review the diff for preserved production behavior and features.
- R3: identify actual required services/credentials from configuration and
  observed failures. The default DB-IP path needs no MaxMind credential; request
  a genuine prerequisite only if the selected configuration actually requires it.
- R4: retain the post-startup normal-check report proving checks executed and
  passed. Install/service phase success and focused tests cannot satisfy R4.
- R5: review all changed files to ensure no provider-specific preview provisioning
  or fabricated readiness was introduced. Keep setup recipes external.

No runtime acceptance is claimed in this planning stage. Later delivery should
summarize actual verification evidence and remaining limitations, then prepare
an open PR in `ProjectTathastu/analytics` on the preserved branch (or emit a
compare URL if no GitHub token is bound). Leave it unmerged. This stage creates
only PLAN.md and performs no implementation, commit, push, or PR operation.
