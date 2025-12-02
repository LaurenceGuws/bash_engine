#!/bin/bash
# Decrease screen brightness by 10% using KDE's D-Bus interface
BUS="org.kde.Solid.PowerManagement"
PATH_DBUS="/org/kde/Solid/PowerManagement/Actions/BrightnessControl"
IFACE="org.kde.Solid.PowerManagement.Actions.BrightnessControl"

CUR=$(/usr/bin/qdbus6 $BUS $PATH_DBUS $IFACE.brightness)
MAX=$(/usr/bin/qdbus6 $BUS $PATH_DBUS $IFACE.brightnessMax)
STEP=$(( MAX / 10 ))   # 10% decrement
NEW=$(( CUR - STEP ))
(( NEW < 0 )) && NEW=0

/usr/bin/qdbus6 $BUS $PATH_DBUS $IFACE.setBrightness $NEW

