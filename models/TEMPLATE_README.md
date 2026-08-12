# <Model name>

Short description and target hardware.

## Sources

- [Official model](<URL>)
- [GGUF files](<URL>)
- [Backend](<URL>)

State the licenses and access restrictions.

## Files

| Variant/file | Size | SHA-256 | Default |
| --- | ---: | --- | --- |
| `<variant>` | `<bytes>` | `<digest>` | yes |

## Run

```sh
./llm setup <model> <backend>
./llm download <model> <variant>
./llm download <model> <variant> --speculative
./llm serve <model> <backend>
./llm benchmark <model> <backend>
```

Record the endpoint, tuned defaults, important overrides, and limitations.
Link to [BENCHMARK.md](BENCHMARK.md).

Also copy `TEMPLATE_MODEL.conf` to `model.conf`; `llm` discovers the model
from that file.
