# Configuring Links #

You configure links to templates or images. You can use links to enable communication between multiple services in your application. Links in vSphere Integrated Containers are similar to Docker links, but connect containers across hosts. A link consists of two parts: a service name and an alias. The service name is the name of the service or template being called. The alias is the hostname that you use to communicate with that service.

For example, if you have an application that contains a Web and database service and you define a link in the Web service to the database service by using an alias of *my-db*, the Web service application opens a TCP connection to *my-db:PORT_OF_DB*. The *PORT_OF_DB* is the port that the database listens to, regardless of the public port that is assigned to the host by the container settings. If MySQL is checking for updates on its default *3306* port, and the published port for the container host is *32799*, the Web application accesses the database at *my-db:3306*.

You can use networks instead of links. Links are a legacy Docker feature with significant limitations when linking container clusters, including:
- Docker does not support multiple links with the same alias. 
- You cannot update the links of a container runtime. When scaling up or down a linked cluster, the dependent container’s links will not be updated.