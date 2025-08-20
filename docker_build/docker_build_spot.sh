#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

docker build -t spot-ros_ana:main -f "$REPO_ROOT/Dockerfiles/Spot_Dockerfile"  .