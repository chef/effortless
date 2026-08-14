#!/usr/bin/env bash

set -euo pipefail

export HAB_LICENSE="accept"
export HAB_NONINTERACTIVE="true"

HAB_VERSION="${HAB_VERSION:-2.1.23}"
hab_target="${1:-x86_64-linux}"

# print error message and exit
error() {
  echo -e "\nERROR: ${1}\n" >&2
  exit 1
}

install_habitat() {
  echo "--- :habicat: Installing Habitat $HAB_VERSION for $hab_target"
  curl -fsSL https://raw.githubusercontent.com/habitat-sh/habitat/main/components/hab/install.sh \
    | bash -s -- -t "$hab_target" -v "$HAB_VERSION"
  hab license accept
}

# Returns 0 if $1 >= $2 (minimum version met)
version_at_least() {
  [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n 1)" = "$2" ]
}

if command -v hab &>/dev/null; then
  current_version=$(hab --version 2>/dev/null | awk '{print $2}' | cut -d'/' -f1 || true)
  if version_at_least "$current_version" "$HAB_VERSION"; then
    echo "--- :habicat: :thumbsup: Habitat $current_version already installed (>= $HAB_VERSION)"
  else
    echo "--- :habicat: Habitat $current_version found (below minimum $HAB_VERSION). Upgrading..."
    install_habitat
  fi
else
  install_habitat
fi
