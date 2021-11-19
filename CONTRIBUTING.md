# Contributing to Chef Projects

We're glad you want to contribute to a Chef project! This document will help answer common questions you may have during your first contribution.

## Submitting Issues

Not every contribution comes in the form of code. Submitting, confirming, and triaging issues is an important task for any project. At Chef we use GitHub to track all project issues.

If you are familiar with Chef and know the component that is causing you a problem, you can file an issue in the corresponding GitHub project. All of our Open Source Software can be found in our [Chef GitHub organization](https://github.com/chef/).

We ask you not to submit security concerns via GitHub. For details on submitting potential security issues please see <https://www.chef.io/security/>

In addition to GitHub issues, we also utilize a feedback site that helps our product team track and rank feature requests. If you have a feature request, this is an excellent place to start <https://www.chef.io/feedback/>

## Preparing to contribute

When you are ready to contribute, we include several tools to help check your code. These are the same checks that will be run on your Pull Request after you submit it.

- [pre-commit](https://pre-commit.com/) - pre-commit is the tool we use that is responsible for running all lint checks. It wraps several custom checks to adhere to this project's design standards. It also wraps [shellcheck](https://www.shellcheck.net/), our bash linter.

## Contribution Process

We have a 3 step process for contributions:

1. Commit changes to a git branch, making sure to sign-off those changes for the [Developer Certificate of Origin](#developer-certification-of-origin-dco).
2. Create a GitHub Pull Request for your change.
3. Perform a [Code Review](#code-review-process) with approvers or project owners on the pull request.

### Pull Request Requirements

Chef projects are built to last. We strive to ensure high quality throughout the experience. In order to ensure this, we require that all pull requests to Chef projects meet these specifications:

1. **Tests:** To ensure high quality code and protect against future regressions, we require all the code in Chef Projects to have at least unit test coverage. We use [Bats](https://github.com/sstephenson/bats) and [Pester](https://github.com/pester/Pester) for unit tests. Additionally, we use [InSpec](https://www.inspec.io) for integration tests.
2. **Green CI Tests:** We use Chef Software's [Expeditor](https://expeditor.chef.io/docs/getting-started/) and [Build Kite](https://buildkite.com/) to run CI checks to test all pull requests. We require these test runs to succeed on every pull request before being merged.

### Code Review Process

Code review takes place in GitHub pull requests. See [this article](https://help.github.com/articles/about-pull-requests/) if you're not familiar with GitHub Pull Requests.

Once you open a pull request, approvers and project owners will review your code and respond to your pull request with any feedback they might have.

1. Approval is required from at least one approver or project owner. See (CODEOWNERS)[/CODEOWNERS] for a full list. If an approver or project owner requests changes, then the changes must be addressed before continuing.
2. Your change will be merged into the project's `main` branch.
3. The Expeditor bot will automatically update the project's changelog with your contribution.

### Developer Certification of Origin (DCO)

Chef uses [the Apache 2.0 license](https://github.com/chef/chef/blob/main/LICENSE) for its software projects.

The license tells you what rights you have that are provided by the copyright holder. It is important that the contributor fully understands what rights they are licensing and agrees to them. Sometimes the copyright holder isn't the contributor, such as when the contributor is doing work on behalf of a company.

To make a good faith effort to ensure these criteria are met, Chef requires the Developer Certificate of Origin (DCO) process to be followed.

The DCO is an attestation attached to every contribution made by every developer. In the commit message of the contribution, the developer simply adds a Signed-off-by statement and thereby agrees to the DCO, which you can find below or at <http://developercertificate.org/>.

```
Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
    have the right to submit it under the open source license
    indicated in the file; or

(b) The contribution is based upon previous work that, to the
    best of my knowledge, is covered under an appropriate open
    source license and I have the right under that license to
    submit that work with modifications, whether created in whole
    or in part by me, under the same open source license (unless
    I am permitted to submit under a different license), as
    Indicated in the file; or

(c) The contribution was provided directly to me by some other
    person who certified (a), (b) or (c) and I have not modified
    it.

(d) I understand and agree that this project and the contribution
    are public and that a record of the contribution (including
    all personal information I submit with it, including my
    sign-off) is maintained indefinitely and may be redistributed
    consistent with this project or the open source license(s)
    involved.
```

#### DCO Sign-Off Methods

The DCO requires a sign-off message in the following format appear on each commit in the pull request:

```
Signed-off-by: Julia Child <juliachild@chef.io>
```

The DCO text can either be manually added to your commit body, or you can add either **-s** or **--signoff** to your usual git commit commands. If you forget to add the sign-off you can also amend a previous commit with the sign-off by running **git commit --amend -s**. If you've pushed your changes to GitHub already you'll need to force push your branch after this with **git push -f**.

## Release

We release `Effortless` as a set of Habitat packages. These packages are available from [Chef Habitat Builder](https://bldr.habitat.sh).

### Release Packages

[chef/scaffolding-chef-infra](https://bldr.habitat.sh/#/pkgs/chef/scaffolding-chef-infra/latest)

[chef/scaffolding-chef-inspec](https://bldr.habitat.sh/#/pkgs/chef/scaffolding-chef-inspec/latest)

### Supported Platforms

- Linux x86_64
- Linux x86_64 Kernal2
- Windows x86_64

### Versioning

Our version numbering follows [Semantic Versioning](http://semver.org/) standard. Our standard version numbers look like X.Y.Z which means:

- X is a major release, which introduces breaking changes with previous major releases
- Y is a minor release, which adds both new features and bug fixes
- Z is a patch release, which adds just bug fixes

## Project Membership

As you make more contributions to this project, you may desire greater responsibility and privileges for the direction of the project. Project membership is governed by Chef Software's OSS Practices [project membership](https://github.com/chef/chef-oss-practices/blob/main/project-membership.md). This document details all of the procedures neccessary for project membership and role changes.

## Documentation

- [Chef Infra Docs](https://docs.chef.io/)
- [Chef InSpec Docs](https://www.inspec.io/docs/)
- [Chef Habitat Docs](https://habitat.sh/docs)
- [Learn Chef](https://learn.chef.io/)
- [Chef Software Inc. Website](https://www.chef.io/)
