# DGX Spark vLLM — Qwen3.6-35B-A3B-DFlash

High-performance inference of **Qwen3.6-35B-A3B** with **DFlash speculative decoding** support on NVIDIA DGX Spark using vLLM with Docker.

## Performance

- **~50 tok/s** sustained generation speed
- **Qwen3.6-35B-A3B** architecture with FP8 MoE quantization
- **262K context window** (same as Gemma-4-26B-A4B)
- **~43 GiB GPU memory** at 38% utilization
- **CUDA 13.0 + Blackwell optimized**
- **DFlash speculative decoding** ready (requires vLLM with DFlash support)

## Benchmark Results

| Test | Prompt | Tokens | Time | Speed |
|------|--------|--------|------|-------|
| 1 | What is machine learning? | 512 | 10.21s | **50.15 tok/s** |
| 2 | Python factorial function | 512 | 10.18s | **50.29 tok/s** |
| 3 | Quantum computing | 512 | 10.35s | **49.47 tok/s** |
| 4 | Photosynthesis | 512 | 10.12s | **50.59 tok/s** |
| 5 | HTTP vs HTTPS | 512 | 10.28s | **49.81 tok/s** |
| **Average** | | **512** | **10.23s** | **50.06 tok/s** |

## Hardware Requirements

- **NVIDIA DGX Spark** (GB10 Blackwell GPU)
- **~45 GiB free GPU memory**
- **~35 GiB disk space** for model weights

## Quick Start

```bash
# Clone repository
cd ~/dgx-spark-vllm-qwen3.6-35b-a3b-dflash

# Start the server
bash scripts/start.sh

# Test
bash scripts/speed-test.sh
```

## Installation

### 1. Download Model

```bash
bash scripts/download-model.sh
```

### 2. Install Systemd Service (Auto-start)

```bash
bash scripts/install-service.sh
systemctl --user start vllm-qwen3.6-35b-a3b-dflash
```

## API Usage

```bash
# List models
curl http://localhost:8000/v1/models

# Chat completion
curl http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen3.6-35b-a3b",
    "messages": [{"role": "user", "content": "Hello!"}],
    "max_tokens": 512
  }'
```

## Configuration

| Parameter | Value | Description |
|-----------|-------|-------------|
| `--gpu-memory-utilization` | 0.38 | GPU memory allocation |
| `--max-model-len` | 262144 | Maximum sequence length |
| `--tensor-parallel-size` | 1 | Single GPU |
| `--kv-cache-dtype` | auto | Automatic KV cache dtype |
| `--quantization` | fp8 | FP8 MoE quantization |

## About DFlash

DFlash is a speculative decoding method using a lightweight block diffusion model to draft multiple tokens in parallel. When enabled with vLLM DFlash support, it pairs:
- **Base model**: `Qwen/Qwen3.6-35B-A3B` (35B MoE, 3B active)
- **Draft model**: `z-lab/Qwen3.6-35B-A3B-DFlash` (0.5B params)

*Note: DFlash speculative decoding is configured but currently requires a vLLM build with DFlash support. Uncomment the speculative-config lines in startup.sh when available.*

## Troubleshooting

See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

## License

MIT
