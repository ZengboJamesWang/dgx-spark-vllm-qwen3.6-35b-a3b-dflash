#!/bin/bash
set -e

MODEL_ID="Qwen/Qwen3.6-35B-A3B"
LOCAL_DIR="${HOME}/models/Qwen3.6-35B-A3B-FP8"

echo "=================================="
echo "Model Pre-downloader"
echo "Model: $MODEL_ID"
echo "=================================="

AVAILABLE_GB=$(df -BG "$HOME" | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "$AVAILABLE_GB" -lt 40 ]; then
    echo "⚠️  Warning: Only ${AVAILABLE_GB}GB disk space available."
    echo "   Model needs ~35GB. Free up space first."
    exit 1
fi

if [ -d "$LOCAL_DIR" ] && [ "$(ls -A $LOCAL_DIR)" ]; then
    echo ""
    echo "✅ Model already exists at: $LOCAL_DIR"
    echo "   Skipping download. Delete the folder to re-download."
    exit 0
fi

if ! command -v huggingface-cli &> /dev/null; then
    echo "Installing huggingface-hub..."
    pip install -U huggingface-hub
fi

if [ -z "$HF_TOKEN" ]; then
    echo ""
    echo "ℹ️  Tip: Set HF_TOKEN environment variable if you encounter rate limits"
    echo "   or need to download gated models:"
    echo "   export HF_TOKEN='your_token_here'"
fi

echo ""
echo "Downloading model (~35GB) to $LOCAL_DIR..."
mkdir -p "$LOCAL_DIR"
huggingface-cli download "$MODEL_ID" \
  --local-dir "$LOCAL_DIR" \
  --local-dir-use-symlinks False

echo ""
echo "✅ Model downloaded to: $LOCAL_DIR"
