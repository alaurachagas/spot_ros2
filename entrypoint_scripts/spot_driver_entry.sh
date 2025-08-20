#!/bin/bash

source /opt/ros/humble/setup.bash
source /ros_ws/install/setup.bash
source /velodyne_ws/install/setup.bash
export RMW_IMPLEMENTATION=rmw_zenoh_cpp
export ROS_DOMAIN_ID=22
export BOSDYN_CLIENT_USERNAME="user"
export BOSDYN_CLIENT_PASSWORD="7imkn5gffaz9"
export SPOT_IP=192.168.50.3
export SPOT_VELODYNE=1
export SPOT_LIDAR_MOUNT=1
export SPOT_VELODYNE_XYZ='-0.33 0 0.12'
export SPOT_PACK=1

ros2 launch spot_driver spot_driver.launch.py