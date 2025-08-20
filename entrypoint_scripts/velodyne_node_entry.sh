#!/bin/bash

source /opt/ros/humble/setup.bash
source /colcon_velodyne/install/setup.bash
export RMW_IMPLEMENTATION=rmw_zenoh_cpp
export ROS_DOMAIN_ID=22

ros2 run velodyne_driver velodyne_driver_node \
    --ros-args -p device_ip:=192.168.0.186