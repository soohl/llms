#!/usr/bin/env bash

require_command() {
    command -v "$1" >/dev/null 2>&1 || {
        printf 'Required command not found: %s\n' "$1" >&2
        exit 1
    }
}

require_os() {
    wanted=$1
    [ -z "$wanted" ] || [ "$(uname -s)" = "$wanted" ] || {
        printf 'The %s profile requires %s.\n' "$BACKEND" "$wanted" >&2
        exit 1
    }
}

checkout_backend() {
    repo=$1
    revision=$2
    require_command git
    mkdir -p "$ROOT/backends"
    if [ -e "$BACKEND_ROOT" ] && [ ! -d "$BACKEND_ROOT/.git" ]; then
        printf 'Refusing to replace non-Git backend path: %s\n' \
            "$BACKEND_ROOT" >&2
        exit 1
    fi
    if [ ! -d "$BACKEND_ROOT/.git" ]; then
        git init -q "$BACKEND_ROOT"
        git -C "$BACKEND_ROOT" remote add origin "$repo"
        git -C "$BACKEND_ROOT" fetch --depth 1 origin "$revision"
        git -C "$BACKEND_ROOT" checkout --detach FETCH_HEAD
    fi

    current=$(git -C "$BACKEND_ROOT" rev-parse HEAD)
    [ "$current" = "$revision" ] && return
    if ! git -C "$BACKEND_ROOT" diff --quiet ||
       ! git -C "$BACKEND_ROOT" diff --cached --quiet; then
        printf 'Refusing to change modified checkout: %s\n' \
            "$BACKEND_ROOT" >&2
        exit 1
    fi
    git -C "$BACKEND_ROOT" fetch origin "$revision"
    git -C "$BACKEND_ROOT" checkout --detach "$revision"
}

primary_model_file() {
    wanted=$1
    while IFS='|' read -r variant kind file _; do
        if [ "$variant" = "$wanted" ] && [ "$kind" = target ]; then
            printf '%s\n' "$file"
            return
        fi
    done <<<"$DOWNLOADS"
    printf 'No model file configured for variant: %s\n' "$wanted" >&2
    exit 1
}

model_path() {
    variant=$1
    path="$GGUF_ROOT/$(primary_model_file "$variant")"
    [ -f "$path" ] || {
        printf 'Model is missing. Run: ./llm download %s %s\n' \
            "$MODEL_ID" "$variant" >&2
        exit 1
    }
    printf '%s\n' "$path"
}

missing_backend() {
    printf '%s is not built. Run: ./llm setup %s %s\n' \
        "$BACKEND" "$MODEL_ID" "$BACKEND" >&2
    exit 1
}
