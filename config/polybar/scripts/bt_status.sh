#!/bin/bash
get_paired() {
  echo $(bluetoothctl paired-devices) | grep -oE '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'
}

get_name_connected() {
  echo $(bluetoothctl info $1) | grep -e 'Connected: yes' | grep -Po '(?<=Name:\s)(\S*)'
}

# ----------------------- DISPLAY -------------------------
t=0

toggle() {
  t=$(((t + 1) % 2))
}

display_status() {
  display=""
  if [ -z "$(bluetoothctl show | grep "Powered: yes")" ]
  then
    display="%{F#2f343f}"
  else
    paired=$(get_paired)
    if [ -z paired ]; then
      display="%{F#59adff}"
    else
      for i in ${paired[@]}; do
        name=$(get_name_connected "$i")
        if [ -z "name" ]
        then
          echo "%{F#59adff}"
          break
        else
          if [ $t -eq 0 ]; then
            display="%{F#2cda9d}"
            break
          else
            display=$display$name" / "
          fi
        fi
        display="%{F#2cda9d}"$display
      done
    fi
  fi
  echo $display"  "
}

trap "toggle" USR1

while true; do
  display_status
  sleep 1 &
  wait
done
