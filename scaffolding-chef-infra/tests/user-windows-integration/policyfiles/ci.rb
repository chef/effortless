name "ci"

default_source :chef_repo, '../'

run_list [
  "ci::default",
]
