# Model Comparison

## Qwen3.6-35B-A3B vs Gemma-4-26B on DGX Spark

| Metric | Qwen3.6-35B-A3B | Gemma-4-26B Uncensored |
|--------|----------------|----------------------|
| **Speed** | ~50 tok/s | ~45 tok/s |
| **Total Params** | 35.6B | 31B (Gemma-4-31B-it base) |
| **Active Params** | 3.9B per token | 26B per token |
| **Memory** | ~53 GiB (262K context) | ~47 GiB (262K context) |
| **Context** | 262K | 262K |
| **Quantization** | FP8 MoE | NVFP4 MoE |
| **Architecture** | MoE | MoE |
| **Best For** | Reasoning, coding | Long context, creative, tool calling |

## Key Differences

1. **Active Parameters:** Qwen3.6 uses 3.9B active params vs Gemma4's 26B active params
   - Qwen3.6: More efficient per-token computation
   - Gemma4: More capacity per token but higher compute cost

2. **Speed:** Qwen3.6 achieves ~50 tok/s vs Gemma4's ~45 tok/s
   - Qwen3.6's smaller active parameter count allows faster generation
   - Both use optimized kernels for their respective quantization schemes

3. **Quantization:**
   - Qwen3.6: FP8 MoE (Cutlass kernels)
   - Gemma4: NVFP4 MoE (FlashInfer Cutlass kernels)
   - Both are optimized for Blackwell architecture

## Why Qwen3.6 is Faster

1. **Smaller active params**: 3.9B vs 26B per token means less computation
2. **Better memory layout**: FP8 MoE kernels optimized for Blackwell
3. **Flash Attention 2**: More efficient attention computation
4. **Async scheduling**: V1 engine overlapping

## When to Use Each

**Use Qwen3.6-35B-A3B when:**
- You need maximum speed (~50 tok/s)
- Working with coding or reasoning tasks
- Want efficient MoE with small active parameter count
- Need DFlash speculative decoding (when available)

**Use Gemma-4-26B when:**
- You need uncensored outputs
- Working with creative writing
- Need tool calling support
- Want more capacity per token (26B active)

## Benchmark Methodology

Both models tested with:
- Same 5 prompts
- 512 max_tokens
- Temperature 0.7
- Single concurrent request
- Warmup run discarded

See [benchmarks/](../benchmarks/) for raw results.
