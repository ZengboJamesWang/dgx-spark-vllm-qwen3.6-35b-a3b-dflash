#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

CONTAINER_NAME="vllm-qwen3.6-35b-a3b-dflash"
IMAGE="vllm/vllm-openai@sha256:a6cb8f72c66a419f2a7bf62e975ca0ba33dd4097b6b26858d166647c4cf4ba1f"
MODEL_PATH="/models/qwen3.6-35b-a3b"
STARTUP_SCRIPT="$SCRIPT_DIR/startup.sh"

echo "=================================="
echo "DGX Spark vLLM Starter"
echo "Qwen3.6-35B-A3B-DFlash"
echo "=================================="

if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker first."
    exit 1
fi

if ! docker info 2>/dev/null | grep -q "nvidia"; then
    echo "⚠️  Warning: NVIDIA Container Runtime may not be configured."
    echo "   Make sure 'docker run --gpus all' works on your system."
fi

if [ ! -f "$STARTUP_SCRIPT" ]; then
    echo "❌ Startup script not found: $STARTUP_SCRIPT"
    exit 1
fi

if lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "⚠️  Port 8000 is already in use."
    echo "   Stop the existing service first or change the port."
    exit 1
fi

AVAILABLE_GB=$(df -BG "$HOME" | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "$AVAILABLE_GB" -lt 40 ]; then
    echo "⚠️  Warning: Only ${AVAILABLE_GB}GB disk space available."
    echo "   Model + Docker image need ~40GB. Free up space first."
    exit 1
fi

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Stopping existing container: $CONTAINER_NAME"
    docker stop "$CONTAINER_NAME" > /dev/null 2>&1 || true
    docker rm "$CONTAINER_NAME" > /dev/null 2>&1 || true
fi

mkdir -p ~/.cache/huggingface

echo ""
echo "Starting vLLM container..."
echo "Model: $MODEL_PATH"
echo "This may take 5-10 minutes on first run for CUDA graph compilation."
echo ""

docker run -d --name "$CONTAINER_NAME" \
  --restart unless-stopped \
  --gpus all \
  --ipc=host \
  -p 8000:8000 \
  -v /home/jameszbw/models/Qwen3.6-35B-A3B-FP8:/models/qwen3.6-35b-a3b:ro \
  -v ~/.cache/huggingface:/root/.cache/huggingface \
  -v "$STARTUP_SCRIPT:/startup.sh" \
  "$IMAGE" \
  bash /startup.sh

echo ""
echo "Container started: $CONTAINER_NAME"
echo ""
echo "⏳ Waiting for server to be ready (this can take 5-10 min on first run)..."

for i in {1..60}; do
    if curl -s http://localhost:8000/v1/models > /dev/null 2>&1; then
        echo ""
        echo "✅ Server is ready!"
        echo ""
        echo "Test it:"
        echo "  curl http://localhost:8000/v1/chat/completions \\"
        echo "    -H 'Content-Type: application/json' \\"
        echo "    -d '{\"model\":\"qwen3.6-35b-a3b-dflash\",\"messages\":[{\"role\":\"user\",\"content\":\"Hello\"}],\"max_tokens\":100}'"
        echo ""
        echo "View logs: docker logs -f $CONTAINER_NAME"
        echo "Stop: docker stop $CONTAINER_NAME"
        exit 0
    fi
    echo -n "."
    if [ $((i % 10)) -eq 0 ]; then
        echo " ($((i*10))s)"
    fi
    sleep 10
done

echo ""
echo "⚠️  Server did not become ready within 10 minutes."
echo "Check logs: docker logs $CONTAINER_NAME"
exit 1
