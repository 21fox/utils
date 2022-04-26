#!/bin/bash

zfs list | grep -v docker
zfs list -t snapshot