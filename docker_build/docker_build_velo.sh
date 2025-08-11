#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

docker build -t velodyne-ros:main -f "$REPO_ROOT/dockerfiles/Velodyne_Dockerfile"  .