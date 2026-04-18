#!/bin/bash
set -e

CONTAINER_NAME="vllm-qwen3.6-35b-a3b"

if docker ps -q -f name="^/${CONTAINER_NAME}$" | grep -q .; then
    echo "Stopping vLLM container: $CONTAINER_NAME..."
    docker stop "$CONTAINER_NAME" > /dev/null
    docker rm "$CONTAINER_NAME" > /dev/null 2>&1 || true
    echo "✅ Stopped."
else
    echo "vLLM container is not running."
fi
