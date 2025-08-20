#!/bin/bash

source /opt/ros/humble/setup.bash
source /colcon_velodyne/install/setup.bash
export RMW_IMPLEMENTATION=rmw_zenoh_cpp
export ROS_DOMAIN_ID=22

ros2 launch velodyne_pointcloud velodyne_transform_node-VLP16-launch.py