#! /usr/bin/env sh
# example: $0 firefox 0,1,2-7

set -o errexit
set -o nounset
unalias -a

PROCNAME="$1"
MAX_PROC=$(( $(nproc) - 1 ))
CPU_LIST="${2:-"0-$MAX_PROC"}"

PIDS="$(pidof "$PROCNAME")"
#PIDS="369828"

for pid in $PIDS; do
  taskset -cp "$CPU_LIST" "$pid" || true
  for tid in $(/usr/bin/ls "/proc/$pid/task"); do
    taskset -cp "$CPU_LIST" "$tid" || true
  done
done
