#!/bin/bash

source /opt/ros/humble/setup.bash
source /colcon_velodyne/install/setup.bash
source /colcon_ws/install/setup.bash
export RMW_IMPLEMENTATION=rmw_zenoh_cpp
export ROS_DOMAIN_ID=22

ros2 run point_cloud_transport republish --ros-args -p in_transport:=draco -p out_transport:=raw -p out.draco.force_quantization:=true -r in/draco:=/velodyne_points_encoded -r out:=/velodyne_points_decoded

