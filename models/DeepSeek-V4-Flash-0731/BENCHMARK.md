# DeepSeek V4 Flash 0731 Benchmarks

Representative local throughput results, grouped by backend. Raw output and
historical tuning experiments are intentionally not committed. `./llm
benchmark` prints a fresh result to standard output without creating a file; an
agent should update this document only after checking that the run is
representative.

## Common workload

- Prompt: `benchmark/prompts/promessi-sposi.txt`
- Contexts: 128, 256, 512, 1,024, 2,048, 4,096, and 8,192 tokens
- Generated tokens: 128, greedy single-stream decoding
- Prefill chunk: 8,192 tokens

## DS4

**Environment**

- Backend revision: `84cc882352757baf628a1776badf7cc54d584e28`
- Machine: Apple M3 Ultra, 60 GPU cores, 28 CPU cores
- Memory: 256 GiB unified
- Accelerator: Metal, fully resident model
- Kernel geometry: automatic
- DSpark/MTP: disabled

### Q4 versus MXFP4

| Context | Q4 prefill | MXFP4 prefill | Q4 steady decode | MXFP4 steady decode |
| ---: | ---: | ---: | ---: | ---: |
| 128 | 139.14 t/s | 141.74 t/s | 39.71 t/s | 41.43 t/s |
| 256 | 164.37 t/s | 166.36 t/s | 39.58 t/s | 41.53 t/s |
| 512 | 234.55 t/s | 241.00 t/s | 38.38 t/s | 41.35 t/s |
| 1,024 | 312.71 t/s | 315.58 t/s | 39.49 t/s | 41.20 t/s |
| 2,048 | 388.17 t/s | 389.70 t/s | 39.76 t/s | 40.59 t/s |
| 4,096 | 409.30 t/s | 439.24 t/s | 36.60 t/s | 36.99 t/s |
| 8,192 | 423.37 t/s | 447.08 t/s | 35.37 t/s | 36.60 t/s |

| Aggregate metric | Q4 | MXFP4 | MXFP4 change |
| --- | ---: | ---: | ---: |
| Prefill | 376.75 t/s | 393.67 t/s | +4.49% |
| Steady decode | 38.34 t/s | 39.85 t/s | +3.93% |

MXFP4 is the default because it is smaller and was faster across the tested
contexts. Re-run either profile with:

```sh
./llm benchmark deepseek ds4 q4
./llm benchmark deepseek ds4 mxfp4
```

## llama.cpp

Not yet tested. Add this section only after the backend can serve this GGUF
reliably with a tuned profile and complete the common workload.
