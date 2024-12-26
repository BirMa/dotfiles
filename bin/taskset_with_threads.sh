#! /usr/bin/env sh
# example: $0 firefox 1

set -o errexit
set -o nounset
unalias -a

PROCNAME="$1"
MAX_PROC=$(( $(nproc) - 1 ))
MASK="${2:-"0-$MAX_PROC"}"

PIDS="$(pidof "$PROCNAME")"

for pid in "$PIDS"; do
  taskset -cp "$MASK" "$pid" || true
  for tid in $(/usr/bin/ls "/proc/$pid/task"); do
    taskset -cp "$MASK" "$tid" || true
  done
done
