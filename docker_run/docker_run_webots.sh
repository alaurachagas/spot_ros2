#!/bin/bash

# Allow Docker to use the local X server (for GUI applications)
xhost +local:root

# Get the absolute path of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set the project root directory (one level up from docker_run folder)
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Navigate to the project root directory (this was missing in the broken script)
cd "$PROJECT_ROOT"

# Set the path to the maps folder inside the project directory
MAPS_DIR="$PROJECT_ROOT/webots_files/maps_files"
LAUNCH_DIR="$PROJECT_ROOT/webots_files/launch_files"

# Check if the MAPS folder exists, exit if not found
if [ ! -d "$MAPS_DIR" ]; then
    echo "Error: maps directory not found at $MAPS_DIR"
    exit 1
fi

docker run \
    -it \
    --rm \
    --gpus all \
    --net=host \
    --privileged \
    --env="DISPLAY" \
    -v "$HOME/.Xauthority:/root/.Xauthority:rw" \
    --volume "$MAPS_DIR":/maps \
    --volume "$LAUNCH_DIR/agent_nav_launch.py:/colcon_ws/install/webots_spot/share/webots_spot/launch/agent_nav_launch.py" \
    --volume "$LAUNCH_DIR/agent_spot_launch.py:/colcon_ws/install/webots_spot/share/webots_spot/launch/agent_spot_launch.py" \
    --name test \
    spot_webots:main \
    bash -c "ros2 launch webots_spot agent_spot_launch.py; exec bash"