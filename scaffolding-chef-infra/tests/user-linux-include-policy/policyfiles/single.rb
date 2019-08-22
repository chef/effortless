name "single"

include_policy 'ci', path: "./ci.lock.json"

run_list [
  "ci::default",
]

default['ci']['single_quote'] = true
