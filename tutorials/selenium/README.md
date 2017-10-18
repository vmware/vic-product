# Automating Selenium Grid with vSphere Integrated Containers

This is a simple docker compose file that deploys a sample grid with one hub and one node.

## Start the hub and nodes:

```
#!/bin/bash
docker-compose up –d
```

## Verify that the nodes are running:

http://<vch_ip>:4444/grid/console

## If you need more nodes, just scale it up:

```
docker-compose scale chrome=5
```

## If you need less, scale it down:

```
docker-compose scale chrome=1
```

## If you need to stop everyting and restart:

```
docker-compose stop
docker-compose rm
```


