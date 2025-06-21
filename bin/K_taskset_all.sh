#! /usr/bin/env bash
# example:
# ❯ $0 0-7,24
# Sets CPU affinity for all threads of all running processes to the specified CPU list.

if [[ ${EUID} -ne 0 ]]; then
  echo 'need to be root'
  exit 1
fi

ALL_PROCESSORS=$(( $(nproc) - 1 ))
CPU_LIST="${1:-"0-$ALL_PROCESSORS"}"

for tid in $(/usr/bin/ls /proc/*/task); do
  taskset -cp "$CPU_LIST" "$tid" || true
done
