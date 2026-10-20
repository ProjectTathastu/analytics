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

## Focused follow-up — native ClickHouse configuration permissions

Preserve the application repairs and normal checks. For a native server running
without root, the packaged XML's data and log paths must be writable before
configuration preprocessing. Command-line overrides alone do not establish this
requirement. The packaged configuration also declares a custom disk cache path
separately from the main data directory.

Make one documentation commit in `CONTRIBUTING.md` explaining the native-server
path requirement and `users.xml` resolution. Keep environment-specific service
configuration outside the application repository. In the external setup
proposal, generate the complete writable XML before the managed foreground
server starts, retaining the required database service and failure propagation.
Use the existing pinned binary and packaged users configuration.

Focused verification: preprocess the generated configuration with ClickHouse's
`extract-from-config`; inspect data, cache, log, access and users paths; exercise
temporary writable storage and failure on unavailable configuration or unwritable
storage. These checks establish configuration preparation only. Managed service
readiness, real preview startup, Geo lookup and normal validation still require
the owning workflow. Do not start a replacement service or claim runtime
acceptance from static configuration checks.

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

## Implementation record — revision 2

The implementation stage preserved all eight existing repair commits and saved
the untracked triage notes at `/tmp/analytics-startup-evidence/TRIAGE.md` outside
the source tree. Contributor guidance now documents the tracker installation
boundary and the actual compiler probe/build sequence without changing packages,
watchers, geolocation, normal checks, or runtime failure handling.

Focused verification on 2026-10-18 used the declared Node 24.17.0 with npm
11.13.0. Both `npm ci --prefix assets` and `npm ci --prefix tracker` exited 0;
`node --test tracker/compiler/startup.test.js` passed its one test, and
`npm run deploy --prefix tracker` exited 0 after compiling all 1,028 variants.
The deploy log is retained outside Git at
`/tmp/analytics-startup-evidence/tracker-deploy.log`. Generated tracker outputs
remain ignored build artifacts; manifests and lockfiles did not change.

Bounded inspection again found no ClickHouse process/listener on 8123 or preview
server log. `/ping` and the exact report URL both refused connections. This
corroborates the current missing service, but cannot reconstruct attempt 12's
07:06:59–07:07:05 window or the fresh trial's truncated startup output. The
ClickHouse adapter's `storage_up/1` connects before executing `CREATE DATABASE`
and propagates connection failure; both repositories remain required. No
application workaround or weakened readiness check is justified.

The declared Node toolchain and official ClickHouse 25.11.5.8 binary were
installed; its version was confirmed without starting an unmanaged service.
A portable external setup proposal accompanies the final commit for managed
ClickHouse and explicit npm installation/build. Its service lifecycle and fresh
workspace behavior remain for the owning setup workflow to verify. The saved
setup/check definitions are not exposed through an available owning interface
in this session; their absence from the repository is not a missing prerequisite.
Configured validation, database creation/migration, Phoenix startup, and
publication were left to Replicorg as required by this implementation stage.
R1, R2's preview lookup, and R4 therefore remain unproven; no passing preview,
successful full validation, or published PR is claimed.

## Authorized revision 5 — deterministic test lifecycle repair

The operator's latest fresh-master report supersedes the earlier startup
failures: installation, assets/country data, isolated databases, migrations and
preview readiness succeeded. The unchanged four-case full suite passed 6394 of
6396 tests, with 69 existing exclusions; an earlier identical-source run passed
all 6396. This is evidence of intermittency, not proof of an application defect.
Preserve all existing repairs and normal checks; keep publication to the owning
stage and leave the PR unmerged.

Source inspection identifies two test lifecycle hazards to repair in focused
commits, within the authorized nondeterminism investigation:

1. `Double.stub/3` starts a new double for each billing stub and its synchronous
   `{:allow, ...}` GenServer call invokes `Code.eval_string/1` to compile a new
   module before replying. It therefore includes compiler/code-server latency in
   the default five-second call deadline. Replace only this worker test's dynamic
   doubles with a once-defined Mox module and process-owned responses. Preserve
   every usage value, billing/email assertion and the two-call grace-period
   transition. Include a missing-response failure assertion. This removes runtime
   compilation from registration, without claiming to reproduce the original
   timeout or increasing it.
2. The late-update dismissal test starts checks with zero delay and immediately
   successful HTTP responses, then expects an in-progress render. Completion and
   that render race. Gate the real mocked HTTP response with a message handshake,
   dismiss while it is pending, then release it and observe actual completion.
   Cover late success and late service failure, preserving failure reporting and
   hidden-banner assertions. Do not add sleeps or application-only test hooks.

Focused verification may exercise the mock lifecycle independently with compiled
Mox dependencies and parse/format the changed files. Do not run the configured
Mix test alias or full validation. Application-level tests require managed
ClickHouse; do not replace managed processes. On this turn, bounded inspection
found no ClickHouse listener on 8123, no preview log or ClickHouse service log,
and the report endpoint on 4000 refused connections. That cannot establish the
cause of attempt 17 at its recorded timestamp. No connection workaround or new
setup change is justified by those observations, especially given the newer
successful preview report. Capture an empty setup patch if no settings change is
needed; do not re-propose the older unadopted setup over newer operator evidence.
Runtime acceptance and a passing full-suite report remain the owning workflow's
responsibility and must not be inferred from these focused checks.

