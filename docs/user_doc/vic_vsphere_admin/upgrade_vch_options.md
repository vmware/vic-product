#  VCH Upgrade Options #

The command line utility for vSphere Integrated Containers Engine, `vic-machine`, provides an `upgrade` command that allows you to upgrade virtual container hosts (VCHs) to a newer version. 

The `vic-machine upgrade` command includes the following options in addition to the common options described in [Common `vic-machine` Options](common_vic_options.md).

**NOTE**: Wrap any option arguments that include spaces or special characters in quotes. Use single quotes if you are using `vic-machine` on a Linux or Mac OS system and double quotes on a Windows system. 

### `--appliance-iso` ###

Short name: `--ai`

The path to the new version of the ISO image from which to upgrade the VCH appliance. Set this option if you have moved the `appliance.iso` file to a folder that is not the folder that contains the `vic-machine` binary or is not the folder from which you are running `vic-machine`. Include the name of the ISO file in the path.

**NOTE**: Do not use the `--appliance-iso` option to point `vic-machine` to an `--appliance-iso` file that is of a different version to the version of `vic-machine` that you are running.

<pre>--appliance-iso <i>path_to_ISO_file</i>/<i>ISO_file_name</i>.iso</pre>

### `--bootstrap-iso` ###

Short name: `--bi`

The path to the new version of the ISO image from which to upgrade the container VMs that the VCH manages. Set this option if you have moved the `bootstrap.iso` file to a folder that is not the folder that contains the `vic-machine` binary or is not the folder from which you are running `vic-machine`. Include the name of the ISO file in the path.

**NOTE**: Do not use the `--bootstrap-iso` option to point `vic-machine` to a `--bootstrap-iso` file that is of a different version to the version of `vic-machine` that you are running.

<pre>--bootstrap-iso <i>path_to_ISO_file</i>/bootstrap.iso</pre>

### `--force` ###

Short name: `-f`

Forces `vic-machine upgrade` to ignore warnings and continue with the upgrade of a VCH. Errors such as an incorrect compute resource still cause the upgrade to fail. 

You can bypass certificate thumbprint verification by specifying the `--force` option instead of `--thumbprint`. 

**CAUTION**: It is not recommended to use `--force` to bypass thumbprint verification in production environments. Using `--force` in this way exposes VCHs to the risk of man-in-the-middle attacks, in which attackers can learn vSphere credentials.

<pre>--force</pre>

### `--rollback` ###

Short name: None

Rolls a VCH back to its previous version, for example if upgrade failed. Before starting the upgrade process, `vic-machine upgrade` takes a snapshot of the existing VCH. The upgrade process deletes older snapshots from any previous upgrades. The `--rollback` option reverts an upgraded VCH to the snapshot of the previous deployment. Because `vic-machine upgrade` only retains one snapshot, you can only use `--rollback` to revert the VCH to the version that immediately precedes the most recent upgrade.  

<pre>--rollback</pre>
