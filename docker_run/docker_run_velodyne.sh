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
    velodyne-ros:main \
    #ros2 run velodyne_driver velodyne_driver_node \
    #--ros-args -p device_ip:=192.168.0.185 -p frame_id:=VLP-16_base_link

