# policyfile_cookbook

This cookbook meant to serve as an example of testing a Policyfile cookbook via
Habitat + Chef Scaffolding. It works by sharing `results/` with a Kitchen VM
and then running `test/scripts/provisioner.sh` which will:

  - Install the Habitat CLI in the Kitchen instance
  - Configure the `hab` user and group
  - Install the latest Habitat `.hart` package in `/tmp/results`
    - Don't forget to run `hab pkg build` in the root of the cookbook!
  - Run `chef-client` inside the package to converge the Kitchen instance

## Converting a Policyfile cookbook

After generating a Policyfile cookbook (default generator will do it, but if
you're on an older version of ChefDK/Workstation use `-P`) do the following:

  - Copy and modify `habitat/` and `habitat/plan.sh` from this example
  - Add `results/*` to `chefignore` to prevent uploading Habitat files to Chef Server
  - Add `results/*` to `.gitignore` to prevent committing Habitat files
  - Copy `test/scripts/provisioner.sh` from this example
  - Copy `kitchen.yml` from this example

## Testing with Kitchen

Provided you've setup your cookbook using the instructions above, after
performing a `hab pkg build` in the root of your cookbook, you can use
the usual `kitchen` commands such as `kitchen converge` and
`kitchen verify` to test your artifact.

## TODO

### Building the hart automatically

Ideally, `kitchen converge` would build a new `.hart` for you but this would
require setting up the Habitat CLI and creating an origin which is not easily
automated at this time.

### Making a generator

I would like see a cookbook generator that would automatically generate the
files needed for this. Example: `chef generate cookbook my_example --habitat`

### Creating a Kitchen Provisioner

Having a Kitchen provisioner would prevent the need for running the
`provisioner.sh` script that I've included and would be more intuitive.
