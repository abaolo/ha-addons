FROM python:3.12-slim-bookworm

# libmagic1: neonizen python-magic-riippuvuus
# xvfb, x11vnc, novnc, websockify: S-kaupat-selaimen virtuaalinäyttö ja sen näkymä Home Assistantin paneelissa
RUN apt-get update \
    && apt-get install -y --no-install-recommends libmagic1 xvfb x11vnc novnc websockify fonts-dejavu-core \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
# Chromium S-kaupat-selaimelle
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
RUN python -m playwright install --with-deps chromium \
    && rm -rf /var/lib/apt/lists/*
COPY novnc-index.html /usr/share/novnc/index.html
COPY paneeli-pois ./paneeli-pois
COPY run.sh agent.py ./
RUN chmod +x run.sh

CMD ["./run.sh"]
