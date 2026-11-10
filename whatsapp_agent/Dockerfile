FROM python:3.12-slim

# libmagic1: neonizen python-magic-riippuvuus
RUN apt-get update \
    && apt-get install -y --no-install-recommends libmagic1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY agent.py .

CMD ["python", "-u", "agent.py"]
