#!/bin/bash
# Käynnistää virtuaalinäytön, Chromiumin (CDP vain kontin sisällä), päätteen ja paneelin.
set -u

WORK=/config              # lisäosan oma kansio (Samba: addon_configs\..._claude_tyopoyta)
export HOME=/data/home    # Claude Coden kirjautuminen ja asetukset säilyvät päivityksissä
export DISPLAY=:99
mkdir -p "$HOME" "$WORK" /data/chromium

# Työkansion ohjeet ja selaimen MCP-asetus, jos niitä ei vielä ole (käyttäjän muutoksia ei korvata)
for f in CLAUDE.md .mcp.json; do
    [ -e "$WORK/$f" ] || cp "/app/tyotila/$f" "$WORK/$f"
done

echo "Claude-työpöytä: käynnistetään virtuaalinäyttö"
Xvfb :99 -screen 0 1280x800x24 -nolisten tcp &
for i in $(seq 1 20); do
    [ -e /tmp/.X11-unix/X99 ] && break
    sleep 0.5
done
x11vnc -display :99 -localhost -rfbport 5900 -forever -shared -nopw -quiet -bg -o /tmp/x11vnc.log \
    || echo "x11vnc ei käynnistynyt (katso /tmp/x11vnc.log)"
websockify --web /usr/share/novnc 127.0.0.1:6081 localhost:5900 >/tmp/websockify.log 2>&1 &

# Chromium käynnistetään uudelleen, jos se suljetaan. Etäohjausportti kuuntelee vain kontin sisällä.
(
    while true; do
        sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' /data/chromium/Default/Preferences 2>/dev/null
        chromium --no-sandbox --user-data-dir=/data/chromium \
            --remote-debugging-address=127.0.0.1 --remote-debugging-port=9222 \
            --no-first-run --no-default-browser-check --disable-session-crashed-bubble \
            --disable-dev-shm-usage --window-position=0,0 --window-size=1280,800 \
            --disable-features=Translate --lang=fi about:blank >/tmp/chromium.log 2>&1
        sleep 3
    done
) &

# Pääte: tmux-istunto säilyy, vaikka paneelin sulkee
tmux -u new-session -d -s claude -c "$WORK" -n paate
tmux send-keys -t claude:paate "cd $WORK && clear && echo 'Kirjoita: claude   (ensimmäisellä kerralla /login; kirjautumissivu avautuu Selain-välilehdelle)'" Enter
if jq -e '.etaohjaus == true' /data/options.json >/dev/null 2>&1; then
    echo "Claude-työpöytä: etäohjaus päällä (claude remote-control)"
    tmux new-window -d -t claude -n etaohjaus -c "$WORK" \
        "while true; do claude remote-control --name Minikone; echo 'Etäohjaus päättyi, uusi yritys 60 s päästä'; sleep 60; done"
fi
ttyd -p 7681 -i lo -W -t fontSize=14 -t titleFixed=Claude -t rendererType=dom tmux -u new-session -A -s claude -c "$WORK" \
    >/tmp/ttyd.log 2>&1 &

python3 /app/apuri.py >/tmp/apuri.log 2>&1 &

echo "Claude-työpöytä: paneeli valmis"
exec nginx -c /app/nginx.conf -g 'daemon off;'
