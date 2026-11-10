#!/bin/sh
# Käynnistää S-kaupat-selaimen virtuaalinäytön (jos asetus skaupat_selain on päällä) ja sitten agentin.
set -e

if python3 -c 'import json, sys; sys.exit(0 if json.load(open("/data/options.json")).get("skaupat_selain") else 1)'; then
    echo "S-kaupat-selain: käynnistetään virtuaalinäyttö ja paneeli"
    Xvfb :99 -screen 0 1280x800x24 -nolisten tcp &
    export DISPLAY=:99
    sleep 1
    # VNC vain kontin sisällä; Home Assistantin paneeli (ingress) näkee sen websockifyn kautta.
    x11vnc -display :99 -localhost -rfbport 5900 -forever -shared -nopw -quiet &
    websockify --web /usr/share/novnc 6080 localhost:5900 >/dev/null 2>&1 &
fi

exec python -u agent.py
