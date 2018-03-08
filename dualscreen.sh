#!/bin/bash
xrandr --newmode "1440x900_60.00"  106.50  1440 1528 1672 1904  900 903 909 934 -hsync +vsync
xrandr --addmode DVI-I-1 "1440x900_60.00"
xrandr --output DisplayPort-0 --off --output DVI-D-0 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DVI-I-1 --mode 1440x900_60.00 --pos 1992x0 --rotate normal --output HDMI-A-0 --off
