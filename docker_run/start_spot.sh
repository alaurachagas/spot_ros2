#!/bin/bash

###### Common config ######
# Environment variables
export ROS_DOMAIN_ID=22
export RMW_IMPLEMENTATION=rmw_zenoh_cpp

export HOST_NAME=${USER}
export HOST_IP=localhost

export ROBOT_NAME=hiwi
export ROBOT_IP=192.168.10.135 #172.16.35.6 --> 5G ICE

export USE_SIM_TIME=False

# Folder config
SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT")"
SCRIPT_DIR="$(dirname "$(dirname "$SCRIPT")")/scripts"
MAIN_FOLDER="${SCRIPT_DIR}/all"
source ${SCRIPT_DIR}/config.sh

COMPONENTS=(
    "zenoh","run_all_zenoh.sh"
    "spot_drive","run_all_spot.sh"
    "velodyne","run_all_velodyne.sh"
    "mapping","run_all_map_carto.sh"
    #"localization","run_all_loc_carto.sh"
    "nav2","run_all_nav2.sh"
    "rviz","run_description.sh"
)

# Check user input
if [ "$1" == "wait_for_user_and_kill" ]; then
    wait_for_user_and_kill "${COMPONENTS[@]}"
    exit 0
else
    start_components "$MAIN_FOLDER" "${COMPONENTS[@]}"
fi
