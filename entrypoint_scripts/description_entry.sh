#!/bin/bash

source /opt/ros/humble/setup.bash
source /colcon_ws/install/setup.bash
export RMW_IMPLEMENTATION=rmw_zenoh_cpp
export ROS_DOMAIN_ID=22

export SPOT_VELODYNE=1
export SPOT_LIDAR_MOUNT=1
export SPOT_VELODYNE_XYZ='-0.33 0 0.12'
export SPOT_PACK=1

rviz2