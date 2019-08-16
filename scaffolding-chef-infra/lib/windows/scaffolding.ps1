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
if(!$scaffold_cacerts){
    $scaffold_cacerts = "core/cacerts"
}

# Internals
$scaffolding_package = $pkg_scaffolding.split("/")[1]
$lib_dir = "$(Get-HabPackagePath $scaffolding_package)/lib"

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

function Invoke-DefaultBuildService {
    $dir = "$pkg_prefix/hooks"
    if (!(Test-Path -Path $dir)) {
        New-Item -ItemType directory -Path $dir
    }

    $run_hook = (Get-Content -Path "$lib_dir/run.ps1") -join "`n"
    $run_hook -replace 'scaffold_cacerts', $scaffold_cacerts | Add-Content -Path "$pkg_prefix/hooks/run"
}

function Invoke-DefaultBuild {
    Remove-Item "$scaffold_policyfile_path/*.lock.json" -Force
    $policyfile = "$scaffold_policyfile_path/$scaffold_policy_name.rb"

    Get-Content $policyfile | ? { $_.StartsWith("include_policy") } | % {
        $p = $_.Split()[1]
        $p = $p.Replace("`"", "").Replace(",", "")
        chef install "$scaffold_policyfile_path/$p.rb"
    }
    chef install "$policyfile"
}

function Invoke-DefaultInstall {
    chef export "$scaffold_policyfile_path/$scaffold_policy_name.lock.json" "$pkg_prefix"

    $dir = "$pkg_prefix/config"
    if (!(Test-Path -Path $dir)) {
        New-Item -ItemType directory -Path $dir
    }

    $export_chunk = (Get-Content -Path "$pkg_prefix/.chef/config.rb") -join "`n"

    $shared_chunk = (Get-Content -Path "$lib_dir/shared-chunk.rb") -join "`n"
    $shared_chunk = "$export_chunk`n$shared_chunk"

    $bootstrap_chunk = (Get-Content -Path "$lib_dir/bootstrap-chunk.rb") -join "`n"
    "$shared_chunk`n$bootstrap_chunk" | Add-Content -Path "$pkg_prefix/config/bootstrap-config.rb"


    # Report on install conditional
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

    $client_chunk = (Get-Content -Path "$lib_dir/client-chunk.rb") -join "`n"
    "$shared_chunk`n$client_chunk" | Add-Content -Path "$pkg_prefix/config/client-config.rb"

    (Get-Content -Path "$lib_dir/attributes.json") -join "`n" | Add-Content -Path "$pkg_prefix/config/attributes.json"

    (Get-Content -Path "$lib_dir/default.toml") -join "`n" | Add-Content -Path "$pkg_prefix/default.toml"

    $scaffold_data_bags_path = "not_using_data_bags"
    if (Test-Path "$scaffold_data_bags_path") {
        Copy-Item "$scaffold_data_bags_path/*" -Destination "$pkg_prefix" -Recurse
    }

    Remove-Item "$pkg_prefix/.chef" -Force -Recurse
    Remove-Item "$pkg_prefix/README.md" -Force
}
