pkg_name=scaffolding-chef-infra
pkg_description="Scaffolding for Chef Infra Policyfiles"
pkg_origin=chef
pkg_version=$(cat "${PLAN_CONTEXT}/../VERSION")
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_upstream_url="https://www.chef.sh"

do_download() {
  return 0
}

do_verify() {
  return 0
}

do_unpack() {
  return 0
}

do_build() {
  return 0
}

do_install() {
  mkdir -p "${pkg_prefix}/lib/linux"/
  cp -r "${PLAN_CONTEXT}/lib/linux"/* "${pkg_prefix}/lib"/
}
