#! /usr/bin/env bash

set -euo pipefail

sudo echo "sudo..."

CGROUP_NAME="defaultCgroup1"
CPU_LIMIT_PROC_TIME_SPACE_CPU_TIME_US="1000 20000"
CPU_LIMIT_HALT="1000 100000"
CPU_LIMIT_LOW="2000 20000"
CPU_LIMIT_NONE="max 100000"

HELP="Usage: $0 [-n cgroup_name>] [-c 'cpu_limit|\"max\" proc_time_space_cpu_time_us'] pid { pid }"
while getopts "n:c:" opt; do
  case "$opt" in
    n)
      if ! [[ "$OPTARG" =~ ^[a-zA-Z][a-zA-Z0-9_\-]*$ ]]; then
        echo -e "-n needs a proper cgroup name\n$HELP" >&2
        exit 1
      fi
      CGROUP_NAME="$OPTARG"
      ;;
    c)
      if [[ "$OPTARG" =~ ALL|all|MAX|max ]]; then
        CPU_LIMIT_PROC_TIME_SPACE_CPU_TIME_US="$CPU_LIMIT_NONE"
      elif [[ "$OPTARG" =~ LOW|low ]]; then
        CPU_LIMIT_PROC_TIME_SPACE_CPU_TIME_US="$CPU_LIMIT_LOW"
      elif [[ "$OPTARG" =~ HALT|halt ]]; then
        CPU_LIMIT_PROC_TIME_SPACE_CPU_TIME_US="$CPU_LIMIT_HALT"
      elif [[ -z "$OPTARG" ]] || ! [[ "$OPTARG" =~ ^([0-9]+)|max\ [0-9]+$ ]]; then
        echo -e "-c needs proper value\n$HELP" >&2
        exit 1
      else
        CPU_LIMIT_PROC_TIME_SPACE_CPU_TIME_US="$OPTARG"
      fi
      ;;
    *) echo "$HELP" >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

if [ "$#" -eq 0 ]; then
  echo -e "No PIDs provided. Please provide at least one PID.\n$HELP" >&2
  exit 1
fi
PID_LIST=( "$@" )


# Create cgroup
sudo mkdir -p "/sys/fs/cgroup/$CGROUP_NAME"

# Configure cgroup
# see https://www.kernel.org/doc/html/latest/admin-guide/cgroup-v2.html
#touch "/sys/fs/cgroup/$CGROUP_NAME/cpu.max"
echo "$CPU_LIMIT_PROC_TIME_SPACE_CPU_TIME_US" | sudo tee "/sys/fs/cgroup/$CGROUP_NAME/cpu.max">/dev/null
echo "set cgroup $CGROUP_NAME cpu.max to '$CPU_LIMIT_PROC_TIME_SPACE_CPU_TIME_US'"

# Get child pids
mapfile -d\  -t PID_LIST < <( pids_get_all_child_pids.sh "${PID_LIST[*]}" )

# ALL_ROOT_CGROUP_PIDS="$(cat /sys/fs/cgroup/cgroup.procs 2>/dev/null || true)"

# "Only one PID at a time should be written to this file." -- cgroups(7)
for pid in "${PID_LIST[@]}"; do
  if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
    echo "Invalid PID: $pid. PIDs must be numeric." >&2
    continue
  fi

  # # TODO leave systemd cgroups alone, it breaks systemd. But processes in any user-slice should be fine
  # if ! [[ TODO "$ALL_ROOT_CGROUP_PIDS" == *"$pid"* ]]; then
  #   echo "PID $pid is already in a system-systemd cgroup. Refusing to move it to $CGROUP_NAME. Could break systemd..." >&2
  #   continue
  # fi

  echo "moving pid $pid to cgroup $CGROUP_NAME"
  echo "$pid" | sudo tee "/sys/fs/cgroup/$CGROUP_NAME/cgroup.procs">/dev/null || {
    echo "Failed to move PID $pid to cgroup $CGROUP_NAME" >&2
    continue
  }
done
