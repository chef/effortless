#
# A scaffolding for an InSpec profile
#
if(!$scaffold_inspec_client){
    $scaffold_inspec_client = "chef/inspec"
}
if(!$scaffold_cacerts){
    $scaffold_cacerts = "core/cacerts"
}

$scaffolding_package = $pkg_scaffolding.split("/")[1]
$lib_dir = "$(Get-HabPackagePath $scaffolding_package)/lib"

function Load-Scaffolding {
    $pkg_deps += @(
        $scaffold_inspec_client,
        $scaffold_cacerts
    )

    $pkg_svc_user="administrator"
    $pkg_svc_run = "set_just_so_you_will_render"
}

function Invoke-DefaultBefore {
    $env:CHEF_LICENSE='accept-no-persist'
    if(!(Test-Path "$PLAN_CONTEXT/../inspec.yml")) {
        Write-BuildLine "Error: Cannot find inspec.yml"
        Write-BuildLine "  Please build from the profile root"
        exit 1
    }

    if((Select-String -Path "$PLAN_CONTEXT/../inspec.yml" -Pattern "compliance: ")){
        if(!$scaffold_automate_server_url){
            Write-BuildLine "You have a dependency on a profile in Automate"
            Write-BuildLine " please specify the `$scaffold_automate_server_url"
            Write-BuildLine " in your plan.ps1 file."
            exit 1
        }
        elseif(!$scaffold_automate_user){
            Write-BuildLine "You have a dependency on a profile in Automate"
            Write-BuildLine " please specify the `$scaffold_automate_user"
            Write-BuildLine " in your plan.ps1 file."
            exit 1
        }
        elseif(!$scaffold_automate_token){
            Write-BuildLine "You have a dependency on a profile in Automate"
            Write-BuildLine " please specify the `$scaffold_automate_token"
            Write-BuildLine " in your plan.ps1 file."
            exit 1
        }
        else{
          inspec compliance login "$scaffold_automate_server_url" `
                            --user "$scaffold_automate_user" `
                            --token "$scaffold_automate_token"
        }
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
    $dir = "$pkg_prefix/hooks"
    if (!(Test-Path -Path $dir)) {
        New-Item -ItemType directory -Path $dir
    }

    (Get-Content -Path "$lib_dir/run.ps1") -join "`n" | Foreach-Object {
        $_ -replace 'scaffold_inspec_client', $scaffold_inspec_client `
           -replace 'scaffold_cacerts', $scaffold_cacerts
    } | Set-Content "$pkg_prefix/hooks/run"
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
          "stdout": true
        }{{#if cfg.automate.enable ~}},
        "automate" : {
          "url": "{{cfg.automate.server_url}}/data-collector/v0/",
          "token": "{{cfg.automate.token}}",
          "node_name": "{{ sys.hostname }}",
          "verify_ssl": false{{#if cfg.automate.environment}},
          "environment": "{{cfg.automate.environment}}"{{/if }}
        }{{/if }}
    }
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

[chef_license]
acceptance = "undefined"

[automate]
enable = false
server_url = 'https://<automate_url>'
token = '<automate_token>'
user = '<automate_user>'
"@

    Add-Content -Path "$pkg_prefix/config/waiver.yml" -Value @"
{{#if cfg.waivers ~}}
{{toYaml cfg.waivers}}
{{/if ~}}
"@
}
