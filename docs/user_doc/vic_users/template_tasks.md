# Template Configuration Tasks #

To configure a template, you can perform the following tasks:

## Add Containers to a Template ##

After you create a template, you can add one or more containers in the the Edit Template page.

2. On the Edit Template page, click **Add Container**. The Add Container Definition page is displayed. 
2. Select the container you require and click **Continue**. 
2. Specify the configuration for the container and click **Add**.

For information about the configuration, see [Provisioning Container VMs](provision_containers_portal.md).

## Add Volumes to a Template ##

After you create a template, you can add one or more volumes.  

1. On the Edit Template page, click **Add Volume**. The Add Volume page is displayed. 
1. Configure the storage and click **Save**. The volume appears in the template.
1. Drag the link from the volume to a container to associate it with the container.

For more information, see [Creating New Volumes](create_volumes.md).

## Add Networks to a Template ##

After you create a template, you can create a bridge network or a container network.

1. On the Edit Template page, click **Add Network**. The Add Network page is displayed.
1. Configure the snetwrokand click **Save**. The network appears in the template.
1. Drag the link from the network to a container to associate it with the container.

For more information, see [Creating New Networks](create_network.md).

## Configure Links ##

You configure links to templates or images. You can use links to enable communication between multiple services in your application. Links in vSphere Integrated Containers are similar to Docker links, but connect containers across hosts. A link consists of two parts: a service name and an alias. The service name is the name of the service or template being called. The alias is the hostname that you use to communicate with that service.

For example, if you have an application that contains a Web and database service and you define a link in the Web service to the database service by using an alias of *my-db*, the Web service application opens a TCP connection to *my-db:PORT_OF_DB*. The *PORT_OF_DB* is the port that the database listens to, regardless of the public port that is assigned to the host by the container settings. If MySQL is checking for updates on its default *3306* port, and the published port for the container host is *32799*, the Web application accesses the database at *my-db:3306*.

You can use networks instead of links. Links are a legacy Docker feature with significant limitations when linking container clusters, including:

- Docker does not support multiple links with the same alias. 
- You cannot update the links of a container runtime. When scaling up or down a linked cluster, the dependent container’s links will not be updated.

## Configure Scale ##

You can create container clusters by using scale to specify cluster size. 

When you configure a cluster, a specified number of containers is provisioned. Requests are load balanced among all containers in the cluster. You can modify the cluster size on a provisioned container or application to increase or decrease the size of the cluster by one. When you modify the cluster size at runtime, all affinity filters and placement rules are considered.


## Provision Templates ##

After you perform the necessary configurations, you can provision the template. Navigate to **Library** > **Templates** and click **Provision** on the required template. 

## Export and Import Templates

After you create a template, you can export the configuration as a YAML file or a Docker Compose file. 

On the Edit Template page, click the **Export** icon and choose the format you require. 

Similary, you can import a template as a YAML file or a Docker Compose file. 

1. In the management portal, navigate to **Library** > **Templates** and click **Import Template**.
1. In the Import Template page, you can either upload a template or enter its contents.
1. Click **Import**. The template is added to your template library.

## View or Delete Templates ##

You can see the list of templates that are available by navigating to **Library** > **Templates**. 

To delete a template, click the **Delete** icon in the template.