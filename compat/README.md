# Local API compatibility profiles

Profiles describe the boundary between Pi, a local serving backend, and a
model's chat template. A model selects one profile with `COMPAT_PROFILE` in
`model.conf`; [`resolve.py`](resolve.py) merges inherited profiles and produces
the Pi metadata and server settings used by `llm`.

Current profiles:

| Profile | Purpose |
| --- | --- |
| `ds4-openai` | DS4's OpenAI-compatible API and reasoning levels |
| `llamacpp-openai` | Common llama.cpp OpenAI compatibility and Jinja |
| `llamacpp-gemma` | llama.cpp plus Gemma per-request thinking controls |
| `llamacpp-qwen` | llama.cpp plus Qwen per-request thinking controls |
| `llamacpp-muse` | llama.cpp plus Muse server-side reasoning strength |

Profiles may contain:

```json
{
  "extends": "optional-parent",
  "backend": "backend-name",
  "pi": {
    "compat": {},
    "thinkingLevelMap": {}
  },
  "benchmark": {
    "reasoning": {
      "mode": "native-strong",
      "piThinking": "high",
      "control": "toggle",
      "nativeValue": "enabled"
    }
  },
  "server": {
    "jinja": true,
    "reasoningStrength": "high"
  }
}
```

Nested objects are merged when `extends` is used. The resolver validates the
selected backend and emits compact, generated Pi JSON; model files do not need
to contain Pi's low-level compatibility fields. Agentic profiles also record
how the shared `native-strong` policy resolves to the model's actual control.
Compatibility is resolved only for chat serving and agentic runs; raw speed
benchmarks do not use it.

To inspect a resolved profile:

```sh
python3 compat/resolve.py llamacpp-qwen --backend llamacpp
```
