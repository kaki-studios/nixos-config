#!/usr/bin/env bash

current_profile=$(powerprofilesctl get)


if [ "$current_profile" = "power-saver" ]; then
  powerprofilesctl set balanced
  notify-send "Changed profile to: balanced" -a "system"
elif [ "$current_profile" = "balanced" ]; then
  powerprofilesctl set performance
  notify-send "Changed profile to: performance" -a "system"
else
  powerprofilesctl set power-saver
  notify-send "Changed profile to: power-saver" -a "system"
fi


