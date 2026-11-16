FROM node:22-bookworm-slim

# xvfb, x11vnc, novnc, websockify: virtuaalinäyttö ja sen näkymä paneelissa
# chromium: selain, jota Claude Code ohjaa (Playwright MCP, CDP-yhteys)
# ttyd, tmux: pääte paneelissa; istunto säilyy, vaikka paneeli suljetaan
# nginx: yhdistää näytön ja päätteen yhteen ingress-porttiin
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        xvfb x11vnc x11-xserver-utils xdotool novnc websockify chromium fonts-dejavu-core fonts-liberation \
        nginx tmux git curl ca-certificates jq less procps python3 python3-venv python3-pip \
    && rm -rf /var/lib/apt/lists/*

# ttyd (pääte selaimessa) ei ole Debianin paketeissa: projektin julkaisu, tarkistussumma varmistetaan.
ARG TTYD_VERSION=1.7.7
ARG TTYD_SHA256=8a217c968aba172e0dbf3f34447218dc015bc4d5e59bf51db2f2cd12b7be4f55
RUN curl -fsSL -o /usr/local/bin/ttyd \
        "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.x86_64" \
    && echo "${TTYD_SHA256}  /usr/local/bin/ttyd" | sha256sum -c - \
    && chmod +x /usr/local/bin/ttyd

RUN npm install -g @anthropic-ai/claude-code @playwright/mcp \
    && npm cache clean --force

# Päivitykset tulevat lisäosan päivityksen mukana (kuva rakennetaan uudelleen).
ENV BROWSER=/app/avaa-selaimessa.sh DISABLE_AUTOUPDATER=1 LANG=C.UTF-8 LC_ALL=C.UTF-8 TERM=xterm-256color

WORKDIR /app
COPY nginx.conf run.sh avaa-selaimessa.sh apuri.py ./
COPY www ./www
COPY tyotila ./tyotila
COPY vnc-index.html /usr/share/novnc/index.html
RUN chmod +x run.sh avaa-selaimessa.sh \
    && ln -sf /app/avaa-selaimessa.sh /usr/local/bin/xdg-open

CMD ["/app/run.sh"]
