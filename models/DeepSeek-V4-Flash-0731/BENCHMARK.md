# DeepSeek V4 Flash 0731 Benchmarks

- Backend: DS4 `84cc882352757baf628a1776badf7cc54d584e28`
- Hardware: Apple M3 Ultra, 256 GiB unified memory
- Workload: native incremental-prefix 128–8,192 sweep, 128 generated tokens
- Tuning: fully resident Metal, 8,192 prefill chunk, DSpark/MTP off
- Run dates: Q4 2026-08-12; MXFP4 2026-08-14

| Context frontier | Q4 incremental prefill | MXFP4 incremental prefill | Q4 decode | MXFP4 decode |
| ---: | ---: | ---: | ---: | ---: |
| 128 | 130.01 t/s | 143.06 t/s | 39.89 t/s | 41.32 t/s |
| 256 | 158.30 t/s | 167.36 t/s | 40.29 t/s | 41.38 t/s |
| 512 | 231.47 t/s | 242.06 t/s | 40.15 t/s | 41.19 t/s |
| 1,024 | 307.65 t/s | 319.12 t/s | 39.98 t/s | 40.97 t/s |
| 2,048 | 382.15 t/s | 392.54 t/s | 39.68 t/s | 40.71 t/s |
| 4,096 | 403.08 t/s | 438.04 t/s | 36.32 t/s | 37.09 t/s |
| 8,192 | 424.14 t/s | 447.57 t/s | 35.58 t/s | 36.20 t/s |

The current backend automatically selects its supported Metal kernels. MXFP4
remains the default: it is 5.3% smaller, averaged 2.6% faster steady decode,
and was faster at every prefill frontier in this run.

## Agentic ability

Offline sandbox profile: 65,536 context, native-strong reasoning, no internet
or web-search tool. Run date: 2026-08-14.

| Task | Difficulty | Result | Score | Time | Generated | Reasoning est. |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| Python repair | easy | PASS | 6/6 | 198.4s | 6,566 | ≈2,531 |
| Data reconciliation | medium | FAIL | 0/12 | 125.1s | 4,229 | ≈3,524 |
| Dependency planner | hard | FAIL | 0/20 | 137.3s | 4,537 | ≈3,824 |
| **Total** | — | **1/3** | **6/38** | **460.8s** | **15,332** | **≈9,879** |

The medium run produced none of its required output artifacts. The hard run
inspected the workspace but did not complete the implementation. Full metrics
are in [`benchmarks/agentic/REPORT.md`](../../benchmarks/agentic/REPORT.md).

## Web research

Sandboxed search profile: 65,536 context, native-strong reasoning, and
`pi-web-search@1.3.1` using `openai-codex/gpt-5.6-luna`. Run date: 2026-08-14.

| Task | Difficulty | Result | Score | Time | Searches | Generated | Reasoning est. |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Python standards | easy | PASS | 8/8 | 66.8s | 3 | 1,228 | ≈262 |
| HTTP retry policy | medium | PASS | 14/14 | 103.5s | 6 | 2,100 | ≈480 |
| XZ incident | hard | FAIL | 15/20 | 113.5s | 6 | 1,622 | ≈322 |
| **Total** | — | **2/3** | **37/42** | **283.9s** | **15** | **4,950** | **≈1,064** |

The hard run passed incident identity, construction, targeting, and dependency
path checks, but missed the exact Red Hat impact/mitigation and required source
set. Full metrics are in
[`benchmarks/research/REPORT.md`](../../benchmarks/research/REPORT.md).

## DSpark compare

MXFP4, greedy no-thinking generation, a 512-token limit, and the configured
0.6 confidence threshold:

| Prompt | Token limit | Target decode | DSpark decode | Speedup | Acceptance |
| --- | ---: | ---: | ---: | ---: | ---: |
| Technical | 512 | 40.96 t/s | 35.08 t/s | 0.86x | 69.7% |
| Coding | 512 | 41.35 t/s | 39.43 t/s | 0.95x | 83.5% |
| Analysis | 512 | 41.34 t/s | 35.32 t/s | 0.85x | 73.0% |
| **Macro average** | — | **41.22 t/s** | **36.61 t/s** | **0.89x** | **76.3%** |

DSpark was slower for all three prompts on this machine despite high draft
acceptance, so it remains disabled by default. The native CLI comparison times
decode only; model loading and prompt prefill are excluded.

```sh
./llm benchmark speed deepseek-v4-flash-0731 q4
./llm benchmark speed deepseek-v4-flash-0731 mxfp4
./llm benchmark speed deepseek-v4-flash-0731 mxfp4 --speculative compare
```
