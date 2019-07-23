#!/usr/bin/env bash
set -euo pipefail

export HAB_NONINTERACTIVE=true
export HAB_NOCOLORING=true
export HAB_LICENSE=accept-no-persist

groupadd hab
useradd -g hab hab
curl https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | sudo bash >> /tmp/svc-load.log 2>&1 # https://github.com/habitat-sh/habitat/issues/6260
hab license accept
mv /home/${ssh_user}/hab-sup.service /etc/systemd/system/hab-sup.service
chmod 664 /etc/systemd/system/hab-sup.service
systemctl daemon-reload
systemctl enable hab-sup.service
systemctl start hab-sup.service
sleep 15
hab pkg install chef/chef-client --channel stable -b -f >> /tmp/svc-load.log 2>&1
