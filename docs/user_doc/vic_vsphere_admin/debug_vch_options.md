# VCH Debug Options #

The command line utility for vSphere Integrated Containers Engine, `vic-machine`, provides a `debug` command that allows you to enable VM console or SSH access to the virtual container host (VCH) endpoint VM, set a password for the root user account, and upload a key file for automatic public key authentication. 

If you authorize SSH access to the VCH endpoint VM, you can edit system configuration files that you cannot edit by running `vic-machine` commands.

**IMPORTANT**: If you set a password or enable shell access on a VCH endpoint VM, these changes do not persist if you reboot the VM. You must run `vic-machine debug` to reenable access and reset the password each time that the VCH endpoint VM reboots.

The `vic-machine debug` command includes the following options in addition to the common options described in [Common `vic-machine` Options](common_vic_options.md).

### `--rootpw` ###

Short name: `--pw`

Set a new password for the root user account on the VCH endpoint VM. Setting a password on the VCH allows you to access the VCH by using the VM console. If you also set the `--enable-ssh` option, you can use this password to connect to the VCH by using SSH. 

When you use the password to log in to a VCH, you see the message that the password will expire in 0 days. To obtain a longer expiration period, use the Linux `passwd` command in the endpoint VM to set a new password. If the password expires, the VCH does not revert to the default security configuration from before you ran `vic-machine debug`. If you attempt to log in using an interactive password via the terminal or SSH, you see a prompt to change the password. If you are using an SSH key, you cannot log in until you either change the password or run `vic-machine debug` again.

Wrap the password in single quotes (Linux or Mac OS) or double quotes (Windows) if it includes shell characters such as `$`, `!` or `%`.

<pre>--rootpw '<i>new_p@ssword</i>'</pre>

### `--enable-ssh` ###

Short name: `--ssh`

Enable an SSH server in the VCH endpoint VM. The `sshd` service runs until the VCH endpoint VM reboots. The `--enable-ssh` takes no arguments. 

If you have already enabled SSH access but the password that you set has expired, and you then rerun `--enable-ssh` without specifying `--rootpw`, the password expiry is set to 1 day in the future and the password is preserved.

<pre>--enable-ssh</pre>

### `--authorized-key` ###

Short name: `--key`

Upload a public key file to `/root/.ssh/authorized_keys` to enable SSH key authentication for the `root` user. Include the name of the `*.pub` file in the path.

<pre>--authorized-key <i>path_to_public_key_file</i>/<i>key_file</i>.pub</pre>