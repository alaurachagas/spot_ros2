#!/bin/bash

# Enable GUI display forwarding
xhost +local:docker

# Run the Docker Container with GUI, AI, and ROS 2 support
docker run \
    -it \
    --rm \
    --net=host \
    --privileged \
    --env="DISPLAY" \
    -v "$HOME/.Xauthority:/root/.Xauthority:rw" \
    --name agent \
    ai-agent_spot_test:main \
    bash -c "bash /llm_entry.sh; exec bash"



