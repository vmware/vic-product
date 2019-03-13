# Release Procedures

This project does not use semantic versioning.

All examples in this document assume `vmware/vic-product` is at `upstream` and
your fork is at `origin`. If you have used a different remote name (e.g.,
`origin` for `vmware/vic-product`), adjust accordingly.


## Overview

Git branches and tags are the building blocks of the release process.

A git tag is created for each milestone: a `vX.Y.Z-dev` tag is created when
development of version X.Y.Z begins, a `vX.Y.Z-rcN` tag is created for each
release candidate, and a `vX.Y.Z` tag is created when the release is complete).

The version number assigned to a component and its deliverables is determined by
the first reachable tag in the history of the commit being built. (When a "tie"
exists, the annotated tag created most recently or the lightweight tag which
would come first in lexicographical order is used.)

A special "tag build" is triggered in Drone when a tag is created.

Release branches (which must be named `releases/X.Y.Z`) are used to insulate the
code which is being prepared for release from churn on `master`. When a version
is developed on `master`, the release branch is created from the commit used for
the first release candidate. For a patch, the release branch is created from the
parent release's branch.

All Drone builds on a release branch behave differently from builds on `master`:
they consume tagged versions of components (instead of the most recent build).


### Branching

It is desirable to ensure that only changes which have already been reviewed and
pushed are included when creating a release branch. While there are a variety of
ways to create a new branch, the following process minimizes risk of including
changes which were not intended. (It is not possible to use a pull request to
allow for review of the creation of a branch, so you may wish to confirm your
changes directly with another member of the team.)

For a release branching from `master`:
```
git remote update
git checkout upstream/master
git push upstream HEAD:releases/X.Y.0
```

For a patch release:
```
git remote update
git checkout upstream/releases/X.Y.0
git push upstream HEAD:releases/X.Y.1
```

After creating a new branch:

1. A tag for ongoing development should also be created at the commit **after**
   the start of the release branch using the [Tagging](#Tagging) procedure.
2. GitHub branch protection rules should be configured based on the rules used
   for the `master` branch.


### Upgrade

To ensure that future releases will be able to upgrade from the release that is
being prepared, it is necessary to update the upgrade scripts to list the new
release. As this process may change over time, this document will not attempt to
describe the exact steps necessary. Referring to the most recent change that
added support for upgrade and searching the code for previous version numbers
may each help identify some of the necessary steps.


### Cherry picking

Commits that need to be pulled into the release should be cherry picked into the
release branch after they are merged into master. (This eliminates the potential
for a regression in a future release resulting from a fix committed directly to
the release branch, and not cherry-picked to `master`.)

```
git remote update
git checkout releases/X.Y.Z
git pull --rebase
git checkout -b cherry/1234
git cherry-pick -x aaaaaaa
git push -u origin
```

Then, post a pull request for the cherry-pick targetting the release branch.

If mutliple cherry-picks are included in a single pull request, manually add the
PR number to the summary line of each commit message and use "Rebase & Merge" to
merge the change. This allows cherry-picked changes to be more easily correlated
between branches.


### Tagging

Use annotated tags to mark significant commits: the first commit of a version
(`vX.Y.Z-dev`), each release candidate (`vX.Y.Z-rcN`), and the final commit of a
release (`vX.Y.Z`).

These tags are used to determine the version number of a build.

For tagging RC1:
```
git remote update
git checkout upstream/releases/X.Y.Z
git tag -a vX.Y.Z-rc1
git push upstream vX.Y.Z-rc1
```

For tagging the beginning of development of the next release:
```
git remote update
git checkout upstream/master
git tag -a vA.B.C-dev
git push upstream vA.B.C-dev
```

For tagging the final commit of a release:
```
git remote update
git checkout upstream/releases/X.Y.Z
git tag -a vX.Y.Z
git push upstream vX.Y.Z
```

## Github Releases

After pushing the tag to Github, go to https://github.com/vmware/vic-product/releases/new

Select the appropriate tag

Release title follows form `vSphere Integrated Containers Appliance <tag>` (e.g. `vSphere Integrated Containers Appliance v1.4.0-rc3`)

Obtain artifact hashes from CI build output at the end of `unified-ova-build` step

Obtain version information from `/etc/vmware/version`

Description template for release candidates and releases:

```````
### [Download OVA](https://storage.googleapis.com/vic-product-ova-releases/vic-v1.4.0-rc3-4824-d99cbdb4.ova)
Filesize (vic-v1.4.0-rc3-4824-d99cbdb4.ova) = ...
SHA256 (vic-v1.4.0-rc3-4824-d99cbdb4.ova) = ...
SHA1 (vic-v1.4.0-rc3-4824-d99cbdb4.ova) = ...
MD5 (vic-v1.4.0-rc3-4824-d99cbdb4.ova) = ...

### OVA will contain:
```
appliance=v1.4.0-rc3-4824-d99cbdb4
harbor=harbor-offline-installer-v1.5.0-rc4.tgz
engine=vic_v1.4.0-rc2.tar.gz
admiral=vmware/admiral:vic_v1.4.0-rc4 45a773ffae33
vic-machine-server=gcr.io/eminent-nation-87317/vic-machine-server:latest b3412e003674
vic-ui=vic_ui_v1.4.0-rc2.tar.gz
```
### [Changes from v1.3.1](https://github.com/vmware/vic-product/compare/v1.3.1...v1.4.0-rc3)

```````

If the release is a release candidate, mark `This is a pre-release`

## Building Releases

Follow instructions in [How to build VIC Product OVA](BUILD.md)
