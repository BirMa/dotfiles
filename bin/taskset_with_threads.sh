#! /usr/bin/env sh

set -o errexit
set -o nounset
unalias -a

PROCNAME="$1"
MASK="${2:-"0-31"}"

for pid in $(pidof "$PROCNAME"); do
  taskset -cp "$MASK" "$pid" || true
  for tid in $(/usr/bin/ls "/proc/$pid/task"); do
    taskset -cp "$MASK" "$tid" || true
  done
done
