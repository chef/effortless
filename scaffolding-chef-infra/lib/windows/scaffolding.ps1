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
# These variables are being set because Load-Scaffolding is not working.
# When loading gets fixed these can be removed.
if(!$scaffold_cacerts){
    $scaffold_cacerts = "core/cacerts"
}
if(!$scaffold_chef_client){
    $scaffold_chef_client = "chef/chef-infra-client"
}

# Internals
$scaffolding_package = $pkg_scaffolding.split("/")[1]
$lib_dir = "$(Get-HabPackagePath $scaffolding_package)/lib"

function Load-Scaffolding {
    $scaffold_chef_client = "chef/chef-infra-client"
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

    (Get-Content -Path "$lib_dir/run.ps1") -join "`n" | Foreach-Object {
        $_ -replace 'scaffold_cacerts', $scaffold_cacerts `
           -replace 'scaffold_chef_client', $scaffold_chef_client
    } | Set-Content "$pkg_prefix/hooks/run"
}

function Invoke-DefaultBuild {
    Remove-Item "$scaffold_policyfile_path/*.lock.json" -Force
    $policyfile = "$scaffold_policyfile_path/$scaffold_policy_name.rb"
    $env:CHEF_LICENSE = 'accept-no-persist'
    gem install chef-cli --no-document

    Get-Content $policyfile | ? { $_.StartsWith("include_policy") } | % {
        $p = $_.Split()[1]
        if ($p.Contains("'")) {
            $p = $p.Replace("'", "").Replace(",", "")
        }
        elseif($p.Contains("`"")) {
            $p = $p.Replace("`"", "").Replace(",", "")
        }
        else {
            Write-Buildline "There is a problem in the policyfile with this line"
            Write-BuildLine "$_"
            Write-BuildLine "Please fix this before continuing."
            exit 1
        }
        Write-BuildLine "Detected included policyfile, $p.rb, installing"
        chef-cli install "$scaffold_policyfile_path/$p.rb"
    }
    chef-cli install "$policyfile"
}

function Invoke-DefaultInstall {
    chef-cli export "$scaffold_policyfile_path/$scaffold_policy_name.lock.json" "$pkg_prefix"

    $dir = "$pkg_prefix/config"
    if (!(Test-Path -Path $dir)) {
        New-Item -ItemType directory -Path $dir
    }

    $export_chunk = (Get-Content -Path "$pkg_prefix/.chef/config.rb") -join "`n"

    $shared_chunk = (Get-Content -Path "$lib_dir/shared-chunk.rb") -join "`n"
    $shared_chunk = "$export_chunk`n$shared_chunk"

    $bootstrap_chunk = (Get-Content -Path "$lib_dir/bootstrap-chunk.rb") -join "`n"
    "$shared_chunk`n$bootstrap_chunk" | Add-Content -Path "$pkg_prefix/config/bootstrap-config.rb"

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
