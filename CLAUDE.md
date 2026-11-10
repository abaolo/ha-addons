# CLAUDE.md

Home Assistant -lisäosarepositorio (`repository.yaml` + lisäosakansiot, nyt `whatsapp_agent/`).
Home Assistant lukee repon `main`-haarasta. Lisäosat näkyvät HA:ssa kohdassa *Apps*.
Repo on julkinen: älä lisää tänne mitään yksityistä.

## Home Assistant -ympäristö

- Home Assistant OS, Gigabyte BRIX (amd64), `http://192.168.1.166:8123`, Samba `\\192.168.1.166\share`.
- Zigbee: SMLIGHT SLZB-MR3U `192.168.1.167`, ZHA `socket://192.168.1.167:7638`, kanava 15.
- Laitteet: Aqara T1 -anturit, Aqara-vuotovahti, Shelly Gen4 (WiFi).

## WhatsApp Agent (`whatsapp_agent/`)

- Docker `python:3.12-slim-bookworm`, `agent.py` + `run.sh` (S-kaupat-selaimen virtuaalinäyttö, VNC, noVNC-paneeli).
- WhatsApp: `neonize==0.10.0` (async `neonize.aioze`), linkitetty laite. QR-koodi → `/share/agent/whatsapp_qr.png`,
  istunto `/data/whatsapp.sqlite3`. Prepaid-numero, koska tapa rikkoo WhatsAppin ehtoja.
- LLM: Claude API, malli asetuksesta `model`.
- Home Assistant API: `http://supervisor/core/api` + `SUPERVISOR_TOKEN`.
- Tiedostot: `/share/agent` (reseptit/, asetukset/, ruokalistat/, saapuneet/).

## Säännöt

- Aina kun muutat `whatsapp_agent/`-kansion tiedostoja: nosta `whatsapp_agent/config.yaml`:n `version`-kentän
  patch-numeroa, aja `python -m py_compile whatsapp_agent/agent.py`, commit ja push. Ilman versionnostoa
  Home Assistant ei näe päivitystä. Päivitys näkyy HA:ssa vasta, kun muutos on `main`-haarassa.
- Älä koskaan lisää koodiin API-avaimia, puhelinnumeroita tai muita salaisuuksia. Ne kuuluvat lisäosan asetuksiin.
- Pidä agentti yhdessä tiedostossa niin kauan kuin se on järkevää. Käyttöliittymäteksteissä ja kehotteissa
  käytetään suomea.
- Älä laajenna `ALLOWED_SERVICE_DOMAINS`-listaa (erityisesti lock, alarm_control_panel tai homeassistant)
  kysymättä käyttäjältä.
- Älä muuta `system_prompt()`-tekstiä ajon aikana (ei kellonaikoja tms.) äläkä muokkaa keskusteluhistorian
  keskeltä: uusien mallien ajattelulohkot on sidottu system promptiin ja aiempiin viesteihin, ja muutos
  aiheuttaa 400-virheen ("Invalid `signature` in `thinking` block"). Muuttuva tieto käyttäjän viestin alkuun.
- Tiedostotyökalujen pitää käyttää `safe_path()`-funktiota (rajaus `/share/agent`-kansioon).
- Ostoksia tai maksuja ei koskaan automatisoida loppuun asti. Agentti saa koota ostoskorin, mutta käyttäjä
  maksaa itse.

## Kehitysjono (käyttäjän pyynnöstä)

1. Vianetsintä ensikäynnistyksessä (neonize-yhteys, QR) lokin perusteella.
2. PDF- ja kuvatiedostojen lukeminen (document/image block), esim. resepti kuvasta → `reseptit/*.md`.
3. Keskusteluhistorian tallennus `/data`-kansioon.
4. Ajastetut viestit (iltaisin "mitä söitte tänään?", ruokalistaehdotus kahden viikon välein).
5. S-kaupat (0.6.0, käyttäjän päätös ja hyväksyntä): lisäosan oma Chromium virtuaalinäytöllä, käyttäjä kirjautuu
   itse ingress-paneelissa (noVNC), agentti tekee GraphQL-kyselyt s-kaupat.fi-välilehdeltä (`sk_call`,
   s-kaupat-mcp:n malli). Rajat: agentti ei kirjaudu, ei ratkaise kuvavarmenteita, ei naamioi selainta, ei tilaa
   eikä maksa; kirjoittaa vain ostoslistoja ja poistaa vain itse luomansa. Testattu testipalvelimella, ei vielä
   oikeaa kauppaa vasten.
6. Hälytysten välitys WhatsAppiin (vuotovahti ym.).
