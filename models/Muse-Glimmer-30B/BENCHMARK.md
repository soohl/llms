# Muse Glimmer 30B Benchmarks

- Backend: llama.cpp b10356, `0666ad2b2b2452668733729e8b54234f5964643a`
- Hardware: NVIDIA RTX 4090, 24 GB VRAM
- Runtime: CUDA 12.8, full offload, Flash Attention, F16 KV
- Batch/micro-batch: 2,048/2,048
- Target benchmark run date: 2026-08-12
- Tested target SHA-256: `7e9b74b7c8875e9e265695df9613bf6290f2392e479ce740495a129019c488d8`
- Tested drafter SHA-256: `27d9a805fa29b943cfb6ad4843367cd4eaaaf06bd452d8cc3e00a2cd18a677bc`

These results used the original aliases. The configured canonical files contain
the upstream chat-template fix; rerun agentic results rather than treating the
legacy template as equivalent.

## Common benchmark

| Context | Prefill | Generated | Decode |
| ---: | ---: | ---: | ---: |
| 128 | 1,626.82 t/s | 128 | 49.37 t/s |
| 256 | 2,084.45 t/s | 128 | 48.95 t/s |
| 512 | 2,418.88 t/s | 128 | 48.80 t/s |
| 1,024 | 2,499.50 t/s | 128 | 48.49 t/s |
| 2,048 | 2,724.03 t/s | 128 | 48.34 t/s |
| 4,096 | 2,748.47 t/s | 128 | 47.59 t/s |
| 8,192 | 2,757.15 t/s | 128 | 47.75 t/s |
| 16,384 | 2,704.06 t/s | 128 | 47.08 t/s |

## Speculative compare

Fixed technical, coding, and analysis prompts from
`benchmarks/speed/speculative.json`, with 512 generated tokens per prompt:

| Prompt | Prompt tokens | Generated | Target decode | DFlash decode | Speedup | Acceptance |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Technical | 20 | 512 | 48.85 t/s | 61.79 t/s | 1.26x | 34.5% |
| Coding | 27 | 512 | 48.84 t/s | 109.68 t/s | 2.25x | 80.9% |
| Analysis | 29 | 512 | 48.77 t/s | 56.68 t/s | 1.16x | 29.9% |
| **Macro average** | — | — | **48.82 t/s** | **76.05 t/s** | **1.56x** | **42.5%** |

DFlash benefits longer, structured generation when its draft acceptance is
high. It does not improve prefill and may regress on low-acceptance text.

## Vision

The Q4_K_M projector identified a generated solid-red PNG as `red`. The server
used 18,644 MiB after the image request and decoded at 48.86 t/s with an
8,192-token prompt. Vision plus DFlash also loaded successfully and used
22,152 MiB.

```sh
./llm benchmark speed muse-glimmer-30b kquant-17gb --vision
```

## Tuning decisions

| Setting | Result |
| --- | --- |
| Flash Attention | Kept; about 20% faster 4K prefill |
| Micro-batch 2,048 | Fastest tested; 4,096 was slower |
| F16 KV | Faster than Q8_0 and Q4_0 |
| DFlash max 4 | Faster than tested 8, 12, and 15 |

```sh
./llm benchmark speed muse-glimmer-30b kquant-17gb
./llm benchmark speed muse-glimmer-30b kquant-17gb --compare
```
