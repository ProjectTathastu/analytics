import assert from 'node:assert/strict'
import { spawnSync } from 'node:child_process'
import test from 'node:test'
import { fileURLToPath } from 'node:url'

// Run after setup: node --test tracker/compiler/startup.test.js
// Trial a030eac0-bfa6-4c4e-888a-af61dd4fb6cd passed installs but the
// Phoenix tracker watcher failed importing @swc/core. Exercise its real npm
// entry point and working directory without requiring Phoenix or databases.
test('tracker deploy can load its compiler dependencies after setup', () => {
  // --help still loads the compiler's static imports (including native SWC),
  // but exits before compilation can write generated tracker assets.
  const result = spawnSync('npm', ['run', 'deploy', '--', '--help'], {
    cwd: fileURLToPath(new URL('..', import.meta.url)),
    encoding: 'utf8',
    timeout: 30_000
  })

  assert.ifError(result.error)
  assert.equal(
    result.status,
    0,
    `Tracker startup failed (signal: ${result.signal}):\n${result.stdout}\n${result.stderr}`
  )
  assert.match(result.stdout, /Usage: node compile\.js \[flags\]/)
})
