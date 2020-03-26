$pkg_name="effortless-a2-profile-test"
$pkg_origin="chef"
$pkg_version="0.1.0"
$pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
$pkg_license=("Apache-2.0")
$pkg_build_deps=@("stuartpreston/inspec")
$pkg_deps=@("stuartpreston/inspec")
$pkg_description="Effortless Windows Audit"
$pkg_scaffolding="chef/scaffolding-chef-inspec"
$scaffold_automate_server_url = "$env:AUTOMATE_SERVER_URL" # Example: https://foo.bar.com
$scaffold_automate_user = "$env:AUTOMATE_USER"             # Example: "admin"
$scaffold_automate_token = "$env:AUTOMATE_TOKEN"           # Example: "DI0WVxInnyGnWKRlZBGizTXySgk="
$scaffold_compliance_insecure=true