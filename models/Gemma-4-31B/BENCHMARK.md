# Gemma 4 31B Benchmarks

- Backend: llama.cpp b10356, `0666ad2b2b2452668733729e8b54234f5964643a`
- Target hardware: NVIDIA RTX 4090, 24 GB VRAM
- Variant: Q4_0
- Profile: 16,384 context, full CUDA offload, Flash Attention, F16 KV
- Tuned batch/micro-batch: 1,024/512
- Run date: 2026-08-12

## Common benchmark

| Context | Prefill | Generated | Decode |
| ---: | ---: | ---: | ---: |
| 128 | 1,525.59 t/s | 128 | 44.40 t/s |
| 256 | 1,793.71 t/s | 128 | 43.89 t/s |
| 512 | 2,006.67 t/s | 128 | 43.21 t/s |
| 1,024 | 1,939.53 t/s | 128 | 42.22 t/s |
| 2,048 | 2,062.85 t/s | 128 | 41.61 t/s |
| 4,096 | 2,126.50 t/s | 128 | 41.55 t/s |
| 8,192 | 2,131.06 t/s | 128 | 40.58 t/s |
| 16,384 | 2,068.41 t/s | 128 | 39.65 t/s |

The benchmark completed through 16,384 prompt tokens. A separate server test
processed 16,000 prompt tokens and generated 128 tokens at 39.67 t/s while
sampling the server process with `nvidia-smi`; peak usage was 20,282 MiB.
That leaves 4,282 MiB relative to the RTX 4090's 24,564 MiB capacity, so the
profile fits with useful headroom.

## Tuning decisions

| Setting | Result |
| --- | --- |
| F16 KV | 39.44 t/s decode at 16K; Q8_0 reached 36.26 t/s |
| Batch/micro-batch 1,024/512 | Best balance of long-context prefill and decode |
| 2,048/1,024 | Slightly higher peak prefill, but lower 16K decode |
| 2,048/2,048 and 4,096 batches | Regressed long-context throughput |

```sh
./llm benchmark gemma-4-31b llamacpp q4-0
```
