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

S-kauppojen rajapinta vastaa vain kaupan omalle sivulle, joten lisäosassa on oma selain (Chromium
virtuaalinäytöllä). Kirjaudut siihen itse Home Assistantin sivupalkin **S-kaupat**-paneelissa, ja agentti tekee
kyselyt sen s-kaupat.fi-välilehdeltä samassa kirjautumisessa. Toimintamalli ja kyselyt:
[s-kaupat-mcp](https://github.com/Vkuparin/s-kaupat-mcp) (Apache-2.0). Selain ei naamioi itseään, kutsujen
väli on vähintään 0,5 s, eikä agentti koskaan kirjaudu, tilaa tai maksa. S-kaupat ei toivo automaattista
käyttöä: käyttö on omalla vastuulla ja voi rikkoa käyttöehtoja.

**Käyttöönotto:**
1. Asetukset: `skaupat_selain: true` ja `skaupat_kauppa` (esim. *Prisma Liisanlehto*). Tallenna.
2. Avaa sivupalkista **S-kaupat**. Näet selaimen, jossa on auki s-kaupat.fi. Kirjaudu sisään tavalliseen
   tapaan (kuvavarmenne ja sähköpostikoodi kuten aina). Älä kirjaudu ulos.
3. Kokeile WhatsAppissa: *"Mitä S-kaupan ostoslistoja meillä on?"*

Kun kirjautuminen vanhenee, agentti pyytää kirjautumaan paneelissa uudelleen. Selain vie muistia noin
300–500 Mt ja on päällä aina, kun `skaupat_selain` on päällä.

**Käyttö:**
- *"Opettele aiemmista tilauksista, mitä juoksevia meillä menee"*: tilaukset kansioon `ostokset/tilaukset/`,
  kulutus tiedostoon `ostokset/kulutus.md`.
- *"Tee S-kaupan ostokset ensi viikon ruokalistasta"*: agentti yhdistää ruokien ostoslistat ja juoksevat
  tuotteet ja luo vahvistuksesi jälkeen uuden ostoslistan. Avaa se S-kaupat-sovelluksessa, paina
  **Lisää kaikki ostoskoriin** ja tilaa itse.
- Ilman selainta (`skaupat_selain: false`) agentti toimii kuvakaappauksilla: lähetä kuvat ostoslistoista tai
  tilauksista, ja se kokoaa viikon ostokset viestinä.

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

