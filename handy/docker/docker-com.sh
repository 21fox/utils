#!/bin/bash

# config path
/etc/docker/daemon.json

# restart all containers
docker restart $(docker ps -a -q)

# container bash
docker exec -it gotit-db bash

# rebuild container
docker-compose up -d --build mongo
