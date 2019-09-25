$env:SSL_CERT_FILE="{{pkgPathFor "scaffold_cacerts"}}/ssl/cert.pem"
$env:SSL_CERT_DIR="{{pkgPathFor "scaffold_cacerts"}}/ssl/certs"

$env:CFG_INTERVAL = "{{cfg.interval}}"
if(!$env:CFG_INTERVAL){
    $env:CFG_INTERVAL = "1800"
}

$env:CFG_LOG_LEVEL = "{{cfg.log_level}}"
if(!$env:CFG_LOG_LEVEL){
    $env:CFG_LOG_LEVEL = "warn"
}

$env:CFG_RUN_LOCK_TIMEOUT = "{{cfg.run_lock_timeout}}"
if(!$env:CFG_RUN_LOCK_TIMEOUT){
    $env:CFG_RUN_LOCK_TIMEOUT = "1800"
}

$env:CFG_SPLAY = "{{cfg.splay}}"
if(!$env:CFG_SPLAY){
    $env:CFG_SPLAY = "1800"
}

$env:CFG_SPLAY_FIRST_RUN = "{{cfg.splay_first_run}}"
if(!$env:CFG_SPLAY_FIRST_RUN){
    $env:CFG_SPLAY_FIRST_RUN = "0"
}

$env:CHEF_LICENSE = "{{cfg.chef_license.acceptance}}"

function Invoke-ChefClient {
  {{pkgPathFor "scaffold_chef_client"}}/bin/chef-client.bat -z -l $env:CFG_LOG_LEVEL -c {{pkg.svc_config_path}}/client-config.rb -j {{pkg.svc_config_path}}/attributes.json --once --no-fork --run-lock-timeout $env:CFG_RUN_LOCK_TIMEOUT
}

$SPLAY_DURATION = Get-Random -InputObject (0..$env:CFG_SPLAY) -Count 1

$SPLAY_FIRST_RUN_DURATION = Get-Random -InputObject (0..$env:CFG_SPLAY_FIRST_RUN) -Count 1

cd {{pkg.path}}

Start-Sleep -Seconds $SPLAY_FIRST_RUN_DURATION
Invoke-ChefClient

while($true){
  Start-Sleep -Seconds $SPLAY_DURATION
  Start-Sleep -Seconds $env:CFG_INTERVAL
  Invoke-ChefClient
}
