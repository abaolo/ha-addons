#!/bin/sh
# Käynnistää S-kaupat-selaimen virtuaalinäytön ja paneelin (jos asetus skaupat_selain on päällä) ja sitten agentin.
# Paneeli (Home Assistantin ingress, portti 6080) vastaa aina: pois päältä se näyttää ohjeen.

if python3 -c 'import json, sys; sys.exit(0 if json.load(open("/data/options.json")).get("skaupat_selain") else 1)'; then
    echo "S-kaupat-selain: käynnistetään virtuaalinäyttö ja paneeli"
    Xvfb :99 -screen 0 1280x800x24 -nolisten tcp &
    export DISPLAY=:99
    for i in 1 2 3 4 5 6 7 8 9 10; do
        [ -e /tmp/.X11-unix/X99 ] && break
        sleep 0.5
    done
    # VNC vain kontin sisällä; paneeli näkee sen websockifyn kautta.
    x11vnc -display :99 -localhost -rfbport 5900 -forever -shared -nopw -quiet -bg -o /tmp/x11vnc.log \
        || echo "S-kaupat-selain: x11vnc ei käynnistynyt (katso /tmp/x11vnc.log)"
    websockify --web /usr/share/novnc 6080 localhost:5900 2>&1 | sed -u 's/^/websockify: /' &
else
    echo "S-kaupat-selain pois päältä (asetus skaupat_selain); paneeli näyttää ohjeen"
    python3 -m http.server 6080 --directory /app/paneeli-pois >/dev/null 2>&1 &
fi

exec python -u agent.py
