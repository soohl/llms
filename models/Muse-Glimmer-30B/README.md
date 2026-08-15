# Muse Glimmer 30B

Dense reasoning and agentic model tuned for an NVIDIA RTX 4090 with the
official 17 GB K-quant and DFlash drafter. The vision projector is optional.

## Sources

- [Official model](https://huggingface.co/meta-models/Muse-Glimmer-30B)
- [Official GGUF files](https://huggingface.co/meta-models/Muse-Glimmer-30B-GGUF)
- [llama.cpp](https://github.com/ggml-org/llama.cpp)

Artifacts are Apache 2.0 and ungated, with Meta's usage policy included in the
model repository; llama.cpp is MIT.

## Files

| File | Size | SHA-256 |
| --- | ---: | --- |
| `Muse-Glimmer-30B-KQuant-17GB-Q4_K_M.gguf` | 16,756,683,904 | `4cc57c0f51040a226e5a72cc47b7613f7772950e460a665f7083de89f183f60e` |
| `dflash-Muse-Glimmer-30B-Q4_K_M.gguf` | 1,631,208,128 | `b2e808bf656086fe86bd0d0bd990f01d33e377537a07c02d45371517c8b264ef` |
| `mmproj-Muse-Glimmer-30B-Q4_K_M.gguf` | 1,400,328,928 | `f48b452316f9b213758e8659444029b961a24a07f99a1abb2a9f88b06f7c00c6` |

## Run

```sh
./llm setup muse-glimmer-30b
./llm download muse-glimmer-30b kquant-17gb
./llm download muse-glimmer-30b kquant-17gb --speculative
./llm download muse-glimmer-30b kquant-17gb --vision
./llm serve muse-glimmer-30b
./llm serve muse-glimmer-30b --vision
./llm benchmark speed muse-glimmer-30b
./llm benchmark agentic muse-glimmer-30b
```

Setup uses llama.cpp b10356, CUDA 12.8, and an NVIDIA RTX 4090. The server
provides an OpenAI-compatible API at `http://127.0.0.1:8080/v1` with model
name `muse-glimmer-30b`.
The `llamacpp-muse` compatibility profile enables the embedded Jinja template
and sets Muse's server-side reasoning strength.

Tuned defaults: 32,768 context, 2,048 batch/micro-batch, F16 KV, Flash
Attention, DFlash max 4, and high reasoning. Speculative decoding and vision
are opt-in. The vision smoke test identified a red image and used 18,644 MiB;
vision plus DFlash used 22,152 MiB.

Common overrides: `LLM_CTX`, `LLM_BATCH`, `LLM_UBATCH`, `LLM_CACHE_TYPE`,
`LLM_HOST`, `LLM_PORT`, `LLM_REASONING_STRENGTH`, and `LLM_SPECULATIVE`.

```sh
./llm benchmark speed muse-glimmer-30b kquant-17gb --compare
```

The comparison uses a fixed three-prompt generation suite with 512 output
tokens per prompt. The common context benchmark remains target-only.

Do not expose the unauthenticated server to an untrusted network. See
[BENCHMARK.md](BENCHMARK.md) for results.
