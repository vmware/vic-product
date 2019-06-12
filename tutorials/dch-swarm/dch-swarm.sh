#!/bin/bash

## USER-DEFINED VARIABLES
# Number of swarm workers desired
NUM_WORKERS=3
# name of routable (external) network
# this needs to be defined on your VCH using the '--container-network' option
# use 'docker network ls' to list available external networks
CONTAINER_NET=routable
# Docker Container Host (DCH) image to use 
# see https://hub.docker.com/r/vmware/dch-photon/tags/ for list of available Docker Engine versions
DCH_IMAGE="vmware/dch-photon:18.06"

## NO NEED TO MODIFY BEYOND THIS POINT
# pull the image
docker pull $DCH_IMAGE

# create a docker volume for the master image cache
docker volume create --opt Capacity=10GB --name registrycache
# create and run the master instance
docker run -d -v registrycache:/var/lib/docker \
  --net $CONTAINER_NET \
  --name manager1 --hostname=manager1 \
  $DCH_IMAGE
# get the master IP
SWARM_MASTER=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' manager1)
# create the new swarm on the master
docker -H $SWARM_MASTER swarm init

# get the join token
SWARM_TOKEN=$(docker -H $SWARM_MASTER swarm join-token -q worker)
sleep 10

# run $NUM_WORKERS workers and use $SWARM_TOKEN to join the swarm
for i in $(seq "${NUM_WORKERS}"); do

  # create docker volumes for each worker to be used as image cache
  docker volume create  --opt Capacity=10GB --name worker-vol${i}
  # run new worker container
  docker run -d -v worker-vol${i}:/var/lib/docker \
    --net $CONTAINER_NET \
    --name worker${i} --hostname=worker${i}  \
    $DCH_IMAGE  
  # wait for daemon to start
  sleep 10

  # join worker to the swarm
  for w in $(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' worker${i}); do
    docker -H $w:2375 swarm join --token ${SWARM_TOKEN} ${SWARM_MASTER}:2377
  done
 
done
 
# display swarm cluster information
printf "\nLocal Swarm Cluster\n=========================\n"

docker -H $SWARM_MASTER node ls

printf "=========================\nMaster available at DOCKER_HOST=$SWARM_MASTER:2375\n\n"
