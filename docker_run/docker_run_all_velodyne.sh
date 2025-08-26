#!/bin/bash

# Get common params
: "${ROS_DOMAIN_ID:=22}"
echo "ROS_DOMAIN_ID is set to: $ROS_DOMAIN_ID"

: "${HOST_NAME:=spot}"
echo "HOST_NAME is set to: $HOST_NAME"

: "${HOST_IP:=192.168.10.134}"
echo "HOST_IP is set to: $HOST_IP"

: "${ROBOT_NAME:=hiwi}"
echo "ROBOT_NAME is set to: $ROBOT_NAME"

: "${ROBOT_IP:=192.168.10.135}"
echo "ROBOT_IP is set to: $ROBOT_IP"

: "${RMW_IMPLEMENTATION:=rmw_zenoh_cpp}"
echo "RMW_IMPLEMENTATION is set to: $RMW_IMPLEMENTATION"

: "${USE_SIM_TIME:=False}"
echo "USE_SIM_TIME is set to: $USE_SIM_TIME"

# Name of docker containers and docker images
IMAGE=velodyne-ros:main 
CONTAINER_NAME_VELODYNE_DRIVER=velodyne_driver_node
CONTAINER_NAME_VELODYNE_DRIVER_POINTS=velodyne_driver_points
CONTAINER_NAME_ENCODING=velodyne_encoding
CONTAINER_NAME_DECODING=velodyne_decoding

# Docker kill commands
DOCKER_KILL_COMMAND_VELODYNE_DRIVER="docker ps -q --filter name=${CONTAINER_NAME_VELODYNE_DRIVER} | grep -q . && docker rm -fv ${CONTAINER_NAME_VELODYNE_DRIVER}"
DOCKER_KILL_COMMAND_VELODYNE_DRIVER="docker ps -q --filter name=${CONTAINER_NAME_VELODYNE_DRIVER_POINTS} | grep -q . && docker rm -fv ${CONTAINER_NAME_VELODYNE_DRIVER_POINTS}"
DOCKER_KILL_COMMAND_ENCODING="docker ps -q --filter name=${CONTAINER_NAME_ENCODING} | grep -q . && docker rm -fv ${CONTAINER_NAME_ENCODING}"
DOCKER_KILL_COMMAND_DECODING="docker ps -q --filter name=${CONTAINER_NAME_DECODING} | grep -q . && docker rm -fv ${CONTAINER_NAME_DECODING}"

# Tmux session
TMUX_SESSION='tmux-session_'
RANDOM_NUMBER=$RANDOM
TMUX_SESSION_NAME="$TMUX_SESSION$RANDOM_NUMBER"
echo "TMUX_SESSION is set to: $TMUX_SESSION$RANDOM_NUMBER"

# Function to test the connection
function ping_test() {
	if ping -c 1 $1 &>/dev/null; then
		echo "Connection to $1 successful!"
	else
		echo "Can't establish a connection to $1!"
	fi
}

# Function to kill all docker containers with q
function kill_all() {
	bash -c "ssh ${ROBOT_NAME}@${ROBOT_IP} '${DOCKER_KILL_COMMAND_VELODYNE_DRIVER}'"
	bash -c "ssh ${ROBOT_NAME}@${ROBOT_IP} '${DOCKER_KILL_COMMAND_ENCODING}'"
	bash -c "ssh ${HOST_NAME}@${HOST_IP} '${DOCKER_KILL_COMMAND_DECODING}'"

	# Kill tmux
	sleep 5
    TMUX_SESSION_NAME_ATTACHED=$(tmux display-message -p '#S')
    tmux kill-session -t ${TMUX_SESSION_NAME_ATTACHED}
    tmux kill-session -t ${TMUX_SESSION_NAME}
}

# Function that waits for user input and then kills all running docker containers and tmux session
function wait_for_user_and_kill() {
	echo "Press 'q' to kill every process"
	while :; do
		read -n 1 k <&1

		if [[ $k = q ]]; then
			printf "\nQuitting all processes\n"
			kill_all
		fi
	done
}
"$@"

# Allow clients to access the x-server
xhost +

# Create a new session named $TMUX_SESSION_NAME, split panes and change directory in each
tmux new-session -d -s $TMUX_SESSION_NAME

