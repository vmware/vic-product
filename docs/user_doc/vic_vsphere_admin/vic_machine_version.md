# Obtain `vic-machine` Version Information #

You can obtain information about the version of `vic-machine` by using the `vic-machine version` command.

The `vic-machine version` command has no arguments.

## Example ##

<pre>$ vic-machine-<i>operating_system</i> version</pre>

## Output ##

The `vic-machine` utility displays the version of the instance of `vic-machine` that you are using. 

<pre>vic-machine-<i>operating_system</i> 
version <i>vic_machine_version</i>-<i>vic_machine_build</i>-<i>git_commit</i></pre>

- <code><i>vic_machine_version</i></code> is the version number of this release of vSphere Integrated Containers Engine.
- <code><i>vic_machine_build</i></code> is the build number of this release.
- <code><i>tag</i></code> is the short `git commit` checksum for the latest commit for this build.