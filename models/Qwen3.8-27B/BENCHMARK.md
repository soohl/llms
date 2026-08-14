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

## Agentic ability

Text-only profile with 65,536 context, 16,384 maximum output per turn,
native-strong reasoning, temperature zero, and speculative decoding disabled:

| Task | Difficulty | Result | Score | Time | Generated |
| --- | --- | ---: | ---: | ---: | ---: |
| Python repair | Easy | PASS | 6/6 | 507.5s | 20,110 |
| Data reconciliation | Medium | PASS | 12/12 | 421.9s | 16,747 |
| Dependency planner | Hard | FAIL | 0/20 | 405.1s | 16,384 |
| **Total** | — | **2/3** | **18/38** | **1,334.4s** | **53,241** |

The model used 17 turns and 27 successful tool calls with no tool errors. It
passed every check in the easy and medium tasks. In the hard task it consumed
the complete output allowance in one reasoning turn, made no tool call, and
therefore produced no gradable implementation.

```sh
./llm benchmark agentic qwen3.8-27b q4-k-m
```

## Web research

Text-only profile with 65,536 context, 4,096 maximum output per turn,
native-strong reasoning, temperature zero, and the controlled web-search tool:

| Task | Difficulty | Result | Score | Time | Generated |
| --- | --- | ---: | ---: | ---: | ---: |
| Python standards | Easy | PASS | 8/8 | 119.4s | 3,948 |
| HTTP retry policy | Medium | PASS | 14/14 | 145.9s | 4,566 |
| XZ incident | Hard | FAIL | 9/20 | 191.9s | 6,239 |
| **Total** | — | **2/3** | **31/42** | **457.2s** | **14,753** |

The model met every search/tool execution requirement and had no tool errors.
The hard-task artifact missed build targeting, the impact dependency path, Red
Hat impact and mitigation, and the required citation-source mix.

```sh
./llm benchmark research qwen3.8-27b q4-k-m
```
