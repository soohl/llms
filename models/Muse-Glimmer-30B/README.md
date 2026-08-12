# Muse Glimmer 30B

Dense reasoning and agentic model tuned for an NVIDIA RTX 4090 with the
official 17 GB K-quant and DFlash drafter. This directory supports text only;
the perception encoder is not included.

## Sources

- [Official model](https://huggingface.co/meta-models/Muse-Glimmer-30B)
- [Official GGUF files](https://huggingface.co/meta-models/Muse-Glimmer-30B-GGUF)
- [llama.cpp](https://github.com/ggml-org/llama.cpp)

Artifacts are Apache 2.0; llama.cpp is MIT.

## Files

| File | Size | SHA-256 |
| --- | ---: | --- |
| `muse-glimmer-30B-kquant-17gb.gguf` | 16,756,681,056 | `7e9b74b7c8875e9e265695df9613bf6290f2392e479ce740495a129019c488d8` |
| `dflash-kquant.gguf` | 1,631,205,312 | `27d9a805fa29b943cfb6ad4843367cd4eaaaf06bd452d8cc3e00a2cd18a677bc` |

## Run

```sh
./llm setup muse-glimmer-30b llamacpp
./llm download muse-glimmer-30b kquant-17gb
./llm download muse-glimmer-30b kquant-17gb --speculative
./llm serve muse-glimmer-30b llamacpp
./llm benchmark muse-glimmer-30b llamacpp
```

Setup uses llama.cpp b10356, CUDA 12.8, and an NVIDIA RTX 4090. The server
provides an OpenAI-compatible API at `http://127.0.0.1:8080/v1` with model
name `muse-glimmer-30b`.

Tuned defaults: 32,768 context, 2,048 batch/micro-batch, F16 KV, Flash
Attention, DFlash max 4, and high reasoning. Use `--speculative off` for
target-only serving.

Common overrides: `LLM_CTX`, `LLM_BATCH`, `LLM_UBATCH`, `LLM_CACHE_TYPE`,
`LLM_HOST`, `LLM_PORT`, `LLM_REASONING_STRENGTH`, and `LLM_SPECULATIVE`.

```sh
./llm benchmark muse-glimmer-30b llamacpp kquant-17gb --speculative compare
```

The comparison uses a fixed three-prompt generation suite with 512 output
tokens per prompt. The common context benchmark remains target-only.

Do not expose the unauthenticated server to an untrusted network. See
[BENCHMARK.md](BENCHMARK.md) for results.
