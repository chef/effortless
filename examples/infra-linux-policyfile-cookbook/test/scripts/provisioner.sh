#!/bin/bash
export HAB_LICENSE="accept-no-persist"

# Install the Habitat CLI if it isn't installed
if [ ! -e "/bin/hab" ]; then
  # Using wget since curl isn't available on Ubuntu
  wget -q -O - https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | sudo bash
fi

# Create `hab` user and group if they do not exist
if grep "^hab:" /etc/passwd > /dev/null; then
  echo "Hab user exists, skipping user creation"
else
  # NOTE: `useradd` also creates a group by default
  sudo useradd hab && true
fi

source /tmp/results/last_build.env

echo "Installing /tmp/results/$pkg_artifact"
hab pkg install "/tmp/results/$pkg_artifact"

echo "Determing pkg_prefix for $pkg_artifact"
pkg_prefix=$(find "/hab/pkgs/$pkg_origin/$pkg_name" -maxdepth 2 -mindepth 2 | sort | tail -n 1)
echo "Found: $pkg_prefix"

echo "Running chef-client in $pkg_origin/$pkg_name"
cd "$pkg_prefix" || exit 1
hab pkg exec "$pkg_origin/$pkg_name" chef-client -z -c "$pkg_prefix/config/bootstrap-config.rb"
