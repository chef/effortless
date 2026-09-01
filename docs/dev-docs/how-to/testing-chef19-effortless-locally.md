# Testing Chef 19 Effortless Pattern Locally

## Overview

This guide explains how to locally test the Chef 19 Effortless pattern using a sample cookbook
when `chef/scaffolding-chef-infra` is available in a test channel such as `unstable` or
`chef-effortless-main-habitat-build` but not yet promoted to `stable`. This is useful for
verifying that the scaffolding works correctly with Chef Infra Client 19 before promoting
packages to production channels.

The guide covers all three supported platforms: Linux x86_64, Linux ARM (aarch64), and
Windows x86_64.

**Scaffolding package idents used in this guide (from `chef-effortless-main-habitat-build` channel):**

| Platform       | Ident                                              |
|----------------|----------------------------------------------------|
| Linux x86_64   | `chef/scaffolding-chef-infra/0.26.1/20260827072125` |
| Linux aarch64  | `chef/scaffolding-chef-infra/0.26.1/20260827072450` |
| Windows x86_64 | `chef/scaffolding-chef-infra/0.26.1/20260827072430` |

> Update the idents above to match the latest packages in the pipeline channel when testing.

---

## Test Project Structure

Create a test project called `effortless-test` with the following structure on your local
machine and copy it to each VM before testing:

```
effortless-test/
├── habitat/
│   ├── plan.sh          # Linux build plan
│   ├── plan.ps1         # Windows build plan
│   └── default.toml     # Service configuration (all platforms)
├── policyfiles/
│   └── hello.rb         # Policyfile
└── cookbooks/
    └── hello/
        ├── metadata.rb
        └── recipes/
            └── default.rb
```

### `habitat/plan.sh`

The ARM ident is active by default. For x86 builds, swap the `pkg_scaffolding` line
(see the x86 build step).

```bash
pkg_name=effortless-test
pkg_origin=np
pkg_version="0.1.0"
# x86_64-linux:  chef/scaffolding-chef-infra/0.26.1/20260827072125
# aarch64-linux: chef/scaffolding-chef-infra/0.26.1/20260827072450
pkg_scaffolding="chef/scaffolding-chef-infra/0.26.1/20260827072450"
scaffold_policy_name="hello"
```

### `habitat/plan.ps1`

```powershell
$pkg_name="effortless-test"
$pkg_origin="np"
$pkg_version="0.1.0"
# x86_64-windows: chef/scaffolding-chef-infra/0.26.1/20260827072430
$pkg_scaffolding="chef/scaffolding-chef-infra/0.26.1/20260827072430"
$scaffold_policy_name="hello"
```

### `habitat/default.toml`

```toml
interval = 1800
splay = 1800
splay_first_run = 0
log_level = "warn"
env_path_prefix = "/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin"

[chef_license]
acceptance = "accept-no-persist"
```

> **Important:** The `[chef_license]` section must use the nested TOML table format shown
> above. A flat key like `chef_license = "accept-no-persist"` will NOT work because the
> scaffolding's run hook template expects `{{cfg.chef_license.acceptance}}`.

### `policyfiles/hello.rb`

```ruby
name "hello"
default_source :supermarket
cookbook "hello", path: "../cookbooks/hello"
run_list ["hello::default"]
```

### `cookbooks/hello/metadata.rb`

```ruby
name "hello"
version "0.1.0"
```

### `cookbooks/hello/recipes/default.rb`

```ruby
log "Hello from Chef 19 Effortless!" do
  level :info
end
```

---

## Linux ARM (aarch64)

> `plan.sh` has the ARM ident active by default — no changes needed before building.

```bash
# 1. Set env vars — repeat at the start of every new session
export HAB_AUTH_TOKEN="<your_token>"
export HAB_LICENSE=accept-no-persist
export HAB_ORIGIN=np

# 2. Install Hab CLI
curl https://raw.githubusercontent.com/habitat-sh/habitat/main/components/hab/install.sh | sudo -E bash

# 3. Create hab group and user — once per VM only
#    The Habitat supervisor requires a 'hab' group to create service directories under /hab/svc/
sudo groupadd hab
sudo useradd -g hab hab

# 4. Install scaffolding from pipeline channel — once per VM only
#    Install using the full 4-part ident so Habitat uses the local cache during build
#    instead of resolving from Builder, avoiding channel conflicts
sudo -E hab pkg install chef/scaffolding-chef-infra/0.26.1/20260827072450 \
  --channel chef-effortless-main-habitat-build

# 5. Generate np origin key and copy to system cache — once per VM only
#    The Hab studio runs as root and reads keys from /hab/cache/keys (system-level cache),
#    not from ~/.hab/cache/keys (user-level cache). Copying ensures the studio can sign
#    the built package correctly.
hab origin key generate np
sudo cp ~/.hab/cache/keys/np-*.sig.key /hab/cache/keys/
sudo cp ~/.hab/cache/keys/np-*.pub /hab/cache/keys/

# 6. Build the package
#    HAB_BLDR_CHANNEL=base-2025 ensures dependencies like core/cacerts resolve to versions
#    compatible with Chef Infra Client 19
cd ~/effortless-test
HAB_BLDR_CHANNEL=base-2025 hab pkg build habitat/

# 7. Install the built hart
source results/last_build.env
sudo -E hab pkg install results/$pkg_artifact

# 8. Start supervisor in background
#    Redirect output to a log file so the terminal stays free
sudo -E hab sup run > /tmp/hab-sup.log 2>&1 &
sleep 10

# 9. Load the service
sudo -E hab svc load $pkg_ident

# 10. Verify — confirm the Chef run completed successfully
sleep 30
sudo hab svc status
sudo tail -50 /tmp/hab-sup.log
sudo grep "Hello from Chef 19" /tmp/hab-sup.log
```

