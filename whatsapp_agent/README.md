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

## Kotisivun ruokalista ja reseptit

Agentti voi lukea kotisivun ruokalistasovelluksen tiedot (tähtiarviot, reseptilinkit, omat ehdotukset,
aiemmat arvonnat). Täytä lisäosan asetuksiin:
- `supabase_url`: sama kuin kotisivun `VITE_SUPABASE_URL` (Vercelin ympäristömuuttujat)
- `supabase_key`: sama kuin `VITE_SUPABASE_KEY`

Reseptin linkistä agentti osaa tallentaa reseptin kansioon `reseptit/`, esim.
*"tallenna reseptit kaikille ruoille, joilla on linkki kotisivulla"*.

## Ryhmät

Agentti vastaa ryhmässä vain, kun viesti on osoitettu sille:
- viesti alkaa agentin nimellä (asetus `name`, oletus *Kotiapuri*), esim. *"Kotiapuri, mitä syödään huomenna?"*
- agentti mainitaan (`@Kotiapuri`), tai
- vastataan agentin viestiin.

Lisäksi ryhmän pitää olla asetuksen `allowed_groups` listassa ja lähettäjän `allowed_numbers`-listassa.
Ryhmän tunnuksen saat näin: lisää agentti ryhmään, kirjoita ryhmään *"Kotiapuri hei"* ja katso lokista rivi
*"Ryhmä 1203…@g.us ei ole allowed_groups-listassa"*. Kopioi tunnus asetuksiin ja tallenna (lisäosa käynnistyy uudelleen).
Ryhmällä on oma keskusteluhistoriansa.

## Turvallisuus

- Agentti vastaa vain `allowed_numbers`-listan numeroihin, ja ryhmissä vain `allowed_groups`-listan ryhmissä.
- Tiedostot rajataan kansioon `/share/agent`.
- Home Assistant -palvelut on rajattu `agent.py`:n `ALLOWED_SERVICE_DOMAINS`-listaan.
- API-avain on vain lisäosan asetuksissa.

## Vianetsintä

- **"WhatsApp kirjasi laitteen ulos"**: käynnistä lisäosa uudelleen ja linkitä QR-koodilla.
- **Ei vastausta**: tarkista lokista, hylättiinkö viesti (väärä numero `allowed_numbers`-listassa).
