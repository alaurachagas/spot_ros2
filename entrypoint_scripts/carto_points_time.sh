#!/bin/bash

source /opt/ros/humble/setup.bash
source /colcon_ws/install/setup.bash

# Set environment variables
export RMW_IMPLEMENTATION=rmw_zenoh_cpp
export ROS_DOMAIN_ID=22

ros2 run spot_cartographer pc2_time_normalizer \
  --ros-args -p input:=/velodyne_points_decoded \
             -p output:=/velodyne_points_cartographer \
             -p mode:=sorted