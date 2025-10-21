#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

docker build $1 -t ai-agent_spot_test:main -f "$REPO_ROOT/Dockerfiles/Agent_Ollama_Dockerfile" .
