# Debug Running Virtual Container Hosts #

By default, all shell access to the virtual container host (VCH) endpoint VM is disabled. Login shells for all users are set to `/bin/false`. The  `vic-machine` utility provides a `debug` command that allows you to enable shell access to the VCH endpoint VM, either by using the VM console or via SSH.

In addition to the [Common `vic-machine` Options](common_vic_options.md), `vic-machine debug` provides the `--rootpw`, `--enable-ssh` and `--authorized-key` options, which are described in the following sections. 

* [Enable Shell Access to the VCH Endpoint VM](vch_shell_access.md)
* [Authorize SSH Access to the VCH Endpoint VM](vch_ssh_access.md) 

**NOTE**: Do not confuse the `vic-machine debug` command with the `vic-machine create --debug` or `vic-machine configure --debug` options. The `vic-machine debug` command allows you to log into and debug a VCH endpoint VM that you have already deployed. The `vic-machine create --debug` option deploys a new VCH that has increased levels of logging and other modifications, to allow you to debug the environment in which you deploy VCHs. For information about the `vic-machine create --debug` option, see [Debug](vch_general_settings.md#debug) in the topic on configuring general VCH settings.