Billing repair verification: a standalone probe loaded the actual test mock
declaration and passed five focused lifecycle tests under the declared toolchain
with four schedulers/cases: 400 response registrations/replacements across four
independent owners, plus failure for an owner without a response. The initial
probe using the shell's OTP 27/Elixir 1.19 could not load OTP 28 BEAM files; using
`mise exec` selected the repository's OTP 28/Elixir 1.20 and passed. No dependency
artifacts were rebuilt. Worker regressions additionally require missing responses
and usage-retrieval errors to propagate before email/grace-period side effects.
These database-dependent regressions remain for the owning validation stage;
the standalone probe is not a full-suite or preview acceptance result.

Late-update repair verification: a standalone probe extracted the actual response
handshake callback from the changed test. Both focused checks passed: the
response remains blocked until its matching release (including rejection of an
unrelated release), and a dead test owner terminates the pending callback. The
source parses and formats under the declared Elixir toolchain and the diff passes
whitespace checks. The retained LiveView regressions exercise the real check
pipeline through Req.Test, then require the success/failure text, correct
onboarding status, client disconnect event and hidden banner after completion.
No production file, timeout, exclusion or configured check was changed by these
two commits. Full application checks were not run; managed ClickHouse still has
no listener or captured service log in this workspace. No current observation
reconstructs attempt 17 or supersedes the newer successful startup report.
The final setup receipt proposes no changes to the saved settings.

## Authorized revision 6 — restore dependency setup without application changes

Preserve `c6fd0b1` and `084ef2d`, their assertions, and all earlier repairs.
Attempt 19 failed during database creation, before application assertions. The
operator identifies the restored workspace's stopped ClickHouse as the cause and
supplies the previously startup-tested setup. Capture that setup externally for
review against saved settings; keep service lifecycle under the managed runner.
Do not introduce application provisioning, bypass connection failures, extend
test timeouts, or run the configured full validation in this implementation turn.

Focused work:

1. Inspect current listener/process state and bounded available diagnostics.
   Confirm whether the connection is refused before attributing a code defect.
2. Exercise the supplied pinned ClickHouse installation and writable XML
   preparation, npm installations, asset builds, and real country download.
   Check configuration failure propagation without starting a replacement
   service. Preserve build output as ignored artifacts and scratch evidence
   outside the checkout.
3. Recheck the two retained lifecycle repairs with focused probes and the real
   country loader/lookup. Keep their scope distinct from application tests.
4. Capture portable external recipes, foreground service command, database
   preparation and preview settings for managed startup. Retain the normal Mix
   suite with the authorized four-case concurrency. The owning runner must start
   ClickHouse, execute application checks and record fresh acceptance evidence.

Current inspection confirms PostgreSQL listening on 5432 and no ClickHouse
listener on 8123; the HTTP ping refuses connections. No ClickHouse server log
or preview server log is available here to reconstruct the earlier command
window. No application code change is warranted by this dependency failure.
The current tools expose no managed service restart operation; preparing its
configuration does not establish running-service readiness. Publication remains
with the later stage; do not push, open, or merge a PR from this session.

Revision 6 focused results: the pinned ClickHouse binary/config installation,
both `npm ci` commands, asset tool setup, real country download/gzip check,
tracker deploy (1,028 variants) and `mix assets.build` completed successfully.
The compiler startup probe passed. Five billing lifecycle probes and two
response-gate probes passed against the retained test source. Writable XML
checks passed for fresh storage, repeat preparation preserving existing data,
and nonzero failure with unwritable storage, missing packaged XML or missing
users XML. The actual Geo loader loaded the downloaded DB-IP Country Lite data
and returned US for `216.160.83.56`. No placeholder data or credentials were used.

The external setup capture includes the supplied operator recipes and managed
foreground ClickHouse command. Shell syntax and patch structure were checked;
no database preparation, managed service launch, Phoenix preview or full suite
was executed here. Those commands require the managed lifecycle and remain for
fresh verification; capture is a proposal rather than adoption or proof. The
normal four-case full suite, connection errors, existing assertions and
production behavior remain intact. No runtime/application source changes were
needed in this revision. Scratch diagnostics and the setup receipt stay outside
Git; ignored generated output is retained for the owning validation stage.

## Focused follow-up — distinguish late service and browser failures

The late-dismissal regression must exercise the real producer/consumer contract.
`VerifyInstallation.handle_browserless_response/3` maps an HTTP 200 body with
`data.completed: false` to `:browserless_client_error`. Arbitrary browser errors
use the existing unhandled-installation interpretation; they do not imply the
Browserless service was unavailable. An HTTP 503 without completed diagnostics
maps to `:bad_browserless_response`, whose interpretation reports temporary
service unavailability. The retry policy does not retry 503. Preserve both
interpretations and their existing observability, rather than reclassifying
production errors to satisfy a test fixture.

Focused commit: update only the late-dismissal test's response construction to
cover HTTP 200 success, HTTP 503 service unavailability, and the original HTTP
200 browser error separately. Keep the response gate, in-progress assertion,
dismissal/disconnect assertion, actual completion, hidden-banner assertion and
onboarding expectations. Compare decoded heading text so HTML entity escaping
cannot disguise the browser-error result. Restore the shared JSON stub's simple
single-argument interface now that the gated test stubs whole HTTP responses.

Verification: run the LiveView verification tests and existing verification
observability tests with four cases. These exercise the real check pipeline and
failure reporting without running the configured full validation. No application
code, timeout, exclusions, managed services or setup commands change. Preserve
the existing external setup proposal and update its receipt to the final commit;
adoption, full validation and publication remain with the owning workflow.
