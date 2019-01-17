#!/bin/sh
if pidof pavucontrol
then
   kill -9 $(pidof pavucontrol) &&
   pavucontrol
else
   pavucontrol &
fi
