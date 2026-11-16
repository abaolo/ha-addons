# Claude-työpöytä

Tämä on Home Assistant -lisäosan työkansio. Vastaa ja kirjoita suomeksi.

## Selain

- MCP-palvelin `selain` ohjaa lisäosan omaa Chromiumia, joka näkyy käyttäjälle paneelin Selain-välilehdellä.
  Kirjautumiset säilyvät selaimessa.
- Jos sivu pyytää kuvavarmennetta (CAPTCHA), robottitarkistusta, kaksivaiheista tunnistautumista tai kirjautumista:
  pysähdy ja pyydä käyttäjää hoitamaan se Selain-välilehdellä. Jatka vasta, kun käyttäjä sanoo, että se on tehty.
  Älä yritä ohittaa tai ratkaista tarkistuksia itse äläkä naamioi selainta.
- Älä tee ostoksia, maksuja, tilauksia tai muita peruuttamattomia toimia sivustoilla. Kokoa tiedot ja anna käyttäjän
  päättää.

## Skreipperit

- Noudata sivuston käyttöehtoja ja robots.txt:tä, pidä pyyntötahti maltillisena ja hae vain tarvittava.
- Tallenna koodi ja tulokset tähän kansioon (esim. `skreipperit/<nimi>/`). Python-riippuvuudet virtuaaliympäristöön
  (`python3 -m venv .venv`).
- Älä kirjoita tunnuksia tai salasanoja tiedostoihin.
