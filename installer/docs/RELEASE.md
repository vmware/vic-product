# Release Procedures

All examples in this document assume the user's fork is at `origin` and `vmware/vic-product` is at
`upstream`.


## Branching

When the team is ready to build a release candidate, create a branch off of master based on the
release version number. 

A tag for ongoing development should also be created at the commit **after**
the start of the release branch. The tagging procedure is documented in [Tagging](#Tagging). 

```
git remote update
git checkout upstream/master
# or
git checkout aaaaaaa
git checkout -b releases/1.2.0
git push upstream
```

Configure branch protection on Github to have the same protection as the master branch.
`Protect this branch` and `Require pull request reviews before merging` should be set.


## Cherry picking

Commits that need to be pulled into the release should be cherry picked into the release branch
after they are merged into master.

```
git remote update
git checkout releases/1.2.0
git rebase upstream/releases/1.2.0
git checkout -b cherry-pick-branch-name
git cherry-pick aaaaaaa
git push upstream
```


## Tagging

On the master branch, tag the commit for the first release candidate. On the
following commit, tag `dev` for ongoing development. For example, if the
current release is `v1.2.0`, the first release candidate will be `v1.2.0-rc1` and
the tag for ongoing development will be `v1.3.0-dev`.

```
git remote update
git checkout upstream/releases/1.2.0
git tag -a v1.2.0-rc1 aaaaaaa
git push upstream v1.2.0-rc1
```

If there is not yet a commit after the start of the release branch, create an empty commit after
the commit for the release branch. This empty commit will be tagged for ongoing development on master.

```
# Create empty commit on master
git remote update
git checkout upstream/master
git commit --allow-empty -m "v1.3.0-dev"
git push upstream

# Tag empty commit for ongoing development
git remote update
git checkout upstream/master
git tag -a v1.3.0-dev bbbbbbb
git pubsh upstream v1.3.0-dev
```

After the release candidate has passed QA and the team is ready to release, tag the commit in the
release branch (`v1.2.0`) and push the tag to Github.

```
git remote update
git checkout upstream/releases/1.2.0
git tag -a v1.2.0 ccccccc
git push upstream v1.2.0
```

### Point releases

After a release, tag `dev` on the release branch for ongoing development.
For example, if `v1.2.0` was tagged on `/releases/1.2.0` and there is work for `v1.2.1`, on the
following commit, tag `v1.2.1-dev`.

```
git remote update
git checkout upstream/releases/1.2.0
git tag -a v1.2.1-dev ddddddd
git push upstream v1.2.1-dev
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
```
### [Changes from v1.3.1](https://github.com/vmware/vic-product/compare/v1.3.1...v1.4.0-rc3)

```````

If the release is a release candidate, mark `This is a pre-release`

## Building Releases

Follow instructions in [How to build VIC Product OVA](BUILD.md)
