# DeepSeek V4 Flash 0731 Benchmarks

- Backend: DS4 `84cc882352757baf628a1776badf7cc54d584e28`
- Hardware: Apple M3 Ultra, 256 GiB unified memory
- Workload: shared 128–8,192 context sweep, 128 generated tokens
- Tuning: fully resident Metal, 8,192 prefill chunk, DSpark/MTP off
- Run date: 2026-08-12

| Context | Q4 prefill | MXFP4 prefill | Q4 decode | MXFP4 decode |
| ---: | ---: | ---: | ---: | ---: |
| 128 | 130.01 t/s | 126.17 t/s | 39.89 t/s | 41.06 t/s |
| 256 | 158.30 t/s | 157.38 t/s | 40.29 t/s | 41.50 t/s |
| 512 | 231.47 t/s | 231.65 t/s | 40.15 t/s | 41.39 t/s |
| 1,024 | 307.65 t/s | 306.83 t/s | 39.98 t/s | 40.75 t/s |
| 2,048 | 382.15 t/s | 381.06 t/s | 39.68 t/s | 40.34 t/s |
| 4,096 | 403.08 t/s | 421.37 t/s | 36.32 t/s | 37.09 t/s |
| 8,192 | 424.14 t/s | 433.49 t/s | 35.58 t/s | 36.63 t/s |

The current backend automatically selects its supported Metal kernels. MXFP4
remains the default: it is 5.3% smaller, averaged 2.5% faster steady decode,
and was faster on the longer prefill intervals. Short-prefill differences were
small and favored Q4 in this run.

## DSpark compare

MXFP4, greedy no-thinking generation, a 512-token limit, and the configured
0.6 confidence threshold:

| Prompt | Token limit | Target decode | DSpark decode | Speedup | Acceptance |
| --- | ---: | ---: | ---: | ---: | ---: |
| Technical | 512 | 40.96 t/s | 35.08 t/s | 0.86x | 69.7% |
| Coding | 512 | 41.35 t/s | 39.43 t/s | 0.95x | 83.5% |
| Analysis | 512 | 41.34 t/s | 35.32 t/s | 0.85x | 73.0% |
| **Average** | — | **41.22 t/s** | **36.61 t/s** | **0.89x** | **76.3%** |

DSpark was slower for all three prompts on this machine despite high draft
acceptance, so it remains disabled by default. The native CLI comparison times
decode only; model loading and prompt prefill are excluded.

```sh
./llm benchmark deepseek-v4-flash-0731 ds4 q4
./llm benchmark deepseek-v4-flash-0731 ds4 mxfp4
./llm benchmark deepseek-v4-flash-0731 ds4 mxfp4 --speculative compare
```
