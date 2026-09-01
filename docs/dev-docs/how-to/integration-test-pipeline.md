# Integration Test Pipeline for scaffolding-chef-infra

## Overview

The `integration-test` pipeline validates the **published** `chef/scaffolding-chef-infra` package against the **latest** `chef/chef-infra-client` from the `unstable` channel. It is the pre-release quality gate that catches integration issues before packages are promoted to `base-2025`.

## Why This Pipeline Exists

There are two test pipelines for `scaffolding-chef-infra`:

| Pipeline | When it runs | What it tests |
|---|---|---|
| `verify` | Every PR | Scaffolding built **from source** against `base-2025` deps |
| `integration-test` | After every `habitat/build` succeeds | **Published** scaffolding from unstable against **latest chef-infra-client** from unstable |

The `verify` pipeline catches regressions in scaffolding source code. The integration test pipeline catches the harder-to-catch class of issues: **does the just-published scaffolding package actually work with the version of chef-infra-client that will ship alongside it?**

Without this pipeline, a packaging issue (e.g. a dependency version conflict, a broken cacerts chain, a changed chef-infra-client API) could go unnoticed until the packages were already in `base-2025` and in users' hands.

## Channel Strategy

```
chef/scaffolding-chef-infra  -->  latest from unstable  (just published by habitat/build)
chef/chef-infra-client       -->  latest from unstable  (pre-installed by CI script)
core/* and all other deps    -->  base-2025             (stable, tested, prevents flakiness)
```

**Why not unstable for everything?**  
`core/*` packages in `unstable` can contain broken or experimental builds unrelated to Chef. Using `base-2025` for everything except the two chef-owned packages isolates test failures to what we actually care about.

**Why not base-2025 for everything?**  
`chef/scaffolding-chef-infra` and `chef/chef-infra-client` are not yet in `base-2025` — they are promoted there only at release time. The whole point of this pipeline is to test the combination *before* that promotion.

## How the Pre-Install Mechanism Works

### Linux (bind-mount trick)

Linux Habitat studios bind-mount the host's `/hab/pkgs` into the studio. The CI script exploits this:

1. Installs exact idents from `unstable` on the **host** before starting the studio
2. Starts the studio with `HAB_BLDR_CHANNEL=base-2025`
3. When the build resolves `chef/scaffolding-chef-infra` and `chef/chef-infra-client`, Habitat finds them already in the bind-mounted `/hab/pkgs` and uses those cached versions
4. All `core/*` and other deps are resolved from `base-2025` as normal

The exact idents are injected into the studio via `HAB_STUDIO_SECRET_INTEGRATION_SCAFFOLDING_IDENT` and `HAB_STUDIO_SECRET_INTEGRATION_CHEF_CLIENT_IDENT`, which become available as environment variables inside the studio. The test plan's `plan.sh` reads these to pin `pkg_scaffolding` and `scaffold_chef_client`.

### Windows (in-studio install)

Windows Habitat studios do **not** bind-mount the host package cache. Instead:

1. The CI script resolves the latest unstable idents via `hab pkg show`
2. Starts a studio session and installs those exact idents from `unstable` **inside the studio**
3. Sets `HAB_BLDR_CHANNEL=base-2025` for the build step
4. The build finds the pre-installed packages in the studio's local cache

## How It Is Triggered

### Trigger Flow

```
PR merged to main
       │
       ▼
┌─────────────────────────────────────────────────────────┐
│  Expeditor: buildkite_merged_pr workload                │
│  triggers ──▶  habitat/build  pipeline                  │
└─────────────────────────────────────────────────────────┘
       │
       │  builds & publishes to unstable for all platforms:
       │    x86_64-linux  •  aarch64-linux  •  x86_64-windows
       ▼
┌─────────────────────────────────────────────────────────┐
│  Expeditor: buildkite_hab_build_group_published         │
│  fires once — after ALL platforms publish               │
│                                                         │
│  Parallel actions:                                      │
│    ┌──────────────────────┐  ┌────────────────────────┐ │
│    │ promote_habitat_     │  │ trigger_pipeline:      │ │
│    │ packages             │  │ habitat/integration-   │ │
│    │ (unstable → current) │  │ test                   │ │
│    └──────────────────────┘  └────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │  integration-test   │
                         │  (Buildkite)                │
                         │                             │
                         │  Runs per platform:         │
                         │    • Linux x86_64           │
                         │    • Linux aarch64          │
                         │    • Windows x86_64         │
                         │                             │
                         │  Package sources:           │
                         │  chef/scaffolding-chef-     │
                         │  infra + chef-infra-client  │
                         │    ── from current channel  │
                         │  core/* & all other deps    │
                         │    ── from base-2025        │
                         └─────────────────────────────┘
```