---

## Linux x86_64

> Before building, update `plan.sh` to use the x86 ident (step 6).

```bash
# 1. Set env vars — repeat at the start of every new session
export HAB_AUTH_TOKEN="<your_token>"
export HAB_LICENSE=accept-no-persist
export HAB_ORIGIN=np

# 2. Install Hab CLI
curl https://raw.githubusercontent.com/habitat-sh/habitat/main/components/hab/install.sh | sudo -E bash

# 3. Create hab group and user — once per VM only
#    The Habitat supervisor requires a 'hab' group to create service directories under /hab/svc/
sudo groupadd hab
sudo useradd -g hab hab

# 4. Install scaffolding from pipeline channel — once per VM only
#    Install using the full 4-part ident so Habitat uses the local cache during build
#    instead of resolving from Builder, avoiding channel conflicts
sudo -E hab pkg install chef/scaffolding-chef-infra/0.26.1/20260827072125 \
  --channel chef-effortless-main-habitat-build

# 5. Generate np origin key and copy to system cache — once per VM only
#    The Hab studio runs as root and reads keys from /hab/cache/keys (system-level cache),
#    not from ~/.hab/cache/keys (user-level cache). Copying ensures the studio can sign
#    the built package correctly.
hab origin key generate np
sudo cp ~/.hab/cache/keys/np-*.sig.key /hab/cache/keys/
sudo cp ~/.hab/cache/keys/np-*.pub /hab/cache/keys/

# 6. Update plan.sh to use the x86 ident before building
sed -i 's|pkg_scaffolding="chef/scaffolding-chef-infra/0.26.1/20260827072450"|pkg_scaffolding="chef/scaffolding-chef-infra/0.26.1/20260827072125"|' ~/effortless-test/habitat/plan.sh

# 7. Build the package
#    HAB_BLDR_CHANNEL=base-2025 ensures dependencies like core/cacerts resolve to versions
#    compatible with Chef Infra Client 19
cd ~/effortless-test
HAB_BLDR_CHANNEL=base-2025 hab pkg build habitat/

# 8. Install the built hart
source results/last_build.env
sudo -E hab pkg install results/$pkg_artifact

# 9. Start supervisor in background
#    Redirect output to a log file so the terminal stays free
sudo -E hab sup run > /tmp/hab-sup.log 2>&1 &
sleep 10

# 10. Load the service
sudo -E hab svc load $pkg_ident

# 11. Verify — confirm the Chef run completed successfully
sleep 30
sudo hab svc status
sudo tail -50 /tmp/hab-sup.log
sudo grep "Hello from Chef 19" /tmp/hab-sup.log
```

---

## Windows x86_64 (PowerShell as Administrator)

> `plan.ps1` already has the Windows ident active — no changes needed before building.

```powershell
# 1. Set env vars — repeat at the start of every new session
$env:HAB_AUTH_TOKEN = "<your_token>"
$env:HAB_LICENSE = "accept-no-persist"
$env:HAB_ORIGIN = "np"

# 2. Install Hab CLI
Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/habitat-sh/habitat/main/components/hab/install.ps1'))

# 3. Install scaffolding from pipeline channel — once per VM only
#    Install using the full 4-part ident so Habitat uses the local cache during build
#    instead of resolving from Builder, avoiding channel conflicts
hab pkg install chef/scaffolding-chef-infra/0.26.1/20260827072430 `
  --channel chef-effortless-main-habitat-build

# 4. Generate np origin key — once per VM only
hab origin key generate np

# 5. Build the package
#    On Windows, HAB_BLDR_CHANNEL env var is not inherited by the Hab studio process.
#    Use the --refresh-channel flag instead to ensure dependencies resolve to versions
#    compatible with Chef Infra Client 19
cd C:\effortless-test
hab pkg build habitat/ --refresh-channel base-2025

# 6. Install the built hart
. results\last_build.env
hab pkg install results\$pkg_artifact

# 7. Start supervisor in background
Start-Job { hab sup run }
Start-Sleep -Seconds 10

# 8. Load the service
hab svc load $pkg_ident

# 9. Verify — confirm the Chef run completed successfully
Start-Sleep -Seconds 30
hab svc status
Get-Content C:\hab\svc\effortless-test\logs\default.log -Tail 50
Select-String -Path C:\hab\svc\effortless-test\logs\default.log -Pattern "Hello from Chef 19"
```

---

## Important Notes

- **Step 1 (env vars)** must be repeated at the start of every new SSH/PowerShell session
  on all platforms.
- **One-time setup steps** (hab group/user creation, scaffolding install, key generation)
  only need to be done once per VM.
- **Never run `hab config apply`** during testing — it stores config in the gossip layer
  which takes highest priority and can override `default.toml` values, breaking config
  rendering in unexpected ways.
- **Supervisor logs on Linux** are at `/tmp/hab-sup.log` for debugging.
- **`default.toml` chef_license format** must use the nested `[chef_license]` table structure.
  The Habitat supervisor does not merge the scaffolding's `default.toml` with the package's
  at runtime — it only reads the installed package's `default.toml`. The nested structure
  matches the scaffolding's Handlebars template which expects `{{cfg.chef_license.acceptance}}`.
