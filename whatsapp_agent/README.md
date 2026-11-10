# WhatsApp-agentti – käyttöönotto (linkitetty laite)

Agentti on Home Assistantin lisäosa (repositorio `https://github.com/abaolo/ha-addons`). Se liittyy prepaid-numeron
WhatsApp-tiliin **linkitettynä laitteena** (kuten WhatsApp Web), käsittelee viestit
Claude API:lla ja voi käyttää Home Assistantia, kalentereita ja `/share/agent`-kansion
tiedostoja. Metan kehittäjätiliä, verkkotunnusta tai tunnelia ei tarvita.

> **Riski:** tämä tapa rikkoo WhatsAppin käyttöehtoja, ja WhatsApp voi estää numeron.
> Käytä vain erillistä prepaid-numeroa, älä omaa pääasiallista numeroasi.

## 1. Agentin WhatsApp-tili

1. Laita prepaid-kortti varapuhelimeen ja asenna siihen WhatsApp.
2. Rekisteröi WhatsApp prepaid-numerolla tavalliseen tapaan.
3. Pidä puhelin tallessa ja käynnistä WhatsApp siinä **vähintään kerran kahdessa viikossa**.
   Muuten WhatsApp kirjaa linkitetyt laitteet ulos.

## 2. Lisäosan asetukset

1. **Settings → Apps → Install app → ⋮ → Repositories** → lisää `https://github.com/abaolo/ha-addons`.
2. Avaa **WhatsApp Agent**, paina **Install** ja kytke **Auto update** päälle.
3. Täytä **Configuration**-välilehdellä:
   - `anthropic_api_key` (console.anthropic.com)
   - `allowed_numbers`: **oma** numerosi ilman plussaa, esim. `358401234567`
4. Paina **Start** ja avaa **Log**-välilehti.

## 3. Linkitys QR-koodilla

1. Lokiin tulee ilmoitus uudesta QR-koodista.
2. Avaa läppärillä kuva `\\192.168.1.166\share\agent\whatsapp_qr.png`.
3. Avaa varapuhelimen WhatsAppissa **Settings → Linked devices → Link a device** ja skannaa kuva.
4. Koodi vaihtuu noin 20 sekunnin välein. Jos skannaus ei onnistu, sulje kuva ja avaa se uudelleen.
5. Lokiin tulee *"Yhdistetty WhatsAppiin – agentti on valmis."*, ja kuva poistuu.

Linkitys säilyy uudelleenkäynnistysten yli (tiedot ovat lisäosan `/data`-kansiossa).

## 4. Testi

Lähetä omasta puhelimestasi WhatsApp-viesti prepaid-numeroon, esim.
*"mikä on kellarin lämpötila?"*

## Tiedostot ja kalenteri

