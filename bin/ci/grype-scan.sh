#!/bin/bash
#
# Grype scan of the PUBLISHED chef/scaffolding-chef-infra package (Linux)
#
# PURPOSE:
#   After the habitat/build pipeline publishes packages, install the published
#   package on top of a CLEAN Habitat install and scan the whole /hab tree
#   (hab itself, the package, and all transitive dependencies) with grype.
#   Reports are uploaded as Buildkite artifacts by the pipeline step.
#
# CLEAN INSTALL:
#   Habitat honours the FS_ROOT environment variable, so the install goes into
#   a fresh temporary root rather than the host's /hab. Nothing left over from
#   earlier builds on a reused agent can leak into the scan, and the host's
#   /hab is never touched. chef/hab is installed into the same root first so
#   the scanned tree matches what a fresh `hab` bootstrap produces.
#
# OUTPUT:
#   grype-reports/<os>-<arch>-<package-identifier>.txt   (grype table)
#   grype-reports/<os>-<arch>-<package-identifier>.json  (grype json)
#   e.g. linux-arm64-chef-scaffolding-chef-infra-0-26-3-20261016115849.txt
#
# USAGE:
#   HAB_AUTH_TOKEN=<token> ./bin/ci/grype-scan.sh scaffolding-chef-infra x86_64-linux
#   Optional: SCAN_CHANNEL (default unstable), GRYPE_VERSION, REPORT_DIR

set -eou pipefail

package="$(basename "${1}")"
hab_target="${2:-x86_64-linux}"
SCAN_CHANNEL="${SCAN_CHANNEL:-unstable}"
GRYPE_VERSION="${GRYPE_VERSION:-0.120.1}"
REPORT_DIR="${REPORT_DIR:-grype-reports}"
ORIGIN="chef"

export HAB_LICENSE="accept-no-persist"
export HAB_NONINTERACTIVE="true"
# HAB_AUTH_TOKEN is exported by .buildkite/hooks/pre-command in CI.
export HAB_AUTH_TOKEN="${HAB_AUTH_TOKEN:-}"

case "${hab_target}" in
  x86_64-linux)  platform="linux-amd64"; grype_arch="amd64" ;;
  aarch64-linux) platform="linux-arm64"; grype_arch="arm64" ;;
  *) echo "Unsupported hab target: ${hab_target}" >&2; exit 1 ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
work_dir="$(mktemp -d)"
trap 'rm -rf "${work_dir}"' EXIT

echo "--- :habicat: Installing Habitat for ${hab_target}"
"${SCRIPT_DIR}/install-hab.sh" "${hab_target}"

echo "--- :mag: Installing grype ${GRYPE_VERSION} (${platform})"
grype_tar="grype_${GRYPE_VERSION}_linux_${grype_arch}.tar.gz"
grype_url="https://github.com/anchore/grype/releases/download/v${GRYPE_VERSION}"
curl -fsSL -o "${work_dir}/${grype_tar}" "${grype_url}/${grype_tar}"
curl -fsSL -o "${work_dir}/checksums.txt" "${grype_url}/grype_${GRYPE_VERSION}_checksums.txt"
(cd "${work_dir}" && grep " ${grype_tar}\$" checksums.txt | sha256sum -c -)
mkdir -p "${work_dir}/bin"
tar -xzf "${work_dir}/${grype_tar}" -C "${work_dir}/bin" grype
export PATH="${work_dir}/bin:${PATH}"
grype version

echo "--- :habicat: Creating clean Habitat root"
export FS_ROOT="${work_dir}/root"
mkdir -p "${FS_ROOT}"
hab pkg install chef/hab --channel stable

# The buildkite_hab_build_group_published workload exposes the exact ident
# published for each package/target, e.g.
# EXPEDITOR_PKG_IDENTS_SCAFFOLDINGCHEFINFRAX86_64LINUX. Scan exactly that
# release; fall back to the latest in SCAN_CHANNEL (manual/local runs).
ident_var="EXPEDITOR_PKG_IDENTS_$(echo "${package}${hab_target}" | tr -d '-' | tr '[:lower:]' '[:upper:]')"
install_spec="$(echo "${!ident_var:-${ORIGIN}/${package}}" | awk '{print $1}')"

echo "--- :habicat: Installing ${install_spec} from ${SCAN_CHANNEL}"
hab pkg install "${install_spec}" --channel "${SCAN_CHANNEL}"
pkg_path="$(hab pkg path "${install_spec}")"
ident="${pkg_path#"${FS_ROOT}"/hab/pkgs/}"
echo "    Resolved: ${ident}"

ident_kebab="$(echo "${ident}" | tr '/_.' '---' | tr '[:upper:]' '[:lower:]')"
report_base="${REPORT_DIR}/${platform}-${ident_kebab}"
mkdir -p "${REPORT_DIR}"

echo "--- :mag: Scanning ${FS_ROOT}/hab"
grype "dir:${FS_ROOT}/hab" \
  -o "table=${report_base}.txt" \
  -o "json=${report_base}.json"

echo "--- :page_facing_up: Reports"
ls -l "${REPORT_DIR}"
head -n 20 "${report_base}.txt"
