#! /usr/bin/env bash
# Sets CPU affinity for all threads of the specified processes (specified by procname or pid),
# and all of their children (all processes & threads) to the specified CPU list.
#
# Example usage:
# ❯ $0 '0,1,2-7' steam firefox 54321
# ❯ $0 ALL steam firefox 54321
# ❯ $0 ALL ALL

set -euo pipefail
unalias -a

if [[ "$1" = "ALL" ]]; then
  CPU_LIST="0-$(( $(nproc --all) - 1 ))"
else
  CPU_LIST="$1"
fi

shift

PIDS=()
if [[ "$1" = "ALL" ]]; then
  for pid_path in /proc/[0-9]*; do
      pid="${pid_path##*/}"
      PIDS+=("$pid")
  done
else
  PROCNAMES=("$@")
  for pid_or_procname in "${PROCNAMES[@]}"; do
    if [[ "$pid_or_procname" =~ ^[0-9]+$ ]]; then
      PIDS+=("$pid_or_procname")
    else
      for pid in $(pidof "$pid_or_procname"); do
        PIDS+=("$pid")
      done
    fi
  done
fi

mapfile -d\  -t PIDS < <( pids_get_all_child_pids.sh "${PIDS[@]}" )

for pid in "${PIDS[@]}"; do
  echo -e "\n  calling >>> taskset --all-tasks --pid --cpu-list $CPU_LIST $pid <<<"
  taskset --all-tasks --pid --cpu-list "$CPU_LIST" "$pid" || echo "taskset failed for pid $pid"
done
