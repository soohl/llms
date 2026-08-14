# Qwen3.8 27B Vision

Vision-language profile for Qwen3.8 27B on an NVIDIA RTX 4090. It loads the
same Q4_K_M language model as the text profile plus llama.cpp's Q8_0 vision
projector. One vision-enabled server accepts both text-only and image requests.

The profile shares `models/Qwen3.8-27B/gguf/` with the text profile, avoiding a
second 19 GB copy of the language model.

## Sources

- [Official model and model card](https://huggingface.co/Qwen/Qwen3.8-27B)
- [llama.cpp GGUF and projectors](https://huggingface.co/ggml-org/Qwen3.8-27B-GGUF)
- [llama.cpp](https://github.com/ggml-org/llama.cpp)

The model, GGUF, and projector are Apache 2.0 and ungated; llama.cpp is MIT.

## Files

| File | Size | SHA-256 |
| --- | ---: | --- |
| Q4_K_M language model | 18,973,870,432 | `31629f53165ab6a7dad8c9847dcfd1fdf55829dac1e6e748f4a68581b0033d34` |
| Q8_0 vision projector | 629,247,008 | `2e968a6af97ce35d8971890b257b9b7edabf20ad91450501fa53162a19ee33eb` |

## Run

```sh
./llm setup qwen3.8-27b-vision
./llm download qwen3.8-27b-vision q4-k-m
./llm download qwen3.8-27b-vision q4-k-m --projector
./llm serve qwen3.8-27b-vision q4-k-m
./llm benchmark speed qwen3.8-27b-vision q4-k-m
```

The server exposes a multimodal OpenAI-compatible API at
`http://127.0.0.1:8080/v1` with model name `qwen3.8-27b-vision`. The projector
is GPU-offloaded by default. Text requests do not need to use the projector;
image requests can use OpenAI-compatible image content.

The configured server used 19,886 MiB after loading and 19,910 MiB after text
and single-image smoke tests. That is 852 MiB more idle VRAM than the text-only
profile. Text decode was effectively unchanged in the single speed runs:
41.76 t/s versus 41.68 t/s at 8,192 prompt tokens.

The profile deliberately excludes video tuning and MTP speculative decoding.
Large or numerous images can increase token and working-memory use. If the
profile exceeds VRAM, reduce `LLM_CTX`; projector CPU offload is also available
through llama.cpp's `--no-mmproj-offload` argument. Do not expose the
unauthenticated server to an untrusted network. See
[BENCHMARK.md](BENCHMARK.md) for complete results.
