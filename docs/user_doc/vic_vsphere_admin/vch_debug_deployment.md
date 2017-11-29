# Debugging Virtual Container Host Deployment #

If you experience problems when deploying virtual container hosts (VCHs), you can specify additional `vic-machine create` options to help you to debug the deployment. You can also configure a VCH so that it sends its logs to an external syslog endpoint. 

- [`vic-machine` Options](#options)
- [Example `vic-machine` Command](#example)

## `vic-machine` Options <a id="options"></a>

You debug VCH deployment by using the [`--debug`](#debug), [`--force`](#insecure-registry), and [`--timeout`](#timeout) options. You configure an external syslog endpoint by using the [`--syslog-address`](#syslog) option.



### `--force` <a id="force"></a>

Short name: `-f`

Forces `vic-machine create` to ignore warnings and non-fatal errors and continue with the deployment of a VCH. Errors such as an incorrect compute resource still cause the deployment to fail.

**CAUTION**: Specifying the `--force` option bypasses safety checks, including certificate thumbprint verification. Using `--force` in this way can expose VCHs to the risk of man-in-the-middle attacks, in which attackers can learn vSphere credentials. Using `--force` can result in unexpected deployment topologies that would otherwise fail with an error. Do not use `--force` in production environments. 

**Usage**:

<pre>--force</pre>

### `--timeout` <a id="timeout"></a>

**Short name**: none

The timeout period for uploading the vSphere Integrated Containers Engine files and ISOs to the ESXi host, and for powering on the VCH. Specify a value in the format `XmYs` if the default timeout of 3m0s is insufficient. 

**Usage**:

<pre>--timeout 5m0s</pre> 



