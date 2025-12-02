#!/bin/bash
# Decrease system volume using KDE's global accelerator (no external tools)
exec /usr/bin/qdbus6 org.kde.kglobalaccel /component/kmix invokeShortcut "decrease_volume"

