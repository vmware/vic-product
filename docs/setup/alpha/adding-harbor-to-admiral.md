Admiral supports adding additional registries to the default registry set (```registry.hub.docker.com```).

To manage registries, you need to go to the ```Templates``` tab and click ```Manage Registry```.

If you click ```Add```, you can add additional registries.

Now we are going to add the Harbor instance we just deployed by giving it a name and filling the IP / Hostname field with ```http://10.140.50.77:80```.

As a reminder, Harbor runs on port 80 of our Linux VM (whose IP is ```10.140.50.77```). Make sure you specify port ```80``` when you enter the IP address because Admiral will otherwise default to port ```5000``` for registries.

We are also going to define new credentials in Admiral to match the credentials we have used for the admin user in Harbor (```admin/Vmware123!```).

If everything worked, you should now see two registries listed and available: docker hub and the harbor registry.
