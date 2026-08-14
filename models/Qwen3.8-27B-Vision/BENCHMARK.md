# Qwen3.8 27B Vision Benchmarks

- Backend: llama.cpp b10356, `0666ad2b2b2452668733729e8b54234f5964643a`
- Hardware: NVIDIA RTX 4090, 24 GB VRAM
- Language model: Q4_K_M
- Vision projector: Q8_0
- Provisional profile: 8,192 context, full CUDA offload, Flash Attention, F16 KV
- Smoke-test date: 2026-08-14

## Runtime smoke test

The server loaded successfully with the projector GPU-offloaded. A text-only
request returned the requested `text-ok`, and an image request identified a
generated solid-red PNG as `Red`.

`nvidia-smi` reported 19,886 MiB after loading and 19,910 MiB after the two
requests. These are sampled values rather than a measured peak.

## Common benchmark

The Q8_0 vision projector was loaded and GPU-offloaded during this text
throughput sweep.

| Context | Prefill | Generated | Decode |
| ---: | ---: | ---: | ---: |
| 128 | 1,250.98 t/s | 128 | 43.03 t/s |
| 256 | 1,729.55 t/s | 128 | 43.19 t/s |
| 512 | 2,020.86 t/s | 128 | 43.03 t/s |
| 1,024 | 2,202.06 t/s | 128 | 43.01 t/s |
| 2,048 | 2,364.21 t/s | 128 | 42.70 t/s |
| 4,096 | 2,412.37 t/s | 128 | 42.34 t/s |
| 8,192 | 2,365.56 t/s | 128 | 41.76 t/s |
| 16,384 | 2,286.40 t/s | 128 | 40.81 t/s |

No large-image throughput benchmark has been recorded yet.

## Text-only comparison

Both runs used the same language model and settings. The combined profile also
loaded and GPU-offloaded the Q8_0 projector.

| Context | Text-only decode | Combined decode |
| ---: | ---: | ---: |
| 128 | 42.93 t/s | 43.03 t/s |
| 8,192 | 41.68 t/s | 41.76 t/s |
| 16,384 | 40.77 t/s | 40.81 t/s |

The single runs show no meaningful text decode penalty from loading the
projector. Idle server memory increased from 19,034 MiB to 19,886 MiB, an
observed difference of 852 MiB.

```sh
./llm benchmark speed qwen3.8-27b-vision q4-k-m
```
