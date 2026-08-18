#!/bin/bash

set -euo pipefail

echo "--- Promoting Habitat package from stable to base-2025 and base"

echo "Package Origin: ${EXPEDITOR_PKG_ORIGIN}"
echo "Package Name: ${EXPEDITOR_PKG_NAME}"
echo "Package Version: ${EXPEDITOR_PKG_VERSION}"
echo "Package Release: ${EXPEDITOR_PKG_RELEASE}"
echo "Package Ident: ${EXPEDITOR_PKG_IDENT}"
echo "Package Target: ${EXPEDITOR_PKG_TARGET}"
echo "Source Channel: ${EXPEDITOR_CHANNEL}"

HAB_AUTH_TOKEN=$(vault kv get -field auth_token account/static/habitat/chef-ci)
export HAB_AUTH_TOKEN

echo "--- Promoting ${EXPEDITOR_PKG_IDENT} to base-2025 channel"
hab pkg promote "${EXPEDITOR_PKG_IDENT}" "base-2025"

# Habitat 2.0+ uses 'base' as the default channel for chef origin packages.
echo "--- Promoting ${EXPEDITOR_PKG_IDENT} to base channel"
hab pkg promote "${EXPEDITOR_PKG_IDENT}" "base"

echo "--- Promotion completed successfully!"
