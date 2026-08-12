# DeepSeek V4 Flash 0731

284B-total/13B-active MoE model tuned for an Apple M3 Ultra with 256 GiB
unified memory.

## Sources

- [Official model](https://huggingface.co/deepseek-ai/DeepSeek-V4-Flash)
- [GGUF files](https://huggingface.co/antirez/deepseek-v4-gguf)
- [DS4 backend](https://github.com/antirez/ds4)

## Files

| Artifact | Size | SHA-256 | Role |
| --- | ---: | --- | --- |
| `q4` | 164,633,502,592 | `6bb77b5ddcbc2d974c687cfb63d644ecfb295581b4a53fa4c1d810aea538254a` | no |
| `mxfp4` | 155,976,458,848 | `0e3a161b670f686128ec5f92a601dfde616a37bf5e7e48999fa2d32471b57ec6` | yes |
| DSpark support | 5,989,114,272 | `7e319924541db3f7a163ed7e11d7532a70d48228ab59d36cb81e1d4511885360` | support |

## Run

```sh
./llm setup deepseek-v4-flash-0731 ds4
./llm download deepseek-v4-flash-0731 mxfp4
./llm download deepseek-v4-flash-0731 mxfp4 --speculative
./llm serve deepseek-v4-flash-0731 ds4
./llm benchmark deepseek-v4-flash-0731 ds4 mxfp4
```

Server: `127.0.0.1:8000`. Tuned defaults are 65,536 context, 8,192 prefill
chunk, fully resident Metal, and a 32 GiB KV prefix-cache budget.

Overrides: `LLM_CTX`, `LLM_PREFILL_CHUNK`, `LLM_HOST`, `LLM_PORT`, and
`LLM_KV_DISK_SPACE_MB`.

Only DS4/Metal is supported. DSpark defaults off; serving accepts
`--speculative on`. The MXFP4 comparison found DSpark slower on the current
three-prompt suite, so opt in only when it benefits your workload.
`ds4-bench` provides target-only context sweeps; `--speculative compare` uses
the native CLI and reports DSpark throughput and acceptance. Benchmark
overrides are
`LLM_BENCH_CTX_START`, `LLM_BENCH_CTX_MAX`, `LLM_BENCH_CTX_ALLOC`,
`LLM_BENCH_STEP_MUL`, `LLM_BENCH_STEP_INCR`, `LLM_BENCH_GEN_TOKENS`, and
`LLM_BENCH_CSV`; the speculative comparison also accepts
`LLM_BENCH_SPECULATIVE_CTX` and `LLM_SPECULATIVE_CONFIDENCE`. SSD expert
streaming is disabled. See
[BENCHMARK.md](BENCHMARK.md) for results.
