#!/bin/bash

# Allow Docker to use the local X server (for GUI applications)
xhost +local:root

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

docker run \
    -it \
    --rm \
    --net=host \
    --privileged \
    --env="DISPLAY" \
    -v "$HOME/.Xauthority:/root/.Xauthority:rw" \
    -v "$REPO_ROOT/map:/map" \
    --name navigation \
    navigation-ros:main \
    bash -c "source install/setup.bash && ros2 launch spot_nav2 sim_nav2.launch.py; exec bash"

