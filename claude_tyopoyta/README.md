# Claude-työpöytä

Claude Code Home Assistantin minikoneella sekä oma Chromium-selain virtuaalinäytöllä. Agentti voi tehdä
esimerkiksi skreippereitä ja selata sivuja. Kun sivu pyytää kuvavarmennetta tai kirjautumista, hoidat sen itse
paneelin **Selain**-välilehdellä, ja agentti jatkaa sen jälkeen.

## Käyttöönotto

1. Asenna lisäosa (Asetukset → Apps → Claude-työpöytä) ja käynnistä se. Ensimmäinen käännös kestää muutaman minuutin.
2. Avaa sivupalkista **Claude**-paneeli. **Pääte**-välilehdellä kirjoita `claude` ja kirjaudu `/login`-komennolla
   (avaa näkyvä linkki ja liitä koodi takaisin päätteeseen). Kirjautuminen säilyy päivityksissä.
3. Anna Claudelle tehtävä päätteessä tai ota etäohjaus käyttöön (alla).

## Etäohjaus Claude-sovelluksesta

Asetus `etaohjaus: true` käynnistää `claude remote-control --name Minikone` -istunnon. Se näkyy Claude-sovelluksessa
(Code) ja osoitteessa claude.ai/code, joten voit antaa tehtäviä puhelimesta. Tarvitaan kirjautuminen (kohta 2).
Päätteessä istunto näkyy tmux-ikkunassa `etaohjaus` (Ctrl-b n vaihtaa ikkunaa).

## Selain

Työkansiossa on valmiina `.mcp.json`, joka antaa Claudelle Playwright-työkalut lisäosan selaimeen
(`playwright-mcp --cdp-endpoint`). Claude kysyy ensimmäisellä kerralla luvan käyttää sitä. Selain näkyy
**Selain**-välilehdellä, ja kirjautumiset säilyvät.

## Rajat ja turvallisuus

- Lisäosalla ei ole pääsyä Home Assistantin tai Supervisorin rajapintoihin eikä `/share`-kansioon. Se näkee vain oman
  kansionsa (`/config` lisäosan sisällä; Sambassa `addon_configs\…_claude_tyopoyta`) ja `/data`-kansion.
- Työkansion `CLAUDE.md` ohjeistaa: kuvavarmenteet ja kirjautumiset hoitaa käyttäjä, sivustojen ehtoja noudatetaan,
  ei ostoksia eikä maksuja. Voit muokata tiedostoa.
- Selain ja sen etäohjausportti näkyvät vain kontin sisällä; paneeli vain Home Assistantin kautta.
- Claude Code päivittyy lisäosan päivityksen mukana.
