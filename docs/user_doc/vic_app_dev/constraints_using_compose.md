# Constraints of Using vSphere Integrated Containers Engine with Docker Compose #

There are some constraints on the types of containerized applications that you can deploy with this release of vSphere Integrated Containers Engine. For the lists of Docker features that this release supports and does not support, see [Use and Limitations of Containers in vSphere Integrated Containers Engine](container_limitations.md). 

##  Building Container Images ##

This release does not support  the `docker build` or `push` commands. As a consequence, you must use regular Docker to build a container image and to push it to the global hub or to your private registry server. 


