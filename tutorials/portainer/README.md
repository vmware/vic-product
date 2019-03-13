# Tutorial: Running Portainer on VIC


export DOCKER_HOST=W.X.Y.Z:2375 COMPOSE_TLS_VERSION=TLSv1_2

We will use the -H flag to point to the docker socker over tcp to comminicate to the VCH. Direct access to docker socket is not supported in VIC.

Let's create a volume for the portainer
docker volume create portainer_data

Instanciate the container using the following command. 
docker run -d -p 9000:9000 --name portainer --restart always -v portainer_data:/data portainer/portainer -H tcp://W.X.Y.Z:2375

    - "-p" flag is mapping the port 9000 on VCH to port 9000 on the portainer container
    - "-v" flag is adding a volume
    - "-H" flag is passing the remote Host flag to the portainer so that portainer can access the docker socket of VCH to fetch data
