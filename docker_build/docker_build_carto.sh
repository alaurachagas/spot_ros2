#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

docker build -t cartographer-ros:main -f "$REPO_ROOT/dockerfiles/Cartographer_Dockerfile"  .