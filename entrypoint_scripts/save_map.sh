#!/bin/bash

source /opt/ros/humble/setup.bash
source /colcon_ws/install/setup.bash

# Set environment variables
export RMW_IMPLEMENTATION=rmw_zenoh_cpp
export ROS_DOMAIN_ID=22

ros2 service call /write_state cartographer_ros_msgs/srv/WriteState "{filename: '/map/validation_map.pbstream', include_unfinished_submaps: true}"
# ros2 run nav2_map_server map_saver_cli -t /map -f /map/validation_manual_11