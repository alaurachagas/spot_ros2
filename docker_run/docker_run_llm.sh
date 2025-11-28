#!/bin/bash

# Enable GUI display forwarding
xhost +local:docker

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Run the Docker Container with GUI, AI, and ROS 2 support
docker run \
    -it \
    --rm \
    --gpus all \
    --net=host \
    --privileged \
    -e DISPLAY=${DISPLAY} \
    -e NVIDIA_VISIBLE_DEVICES=all \
    -e NVIDIA_DRIVER_CAPABILITIES=graphics,compute,utility \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v "$HOME/.Xauthority:/root/.Xauthority:rw" \
    -v "$REPO_ROOT/colcon_ws/src/ai_agent_spot/saved_data:/overlay_ws/install/spot_agent/share/spot_agent/saved_data" \
    --name agent \
    ai-agent_spot_test:main \
    bash -c "bash /llm_entry.sh; exec bash"



