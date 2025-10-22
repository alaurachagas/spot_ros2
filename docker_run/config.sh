#!/bin/bash

function start_components() {
    WORKING_DIR=$1
    shift
    COMPONENTS_ARRAY=("$@")

    TERMINAL_COMMAND="mate-terminal --profile=kairos --working-directory=$WORKING_DIR "

    for component in "${COMPONENTS_ARRAY[@]}"; do
        IFS=, read name run_command <<< "$component"

        TERMINAL_COMMAND+="--tab --title=$name -e '$run_command' "
    done

    eval $TERMINAL_COMMAND &
}

function stop_components() {
    COMPONENTS_ARRAY=("$@")

    WINDOW_ID=""

    for component in "${COMPONENTS_ARRAY[@]}"; do
        IFS=, read name run_command arg <<< "$component"

        WINDOW_ID=$(xwininfo -name $name 2>/dev/null | sed -e 's/^ *//' | grep -E "Window id" | awk '{ print $4 }')

        # if error next interation
        if [ -z "$WINDOW_ID" ]; then
            continue
        else
            break
        fi
    done

    if [ -z "$WINDOW_ID" ]; then
        echo "No window found"
        exit 1
    fi

    xdotool windowfocus $WINDOW_ID

    for i in "${COMPONENTS_ARRAY[@]}"; do
        xdotool key ctrl+Page_Down
        sleep 0.1
        xdotool key q
    done
}

function wait_for_user_and_kill() {
    COMPONENTS_ARRAY=("$@")

    echo "Press 'q' to send a 'q' to all the other terminals"

    while :; do
        read -n 1 key <&1

        if [[ ${key} == "q" ]]; then
            printf "\nQuitting all processes\n"
            stop_components "${COMPONENTS_ARRAY[@]}"
            exit 0
        fi
    done
}
