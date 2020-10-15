#!/bin/bash
export HAB_LICENSE="accept-no-persist"
export CHEF_LICENSE="accept-no-persist"

if [ ! -e "/bin/hab" ]; then
curl https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | sudo bash
fi

if grep "^hab:" /etc/passwd > /dev/null; then
echo "Hab user exists"
else
useradd hab && true
fi

if grep "^hab:" /etc/group > /dev/null; then
echo "Hab group exists"
else
groupadd hab && true
fi

pkg_origin=$1
pkg_name=$2

echo "Starting $pkg_origin/$pkg_name"

latest_hart_file=$(ls -la /tmp/results/$pkg_origin-$pkg_name* | tail -n 1 | cut -d " " -f 9)
echo "Latest hart file is $latest_hart_file"

echo "Installing $latest_hart_file"
hab pkg install $latest_hart_file

echo "Determining pkg_prefix for $latest_hart_file"
pkg_prefix=$(find /hab/pkgs/$pkg_origin/$pkg_name -maxdepth 2 -mindepth 2 | sort | tail -n 1)

echo "Found $pkg_prefix"

echo "Running chef for $pkg_origin/$pkg_name"
cd $pkg_prefix
hab pkg exec $pkg_origin/$pkg_name chef-client -z -c $pkg_prefix/config/bootstrap-config.rb
