# Gemma 4 31B

Google's dense 30.7B instruction-tuned reasoning model, configured for a
single NVIDIA GPU with 24 GB VRAM. The text model uses the llama.cpp Q4_0
GGUF (18.0 GB), a 16,384-token context, and a Q8_0 KV cache. This profile is
text-only; the separate vision projector is not downloaded.

## Sources

- [Official model and model card](https://huggingface.co/google/gemma-4-31B-it)
- [llama.cpp GGUF](https://huggingface.co/ggml-org/gemma-4-31B-it-GGUF)
- [llama.cpp](https://github.com/ggml-org/llama.cpp)

The model and GGUF are Apache 2.0; llama.cpp is MIT.

## File

| Variant | Size | SHA-256 |
| --- | ---: | --- |
| `q4-0` | 17,992,313,088 | `031dc1c5fa9c5a0abbf3c39c5173fb2af65f5ac2dc2a090268561d3c72dcd834` |

## Run

```sh
./llm setup gemma-4-31b
./llm download gemma-4-31b q4-0
./llm serve gemma-4-31b q4-0
./llm benchmark speed gemma-4-31b q4-0
./llm benchmark agentic gemma-4-31b q4-0
```

The server exposes an OpenAI-compatible API at
`http://127.0.0.1:8080/v1` with model name `gemma-4-31b`.
The `llamacpp-gemma` compatibility profile enables the embedded Jinja template
and Gemma's per-request thinking mode.

Defaults: 16,384 context, full CUDA offload, Flash Attention, Q8_0 KV,
1,024/512 batch/micro-batch, and Google's recommended sampling values. These
defaults support the standard 65,536-token agentic profile on an RTX 4090:
the server used 21,610 MiB and generated successfully with all layers on the
GPU. The recorded speed results used F16 KV; see
[BENCHMARK.md](BENCHMARK.md) for that profile. Common overrides include
`LLM_CTX`, `LLM_BATCH`, `LLM_UBATCH`, and `LLM_CACHE_TYPE`.

Gemma 4 supports up to 256K context, but that is not the 24 GB profile. The
vision projector would consume additional memory and is deliberately omitted.
Do not expose the unauthenticated server to an untrusted network. See
[BENCHMARK.md](BENCHMARK.md) for the verification status.