# Config tmux
tmux set -g mouse on

# Run ouster driver
ping_test $ROBOT_IP
tmux split-window -hf -t $TMUX_SESSION_NAME
tmux send-keys -t $TMUX_SESSION_NAME "ssh -Y -t ${ROBOT_NAME}@${ROBOT_IP} \
    '${DOCKER_KILL_COMMAND_ENCODING}; \
    docker run \
            -it \
            --rm \
            --net=host \
            --pid=host \
		    --ipc=host \
            --privileged \
            --env=\"DISPLAY\" \
            -v \"\$HOME/.Xauthority:/root/.Xauthority:rw\" \
            --env DISPLAY=\$DISPLAY \
            --env RMW_IMPLEMENTATION=\${RMW_IMPLEMENTATION} \
            --env ROS_DOMAIN_ID=\${ROS_DOMAIN_ID} \
            --name velodyne_driver_node \
            velodyne-ros:main  \
            bash -c \"bash /velodyne_node_entry.sh; exec bash\"'" Enter

sleep 2

# Run ouster driver
ping_test $ROBOT_IP
tmux split-window -hf -t $TMUX_SESSION_NAME
tmux send-keys -t $TMUX_SESSION_NAME "ssh -Y -t ${ROBOT_NAME}@${ROBOT_IP} \
    '${DOCKER_KILL_COMMAND_ENCODING}; \
    docker run \
            -it \
            --rm \
            --net=host \
            --pid=host \
		    --ipc=host \
            --privileged \
            --env=\"DISPLAY\" \
            -v \"\$HOME/.Xauthority:/root/.Xauthority:rw\" \
            --env DISPLAY=\$DISPLAY \
            --env RMW_IMPLEMENTATION=\${RMW_IMPLEMENTATION} \
            --env ROS_DOMAIN_ID=\${ROS_DOMAIN_ID} \
            --name velodyne_driver_points \
            velodyne-ros:main  \
            bash -c \"bash /velodyne_points_entry.sh; exec bash\"'" Enter

sleep 2

# Run encoding
ping_test $ROBOT_IP
tmux split-window -hf -t $TMUX_SESSION_NAME
tmux send-keys -t $TMUX_SESSION_NAME "ssh -Y -t ${ROBOT_NAME}@${ROBOT_IP} \
    '${DOCKER_KILL_COMMAND_ENCODING}; \
    docker run \
            -it \
            --rm \
            --net=host \
            --pid=host \
		    --ipc=host \
            --privileged \
            --env=\"DISPLAY\" \
            -v \"\$HOME/.Xauthority:/root/.Xauthority:rw\" \
            --env DISPLAY=\$DISPLAY \
            --env RMW_IMPLEMENTATION=\${RMW_IMPLEMENTATION} \
            --env ROS_DOMAIN_ID=\${ROS_DOMAIN_ID} \
            --name velodyne_encoding \
            velodyne-ros:main  \
            bash -c \"bash /velodyne_encoder_entry.sh; exec bash\"'" Enter

sleep 2

# Run decoding
ping_test $HOST_IP
tmux split-window -hf -t $TMUX_SESSION_NAME
tmux send-keys -t $TMUX_SESSION_NAME "ssh -Y -t ${HOST_NAME}@${HOST_IP} \
	'${DOCKER_KILL_COMMAND_DECODING}; \
    docker run \
            -it \
            --rm \
            --net=host \
            --pid=host \
		    --ipc=host \
            --privileged \
            --env=\"DISPLAY\" \
            -v \"\$HOME/.Xauthority:/root/.Xauthority:rw\" \
            --env DISPLAY=\$DISPLAY \
            --env RMW_IMPLEMENTATION=\${RMW_IMPLEMENTATION} \
            --env ROS_DOMAIN_ID=\${ROS_DOMAIN_ID} \
            --name velodyne_decoding \
            velodyne-ros:main  \
            bash -c \"bash /velodyne_decoder_entry.sh; exec bash\"'" Enter

sleep 2

# Kill process terminal
tmux split-window -t $TMUX_SESSION_NAME
tmux send-keys -t $TMUX_SESSION_NAME "bash $0 wait_for_user_and_kill" Enter

# Attach to session named TMUX_SESSION_NAME
tmux attach -t $TMUX_SESSION_NAME
