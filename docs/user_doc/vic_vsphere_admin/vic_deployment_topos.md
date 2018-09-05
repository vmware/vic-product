# Deployment Topologies for the vSphere Integrated Containers Appliance #

You can deploy multiple vSphere Integrated Containers appliances to the same vCenter Server instance. 

For example, the following deployment scenarios are possible:

- You can deploy two vSphere Integrated Containers appliances to the same vCenter Server instance and use the vSphere Integrated Containers Registry instance in each one as the image replication endpoint for the other.
- If a Platform Services Controller manages multiple vCenter Server instances, you can deploy multiple appliances to different vCenter Server instances that share that Platform Services Controller. This setup provides the following advantages:
 - All of the user accounts that are configured in the Platform Services Controller are available to all of the vSphere Integrated Containers appliances. 
 - You can assign diffferent roles to the same user account in different instances of the appliance. For example, a user can be a vSphere Integrated Containers Management Portal administrator for one instance, but not for another.
- In a large vSphere environment, in which not all vCenter Server instances are located in the same place, or are not all in the same vCenter Single Sign On domain, you can create a hub and spoke configuration: 
 - You deploy one vSphere Integrated Containers appliance to a vCenter Server instance in a centralized location, to act as a hub. 
 - You deploy one vSphere Integrated Containers appliance to each of the  remote vCenter Server instances.
 - You configure image replication between the vSphere Integrated Containers Registry instances in each location and the registry in the hub.
 - In this way, all of the remote locations have access to all of the images from the central hub, and data proximity is enhanced.

## How the vSphere Integrated Containers Plug-in for vSphere Client Handles Multiple Appliances 

Blurb here.