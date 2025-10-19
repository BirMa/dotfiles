#!/usr/bin/env bash
set -euo pipefail

prefix="${1:?usage: $0 <pkgname-prefix>}"

shopt -s nullglob
files=( "$prefix"-*.pkg.tar* )
[[ ${#files[@]} -eq 0 ]] && exit 1

latest=""
latest_ver=""

for f in "${files[@]}"; do
    base="$(basename "$f")"
    base="${base%.pkg.tar.*}"
    arch="${base##*-}"
    rest="${base%-*}"
    pkgrel="${rest##*-}"
    rest="${rest%-*}"
    pkgver="${rest##*-}"
    name="${rest%-*}"

    [[ "$name" != "$prefix" ]] && continue

    ver="${pkgver}-${pkgrel}"
    if [[ -z "$latest" ]]; then
        latest="$f"
        latest_ver="$ver"
    else
        cmp=$(vercmp "$ver" "$latest_ver")
        if (( cmp >= 0 )); then
            latest="$f"
            latest_ver="$ver"
        fi
    fi
done

if [[ -n "$latest" ]]; then
    echo "$latest"
else
    exit 1
fi
