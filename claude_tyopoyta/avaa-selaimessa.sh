#!/bin/sh
# Avaa osoitteen lisäosan omassa Chromiumissa (uusi välilehti käynnissä olevaan selaimeen),
# jotta esim. Claude Coden kirjautuminen näkyy paneelin Selain-välilehdellä.
export DISPLAY="${DISPLAY:-:99}"
chromium --no-sandbox --user-data-dir=/data/chromium "$@" >/dev/null 2>&1 &
exit 0
