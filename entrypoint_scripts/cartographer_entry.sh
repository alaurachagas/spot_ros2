#!/bin/bash

source /opt/ros/humble/setup.bash
source /colcon_ws/install/setup.bash

# Set environment variables
export RMW_IMPLEMENTATION=rmw_zenoh_cpp
export ROS_DOMAIN_ID=22

ros2 launch spot_cartographer real_spot.launch.py 