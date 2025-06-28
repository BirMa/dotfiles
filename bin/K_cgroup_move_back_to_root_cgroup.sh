#! /usr/bin/env bash

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo 'need to be root'
  exit 1
fi

CGROUP_TO_EMPTY="$1"
CGROUP_PIDS_FILE="/sys/fs/cgroup/$CGROUP_TO_EMPTY/cgroup.procs"

while read -r pid; do
    echo "moving $pid to root cgroup"
    echo -n "$pid" > "/sys/fs/cgroup/cgroup.procs" || true
done < "$CGROUP_PIDS_FILE"
