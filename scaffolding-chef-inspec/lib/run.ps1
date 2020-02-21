$env:SSL_CERT_FILE="{{pkgPathFor "scaffold_cacerts"}}/ssl/cert.pem"
$env:SSL_CERT_DIR="{{pkgPathFor "scaffold_cacerts"}}/ssl/certs"
$env:PATH = "{{pkgPathFor "scaffold_inspec_client"}}/bin;$env:PATH"

$env:CFG_SPLAY_FIRST_RUN="{{cfg.splay_first_run}}"
if(!$env:CFG_SPLAY_FIRST_RUN) {
    $env:CFG_SPLAY_FIRST_RUN = "0"
}

$env:CFG_INTERVAL="{{cfg.interval}}"
if(!$env:CFG_INTERVAL){
    $env:CFG_INTERVAL = "1800"
}

$env:CFG_SPLAY="{{cfg.splay}}"
if(!$env:CFG_SPLAY){
    $env:CFG_SPLAY = "1800"
}

$env:CFG_LOG_LEVEL="{{cfg.log_level}}"
if (!$env:CFG_LOG_LEVEL){
    $env:CFG_LOG_LEVEL = "warn"
}

$env:CFG_CHEF_LICENSE="{{cfg.chef_license.acceptance}}"
if(!$env:CFG_CHEF_LICENSE){
    $env:CFG_CHEF_LICENSE = "undefined"
}
$env:CHEF_LICENSE = $env:CFG_CHEF_LICENSE
$WAIVER="{{pkg.svc_config_path}}/waiver.yml"
$CONFIG="{{pkg.svc_config_path}}/inspec_exec_config.json"
$PROFILE_PATH="{{pkg.path}}/{{pkg.name}}-{{pkg.version}}.tar.gz"

function Invoke-Inspec {

    # # TODO: This is set to --json-config due to the
    # #  version of InSpec being used please update when InSpec is updated
    if([Version]({{pkgPathFor "scaffold_inspec_client"}}/bin/inspec --version) -gt [Version]"4.17.27"){
      {{pkgPathFor "scaffold_inspec_client"}}/bin/inspec.bat exec $PROFILE_PATH --json-config $CONFIG --waiver-file $WAIVER --log-level $env:CFG_LOG_LEVEL
    }
    else {
      {{pkgPathFor "scaffold_inspec_client"}}/bin/inspec.bat exec $PROFILE_PATH --json-config $CONFIG --log-level $env:CFG_LOG_LEVEL
    }
}

$SPLAY_DURATION = Get-Random -InputObject (0..$env:CFG_SPLAY) -Count 1

$SPLAY_FIRST_RUN_DURATION = Get-Random -InputObject (0..$env:CFG_SPLAY_FIRST_RUN) -Count 1

Start-Sleep -Seconds $SPLAY_FIRST_RUN_DURATION
Invoke-Inspec

while($true){
  $SLEEP_TIME = $SPLAY_DURATION + $env:CFG_INTERVAL
  Write-Host "InSpec is sleeping for $SLEEP_TIME seconds"
  Start-Sleep -Seconds $SPLAY_DURATION
  Start-Sleep -Seconds $env:CFG_INTERVAL
  Invoke-Inspec
}
