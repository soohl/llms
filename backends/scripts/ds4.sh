#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=common.sh
. "$(dirname -- "$0")/common.sh"

require_ds4() {
    require_os "${DS4_OS:-}"
    [ -x "$BACKEND_ROOT/ds4-server" ] &&
        [ -x "$BACKEND_ROOT/ds4-bench" ] || missing_backend
}

case "${1:-}" in
    setup)
        require_os "${DS4_OS:-}"
        require_command make
        require_command cc
        checkout_backend "$DS4_REPO" "$DS4_REVISION"
        exec make -C "$BACKEND_ROOT"
        ;;
    serve)
        variant=$2
        speculative=${3:-${LLM_SPECULATIVE:-${DS4_SPECULATIVE_DEFAULT:-off}}}
        require_ds4
        model=$(model_path "$variant")
        ctx=${LLM_CTX:-${DS4_CONTEXT:-65536}}
        prefill=${LLM_PREFILL_CHUNK:-${DS4_PREFILL_CHUNK:-8192}}
        host=${LLM_HOST:-127.0.0.1}
        port=${LLM_PORT:-8000}
        kv_mb=${LLM_KV_DISK_SPACE_MB:-${DS4_KV_DISK_SPACE_MB:-32768}}
        cache="$RUNTIME_ROOT/$BACKEND/$variant-kv-cache"
        mkdir -p "$cache"

        unset DS4_METAL_Q8_MV_NSG DS4_METAL_Q8_MV_ROWS
        export DS4_METAL_MODEL_UNTRACKED=${DS4_METAL_MODEL_UNTRACKED:-1}
        args=(
            --model "$model" --metal \
            --host "$host" --port "$port" \
            --ctx "$ctx" --prefill-chunk "$prefill" \
            --kv-disk-dir "$cache" --kv-disk-space-mb "$kv_mb"
        )
        if [ "$speculative" = on ]; then
            [ "${DS4_SPECULATIVE_TYPE:-}" = dspark ] || {
                printf 'Unsupported DS4 speculative type: %s\n' \
                    "${DS4_SPECULATIVE_TYPE:-none}" >&2
                exit 2
            }
            support="$GGUF_ROOT/${DS4_SPECULATIVE_FILE:-}"
            [ -f "$support" ] || {
                printf 'Speculative model is missing. Run: ./llm download %s %s --speculative\n' \
                    "$MODEL_ID" "$variant" >&2
                exit 1
            }
            args+=(--mtp "$support" --dspark)
            [ -z "${DS4_SPECULATIVE_CONFIDENCE:-}" ] ||
                args+=(--dspark-confidence "$DS4_SPECULATIVE_CONFIDENCE")
        fi
        cd "$BACKEND_ROOT"
        exec ./ds4-server "${args[@]}"
        ;;
    benchmark)
        variant=$2
        speculative=${3:-${LLM_SPECULATIVE:-off}}
        [ "$speculative" = off ] || {
            printf 'DS4 speculative benchmark is not supported by the pinned ds4-bench.\n' >&2
            exit 2
        }
        require_ds4
        model=$(model_path "$variant")
        ctx_start=${LLM_BENCH_CTX_START:-128}
        ctx_max=${LLM_BENCH_CTX_MAX:-8192}
        generated=${LLM_BENCH_GEN_TOKENS:-128}
        ctx_alloc=${LLM_BENCH_CTX_ALLOC:-$((ctx_max + generated + 1))}
        step=${LLM_BENCH_STEP_MUL:-2}
        prefill=${LLM_PREFILL_CHUNK:-${DS4_PREFILL_CHUNK:-8192}}

        unset DS4_METAL_Q8_MV_NSG DS4_METAL_Q8_MV_ROWS
        export DS4_METAL_MODEL_UNTRACKED=${DS4_METAL_MODEL_UNTRACKED:-1}
        cd "$BACKEND_ROOT"
        exec ./ds4-bench \
            --model "$model" --metal \
            --prompt-file "$ROOT/benchmark/prompts/promessi-sposi.txt" \
            --ctx-start "$ctx_start" --ctx-max "$ctx_max" \
            --ctx-alloc "$ctx_alloc" --step-mul "$step" \
            --prefill-chunk "$prefill" --gen-tokens "$generated"
        ;;
    *)
        printf 'Unsupported DS4 action: %s\n' "${1:-}" >&2
        exit 2
        ;;
esac
