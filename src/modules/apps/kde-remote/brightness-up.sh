#!/bin/bash
# Increase screen brightness by 10% using KDE's D-Bus interface
BUS="org.kde.Solid.PowerManagement"
PATH_DBUS="/org/kde/Solid/PowerManagement/Actions/BrightnessControl"
IFACE="org.kde.Solid.PowerManagement.Actions.BrightnessControl"

CUR=$(/usr/bin/qdbus6 $BUS $PATH_DBUS $IFACE.brightness)
MAX=$(/usr/bin/qdbus6 $BUS $PATH_DBUS $IFACE.brightnessMax)
STEP=$(( MAX / 10 ))   # 10% increment
NEW=$(( CUR + STEP ))
(( NEW > MAX )) && NEW=$MAX

/usr/bin/qdbus6 $BUS $PATH_DBUS $IFACE.setBrightness $NEW

