#!/bin/bash
set -e

echo "Starting vLLM server with Qwen3.6-35B-A3B-DFlash..."

# Base model + DFlash speculative decoding (when supported by vLLM)
# Draft model: z-lab/Qwen3.6-35B-A3B-DFlash (0.5B params)
# To enable DFlash, add to command:
#   --speculative-config '{"method": "dflash", "model": "z-lab/Qwen3.6-35B-A3B-DFlash", "num_speculative_tokens": 15}' \
#   --attention-backend flash_attn \

exec vllm serve /models/qwen3.6-35b-a3b \
  --served-model-name qwen3.6-35b-a3b-dflash \
  --tensor-parallel-size 1 \
  --max-model-len 32768 \
  --gpu-memory-utilization 0.38 \
  --kv-cache-dtype auto \
  --enable-chunked-prefill \
  --enable-prefix-caching \
  --trust-remote-code \
  --host 0.0.0.0 --port 8000 \
  --dtype bfloat16
