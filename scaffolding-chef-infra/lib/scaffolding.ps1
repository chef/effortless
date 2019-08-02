#
# A scaffolding for Chef Policyfile packages
#

if(!$scaffold_policy_name) {
    Write-Error "You must set `$scaffold_policy_name to a valid policy name. `nTry: `$scaffold_policy_name=example"
    exit 1
}

# TODO: Clean up this check when Load-Scaffolding is fixed
# https://github.com/habitat-sh/habitat/issues/6671
if([string]::IsNullOrWhiteSpace("$scaffold_policyfile_path")){
    Write-Buildline "`$scaffold_policyfile_path is null, empty string, or white space."
    Write-BuildLine "  Setting default `$scaffold_policyfile_path to:"
    Write-BuildLine "  `$PLAN_CONTEXT\..\policyfiles"
    $scaffold_policyfile_path = "$PLAN_CONTEXT\..\policyfiles"
}
if(!(Test-Path -Path "$scaffold_policyfile_path")) {
    Write-Error "`$scaffold_policy_path is not a valid path."
    exit 1
}

function Load-Scaffolding {
    $scaffold_chef_client = "stuartpreston/chef-client"
    $scaffold_chef_dk = "core/chef-dk"
    $scaffold_cacerts = ""
    $scaffold_policyfile_path = "$PLAN_CONTEXT\..\policyfiles"
    $scaffold_data_bags_path = "$PLAN_CONTEXT\..\data_bags"

    $pkg_deps += @(
        "$scaffold_chef_client"
    )
    if(![string]::IsNullOrWhiteSpace("$scaffold_cacerts")){
        $pkg_deps += @($scaffold_cacerts)
    } else{
        $pkg_deps += @("core/cacerts")
    }

    $pkg_build_deps += @(
        "$scaffold_chef_dk"
        "core/git"
    )

    $pkg_svc_user="administrator"
    $pkg_svc_run = "set_just_so_you_will_render"
}

function Invoke-SetupEnvironment {
    if(![string]::IsNullOrWhiteSpace("$scaffold_cacerts")){
        Set-RuntimeEnv "CFG_CACERTS" "${scaffold_cacerts}"
    }
}

