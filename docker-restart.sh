#!/bin/bash
# restart all containers
docker restart $(docker ps -a -q)