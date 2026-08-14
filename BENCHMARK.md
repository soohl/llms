# Combined task benchmark report

Latest local agentic and web-research results for the five benchmarked
text-only models, as of 2026-08-14. The suites measure different capabilities,
so their scores are shown together for convenience but are not added into a
single score.

## Summary

| Model | Agentic tasks | Agentic score | Research tasks | Research score |
| --- | ---: | ---: | ---: | ---: |
| DeepSeek V4 Flash 0731 | 1/3 | **34/38** | 2/3 | **37/42** |
| Gemma 4 31B | 1/3 | 16/38 | 2/3 | **37/42** |
| Muse Glimmer 30B | **2/3** | **34/38** | 2/3 | **37/42** |
| Qwen3.6 27B | 0/3 | 14/38 | 2/3 | 31/42 |
| Qwen3.8 27B | **2/3** | 18/38 | 2/3 | 31/42 |

Muse and Qwen3.8 completed the most agentic tasks, while Muse and DeepSeek tied
on agentic points. DeepSeek, Gemma, and Muse tied on research points. All five
models passed the easy and medium research tasks, but none passed the hard XZ
incident task.

## Run profiles

| Model | Backend | Variant | Hardware | KV cache |
| --- | --- | --- | --- | --- |
| DeepSeek V4 Flash 0731 | DS4 | `mxfp4` | Apple M3 Ultra, 256 GiB | DS4 native |
| Gemma 4 31B | llama.cpp | `q4-0` | NVIDIA RTX 4090, 24 GB | Q8_0 |
| Muse Glimmer 30B | llama.cpp | `kquant-17gb` | NVIDIA RTX 4090, 24 GB | F16 |
| Qwen3.6 27B | llama.cpp | `q4-k-m` | NVIDIA RTX 4090, 24 GB | F16 |
| Qwen3.8 27B | llama.cpp | `q4-k-m` | NVIDIA RTX 4090, 24 GB | F16 |

Both suites used a 65,536-token context, native-strong reasoning, temperature
zero, sequential execution, full local candidate inference, fresh Docker
Sandboxes, and speculative decoding disabled. The offline agentic suite
allowed up to 16,384 output tokens per turn. The research suite allowed 4,096
and provided `pi-web-search` 1.3.1 through
`openai-codex/gpt-5.6-luna`.

## Agentic ability

The agentic suite grades three offline software and data tasks.

| Task | Difficulty | DeepSeek V4 Flash | Gemma 4 | Muse Glimmer | Qwen3.6 | Qwen3.8 |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| Python repair | Easy | FAIL 4/6 | **PASS 6/6** | **PASS 6/6** | FAIL 4/6 | **PASS 6/6** |
| Data reconciliation | Medium | FAIL 10/12 | FAIL 10/12 | FAIL 8/12 | FAIL 10/12 | **PASS 12/12** |
| Dependency planner | Hard | **PASS 20/20** | FAIL 0/20 | **PASS 20/20** | FAIL 0/20 | FAIL 0/20 |

### Agentic totals and activity

| Model | Passed | Score | Time | Generated | Reasoning est. | Turns | Tools/errors |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| DeepSeek V4 Flash 0731 | 1/3 | 34/38 | 811.3s | 27,362 | ≈11,394 | 28 | 37/0 |
| Gemma 4 31B | 1/3 | 16/38 | 793.6s | 28,590 | ≈9,237 | 45 | 42/2 |
| Muse Glimmer 30B | 2/3 | 34/38 | 1,424.3s | 64,120 | ≈57,064 | 80 | 90/1 |
| Qwen3.6 27B | 0/3 | 14/38 | 564.2s | 22,370 | ≈3,039 | 37 | 44/4 |
| Qwen3.8 27B | 2/3 | 18/38 | 1,334.4s | 53,241 | ≈38,150 | 17 | 27/0 |

Gemma and Qwen3.6's dependency-planner submissions did not expose the required
`parse_tasks` API, causing the hidden grader import to fail. Qwen3.8 spent its
complete output allowance reasoning in one turn and made no tool call. Muse
used substantially more turns and generated tokens than the other models and
was the only RTX 4090 model to pass the hard task.

## Web research

The research suite grades sourced artifacts and requires multiple searches and
multiple distinct tools.

| Task | Difficulty | DeepSeek V4 Flash | Gemma 4 | Muse Glimmer | Qwen3.6 | Qwen3.8 |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| Python standards | Easy | **PASS 8/8** | **PASS 8/8** | **PASS 8/8** | **PASS 8/8** | **PASS 8/8** |
| HTTP retry policy | Medium | **PASS 14/14** | **PASS 14/14** | **PASS 14/14** | **PASS 14/14** | **PASS 14/14** |
| XZ incident | Hard | FAIL 15/20 | FAIL 15/20 | FAIL 15/20 | FAIL 9/20 | FAIL 9/20 |

### Research totals and activity

| Model | Passed | Score | Time | Generated | Reasoning est. | Turns | Tools/errors |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| DeepSeek V4 Flash 0731 | 2/3 | 37/42 | 283.9s | 4,950 | ≈1,064 | 21 | 30/0 |
| Gemma 4 31B | 2/3 | 37/42 | 254.8s | 7,412 | ≈3,944 | 13 | 15/0 |
| Muse Glimmer 30B | 2/3 | 37/42 | 474.2s | 10,159 | ≈6,011 | 32 | 45/0 |
| Qwen3.6 27B | 2/3 | 31/42 | 245.8s | 5,936 | ≈1,735 | 18 | 28/0 |
| Qwen3.8 27B | 2/3 | 31/42 | 457.2s | 14,753 | ≈7,336 | 37 | 45/0 |

Gemma and Muse lost the same five points on the hard task: Red Hat impact and
mitigation, plus the required mix of primary, maintainer, and vendor citations.
Both Qwen versions additionally missed build targeting and the impact
dependency path.

## Interpretation limits

- Agentic and research scores must not be summed; they represent separate
  tasks, tools, and output limits.
- Each result is one trial on a small three-task suite.
- Research results depend on changing web-search responses.
- Reasoning tokens are estimates based on reasoning text length.
- Elapsed times are not directly comparable across the DS4/M3 Ultra and
  llama.cpp/RTX 4090 platforms.
- Gemma used a Q8_0 KV cache to fit the common 64K context; Muse and Qwen used
  F16.

Detailed records:

- [Agentic report](benchmarks/agentic/REPORT.md)
- [Research report](benchmarks/research/REPORT.md)
- [Benchmark methodology](benchmarks/README.md)