function Invoke-DefaultBuildService {
    Write-BuildLine "Creating lifecycle hooks"

    # Only create the directory if it does not exist
    $dir = "$pkg_prefix/hooks"
    if (!(Test-Path -Path $dir)) {
        New-Item -ItemType directory -Path $dir
    }

    Add-Content -Path "$pkg_prefix/hooks/run" -Value @"
`$env:CFG_ENV_PATH_PREFIX = "{{cfg.env_path_prefix}}"
if(!`$env:CFG_ENV_PATH_PREFIX){
    `$env:CFG_ENV_PATH_PREFIX = ";C:/WINDOWS;C:/WINDOWS/system32/;C:/WINDOWS/system32/WindowsPowerShell/v1.0;C:/ProgramData/chocolatey/bin"
}

`$env:CFG_INTERVAL = "{{cfg.interval}}"
if(!`$env:CFG_INTERVAL){
    `$env:CFG_INTERVAL = "1800"
}

`$env:CFG_LOG_LEVEL = "{{cfg.log_level}}"
if(!`$env:CFG_LOG_LEVEL){
    `$env:CFG_LOG_LEVEL = "warn"
}

`$env:CFG_RUN_LOCK_TIMEOUT = "{{cfg.run_lock_timeout}}"
if(!`$env:CFG_RUN_LOCK_TIMEOUT){
    `$env:CFG_RUN_LOCK_TIMEOUT = "1800"
}

`$env:CFG_SPLAY = "{{cfg.splay}}"
if(!`$env:CFG_SPLAY){
    `$env:CFG_SPLAY = "1800"
}

`$env:CFG_SPLAY_FIRST_RUN = "{{cfg.splay_first_run}}"
if(!`$env:CFG_SPLAY_FIRST_RUN){
    `$env:CFG_SPLAY_FIRST_RUN = "0"
}

`$env:CFG_SSL_VERIFY_MODE = "{{cfg.ssl_verify_mode}}"
if(!`$env:CFG_SSL_VERIFY_MODE){
    `$env:CFG_SSL_VERIFY_MODE = "verify_peer"
}

`$env:CFG_CHEF_LICENSE = "{{cfg.chef_license.acceptance}}"
if(!`$env:CFG_CHEF_LICENSE){
    `$env:CFG_CHEF_LICENSE = "undefined"
}

if(`$env:CFG_CHEF_LICENSE -eq "undefined"){
    `$env:CFG_CHEF_LICENSE_CMD = ""
} else {
    `$env:CFG_CHEF_LICENSE_CMD = "--chef-license `$env:CFG_CHEF_LICENSE"
}

function Invoke-ChefClient {
  {{pkgPathFor "stuartpreston/chef-client"}}/bin/chef-client.bat -z -l `$env:CFG_LOG_LEVEL -c {{pkg.svc_config_path}}/client-config.rb -j {{pkg.svc_config_path}}/attributes.json --once --no-fork --run-lock-timeout `$env:CFG_RUN_LOCK_TIMEOUT `$env:CFG_CHEF_LICENSE_CMD
}

`$SPLAY_DURATION = Get-Random -InputObject (0..`$env:CFG_SPLAY) -Count 1

`$SPLAY_FIRST_RUN_DURATION = Get-Random -InputObject (0..`$env:CFG_SPLAY_FIRST_RUN) -Count 1

`$env:SSL_CERT_FILE="{{pkgPathFor "$(if(![string]::IsNullOrWhiteSpace("$env:CFG_CACERTS")){$env:CFG_CACERTS} else{'core/cacerts'})"}}/ssl/cert.pem"
`$env:SSL_CERT_DIR="{{pkgPathFor "$(if(![string]::IsNullOrWhiteSpace("$env:CFG_CACERTS")){$env:CFG_CACERTS} else{'core/cacerts'})"}}/ssl/certs"

cd {{pkg.path}}

Start-Sleep -Seconds `$SPLAY_FIRST_RUN_DURATION
Invoke-ChefClient

while(`$true){
  Start-Sleep -Seconds `$SPLAY_DURATION
  Start-Sleep -Seconds `$env:CFG_INTERVAL
  Invoke-ChefClient
}
"@
}

function Invoke-DefaultBuild {
    Remove-Item "$scaffold_policyfile_path/*.lock.json" -Force
    $policyfile = "$scaffold_policyfile_path/$scaffold_policy_name.rb"

    Get-Content $policyfile | ? { $_.StartsWith("include_policy") } | % {
        $p = $_.Split()[1]
        $p = $p.Replace("`"", "").Replace(",", "")
        Write-BuildLine "Detected included policyfile, $p.rb, installing"
        chef install "$scaffold_policyfile_path/$p.rb"
    }
    Write-BuildLine "Installing $policyfile"
    chef install "$policyfile"
}

function Invoke-DefaultInstall {
    Write-BuildLine "Exporting Chef Infra Repository"
    chef export "$scaffold_policyfile_path/$scaffold_policy_name.lock.json" "$pkg_prefix"

    Write-BuildLine "Creating Chef Infra configuration"

    $dir = "$pkg_prefix/.chef"
    if (!(Test-Path -Path $dir)) {
        New-Item -ItemType directory -Path $dir
    }

    $dir = "$pkg_prefix/config"
    if (!(Test-Path -Path $dir)) {
        New-Item -ItemType directory -Path $dir
    }

    Add-Content -Path "$pkg_prefix/.chef/config.rb" -Value @"
cache_path "$($ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("$pkg_svc_data_path/cache").Replace("\","/"))"
node_path "$($ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("$pkg_svc_data_path/nodes").Replace("\","/"))"
role_path "$($ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath("$pkg_svc_data_path/roles").Replace("\","/"))"
chef_zero.enabled true
ENV['PSModulePath'] = "C:/Program\ Files/WindowsPowerShell/Modules;C:/Windows/system32/WindowsPowerShell/v1.0/Modules;#{ENV['PSModulePath']}"
"@

    Write-BuildLine "Creating initial bootstrap configuration"
    Copy-Item -Path "$pkg_prefix/.chef/config.rb" -Destination "$pkg_prefix/config/bootstrap-config.rb"
    Add-Content -Path "$pkg_prefix/config/bootstrap-config.rb" -Value @"
ENV['PATH'] += ";C:/WINDOWS;C:/WINDOWS/system32/;C:/WINDOWS/system32/WindowsPowerShell/v1.0;C:/ProgramData/chocolatey/bin"
"@

    # Get the Automate connection info from the default.toml if it's set and if the $scaffold_report_on_install is set to $true
    if($scaffold_report_on_install){
        if(Test-Path "$PLAN_CONTEXT\default.toml"){
            $input_toml = "$PLAN_CONTEXT\default.toml"
            
            $toml_guid = (Select-String -Path $input_toml -Pattern '^chef_guid').Line -replace "chef_guid\s*=\s*", "chef_guid "
            $toml_data_collector_token = (Select-String -Path $input_toml -Pattern '^token').Line -replace "token\s*=\s*", "data_collector.token "
            $toml_data_collector_server_url = (Select-String -Path $input_toml -Pattern '^server_url').Line -replace "server_url\s*=\s*", "data_collector.server_url "
            
            Add-Content -Path "$pkg_prefix/config/bootstrap-config.rb" -Value $toml_guid
            Add-Content -Path "$pkg_prefix/config/bootstrap-config.rb" -Value $toml_data_collector_token
            Add-Content -Path "$pkg_prefix/config/bootstrap-config.rb" -Value $toml_data_collector_server_url
        }
    }

    Write-BuildLine "Creating Chef Infra client configuration"
    Copy-Item -Path "$pkg_prefix/.chef/config.rb" -Destination "$pkg_prefix/config/client-config.rb"
    Add-Content -Path "$pkg_prefix/config/client-config.rb" -Value @"
ssl_verify_mode {{cfg.ssl_verify_mode}}
ENV['PATH'] += "{{cfg.env_path_prefix}}"

{{#if cfg.automate.enable ~}}
chef_guid "{{sys.member_id}}"
data_collector.token "{{cfg.automate.token}}"
data_collector.server_url "{{cfg.automate.server_url}}"
{{/if ~}}
"@

    Write-BuildLine "Generating config/attributes.json"
    Add-Content -Path "$pkg_prefix/config/attributes.json" -Value @"
{{#if cfg.attributes}}
{{toJson cfg.attributes}}
{{else ~}}
{}
{{/if ~}}
"@

    Write-BuildLine "Generating Chef Habitat configuration default.toml"
    Add-Content -Path "$pkg_prefix/default.toml" -Value @"

# You must accept the Chef License to use this software: https://www.chef.io/end-user-license-agreement/
# Change [chef_license] from acceptance = "undefined" to acceptance = "accept-no-persist" if you agree to the license.

interval = 1800
splay = 1800
splay_first_run = 0
run_lock_timeout = 1800
log_level = "warn"
env_path_prefix = ";C:/WINDOWS;C:/WINDOWS/system32/;C:/WINDOWS/system32/WindowsPowerShell/v1.0;C:/ProgramData/chocolatey/bin"
ssl_verify_mode = ":verify_peer"

[chef_license]
acceptance = "undefined"

[automate]
report_on_bootstrap = false
chef_guid = <your_guid>
enable = false
server_url = "https://<automate_url>/data-collector/v0/"
token = "<automate_token>"
user = "<automate_user>"
"@

    $scaffold_data_bags_path = "not_using_data_bags" # Set default to some string so Test-Path returns false instead of error. Thanks Powershell!
    if (Test-Path "$scaffold_data_bags_path") {
        Write-BuildLine "Detected a data bags directory, installing into package"
        Copy-Item "$scaffold_data_bags_path/*" -Destination "$pkg_prefix" -Recurse
    }
}
