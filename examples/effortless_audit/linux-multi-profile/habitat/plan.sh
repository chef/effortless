pkg_name=effortless-a2-profile-test
pkg_version=1.0.0
pkg_origin=chef
pkg_scaffolding="chef/scaffolding-chef-inspec"
scaffold_automate_server_url=$AUTOMATE_SERVER_URL # Example: https://foo.bar.com
scaffold_automate_user=$AUTOMATE_USER             # Example: "admin"
scaffold_automate_token=$AUTOMATE_TOKEN           # Example: "DI0WVxInnyGnWKRlZBGizTXySgk="
#scaffold_compliance_insecure=true                # set true to ignore SSL cert error when retrieving profile from A2
scaffold_profiles=(
  profile1
  profile2
)
