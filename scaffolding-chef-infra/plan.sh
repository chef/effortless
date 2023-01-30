pkg_name=scaffolding-chef-infra
pkg_description="Scaffolding for Chef Infra Policyfiles"
pkg_origin=chef
pkg_version=$(cat "${PLAN_CONTEXT}/../VERSION")
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_upstream_url="https://www.chef.sh"
pkg_deps=(
  core/git
  core/ruby31
  core/make
  core/gcc
)
pkg_bin_dirs=("vendor/bin")

do_setup_environment() {
  push_runtime_env GEM_PATH "$pkg_prefix/vendor"
  set_runtime_env LANG "en_US.UTF-8"
  set_runtime_env LC_CTYPE "en_US.UTF-8"
}

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
  export GEM_HOME="${HAB_CACHE_SRC_PATH}/${pkg_dirname}/vendor"
  gem install chef-cli --no-document
}

do_install() {
  mkdir -p "${pkg_prefix}/lib/linux"/
  cp -r "${HAB_CACHE_SRC_PATH}/${pkg_dirname}"/* "${pkg_prefix}"
  cp -r "${PLAN_CONTEXT}/lib/linux"/* "${pkg_prefix}/lib"/
}
