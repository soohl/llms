# Qwen3.6 27B Benchmarks

- Backend: llama.cpp b10356, `0666ad2b2b2452668733729e8b54234f5964643a`
- Hardware: NVIDIA RTX 4090, 24 GB VRAM
- Runtime: CUDA 12.8, target full offload, Flash Attention, F16 KV
- Variant: Q4_K_M
- Target batch/micro-batch: 2,048/2,048
- Target benchmark run date: 2026-08-12

## Common benchmark

| Context | Prefill | Generated | Decode |
| ---: | ---: | ---: | ---: |
| 128 | 1,252.67 t/s | 128 | 42.69 t/s |
| 256 | 1,732.25 t/s | 128 | 42.49 t/s |
| 512 | 2,180.79 t/s | 128 | 42.45 t/s |
| 1,024 | 2,193.88 t/s | 128 | 42.37 t/s |
| 2,048 | 2,392.88 t/s | 128 | 42.21 t/s |
| 4,096 | 2,401.69 t/s | 128 | 41.82 t/s |
| 8,192 | 2,385.78 t/s | 128 | 41.37 t/s |
| 16,384 | 2,320.10 t/s | 128 | 40.52 t/s |

The 8,192-token server profile used 19,150 MiB VRAM, leaving about 4.8 GiB
free on the 24 GB card.

## Speculative compare

Q8_0 DFlash drafter with four draft tokens, 1,024/256 batch/micro-batch, and
512 generated tokens per prompt:

| Prompt | Prompt tokens | Generated | Target decode | DFlash decode | Speedup | Acceptance |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Technical | 19 | 512 | 42.18 t/s | 60.51 t/s | 1.43x | 52.5% |
| Coding | 26 | 512 | 42.23 t/s | 75.80 t/s | 1.80x | 71.9% |
| Analysis | 28 | 512 | 42.22 t/s | 66.54 t/s | 1.58x | 60.4% |
| **Macro average** | — | — | **42.21 t/s** | **67.62 t/s** | **1.60x** | **60.9%** |

DFlash used 20,702 MiB VRAM. Four draft tokens were selected as the balanced
setting: 8 and 16 reached slightly higher average throughput in this small
suite, but had substantially lower acceptance and less consistent gains.

## Tuning decisions

| Setting | Result |
| --- | --- |
| Target batch/micro-batch 2,048/2,048 | Fastest tested target prefill |
| F16 KV | Faster decode than tested Q8_0 and Q4_0 |
| DFlash batch/micro-batch 1,024/256 | Largest tested profile that fit |
| DFlash GPU layers 4 | Maximum that fit with the target |
| DFlash max 4 | Kept for 60.9% acceptance and consistent speedup |

```sh
./llm benchmark speed qwen3.6-27b q4-k-m --speculative off
./llm benchmark speed qwen3.6-27b q4-k-m --speculative compare
```
