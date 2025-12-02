#!/bin/bash
# Increase system volume using KDE's global accelerator (no external tools)
exec /usr/bin/qdbus6 org.kde.kglobalaccel /component/kmix invokeShortcut "increase_volume"

