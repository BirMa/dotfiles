#! /usr/bin/env bash

MAX_PROC=$(( $(nproc) - 1 ))
MASK="${1:-"0-$MAX_PROC"}"

for tid in $(/usr/bin/ls /proc/*/task); do
  taskset -cp "$MASK" "$tid" || true
done
