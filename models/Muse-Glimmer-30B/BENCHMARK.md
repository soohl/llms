# Muse Glimmer 30B Benchmarks

- Backend: llama.cpp b10356, `0666ad2b2b2452668733729e8b54234f5964643a`
- Hardware: NVIDIA RTX 4090, 24 GB VRAM
- Runtime: CUDA 12.8, full offload, Flash Attention, F16 KV
- Batch/micro-batch: 2,048/2,048

## Common benchmark

| Context | Prefill | Generated | Decode |
| ---: | ---: | ---: | ---: |
| 128 | 1,686.10 t/s | 128 | 49.34 t/s |
| 256 | 2,426.10 t/s | 128 | 49.35 t/s |
| 512 | 2,399.51 t/s | 128 | 48.86 t/s |
| 1,024 | 2,481.54 t/s | 128 | 48.77 t/s |
| 2,048 | 2,658.72 t/s | 128 | 48.05 t/s |
| 4,096 | 2,731.04 t/s | 128 | 47.28 t/s |
| 8,192 | 2,733.81 t/s | 128 | 47.56 t/s |

## Speculative compare

Fixed technical, coding, and analysis prompts from
`benchmark/prompts/speculative.json`, with 512 generated tokens per prompt:

| Prompt | Prompt tokens | Generated | Target decode | DFlash decode | Speedup | Acceptance |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Technical | 20 | 512 | 48.85 t/s | 61.79 t/s | 1.26x | 34.5% |
| Coding | 27 | 512 | 48.84 t/s | 109.68 t/s | 2.25x | 80.9% |
| Analysis | 29 | 512 | 48.77 t/s | 56.68 t/s | 1.16x | 29.9% |
| **Average** | — | — | **48.82 t/s** | **76.05 t/s** | **1.56x** | **42.5%** |

DFlash benefits longer, structured generation when its draft acceptance is
high. It does not improve prefill and may regress on low-acceptance text.

## Tuning decisions

| Setting | Result |
| --- | --- |
| Flash Attention | Kept; about 20% faster 4K prefill |
| Micro-batch 2,048 | Fastest tested; 4,096 was slower |
| F16 KV | Faster than Q8_0 and Q4_0 |
| DFlash max 4 | Faster than tested 8, 12, and 15 |

```sh
./llm benchmark muse-glimmer-30b llamacpp kquant-17gb --speculative compare
```
