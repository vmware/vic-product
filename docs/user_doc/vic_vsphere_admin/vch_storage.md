# Virtual Container Host Storage #

The `vic-machine` utility allows you to specify the datastore in which to store container image files, container VM files, and the files for the VCH. You can also specify datastores in which to create container volumes. 

- vSphere Integrated Containers Engine fully supports VMware vSAN datastores. 
- vSphere Integrated Containers Engine supports all alphanumeric characters, hyphens, and underscores in datastore paths and datastore names, but no other special characters.
- If you specify different datastores in the different datastore options, and if no single host in a cluster can access all of those datastores, `vic-machine create` fails with an error.
    <pre>No single host can access all of the requested datastores. 
  Installation cannot continue.</pre>
- If you specify different datastores in the different datastore options, and if only one host in a cluster can access all of them, `vic-machine create` succeeds with a warning.
    <pre>Only one host can access all of the image/container/volume datastores. 
  This may be a point of contention/performance degradation and HA/DRS 
  may not work as intended.</pre> 
- VCHs do not support datastore name changes. If a datastore changes name after you have deployed a VCH that uses that datastore, that VCH will no longer function.


