# Obtain Virtual Container Host Configuration Information #

You can obtain information about the configuration of a virtual container host (VCH) by using the `config` command with `vic-machine inspect`. The `config` command provides details of the options with which the VCH was deployed with `vic-machine create` or subsequently reconfigured with  `vic-machine configure`. 

The `config` command only includes one option, `--format`, the value of which can be either `verbose` or `raw`. 

- `verbose`: Provides an easily readable list of the options with which the VCH was deployed. If you do not specify `--format`, `config` provides verbose output by default. 
- `raw`: Provides the options with which the VCH was deployed in command line option format. You can copy or pipe the output into a `vic-machine create` command, to create an identical VCH.

You must specify the `vic-machine inspect --target`, `--thumbprint`, `--name` or `--id`, and possibly `--compute-resource` options before you include  `config` in the command.

## Verbose Example ##

The following example obtains the configuration of a VCH by using its VCH ID. It does not specify `--format`, so the command provides verbose output.

<pre>$ vic-machine-<i>operating_system</i> inspect
    --target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i>
    config
</pre>


### Output ###

By default, the `vic-machine inspect config` command lists the options with which the VCH was deployed in the easily readable verbose format. 

<pre>Target VCH created with the following options:

        --target=<i>vcenter_server_address</i>
        --thumbprint=<i>certificate_thumbprint</i>
        --name=vch1
        --compute-resource=/<i>datacenter_name</i>/host/<i>vcenter_server_address</i>/Resources
        --ops-user=Administrator@vsphere.local
        --image-store=ds://datastore1
        --volume-store=ds://datastore1/volumes:default
        --volume-store=ds://datastore1/volumes:vol1
        --bridge-network=vic-bridge
        --public-network=vic-public
        --memory=1024
        --cpu=1024</pre>

In addition to the minimum required `vic-machine create` options, the VCH in this example was deployed with two volume stores, named `default` and `vol1`, a specific public network, and constraints on memory and cpu usage. Also, because the VCH was not deployed with the `--ops-user` option, `config` lists `--ops-user` as Administrator@vsphere.local, which is the same user account as the one that was used to deploy the VCH.

## Raw Example ##

The following example specifies the `--format raw` option.

<pre>$ vic-machine-<i>operating_system</i> inspect
    --target 'Administrator@vsphere.local':<i>password</i>@<i>vcenter_server_address</i>
    --thumbprint <i>certificate_thumbprint</i>
    --id <i>vch_id</i>
    config 
    --format raw
</pre>


### Output ###

The `vic-machine inspect config` command lists the options with which the VCH was deployed in command line format. 

<pre>--target=<i>vcenter_server_address</i> --thumbprint=<i>certificate_thumbprint</i> --name=vch1 --compute-resource=/<i>datacenter_name</i>/host/<i>vcenter_server_address</i>/Resources --ops-user=Administrator@vsphere.local --image-store=ds://datastore1 --volume-store=ds://datastore1%5Cvolumes%5Ctlsverify:default --volume-store=ds://datastore1%5Cvolumes%5Cconfigtest:vol1 --bridge-network=vic-bridge --public-network=vic-public --memory=1024 --cpu=1024</pre>