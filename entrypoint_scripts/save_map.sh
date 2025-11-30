#!/bin/bash

source /opt/ros/humble/setup.bash
source /colcon_ws/install/setup.bash

# Set environment variables
export RMW_IMPLEMENTATION=rmw_zenoh_cpp
export ROS_DOMAIN_ID=22

ros2 run nav2_map_server map_saver_cli -t /map -f /map/simulation_mapping_manual_10