- Reseptit: `\\192.168.1.166\share\agent\reseptit\` (.md tai .txt)
- Mieltymykset: `\\192.168.1.166\share\agent\asetukset\ruokamieltymykset.md`
- Ruokalistat ja ruokapäiväkirja: `\\192.168.1.166\share\agent\ruokalistat\`
- WhatsAppissa lähetetyt tiedostot: `\\192.168.1.166\share\agent\saapuneet\`
- Google-kalenteri: lisää Home Assistantiin **Google Calendar** -integraatio. Agentti löytää sen automaattisesti.
- Ostoslista: lisää **Shopping list** -integraatio.

## Reseptit

Jokaisella ruoalla on oma tiedosto `\\192.168.1.166\share\agent\reseptit\<ruoka>.md` (arvio, linkki,
ainekset, ohje) ja kuvat kansiossa `reseptit\kuvat\`. Arviot on koottu tiedostoon `reseptit\arviot.md`.

**Siirto kotisivulta (kerran):** kotisivu → *Siirrä data* → *Hae data* → *Kopioi leikepöydälle*. Liitä teksti
Muistioon ja tallenna nimellä `kotisivu.json` kansioon `\\192.168.1.166\share\agent\saapuneet\`. Kirjoita sitten
agentille *"tuo kotisivun data saapuneet/kotisivu.json"*.

Reseptin linkistä agentti tallentaa ainekset ja ohjeen ruoan tiedostoon, esim.
*"hae reseptit kaikille ruoille, joilla on linkki"*.

## Ryhmät

Agentti vastaa ryhmässä vain, kun viesti on osoitettu sille:
- viesti alkaa agentin nimellä (asetus `name`, oletus *Kotiapuri*), esim. *"Kotiapuri, mitä syödään huomenna?"*
- agentti mainitaan (`@Kotiapuri`), tai
- vastataan agentin viestiin.

Lisäksi ryhmän pitää olla asetuksen `allowed_groups` listassa ja lähettäjän `allowed_numbers`-listassa.
Ryhmän tunnuksen saat näin: lisää agentti ryhmään, kirjoita ryhmään *"Kotiapuri hei"* ja katso lokista rivi
*"Ryhmä 1203…@g.us ei ole allowed_groups-listassa"*. Kopioi tunnus asetuksiin ja tallenna (lisäosa käynnistyy uudelleen).
Ryhmällä on oma keskusteluhistoriansa.

**Ilman mainintaa (`group_reply_all: true`):** agentti lukee ryhmän kaikki tekstiviestit ja kuvatekstit ja
päättää itse, kuuluuko viesti sille. Pyyntöihin (valot, kalenteri, ruoat) se vastaa, keskinäiseen
keskusteluun ei. Kuvat ilman kuvatekstiä ohitetaan, ja kuvat, joihin agentti ei reagoi, poistetaan.
Jokainen ryhmäviesti on Claude API -kutsu, joten vilkkaassa ryhmässä kulut kasvavat.

## S-kaupat

Agentti käyttää S-kauppojen rajapintaa (`api.s-kaupat.fi`, ei verkkosivua eikä selainta). Se hakee tuotteita
ja hintoja, lukee ostoslistat ja aiemmat tilaukset ja kokoaa viikon ostokset **uudeksi ostoslistaksi**.
Ostoskori on S-kaupoissa vain selaimen muistissa, joten koria agentti ei täytä: avaat listan S-kaupat-
sovelluksessa, painat **Lisää kaikki ostoskoriin** ja tilaat itse. Agentti ei koskaan tilaa eikä maksa.
Rajapinta on epävirallinen (kyselyt: [s-kaupat-mcp](https://github.com/Vkuparin/s-kaupat-mcp), Apache-2.0),
ja S-ryhmä voi muuttaa sitä. Tarkista S-kauppojen käyttöehdot.

**Asetukset:** `skaupat_kauppa` (esim. *Prisma Liisanlehto* tai kaupan numerotunnus) ja
`skaupat_refresh_token` (kirjautumisavain, alla). Tuotehaku toimii ilman kirjautumista.

**Kirjautumisavain (kerran, tietokoneella Chrome tai Edge):**
1. Avaa www.s-kaupat.fi ja kirjaudu sisään tavalliseen tapaan.
2. Paina **F12** ja valitse **Console** (Konsoli). Jos Chrome pyytää, kirjoita ensin `allow pasting` ja Enter.
3. Liitä tämä rivi ja paina Enter. Se etsii kirjautumisavaimen sivun tallennuksista ja kopioi sen leikepöydälle:
   ```js
   (()=>{const f=o=>{if(typeof o==='string'){try{return f(JSON.parse(o))}catch{return null}}if(o&&typeof o==='object'){if(typeof o.refreshToken==='string'&&o.refreshToken)return o.refreshToken;for(const v of Object.values(o)){const r=f(v);if(r)return r}}return null};const t=Object.values(localStorage).map(f).find(Boolean);if(t)copy(t);return t?'Kopioitu leikepöydälle':'Ei löytynyt: oletko kirjautunut?'})()
   ```
4. Liitä avain Home Assistantissa: **Apps → WhatsApp Agent → Asetukset → skaupat_refresh_token** ja tallenna.
5. Sulje S-kaupat-välilehti, mutta **älä kirjaudu ulos**: uloskirjautuminen voi mitätöidä avaimen.

Avain on salasanan veroinen: älä lähetä sitä kenellekään. Agentti uusii pääsyavaimen itse ja tallentaa sen
`/data`-kansioon. Jos agentti kertoo kirjautumisen vanhentuneen, toista ohje.

**Käyttö:**
- *"Opettele aiemmista tilauksista, mitä juoksevia meillä menee"*: tilaukset kansioon `ostokset/tilaukset/`,
  kulutus tiedostoon `ostokset/kulutus.md` (kertoja, tyypillinen määrä, ostoväli, viimeksi ostettu).
- *"Tee S-kaupan ostokset ensi viikon ruokalistasta"*: agentti yhdistää ruokien ostoslistat, ehdottaa
  juoksevia tuotteita ja luo vahvistuksesi jälkeen listan, esim. *Viikon ostokset vko 47*.
- *"Paljonko laktoositon maito maksaa?"*: tuotehaku valitusta kaupasta.

## Turvallisuus

- Agentti vastaa vain `allowed_numbers`-listan numeroihin, ja ryhmissä vain `allowed_groups`-listan ryhmissä.
- Tiedostot rajataan kansioon `/share/agent`.
- Home Assistant -palvelut on rajattu `agent.py`:n `ALLOWED_SERVICE_DOMAINS`-listaan.
- API-avain on vain lisäosan asetuksissa.

## Vianetsintä

- **"WhatsApp kirjasi laitteen ulos"**: käynnistä lisäosa uudelleen ja linkitä QR-koodilla.
- **Ei vastausta**: tarkista lokista, hylättiinkö viesti (väärä numero `allowed_numbers`-listassa).

## Reseptit ja kuvat WhatsAppissa

- **Uusi resepti linkistä:** lähetä linkki, esim. *"tallenna resepti: https://www.valio.fi/reseptit/..."*
- **Uusi resepti tekstinä:** kirjoita ruoan nimi, ainekset ja ohje, ja pyydä tallentamaan.
- **Resepti kuvasta:** lähetä kuva keittokirjan sivusta tai lapusta kuvatekstillä *"tallenna resepti, Lihakeitto"*.
  Agentti lukee kuvan ja kirjoittaa reseptin tiedostoon `reseptit/lihakeitto.md`.
- **Kuva valmiista ruoasta:** lähetä kuva kuvatekstillä *"Kanakeitto"*.
- **Kuva työvaiheesta:** lähetä kuva kuvatekstillä *"Kanakeitto, vaihe: kasvikset pilkottuna"*.
  Kuvat tulevat ruoan tiedoston osioon *Työvaiheet kuvina*.

Kuvatekstin voi jättää pois ja kertoa seuraavassa viestissä, mihin ruokaan kuvat kuuluvat. Ryhmässä
kuvatekstin pitää alkaa agentin nimellä. Kuvat tallentuvat kansioon `reseptit/kuvat/`.

