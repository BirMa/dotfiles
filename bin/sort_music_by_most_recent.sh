#! /usr/bin/env bash

set -euo pipefail

INPUTDIR="$1"

find "$INPUTDIR" -type f -printf '%h|%T@|%f\n' |
awk -F'|' '
{
  directory = $1
  timestamp = $2
  filename  = $3

  if (timestamp > max_timestamp[directory])
    max_timestamp[directory] = timestamp

  files_in_directory[directory] = files_in_directory[directory] filename "\n"
}
END {
  for (directory in files_in_directory) {
    split(files_in_directory[directory], file_list, "\n")
    for (i in file_list)
      if (file_list[i] != "")
        printf "%.10f|%s/%s\n",
               max_timestamp[directory],
               directory,
               file_list[i]
  }
}' |
sort -t'|' -k1,1nr -k2,2 -s |
cut -d'|' -f2-
