# Model Comparison

## Qwen3.6-35B-A3B vs Gemma-4-26B on DGX Spark

| Metric | Qwen3.6-35B-A3B | Gemma-4-26B Uncensored |
|--------|----------------|----------------------|
| **Speed** | ~50 tok/s | ~45 tok/s |
| **Model Size** | 35.6B total (3.9B active) | 26B active |
| **Memory** | ~43 GiB | ~47 GiB |
| **Context** | 32K | 262K |
| **Quantization** | FP8 MoE | NVFP4 |
| **Architecture** | MoE | Dense |
| **Best For** | Reasoning, coding | Long context, creative |

## Why Qwen3.6 is Faster

1. **MoE efficiency**: Only activates 3.9B params per token vs 26B dense
2. **Better memory layout**: FP8 MoE kernels optimized for Blackwell
3. **Flash Attention 2**: More efficient attention computation
4. **Async scheduling**: V1 engine overlapping

## When to Use Each

**Use Qwen3.6-35B-A3B when:**
- You need fast inference (~50 tok/s)
- Working with coding or reasoning tasks
- Want efficient MoE architecture
- Need DFlash speculative decoding (when available)

**Use Gemma-4-26B when:**
- You need very long context (262K)
- Want uncensored outputs
- Working with creative writing
- Need tool calling support

## Benchmark Methodology

Both models tested with:
- Same 5 prompts
- 512 max_tokens
- Temperature 0.7
- Single concurrent request
- Warmup run discarded

See [benchmarks/](../benchmarks/) for raw results.
