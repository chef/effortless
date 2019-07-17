#
# A scaffolding for an InSpec profile
#

function Load-Scaffolding {
    $pkg_deps += @(
        "${pkg_deps[@]}"
        "stuartpreston/inspec"
    )
    $pkg_build_deps += @(
        "${pkg_build_deps[@]}"
        "stuartpreston/inspec"
    )

    $pkg_svc_user="administrator"
    $pkg_svc_run = "set_just_so_you_will_render"
}

function Invoke-DefaultBefore {
    if(!(Test-Path "$PLAN_CONTEXT/../inspec.yml")) {
        Write-BuildLine "Error: Cannot find inspec.yml"
        Write-BuildLine "  Please build from the profile root"
        exit 1
    }

    if((Select-String -Path "$PLAN_CONTEXT/../inspec.yml" -Pattern "compliance: ")){
        Invoke-ComplianceLogin
    }
}

function Invoke-DefaultSetupEnvironment {
    Set-BuildtimeEnv $PROFILE_CACHE_DIR "$HAB_CACHE_SRC_PATH/$pkg_dirname"
    Set-BuildtimeEnv $ARCHIVE_NAME "$pkg_name-$pkg_version.tar.gz"
}

function Invoke-DefaultUnpack {
    New-Item -ItemType Directory -Path "$HAB_CACHE_SRC_PATH/$pkg_dirname"
    Copy-Item $PLAN_CONTEXT/../* "$HAB_CACHE_SRC_PATH/$pkg_dirname" -Exclude habitat,results,*.harts -Recurse -Force
}

function Invoke-DefaultBuildService {
    Write-BuildLine "Creating lifecycle hooks"
    New-Item -ItemType Directory -Path "$pkg_prefix/hooks"

    Add-Content -Path "$pkg_prefix/hooks/run" -Value @"
`$env:PATH = "{{pkgPathFor "stuartpreston/inspec"}}/bin;`$env:PATH"

`$env:CFG_SPLAY_FIRST_RUN="{{cfg.splay_first_run}}"
if(!`$env:CFG_SPLAY_FIRST_RUN) {
    `$env:CFG_SPLAY_FIRST_RUN = "0"
}
`$env:CFG_INTERVAL="{{cfg.interval}}"
if(!`$env:CFG_INTERVAL){

}
`$env:CFG_SPLAY="{{cfg.splay}}"
if(!`$env:CFG_SPLAY){
    `$env:CFG_SPLAY = "1800"
}
`$env:CFG_LOG_LEVEL="{{cfg.log_level}}"
if (!`$env:CFG_LOG_LEVEL){
    `$env:CFG_LOG_LEVEL = "warn"
}
`$env:CFG_CHEF_LICENSE="{{cfg.chef_license.acceptance}}"
if(!`$env:CFG_CHEF_LICENSE){
    `$env:CFG_CHEF_LICENSE = "undefined"
}
`$CONFIG="{{pkg.svc_config_path}}/inspec_exec_config.json"
`$PROFILE_PATH="{{pkg.path}}/{{pkg.name}}-{{pkg.version}}.tar.gz"

function Invoke-Inspec {
    inspec exec `$PROFILE_PATH --config `$CONFIG --log-level `$CFG_LOG_LEVEL
}

`$SPLAY_DURATION = Get-Random -InputObject (0..`$env:CFG_SPLAY) -Count 1

`$SPLAY_FIRST_RUN_DURATION = Get-Random -InputObject (0..`$env:CFG_SPLAY_FIRST_RUN) -Count 1


Start-Sleep -Seconds `$SPLAY_FIRST_RUN_DURATION
Invoke-Inspec

while(`$true){
  `$SLEEP_TIME = `$SPLAY_DURATION + `$env:CFG_INTERVAL
  Write-Host "InSpec is sleeping for `$SLEEP_TIME seconds"
  Start-Sleep -Seconds `$SPLAY_DURATION
  Start-Sleep -Seconds `$env:CFG_INTERVAL
  Invoke-Inspec
}
"@
}

function Invoke-DefaultBuild {
    inspec archive "$HAB_CACHE_SRC_PATH/$pkg_dirname" `
                   --overwrite `
                   -o "$HAB_CACHE_SRC_PATH/$pkg_dirname/$pkg_name-$pkg_version.tar.gz"
}

function Invoke-DefaultInstall {
    Copy-Item "$HAB_CACHE_SRC_PATH/$pkg_dirname/$pkg_name-$pkg_version.tar.gz" "$pkg_prefix"
    New-Item -Type Directory $pkg_prefix/config

    Write-BuildLine "Generating config/cli_only.json"
    Add-Content -Path "$pkg_prefix/config/cli_only.json" -Value @"
{
    "reporter": {
        "cli" : {
            "stdout" : true
        }
    }
}
"@

    Write-BuildLine "Generating config/inspec_exec_config.json"
    Add-Content -Path "$pkg_prefix/config/inspec_exec_config.json" -Value @"
{
    "target_id": "{{ sys.member_id }}",
    "reporter": {
        "cli": {
          "stdout": {{cfg.report_to_stdout}}
        },
        "json": {
          "file": "{{pkg.svc_path}}/logs/inspec_last_run.json"
        }{{#if cfg.automate.enable ~}},
        "automate" : {
          "url": "{{cfg.automate.server_url}}/data-collector/v0/",
          "token": "{{cfg.automate.token}}",
          "node_name": "{{ sys.hostname }}",
          "verify_ssl": false
        }{{/if ~}}
    }
    {{#if cfg.automate.enable }},
    "compliance": {
      "server" : "{{cfg.automate.server_url}}",
      "token" : "{{cfg.automate.token}}",
      "user" : "{{cfg.automate.user}}",
      "insecure" : true,
      "ent" : "automate"
    }{{/if }}
}
"@

    Write-BuildLine "Generating Chef Habitat configuration default.toml"
    Add-Content -Path "$pkg_prefix/default.toml" -Value @"
# You must accept the Chef License to use this software: https://www.chef.io/end-user-license-agreement/
# Change [chef_license] from acceptance = "undefined" to acceptance = "accept-no-persist" if you agree to the license.

interval = 1800
splay = 1800
splay_first_run = 0
log_level = 'warn'
report_to_stdout = true

[chef_license]
acceptance = "undefined"

[automate]
enable = false
server_url = 'https://<automate_url>'
token = '<automate_token>'
user = '<automate_user>'
"@
}

function Invoke-ComplianceLogin {
    if (!$COMPLIANCE_CREDS){
        Write-BuildLine "ERROR: Please preform an 'inspec compliance login' and set"
        Write-BuildLine " `$HAB_STUDIO_SECRET_COMPLIANCE_CREDS to the contents of"
        Write-BuildLine " '~/.inspec/compliance/config.json'"
        exit 1
    }

    $creds = Get-Content $COMPLIANCE_CREDS | ConvertFrom-Json

    inspec compliance login --insecure $creds.insecure `
                            --user $creds.user `
                            --token $creds.token `
                            "$($creds.server)/api/v0/"
}
