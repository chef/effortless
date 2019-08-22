name "double"

include_policy "ci", path: "./ci.lock.json"

run_list [
  "ci::default",
]

default['ci']['double_quote'] = true
