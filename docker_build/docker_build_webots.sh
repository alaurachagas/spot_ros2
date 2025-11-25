#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

docker build $1 --no-cache -t spot_webots_test:main -f "$REPO_ROOT/Dockerfiles/Webots_Dockerfile" .
