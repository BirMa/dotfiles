#! /usr/bin/env bash

# "Rotates through" available sinks.
# Lists all available sinks and switches next available as default.

FILE_NOTIFICATION_ID="/tmp/notification.rotate.default.sinks.id"

SINKS_RAW=$(pactl --format=json list short sinks | jq --raw-output 'map(.name) | sort | .[]')
mapfile -t <<<"$SINKS_RAW" "SINKS"
# Append first element of self to have an "overflow" to the first element when current default sink is last one in list
SINKS=( "${SINKS[@]}" "${SINKS[0]}")
CUR_SINK=$(pactl --format=json get-default-sink)

notif_id="$(cat $FILE_NOTIFICATION_ID || echo '147387')"

idx=0
for sink in "${SINKS[@]}"
do
  echo "looking at sink: $sink"
  if [[ "$sink" = "$CUR_SINK" ]]; then
    echo "found selected sink: $sink"
    new_sink=${SINKS[$(( idx + 1))]}
    echo "setting new default sink: $new_sink"
    # TODO Why doesn't this work on md? Not that I need it there, but still.
    # Maybe look at the comments here, unsure if related at all: https://www.reddit.com/r/linux/comments/1oerjbl/when_pipewire_just_wont_work_usa_alsa/
    pactl set-default-sink "$new_sink"
    notify-send \
      --print-id \
      --replace-id="$notif_id" \
      --urgency="normal" \
      "Switched default sink" \
      "from <b>$CUR_SINK</b>\nto <b>$new_sink</b>" >$FILE_NOTIFICATION_ID
    exit 0
  fi
  idx=$(( idx + 1 ))
done

notify-send \
  --replace-id="my.audio.rotated" \
  --urgency="critical" \
  "Switching sinks failed" \

exit 1
