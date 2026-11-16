"""Paneelin mobiiliapuri: lähettää tekstiä ja näppäimiä tmux-päätteeseen ja poimii päätteen linkit.
Kuuntelee vain kontin sisällä (127.0.0.1:7682); nginx välittää /api/-polun Home Assistantin ingressistä."""
import json
import re
import subprocess
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

TARGET = "claude"  # tmux-istunnon aktiivinen ikkuna
RC_WINDOW = "claude:etaohjaus"
KEYS = {"y", "n", "Enter", "Escape", "Up", "Down", "Left", "Right", "Tab", "BTab", "C-c", "C-d", "BSpace", "Space"}
URL_RE = re.compile(r"https?://[^\s<>\"'`]+")


def tmux(*args: str) -> str:
    return subprocess.run(["tmux", *args], capture_output=True, text=True, timeout=10).stdout


def links() -> list[str]:
    # -J yhdistää rivitetyt rivit, jolloin pitkät osoitteet tulevat kokonaisina
    text = tmux("capture-pane", "-p", "-J", "-S", "-300", "-t", TARGET)
    seen, out = set(), []
    for url in reversed(URL_RE.findall(text)):
        url = url.rstrip(".,);]")
        if url not in seen:
            seen.add(url)
            out.append(url)
    return out[:20]  # uusin ensin


class Handler(BaseHTTPRequestHandler):
    def _json(self, code: int, data) -> None:
        body = json.dumps(data, ensure_ascii=False).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:
        if self.path.rstrip("/").endswith("/linkit"):
            return self._json(200, {"linkit": links()})
        if self.path.rstrip("/").endswith("/etaohjaus"):
            windows = tmux("list-windows", "-t", "claude", "-F", "#{window_name}").split()
            if "etaohjaus" not in windows:
                return self._json(200, {"kaynnissa": False, "teksti": ""})
            text = tmux("capture-pane", "-p", "-J", "-S", "-60", "-t", RC_WINDOW)
            return self._json(200, {"kaynnissa": True, "teksti": text.rstrip()})
        self._json(404, {"virhe": "tuntematon"})

    def do_POST(self) -> None:
        try:
            data = json.loads(self.rfile.read(int(self.headers.get("Content-Length") or 0)) or b"{}")
        except ValueError:
            return self._json(400, {"virhe": "virheellinen pyyntö"})
        if self.path.rstrip("/").endswith("/laheta"):
            text = str(data.get("teksti", ""))[:20000]
            if text:
                tmux("send-keys", "-t", TARGET, "-l", "--", text)
            if data.get("enter", True):
                tmux("send-keys", "-t", TARGET, "Enter")
            return self._json(200, {"ok": True})
        if self.path.rstrip("/").endswith("/nappi"):
            key = str(data.get("nappi", ""))
            if key not in KEYS:
                return self._json(400, {"virhe": "näppäin ei sallittu"})
            tmux("send-keys", "-t", RC_WINDOW if data.get("ikkuna") == "etaohjaus" else TARGET, key)
            return self._json(200, {"ok": True})
        self._json(404, {"virhe": "tuntematon"})

    def log_message(self, *args) -> None:  # ei pyyntölokia
        pass


def confirm_remote_control() -> None:
    """Asetus etaohjaus on käyttäjän suostumus: vastataan etäohjauksen käyttöönottokysymykseen "y".
    Muihin kysymyksiin ei vastata automaattisesti (Etäohjaus-näkymän painikkeet)."""
    while True:
        time.sleep(3)
        try:
            if "etaohjaus" not in tmux("list-windows", "-t", "claude", "-F", "#{window_name}").split():
                continue
            tail = tmux("capture-pane", "-p", "-t", RC_WINDOW).rstrip().splitlines()[-3:]
            if any("Enable Remote Control? (y/n)" in line for line in tail):
                tmux("send-keys", "-t", RC_WINDOW, "y", "Enter")
                time.sleep(10)
        except Exception:
            pass


if __name__ == "__main__":
    threading.Thread(target=confirm_remote_control, daemon=True).start()
    ThreadingHTTPServer(("127.0.0.1", 7682), Handler).serve_forever()
