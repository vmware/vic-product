
When we [deployed VCH1](install-configure-vch.md) we exercised it simply by deploying a few basic containers, namely Busybox and Nginx.

Let’s try to do the same using the Admiral interface now.

To do so you can do the following from the Admiral UI:

*   Move to the `Templates` tab and search for “Busybox”.
*   Click on `Enter additional info` for the Busybox container.
*   Customize the name of this container to _busyboxadmiral_.
*   Click `provision` to instantiate the Busybox image against VCH1.
*   Check in the Admiral UI `Resources->Containers` tab that Busybox has been instantiated and it’s running.
*   Check in the vSphere UI that a new ContainerVM has been created and started.

We can do something similar for Nginx where, in addition, we can expose container’s port 80 on the VCH port 82 (just in case ports 80 and 81 are already used by instances launched in previous exercises).

To do so, this time we are going to launch the _nginx:1.9.0_ image we pushed in the local Harbor registry.

Follow these steps:

*   Move to the `Templates` tab and search for “vmworld/nginx”.
*   Click on `Enter additional info` for the vmworld/nginx container.
*   Since this image has an explicit version, you need to manually add _1.9.0_ (should the version be latest you can leave the string as-is).
*   Customize the name of this container to _nginxadmiral_.
*   Move to the Network tab and map host port _82_ to container port _80_.
*   Click `provision` to instantiate the vmworld/nginx image hosted on Harbor against VCH1.
*   Check in the Admiral UI `Resources->Containers` tab that Nginx has been instantiated and it’s running.
*   Check in the vSphere UI that a new ContainerVM has been created and started.

Once the containerVM is deployed, you can reach nginx on port 82 of the `VCH1` IP address (`10.140.51.101`).
