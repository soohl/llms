#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=common.sh
. "$(dirname -- "$0")/common.sh"

build_root="$BACKEND_ROOT/build-cuda"
server="$build_root/bin/llama-server"

require_llamacpp() {
    require_os "${LLAMACPP_OS:-}"
    [ -x "$server" ] || missing_backend
}

case "${1:-}" in
    setup)
        require_os "${LLAMACPP_OS:-}"
        require_command cmake
        require_command gcc
        require_command g++
        require_command nproc
        cuda_root=${CUDA_ROOT:-${LLAMACPP_CUDA_ROOT:-/usr/local/cuda}}
        cuda_arch=${CUDA_ARCHITECTURE:-${LLAMACPP_CUDA_ARCHITECTURE:-native}}
        nvcc="$cuda_root/bin/nvcc"
        [ -x "$nvcc" ] || {
            printf 'CUDA compiler not found: %s\n' "$nvcc" >&2
            exit 1
        }
        checkout_backend "$LLAMACPP_REPO" "$LLAMACPP_REVISION"
        cmake -S "$BACKEND_ROOT" -B "$build_root" \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_CUDA_COMPILER="$nvcc" \
            -DCUDAToolkit_ROOT="$cuda_root" \
            -DCMAKE_CUDA_ARCHITECTURES="$cuda_arch" \
            -DLLAMA_BUILD_NUMBER="${LLAMACPP_BUILD_NUMBER:-0}" \
            -DBUILD_SHARED_LIBS=OFF \
            -DLLAMA_BUILD_SERVER=ON \
            -DLLAMA_BUILD_APP=OFF \
            -DLLAMA_BUILD_UI=OFF \
            -DLLAMA_USE_PREBUILT_UI=OFF \
            -DGGML_CUDA=ON \
            -DGGML_NATIVE=ON \
            -DLLAMA_BUILD_EXAMPLES=OFF \
            -DLLAMA_BUILD_TESTS=OFF
        exec cmake --build "$build_root" --config Release -j"$(nproc)" \
            --target llama-server
        ;;
    serve)
        variant=$2
        speculative=${3:-${LLM_SPECULATIVE:-${LLAMACPP_SPECULATIVE_DEFAULT:-off}}}
        require_llamacpp
        model=$(model_path "$variant")
        ctx=${LLM_CTX:-${LLAMACPP_CONTEXT:-32768}}
        batch=${LLM_BATCH:-${LLAMACPP_BATCH:-2048}}
        ubatch=${LLM_UBATCH:-${LLAMACPP_UBATCH:-512}}
        if [ "$speculative" = on ]; then
            batch=${LLM_BATCH:-${LLAMACPP_SPECULATIVE_BATCH:-$batch}}
            ubatch=${LLM_UBATCH:-${LLAMACPP_SPECULATIVE_UBATCH:-$ubatch}}
        fi
        threads=${LLM_THREADS:-${LLAMACPP_THREADS:-8}}
        cache=${LLM_CACHE_TYPE:-${LLAMACPP_CACHE_TYPE:-f16}}
        device=${LLM_DEVICE:-${LLAMACPP_DEVICE:-CUDA0}}
        gpu_layers=${LLM_GPU_LAYERS:-${LLAMACPP_GPU_LAYERS:-99}}
        host=${LLM_HOST:-127.0.0.1}
        port=${LLM_PORT:-8080}
        reasoning=${LLM_REASONING_STRENGTH:-${LLAMACPP_REASONING_STRENGTH:-}}

        args=(
            --model "$model" --device "$device" --n-gpu-layers "$gpu_layers"
            --ctx-size "$ctx" --batch-size "$batch" --ubatch-size "$ubatch"
            --threads "$threads" --threads-batch "$threads"
            --cache-type-k "$cache" --cache-type-v "$cache"
            --flash-attn on --parallel 1 --host "$host" --port "$port"
            --alias "$MODEL_ID"
        )
        [ "${LLAMACPP_JINJA:-0}" != 1 ] || args+=(--jinja)
        [ -z "${LLAMACPP_TEMPERATURE:-}" ] ||
            args+=(--temp "$LLAMACPP_TEMPERATURE")
        [ -z "${LLAMACPP_TOP_P:-}" ] || args+=(--top-p "$LLAMACPP_TOP_P")
        [ -z "${LLAMACPP_TOP_K:-}" ] || args+=(--top-k "$LLAMACPP_TOP_K")
        [ -z "$reasoning" ] ||
            args+=(--chat-template-kwargs \
                "{\"reasoning_strength\":\"$reasoning\"}")

        if [ "$speculative" = on ]; then
            [ "${LLAMACPP_SPECULATIVE_TYPE:-}" = dflash ] || {
                printf 'Unsupported llama.cpp speculative type: %s\n' \
                    "${LLAMACPP_SPECULATIVE_TYPE:-none}" >&2
                exit 2
            }
            draft="$GGUF_ROOT/${LLAMACPP_SPECULATIVE_FILE:-}"
            [ -n "${LLAMACPP_SPECULATIVE_FILE:-}" ] && [ -f "$draft" ] || {
                printf 'Speculative model is missing. Run: ./llm download %s %s --speculative\n' \
                    "$MODEL_ID" "$variant" >&2
                exit 1
            }
            args+=(
                --spec-type draft-dflash --spec-draft-model "$draft"
                --spec-draft-device "$device"
                --spec-draft-ngl \
                    "${LLM_SPECULATIVE_GPU_LAYERS:-${LLAMACPP_SPECULATIVE_GPU_LAYERS:-$gpu_layers}}"
                --spec-draft-n-max \
                    "${LLM_SPECULATIVE_MAX_TOKENS:-${LLAMACPP_SPECULATIVE_MAX_TOKENS:-4}}"
            )
        fi
        exec "$server" "${args[@]}"
        ;;
    benchmark)
        variant=$2
        speculative=${3:-${LLM_SPECULATIVE:-off}}
        require_llamacpp
        require_command python3
        model=$(model_path "$variant")
        generated=${LLM_BENCH_GEN_TOKENS:-128}
        if [ "$speculative" = compare ] &&
           [ -z "${LLM_BENCH_GEN_TOKENS:-}" ]; then
            generated=512
        fi
        batch=${LLM_BATCH:-${LLAMACPP_BATCH:-2048}}
        ubatch=${LLM_UBATCH:-${LLAMACPP_UBATCH:-512}}
        if [ "$speculative" = compare ]; then
            speculative_batch=${LLM_BATCH:-${LLAMACPP_SPECULATIVE_BATCH:-$batch}}
            speculative_ubatch=${LLM_UBATCH:-${LLAMACPP_SPECULATIVE_UBATCH:-$ubatch}}
        else
            speculative_batch=$batch
            speculative_ubatch=$ubatch
        fi
        args=(
            "$ROOT/benchmark/scripts/llamacpp.py"
            --server "$server" \
            --model "$model" \
            --prompt "$ROOT/benchmark/prompts/promessi-sposi.txt" \
            --ctx-start "${LLM_BENCH_CTX_START:-128}" \
            --ctx-max "${LLM_BENCH_CTX_MAX:-8192}" \
            --step "${LLM_BENCH_STEP_MUL:-2}" \
            --generated "$generated" \
            --batch "$batch" \
            --ubatch "$ubatch" \
            --speculative-batch "$speculative_batch" \
            --speculative-ubatch "$speculative_ubatch" \
            --threads "${LLM_THREADS:-${LLAMACPP_THREADS:-8}}" \
            --cache-type "${LLM_CACHE_TYPE:-${LLAMACPP_CACHE_TYPE:-f16}}" \
            --device "${LLM_DEVICE:-${LLAMACPP_DEVICE:-CUDA0}}" \
            --gpu-layers "${LLM_GPU_LAYERS:-${LLAMACPP_GPU_LAYERS:-99}}" \
            --speculative "$speculative" \
            --speculative-kind "${LLAMACPP_SPECULATIVE_TYPE:-}" \
            --speculative-file "$GGUF_ROOT/${LLAMACPP_SPECULATIVE_FILE:-}" \
            --speculative-gpu-layers \
            "${LLM_SPECULATIVE_GPU_LAYERS:-${LLAMACPP_SPECULATIVE_GPU_LAYERS:-${LLM_GPU_LAYERS:-${LLAMACPP_GPU_LAYERS:-99}}}}" \
            --speculative-max-tokens \
            "${LLM_SPECULATIVE_MAX_TOKENS:-${LLAMACPP_SPECULATIVE_MAX_TOKENS:-4}}"
        )
        if [ "$speculative" = compare ]; then
            args+=(--speculative-context \
                "${LLAMACPP_CONTEXT:-32768}")
            args+=(--speculative-prompts \
                "$ROOT/benchmark/prompts/speculative.json")
        fi
        exec python3 "${args[@]}"
        ;;
    *)
        printf 'Unsupported llama.cpp action: %s\n' "${1:-}" >&2
        exit 2
        ;;
esac
