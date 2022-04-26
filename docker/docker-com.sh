#!/bin/bash

# config
/etc/docker/daemon.json
# restart all containers
docker restart $(docker ps -a -q)