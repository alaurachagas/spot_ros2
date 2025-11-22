#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

docker build $1 -t spot_webots:main -f "$REPO_ROOT/Dockerfiles/Webots_Dockerfile" .
