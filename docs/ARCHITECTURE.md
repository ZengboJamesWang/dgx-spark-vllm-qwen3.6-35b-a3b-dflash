# Architecture

## Hardware

- **NVIDIA DGX Spark** with GB10 Blackwell GPU
- **128GB unified memory** (shared CPU/GPU)
- **SM 12.1** Streaming Multiprocessors
- **Blackwell Tensor Cores** with FP8 support

## Software Stack

- **vLLM 0.19+** with V1 engine
- **CUDA 13.0**
- **Flash Attention 2** backend
- **FP8 MoE** quantization (Cutlass kernels)
- **CUDA Graphs** for reduced launch overhead
- **Chunked Prefill** for improved throughput

## Model

**Qwen3.6-35B-A3B** is a Mixture-of-Experts (MoE) model with:
- 35.6B total parameters
- 3.9B active parameters per token
- FP8 quantized weights
- Heterogeneous head dimensions (256 local, 512 global)

## DFlash Speculative Decoding

DFlash uses a lightweight block diffusion draft model:
- **Draft model**: z-lab/Qwen3.6-35B-A3B-DFlash (0.5B params)
- Drafts multiple tokens in parallel
- Accept length: ~5-7 tokens on average
- Requires vLLM with DFlash support enabled

## Memory Layout

At 38% GPU memory utilization:
- Model weights: ~34 GiB
- KV cache: ~52 GiB available
- CUDA graphs: ~0.3 GiB
- Total GPU usage: ~43 GiB

## Performance Optimizations

1. **CUDA Graphs**: Reduces CPU launch overhead by ~20-40%
2. **Chunked Prefill**: Processes prefill in chunks for better interleaving
3. **FP8 KV Cache**: Reduces memory footprint by 50%
4. **Prefix Caching**: Reuses cached attention for repeated prefixes
5. **Async Scheduling**: Overlaps computation and communication

## Inference Flow

1. Request arrives via OpenAI-compatible API
2. Tokenizer encodes prompt
3. vLLM scheduler batches requests
4. Engine core executes on GPU with CUDA graphs
5. Speculative decoding (when enabled) drafts tokens
6. Response streamed back token by token
