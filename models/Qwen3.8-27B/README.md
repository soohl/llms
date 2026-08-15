# Qwen3.8 27B

Qwen's dense 27B vision-language coding, reasoning, and agent model for an
NVIDIA RTX 4090. The default text profile uses llama.cpp's Q4_K_M GGUF
(19.0 GB) and an 8,192-token F16 KV cache. Vision is opt-in.

## Sources

- [Official model and model card](https://huggingface.co/Qwen/Qwen3.8-27B)
- [llama.cpp GGUF and MTP draft](https://huggingface.co/ggml-org/Qwen3.8-27B-GGUF)
- [llama.cpp](https://github.com/ggml-org/llama.cpp)

The model and GGUF are Apache 2.0 and ungated; llama.cpp is MIT.

## Files

| Variant | Size | SHA-256 |
| --- | ---: | --- |
| `q4-k-m` | 18,973,870,432 | `31629f53165ab6a7dad8c9847dcfd1fdf55829dac1e6e748f4a68581b0033d34` |
| MTP Q4_0 draft | 1,680,271,648 | `051a1764cff8c4f3ee6ae8b00593a0364c7539c67fa50ffc58f3f96509fca38e` |
| Q8_0 vision projector | 629,247,008 | `2e968a6af97ce35d8971890b257b9b7edabf20ad91450501fa53162a19ee33eb` |

## Run

```sh
./llm setup qwen3.8-27b
./llm download qwen3.8-27b q4-k-m
./llm download qwen3.8-27b q4-k-m --speculative
./llm download qwen3.8-27b q4-k-m --vision
./llm serve qwen3.8-27b q4-k-m
./llm serve qwen3.8-27b q4-k-m --speculative
./llm serve qwen3.8-27b q4-k-m --vision
./llm benchmark speed qwen3.8-27b q4-k-m
./llm benchmark speed qwen3.8-27b q4-k-m --compare
./llm benchmark agentic qwen3.8-27b q4-k-m
```

The server exposes an OpenAI-compatible API at
`http://127.0.0.1:8080/v1` with model name `qwen3.8-27b`. Defaults are 8,192
context, full CUDA offload, Flash Attention, F16 KV, 2,048/2,048
batch/micro-batch, and Qwen's recommended thinking-mode sampling values.

The configured 8,192-token target-only server used 19,034 MiB VRAM. The speed
sweep reached 41.68 t/s decode at 8,192 prompt tokens and 40.77 t/s at 16,384.
The opt-in Q4_0 MTP profile used 20,178 MiB and improved the fixed speculative
suite from 43.80 to 84.33 t/s, a 1.93x macro-average speedup with 82.4%
acceptance. Four draft tokens and a 0.75 minimum draft probability are used.

Speculative decoding and vision remain off unless their flags are passed. A
vision-enabled server accepts both text and image requests; combining vision
and MTP used 21,180 MiB in the smoke test.

Common overrides include `LLM_CTX`, `LLM_BATCH`, `LLM_UBATCH`, and
`LLM_CACHE_TYPE`. The `llamacpp-qwen` compatibility profile enables the
embedded Jinja template and Qwen's per-request thinking controls. Do not expose
the unauthenticated server to an untrusted network.
