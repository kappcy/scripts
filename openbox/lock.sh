#!/bin/sh

###/etc/systemd/system/beforesuspend.service
###[Unit]
###Description=run before suspend
###Before=sleep.target
###
###[Service]
###User=kappcy
###Type=forking
###Environment=DISPLAY=:0
###ExecStart=/home/kappcy/scripts/openbox/lock.sh
###
###[Install]
###WantedBy=sleep.target
###

scrot /tmp/screen.png
betterlockscreen -u /tmp/screen.png
rm /tmp/screen.png
betterlockscreen -l dimblur &
sleep 1
