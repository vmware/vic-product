# Storage Configuration #

Configure the volume settings of the container on the **Storage** tab of the Provision a Container page. 

Configure the following settings:

- Volumes. The volume name and container that are associated with the volume. You must specify a volume name or an absolute path. The container field is mandatory and must contain an absolute path. 
- Read Only. Select this option to configure your volume as read only. For example, if you have an application that contains a Web and database service and the Web service  shares its volume with the database service, you might want to configure the volume as read only. 
- Volumes From. A list of volumes to inherit from another container.
- Working Directory. The working directory for the commands to run in. 