### Why `buildkite_hab_build_group_published`?

This Expeditor workload fires **once**, only after **every configured platform** has published its package — not on each individual platform publish. This prevents the integration test from triggering multiple times per build (once per platform) and ensures all platform packages are available before the test starts.

### Timing and Channel Promotion

```
habitat/build publishes all platforms to unstable
                       │
                       │  ← buildkite_hab_build_group_published fires here
                       │
            ┌──────────┴──────────┐
            │                     │
            ▼                     ▼
  unstable → current     integration-test
  (seconds later)        (pulls from current)
```

Because `promote_habitat_packages` and `trigger_pipeline:integration-test` both fire from the same workload, the promotion to `current` and the integration test start simultaneously. By the time Buildkite agents spin up and begin executing, both packages are already in `current`.

### Expeditor Config Excerpt

```yaml
# .expeditor/config.yml
- workload: buildkite_hab_build_group_published:{{agent_id}}:*
  actions:
    - built_in:promote_habitat_packages   # unstable → current
    - trigger_pipeline:integration-test
```

## Test Packages

The sample user packages used by this pipeline live permanently in the repo:

```
scaffolding-chef-infra/tests/user-linux-integration/    # Linux test package
scaffolding-chef-infra/tests/user-windows-integration/  # Windows test package
```

Each test package contains:
- `habitat/plan.sh` (or `plan.ps1`) — uses env var injection for exact idents
- `policyfiles/ci.rb` — minimal policyfile
- `cookbooks/ci/` — minimal cookbook that writes a test file
- `tests/test.sh` (or `test.ps1`) + `test.bats` (or `test.pester.ps1`) — validates the run

The test asserts:
1. Chef 19 executed successfully (cookbook-created file exists with correct content)
2. The installed `chef-infra-client` is version 19.x
3. Config files render correctly (`bootstrap-config.rb`, `client-config.rb`)
4. `core/cacerts` SSL cert paths render in the run hook

## Files

| File | Purpose |
|---|---|
| `.expeditor/integration-test.scaffolding-chef-infra.yml` | Buildkite pipeline definition |
| `bin/ci/integration-test.sh` | Linux CI script |
| `bin/ci/integration-test.ps1` | Windows CI script |
| `scaffolding-chef-infra/tests/user-linux-integration/` | Linux test package |
| `scaffolding-chef-infra/tests/user-windows-integration/` | Windows test package |

## Interpreting Failures

| Failure symptom | Likely cause |
|---|---|
| Build fails resolving `core/cacerts` (duplicate version conflict) | `chef-infra-client` was built against an older `cacerts` than what `base-2025` now has. The client needs to be rebuilt against the current `core/cacerts`. |
| Build fails resolving `chef/chef-infra-client` | The latest unstable client has a packaging issue. Check the chef/chef habitat/build pipeline. |
| Tests pass but `chef-infra-client` version is not 19.x | The `unstable` channel resolved an older version. Check if a Chef 19 build is available in unstable. |
| Windows build succeeds, Linux fails (or vice versa) | Platform-specific dependency conflict. Check the dependency graph in the error output. |

## Running Locally

```bash
# Linux
export HAB_AUTH_TOKEN="<your-token>"
./bin/ci/integration-test.sh scaffolding-chef-infra user-linux-integration ci

# Windows
$env:HAB_AUTH_TOKEN = "<your-token>"
.\bin\ci\integration-test.ps1 scaffolding-chef-infra user-windows-integration
```
