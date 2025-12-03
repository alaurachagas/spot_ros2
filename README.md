# About this repository

This repository was created as part of the thesis by [Ana Laura Soethe Chagas](https://github.com/alaurachagas) at the [Laboratory for Machine Tools and Production Engineering (WZL) of RWTH Aachen University](https://www.wzl.rwth-aachen.de/go/id/sijq/?lidx=1), entitled *Embodied-AI Agent Integrated with a Quadruped Robot for Mapping & Navigation of Flexible Assembly Environments*.

Here you will find the implementation of an Embodied-AI agent (based on Llama v3.1) running on a [Spot](https://bostondynamics.com/products/spot/) robot, tested both in simulation (with Webots) and on real hardware.

Below you will find a full explanation of the components in this repository and instructions on how to run the system on the real robot and in the simulated environment.

## Table of Contents
[1. General REPO Organization](#1-general-repo-organization) \
[1.1. Submodules: Brief Overview](#11-submodules-brief-overview) \
[2. Prerequisites for Running the REPO](#2-prerequisites-for-running-the-repo) \
[3. ](#3)

# 1. General REPO Organization

This repository is a master repository, meaning it serves as a wrapper around multiple other repositories. The main goal was to create a framework that is:

1. **Modular:** each part of the system can be developed and maintained independently. This is achieved using a submodule structure.

2. **Reproducible:** enabling the same setup to run on different machines without configuration issues, which is why Docker is heavily used throughout this repository.

3. **Interoperable:** compatible with existing robotics software, which explains the choice of ROS 2 Humble.

4. **Scalable:** a consequence of the previous points—new modules and functionalities can be added without redesigning the entire system.

The folder organization is straightforward. The most important folders are:

- ***colcon_ws/src/*** contains all submodules. The *src* structure follows the standard ROS workspace format, making it easier to copy submodules into the Docker images.

- ***Dockerfiles/*** contains all Dockerfiles used to create the Docker images required to run this repository.

- ***docker_build/*** contains *.bash* scripts used to build images on Linux machines.

- ***docker_run/*** similarly contains *.bash* scripts used to run Docker containers using the built images.

- ***entrypoint_scripts/*** holds *.bash* scripts that are automatically executed when starting a Docker container (when using the *docker_run* scripts). These scripts start the appropriate ROS nodes needed for running the repository.

In addition to these, there are four folders with configuration files:

- ***files_to_change/*** holds files (from submodules) that required modifications to work properly with this repository. These modified versions replace the originals inside the Docker images.

- ***map/*** is used exclusively by the *Cartographer* and *Nav2* containers. It is mounted into the container and used to save and share map files.

- ***config/*** is used exclusively by the *Description* and *Webots* containers. It contains RViz2 configuration files.

- ***webots_files/*** contains functionality similar to *files_to_change/* and *map/*, but specifically for the Webots image and container.


## 1.1. Submodules: Brief Overview

This repository makes use of 9 submodules in total. The main submodules, and the ones developed during the Thesis are:

- [***ai_agent_spot***](colcon_ws/src/ai_agent_spot) is the full Embodied-AI agent development. It is stuctured as a ROS 2 package, and was built using LangChain v1.0.0.
- [***cartographer_spot***](colcon_ws/src/cartographer_spot/) has the configuration and launch necessary to run the Cartographer SLAM algorithm using ROS 2, both in real environment and simulation.
- [***spot_nav2***](colcon_ws/src/spot_nav2/) has the custome configuration and launch necessary to launch Nav2 in the real robot.

The remaining submodules were developed by external teams, and <tell how important they were for the thesis>

- [***velodyne***](colcon_ws/src/velodyne/) was originally a branch from the [official *Velodyne* driver repo](https://github.com/ros-drivers/velodyne) from [ROS device drivers](https://github.com/ros-drivers), but during development the Humble branch got deleted, and the content was then saved as a private repo (to prevent losing the it). It is the main Velodyne Puck LiDAR driver, and it converts the LiDAR's data into PointCloud2 ROS 2 data.

- [***point_cloud_transport***](colcon_ws/src/point_cloud_transport/) and [***point_cloud_transport_plugins***](colcon_ws/src/point_cloud_transport_plugins/) were used for encoder PointCloud2 data from the LiDAR mounted in the real robot, and later decoding it in the edge computer, for processing. These submodules made sure the network did not get overwheelmed by the PointCloud2 data, and made wireless comunication reliable for the use case.

- [***velodyne_description***](colcon_ws/src/velodyne_description/) and [***spot_description***](colcon_ws/src/spot_description/) are both ROS packages that contain URDFs and Meshes files to be able to visualize the Spot robot and Velodyne LiDAR in RViz2.

- Finally [***webots_ros2_spot***](colcon_ws/src/webots_ros2_spot/) is a ROS 2 package that has the full configuration to run Spot with a Velodyne LiDAR in the simulation environment of Webots.

<picture>
  <!-- Dark mode image -->
  <source media="(prefers-color-scheme: dark)" srcset="images_readme/dark_Spot_agent_structure.svg">
  <!-- Light mode image -->
  <source media="(prefers-color-scheme: light)" srcset="images_readme/light_Spot_agent_structure.svg">
  <!-- Fallback (if the browser doesn’t support the media query) -->
  <img alt="Spot agent architecture overview" src="light_Spot_agent_structure.svg">
</picture>

# 2. Prerequisites for Running the REPO

- Linux or Windows+WSL2 Ubuntu. (for the bash scripts)
- Docker
- ROS 2 Humble
- RMW Zenoh (See section x.x.)

# 3. Quick start


