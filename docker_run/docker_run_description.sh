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
    -v "$REPO_ROOT/config:/config" \
    --name spot_description \
    spot-description-ros:main \
    bash -c "bash /description_entry.sh"