#!/bin/bash

source /opt/ros/humble/setup.bash
source /colcon_velodyne/install/setup.bash
source /colcon_ws/install/setup.bash
export RMW_IMPLEMENTATION=rmw_zenoh_cpp
export ROS_DOMAIN_ID=22

ros2 run point_cloud_transport republish \
  --ros-args \
  -p in_transport:=raw \
  -p out_transport:=zlib \
  -r in:=/velodyne_points \
  -r out/zlib:=/velodyne_points_encoded
