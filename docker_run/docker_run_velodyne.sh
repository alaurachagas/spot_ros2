#!/bin/bash

# Allow Docker to use the local X server (for GUI applications)
xhost +local:root

docker run \
    -it \
    --rm \
    --net=host \
    --privileged \
    --env="DISPLAY" \
    -v "$HOME/.Xauthority:/root/.Xauthority:rw" \
    --name velodyne \
    velodyne-ros:main
