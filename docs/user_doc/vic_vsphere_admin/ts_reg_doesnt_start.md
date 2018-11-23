# Appliance Deployment Succeeds but Registry Services Do Not Start #

After an apparently successful deployment, any views in vSphere Integrated Containers Management Portal that relate to vSphere Integrated Containers Registry do not render correctly and are unusable.

## Problem ##
Deployment of the vSphere Integrated Containers Appliance succeeds, but when you log into vSphere Integrated Containers Management Portal, the following views do not render correctly and cannot be used:

- **Administration** > **Configuration**
- **Administration** > **Global Registries** 
- Certain tabs in **Administration** > **Projects** > *Project* 

If you [check the service status](service_status.md) for vSphere Integrated Containers Registry, you see that `harbor.service` is in a constant loop of starting, running, and stopping.

## Cause ##

You used a version of the HTML5 vSphere Client that pre-dates vCenter Server 6.7 update 1 to deploy the appliance OVA. Older versions of the HTML5 client do not prevent you from deploying OVA files, but due to an issue in older versions of the client, the vSphere Integrated Containers Registry service is assigned to the incorrect port during deployment. This prevents the service from running.

## Solution ##

Use the Flex-based vSphere Web Client to redeploy the appliance OVA. Alternatively, upgrade vCenter Server to version 6.7 update 1 and use the HTML5 vSphere Client to redeploy the appliance OVA. 