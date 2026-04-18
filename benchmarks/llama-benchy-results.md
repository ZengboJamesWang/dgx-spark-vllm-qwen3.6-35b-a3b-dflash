# llama-benchy Benchmark Results

**Date:** 2026-04-18
**Model:** qwen3.6-35b-a3b-dflash
**Hardware:** NVIDIA DGX Spark (GB10 Blackwell)
**Context:** 262K max
**GPU Memory:** 52.8 GiB

## Results

| model | test | t/s | peak t/s | ttfr (ms) | est_ppt (ms) | e2e_ttft (ms) |
|:-----------------------|--------------:|-----------------:|-------------:|--------------:|---------------:|----------------:|
| qwen3.6-35b-a3b-dflash | pp256 | 3070.13 ± 188.97 | | 150.47 ± 5.33 | 83.87 ± 5.33 | 150.57 ± 5.36 |
| qwen3.6-35b-a3b-dflash | tg128 | 50.48 ± 0.01 | 51.00 ± 0.00 | | | |
| qwen3.6-35b-a3b-dflash | pp256 @ d512 | 4932.48 ± 196.55 | | 222.86 ± 6.53 | 156.27 ± 6.53 | 222.93 ± 6.53 |
| qwen3.6-35b-a3b-dflash | tg128 @ d512 | 50.28 ± 0.07 | 51.00 ± 0.00 | | | |
| qwen3.6-35b-a3b-dflash | pp256 @ d1024 | 3947.86 ± 51.98 | | 391.13 ± 4.27 | 324.54 ± 4.27 | 391.20 ± 4.28 |
| qwen3.6-35b-a3b-dflash | tg128 @ d1024 | 50.16 ± 0.03 | 51.00 ± 0.00 | | | |

## Command Used

```bash
uvx llama-benchy \
  --base-url http://localhost:8000/v1 \
  --model qwen3.6-35b-a3b-dflash \
  --tokenizer /home/jameszbw/models/Qwen3.6-35B-A3B-FP8 \
  --depth 0 512 1024 \
  --pp 256 \
  --tg 128 \
  --runs 2 \
  --latency-mode generation \
  --format md
```

## Summary

- **Generation Speed:** Consistent ~50 tok/s across all context depths
- **Prompt Processing:** 3K-5K tokens/second
- **Latency (TTFT):** 150ms (0 depth) → 391ms (1024 depth)
- **Peak Throughput:** 51 tok/s
- **Coherence:** PASSED

## Comparison with Gemma-4-26B-A4B

| Metric | Qwen3.6-35B-A3B-DFlash | Gemma-4-26B-A4B Uncensored |
|--------|------------------------|----------------------|
| **Speed** | ~50 tok/s | ~45 tok/s |
| **Context** | 262K | 262K |
| **Memory** | 52.8 GiB | ~47 GiB |
| **Architecture** | MoE (35B/3.9B active) | MoE (26B/4B active) |
| **Prompt Processing** | 3K-5K t/s | Similar |

Qwen3.6 achieves similar or better performance with larger model capacity thanks to MoE efficiency.
