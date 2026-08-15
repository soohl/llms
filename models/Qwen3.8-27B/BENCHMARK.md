# Qwen3.8 27B Benchmarks

- Backend: llama.cpp b10356, `0666ad2b2b2452668733729e8b54234f5964643a`
- Hardware: NVIDIA RTX 4090, 24 GB VRAM
- Variant: Q4_K_M
- Runtime: full CUDA offload, Flash Attention, F16 KV
- Batch/micro-batch: 2,048/2,048
- Run date: 2026-08-14

## Common benchmark

This run used the text-only profile without loading a vision projector.

| Context | Prefill | Generated | Decode |
| ---: | ---: | ---: | ---: |
| 128 | 1,238.69 t/s | 128 | 42.93 t/s |
| 256 | 1,847.42 t/s | 128 | 42.77 t/s |
| 512 | 2,012.82 t/s | 128 | 42.91 t/s |
| 1,024 | 2,155.90 t/s | 128 | 42.66 t/s |
| 2,048 | 2,314.02 t/s | 128 | 42.35 t/s |
| 4,096 | 2,351.94 t/s | 128 | 42.28 t/s |
| 8,192 | 2,359.81 t/s | 128 | 41.68 t/s |
| 16,384 | 2,308.60 t/s | 128 | 40.77 t/s |

A separate server startup at the configured 8,192-token context used 19,034
MiB according to `nvidia-smi`.

```sh
./llm benchmark speed qwen3.8-27b q4-k-m
```

## MTP speculative decoding

The official Q4_0 MTP draft was fully GPU-offloaded with four draft tokens, a
0.75 minimum draft probability, and 2,048/512 batch/micro-batch. The
target-only comparison used 2,048/2,048.

| Prompt | Prompt tokens | Generated | Target decode | MTP decode | Speedup | Acceptance |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Technical | 19 | 512 | 43.80 t/s | 81.04 t/s | 1.85x | 81.1% |
| Coding | 26 | 512 | 43.81 t/s | 92.54 t/s | 2.11x | 85.4% |
| Analysis | 28 | 512 | 43.80 t/s | 79.42 t/s | 1.81x | 80.4% |
| **Macro average** | — | — | **43.80 t/s** | **84.33 t/s** | **1.93x** | **82.4%** |

The MTP smoke server used 20,178 MiB, 1,144 MiB more than target-only.

| Maximum draft | MTP decode | Speedup | Acceptance |
| ---: | ---: | ---: | ---: |
| 1 | 62.71 t/s | 1.43x | 94.6% |
| 2 | 72.15 t/s | 1.65x | 88.2% |
| 3 | 78.27 t/s | 1.79x | 85.3% |
| **4** | **84.33 t/s** | **1.93x** | **82.4%** |
| 5 | 79.45 t/s | 1.81x | 77.7% |
| 6 | 79.39 t/s | 1.81x | 72.3% |
| 8 | 81.99 t/s | 1.87x | 72.7% |

Four draft tokens had the highest macro-average throughput and consistent gains
across all three prompts. Speculative decoding remains opt-in.

```sh
./llm benchmark speed qwen3.8-27b q4-k-m --compare
```

Cross-model agentic and research results are consolidated in the
[combined benchmark report](../../BENCHMARK.md).
