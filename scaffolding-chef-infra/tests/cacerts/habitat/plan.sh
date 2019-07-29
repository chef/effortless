pkg_name="cacerts"
pkg_origin="ci"
pkg_version="1.0.0"
pkg_build_deps=(core/cacerts)

do_verify() {
  return 0
}

do_build() {
  cp -r "$(pkg_path_for core/cacerts)/ssl" "${HAB_CACHE_SRC_PATH}/${pkg_dirname}"
  cat "${PLAN_CONTEXT}/../cert-add.pem" >> "${HAB_CACHE_SRC_PATH}/${pkg_dirname}/ssl/certs/cacert.pem"
}

# Add the cert you want to append in the source directory and name it "cert-add.pem"
do_install() {
  cp -r "${HAB_CACHE_SRC_PATH}/${pkg_dirname}"/* "${PREFIX}"/
}
