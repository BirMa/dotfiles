#! /usr/bin/env bash
# Sets CPU affinity for all threads of the specified processes (specified by procname or pid),
# and all of their children (all processes & threads) to the specified CPU list.
#
# Example usage:
# ❯ $0 '0,1,2-7' steam firefox 54321
# > $0 ALL steam firefox 54321
# > $0 ALL ALL

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

ITER_LIMIT=100000
procs_count=0
go_through_all_children() {
  local pid="$1"

  ITER_LIMIT=$((ITER_LIMIT - 1))
  if [[ "$ITER_LIMIT" -lt 0 ]]; then
    echo -e "Limit reached, giving up after setting $procs_count affinities at pid=$pid, for\n${PIDS[*]}"
    exit 1
  fi

  echo -e "\n  calling >>> taskset --all-tasks --pid --cpu-list $CPU_LIST $pid <<<"
  taskset --all-tasks --pid --cpu-list "$CPU_LIST" "$pid" || echo "(that one failed)"

  procs_count=$((procs_count + 1))
  if [[ -r "/proc/$pid/task/$pid/children" ]]; then
    # shellcheck disable=SC2013 # Actually want to read words here
    for child in $(cat "/proc/$pid/task/$pid/children"); do
      go_through_all_children "$child"
    done
  else
    :
    # echo "No children or no perms for /proc/$pid/task/$pid/children"
  fi
}

if [[ ${#PIDS[@]} -eq 0 ]]; then
  echo "No processes found matching: ${PROCNAMES[*]}"
  exit 1
fi

for pid in "${PIDS[@]}"; do
  go_through_all_children "$pid"
done
