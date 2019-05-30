#  VCH Upgrade Options #

The command line utility for vSphere Integrated Containers Engine, `vic-machine`, provides an `upgrade` command that allows you to upgrade virtual container hosts (VCHs) to a newer version. 

The `vic-machine upgrade` command includes the following options in addition to the common options described in [Common `vic-machine` Options](common_vic_options.md).

**NOTE**: Wrap any option arguments that include spaces or special characters in quotes. Use single quotes if you are using `vic-machine` on a Linux or Mac OS system and double quotes on a Windows system. 

### `--appliance-iso` <a id="appliance-iso"></a>

Short name: `--ai`

The path to the new version of the ISO image from which to upgrade the VCH appliance. Set this option if you have moved the `appliance.iso` file to a folder that is not the folder that contains the `vic-machine` binary or is not the folder from which you are running `vic-machine`. Include the name of the ISO file in the path.

**NOTE**: Do not use the `--appliance-iso` option to point `vic-machine` to an `--appliance-iso` file that is of a different version to the version of `vic-machine` that you are running.

<pre>--appliance-iso <i>path_to_ISO_file</i>/<i>ISO_file_name</i>.iso</pre>

### `--bootstrap-iso` <a id="bootstrap-iso"></a>

Short name: `--bi`

The path to the new version of the ISO image from which to upgrade the container VMs that the VCH manages. Set this option if you have moved the `bootstrap.iso` file to a folder that is not the folder that contains the `vic-machine` binary or is not the folder from which you are running `vic-machine`. Include the name of the ISO file in the path.

**NOTE**: Do not use the `--bootstrap-iso` option to point `vic-machine` to a `--bootstrap-iso` file that is of a different version to the version of `vic-machine` that you are running.

<pre>--bootstrap-iso <i>path_to_ISO_file</i>/bootstrap.iso</pre>

### `--force` <a id="force"></a>

Short name: `-f`

Forces `vic-machine upgrade` to ignore warnings and continue with the upgrade of a VCH. Errors such as an incorrect compute resource still cause the upgrade to fail. 

**CAUTION**: Specifying the `--force` option bypasses safety checks, including certificate thumbprint verification. Using `--force` in this way can expose VCHs to the risk of man-in-the-middle attacks, in which attackers can learn vSphere credentials. Using `--force` can result in unexpected deployment topologies that would otherwise fail with an error. Do not use `--force` in production environments. 

<pre>--force</pre>

### `--rollback` <a id="rollback"></a>

Short name: None

Rolls a VCH back to its previous version, for example if upgrade failed. Before starting the upgrade process, `vic-machine upgrade` takes a snapshot of the existing VCH. The upgrade process deletes older snapshots from any previous upgrades. The `--rollback` option reverts an upgraded VCH to the snapshot of the previous deployment. Because `vic-machine upgrade` only retains one snapshot, you can only use `--rollback` to revert the VCH to the version that immediately precedes the most recent upgrade.  

**IMPORTANT**: Since `vic-machine configure` also takes a snapshot of the VCH, when you have to run both `vic-machine upgrade` and c`vic-machine configure` commands, you must run `vic-machine configure --rollback` before `vic-machine upgrade --rollback` in order to roll a VCH back to its previous version.

<pre>--rollback</pre>

### `--reset-progress` <a id="reset-progress"></a>

If an attempt to upgrade a VCH was interrupted before it could complete successfully, any further attempts to run `vic-machine upgrade` fail with the error `another upgrade/configure operation is in progress`. This happens because `vic-machine upgrade` sets an `UpdateInProgress` flag on the VCH endpoint VM that prevents other operations on that VCH while the upgrade operation is ongoing. If an upgrade operation is interrupted before it completes, this flag persists on the VCH indefinitely.

To clear the flag so that you can attempt further `vic-machine upgrade` operations, run `vic-machine upgrade` with the `--reset-progress` option.

<pre>--reset-progress</pre>

**IMPORTANT**: Before you run `vic-machine upgrade --reset-progress`, check in Recent Tasks in the vSphere Client that there are indeed no update or configuration operations in progress on the VCH endoint VM.

### `--debug` <a id="debug"></a>

Short name: `-v`

Upgrade the VCH with more verbose levels of logging. For example, by setting a higher debug level, you increase the verbosity of the logging for VCH upgrade, initialization of VCH services, container VM initialization, and so on. 

**NOTE**: Do not confuse the `vic-machine upgrade --debug` option with the `vic-machine debug` command, that enables access to the VCH endpoint VM. For information about `vic-machine debug`, see [Debug Running Virtual Container Hosts](debug_vch.md). 

You can set a debugging level of 1, 2, or 3. Setting level 2 or 3 changes the behavior of `vic-machine upgrade` as well as increasing the level of verbosity of the logs.

<pre>--debug 1</pre>