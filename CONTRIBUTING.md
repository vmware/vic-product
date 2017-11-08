# Contributing to VIC Product

## Getting started

First, fork the repository on GitHub to your personal account.

Note that _GOPATH_ can be any directory, the example below uses _$HOME/vic-product_.
Change _$USER_ below to your GitHub username.

``` shell
export GOPATH=$HOME/vic-product
mkdir -p $GOPATH/src/github.com/vmware
go get github.com/vmware/vic-product
cd $GOPATH/src/github.com/vmware/vic-product
git config push.default nothing # anything to avoid pushing to vmware/vic-product by default
git remote rename origin vmware
git remote add $USER git@github.com:$USER/vic-product.git
git fetch $USER
```

## Contribution flow

This is a rough outline of what a contributor's workflow looks like:

- Create a topic branch from where you want to base your work.
- Make commits of logical units.
- Make sure your commit messages are in the proper format (see below).
- Push your changes to a topic branch in your fork of the repository.
- Test your changes as detailed in the [Automated Testing](#automated-testing) section.
- Submit a pull request to vmware/vic.
- Your PR must receive approvals from component owners before merging.

Example:

``` shell
git checkout -b my-new-feature
git commit -a
git push $USER my-new-feature
```

### Stay in sync with upstream

When your branch gets out of sync with the vmware/master branch, use the following to update:

``` shell
git checkout my-new-feature
git fetch -a
git rebase vmware/master
git push --force-with-lease $USER my-new-feature
```

### Updating pull requests

If your PR fails to pass CI or needs changes based on code review, you'll most likely want to squash these changes into
existing commits.

If your pull request contains a single commit or your changes are related to the most recent commit, you can simply
amend the commit.

``` shell
git add .
git commit --amend
git push --force-with-lease $USER my-new-feature
```

If you need to squash changes into an earlier commit, you can use:

``` shell
git add .
git commit --fixup <commit>
git rebase -i --autosquash vmware/master
git push --force-with-lease $USER my-new-feature
```

Be sure to add a comment to the PR indicating your new changes are ready to review, as GitHub does not generate a
notification when you git push.

### Code style

The coding style suggested by the Golang community is used in VIC. See the
[style doc](https://github.com/golang/go/wiki/CodeReviewComments) for details.

Try to limit column width to 120 characters for both code and markdown documents such as this one.

### Format of the Commit Message

We follow the conventions on [How to Write a Git Commit Message](http://chris.beams.io/posts/git-commit/).

Be sure to include any related GitHub issue references in the commit message. See
[GFM syntax](https://guides.github.com/features/mastering-markdown/#GitHub-flavored-markdown) for referencing issues
and commits.

To help write conforming commit messages, it is recommended to set up the [git-good-commit][commithook] commit hook. Run this command in the VIC repo's root directory:

```shell
curl https://cdn.rawgit.com/tommarshall/git-good-commit/v0.6.1/hook.sh > .git/hooks/commit-msg && chmod +x .git/hooks/commit-msg
```

[dronevic]:https://ci.vcna.io/vmware/vic-product
[dronesrc]:https://github.com/drone/drone
[dronecli]:http://readme.drone.io/0.5/install/cli/
[commithook]:https://github.com/tommarshall/git-good-commit

## Automated Testing

Automated testing uses [Drone][dronesrc].

PRs must pass unit tests and integration tests before being merged into `master`.

_TODO_ Document testing

## Reporting Bugs and Creating Issues

When opening a new issue, try to roughly follow the commit message format conventions above.



For cross-component or VIC Appliance issues, please use the [vic-product Github issue tracker](https://github.com/vmware/vic-product/issues)

For issues relating to individual components, please use the component specific Github issue tracker:

[VIC Engine](https://github.com/vmware/vic/issues)

[Harbor](https://github.com/vmware/harbor/issues)

[Admiral](https://github.com/vmware/admiral/issues)

If you are unsure which component your issue relates to, submit it here and we will triage it.
Thank you for contributing to VIC Product!


## Repository structure

The layout in the repo is as follows:
* dinv - DCH Photon
* docs - Documentation for VIC Product
* installer - Build and source for building VIC Appliance and its platform services
* tests - VIC Appliance tests
* tutorials - Tutorials

## Troubleshooting

* If you're building the project in a VM, ensure that it has at least 4GB memory to avoid issues while running the build.
