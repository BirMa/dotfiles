#! /usr/bin/env bash

PIDS=("$@")
for pid in "${PIDS[@]}" ; do
  if ! [[ "$pid" =~ ^[0-9]+$ ]] ; then
    echo "Invalid PID: $pid. PIDs must be numeric." >&2
    exit 1
  fi
done

## https://stackoverflow.com/a/52544126
# Make a list of all process pids and their parent pids
ps_output=$(ps -e -o pid= -o ppid=)

# Populate a sparse array mapping pids to (string) lists of child pids
children_of=()
while read -r pid ppid ; do
  [[ -n $pid && pid -ne ppid ]] && children_of[ppid]+=" $pid"
done <<< "$ps_output"

unproc_idx=0    # Index of first process whose children have not been added
while (( ${#PIDS[@]} > unproc_idx )) ; do
  pid=${PIDS[unproc_idx++]}       # Get first unprocessed, and advance
  IFS=" " read -r -a TMP_CHILDPIDS <<< "${children_of[pid]-}"
  PIDS+=( "${TMP_CHILDPIDS[@]}" )  # Add child pids
done

echo -n "${PIDS[*]}"


# TODO untested methods
## https://stackoverflow.com/a/52525005
# collect_children() {
#   # format of /proc/[pid]/stat file; group 1 is PID, group 2 is its parent
#   stat_re='^([[:digit:]]+) [(].*[)] [[:alpha:]] ([[:digit:]]+) '

#   # read process tree into a bash array
#   declare -g children=( )              # map each PID to a string listing its children
#   for f in /proc/[[:digit:]]*/stat; do # forcing initial digit skips /proc/net/stat
#     read -r line <"$f" && [[ $line =~ $stat_re ]] || continue
#     children[${BASH_REMATCH[2]}]+="${BASH_REMATCH[1]} "
#   done
# }

# # run a fresh collection, then walk the tree
# all_children_of() { collect_children; _all_children_of "$@"; }

# _all_children_of() {
#   local -a immediate_children
#   local child
#   read -r -a immediate_children <<<"${children[$1]}"
#   for child in "${immediate_children[@]}"; do
#     echo "$child"
#     _all_children_of "$child"
#   done
# }

# all_children_of "$@"


## Also untested: https://stackoverflow.com/a/52524858
## Maybe combine with above
# unprocessed_pids=( $$ )
# while (( ${#unprocessed_pids[@]} > 0 )) ; do
#     pid=${unprocessed_pids[0]}                      # Get first elem.
#     echo "$pid"
#     unprocessed_pids=( "${unprocessed_pids[@]:1}" ) # Remove first elem.
#     unprocessed_pids+=( $(pgrep -P $pid) )          # Add child pids
# done
