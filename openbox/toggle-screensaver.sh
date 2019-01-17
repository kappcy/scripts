#!/bin/sh
if pgrep -u $UID -x screensaver.sh
then
   kill -9 $(pgrep -u $UID -x screensaver.sh) &
   notify-send "Screensaver Disabled"
else
   ~/scripts/screensaver.sh &
   notify-send "Screensaver Enabled"
fi
