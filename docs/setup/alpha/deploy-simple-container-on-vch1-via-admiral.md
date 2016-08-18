
When we deployed `VCH1` we exercised it mildly by deploying a few basic containers, namely Busybox and Nginx.

Let’s try to do the same using the Admiral interface now.

To do so you can do the following:

*   Move to the `Templates` tab and search for “Busybox”.
*   Click on `Enter additional info` for the Busybox container.
*   Customize the name of this container to busybox-from-admiral.
*   Click `provision` to instantiate the Busybox image against VCH1.
*   Check in the Admiral UI `Containers` tab that Busybox has been instantiated and it’s running.
*   Check in the vSphere UI that a new ContainerVM has been created and started.

We can do something similar for Nginx where, in addition, we can expose container’s port 80 on the VCH port 81.

To do so search for the NGINX image and go through the steps above. In addition, click on the Network tab and map port 80 of the container to port 80 of the host.

Once the container is deployed, you can reach nginx on port 80 of the `VCH1` IP address (`10.140.51.101`).
