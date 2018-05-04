# Appliance Deployment Succeeds but Registry Services Do Not Start #

After an apparently successful deployment, any views in vSphere Integrated Containers Management Portal that relate to vSphere Integrated Containers Registry do not render correctly and are unusable.

## Problem ##
Deployment of the vSphere Integrated Containers Appliance succeeds, but when you log into vSphere Integrated Containers Management Portal, the following views do not render correctly and cannot be used:

- **Administration** > **Configuration**
- **Administration** > **Global Registries** 
- Certain tabs in **Administration** > **Projects** > *Project* 

If you [check the service status](service_status.md) for vSphere Integrated Containers Registry, you see that `harbor.service` is in a constant loop of starting, running, and stopping.

## Cause ##

You used the vSphere 6.7 HTML5 client to deploy the appliance OVA. The vSphere 6.7 HTML5 client does not prevent you from deploying OVA files. Due to an issue in the vSphere 6.7 HTML5 client, the vSphere Integrated Containers Registry service is assigned to the incorrect port during deployment. This prevents the service from running.

## Solution ##

Redeploy the appliance. Always use the Flex-based vSphere Web Client to deploy the appliance OVA, even if you are using vSphere 6.7.