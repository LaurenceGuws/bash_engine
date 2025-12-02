#!/bin/bash
# Toggle mute using KDE's global accelerator
exec /usr/bin/qdbus6 org.kde.kglobalaccel /component/kmix invokeShortcut "mute"

