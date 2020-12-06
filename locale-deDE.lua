local L = LibStub("AceLocale-3.0"):NewLocale("CheeseSLS", "deDE", false)

if L then

-- configs

L["Timings"] = "Zeiten"

L["Bid duration"] = "Dauer für Gebote"
L["Initial time for a bid"] = "Erste Zeit für Gebote"
L["Bids prolong"] = "Verlängern"
L["If a new bid came in, prolong time to end if necessary"] = "Zeit um welche die Gebotsphase verlängert wird, wenn Gebote eingehen"

L["Accept bids"] = "Akzeptierte Gebote"

L["Raid"] = "Raid"
L["Accept bidding in party/raidchat"] = "Akzeptiere Gebote im Raid-/Gruppenchat"
L["Whisper"] = "Geflüstert"
L["Accept bidding by whisper"] = "Akzeptiere geflüsterte Gebote"
L["Same amount"] = "Gleiches Gebot"
L["Accept same amount bids (if disabled: earliest bid wins)"] = "Akzeptiert gleiche Gebote (sonst: früheres Gebot gewinnt)"
L["Revoke bid"] = "Rücknahme"
L["Allows users to revoke bid"] = "Erlaubt die Rücknahme von Geboten"

L["Raid announces"] = "Ausgaben an den Raid"

L["Countdown"] = "Countdown"
L["Give Countdown in raid/party chat"] = "Gibt einen Countdown im Raid-/Gruppenchat aus"
L["New max"] = "Neues Höchstgebot"
L["Announce new max bids to raidchat"] = "Gibt neue Höchstgebote im Raid-/Gruppenchat aus"
L["List to Raid"] = "Liste an Raid"
L["Outputs full list to raid/party on finish (disables output to user)"] = "Gibt eine volle Liste der Gebote an den Raid-/Gruppenchat (deaktiviert -Liste an dich-)"


L["Whisper announces"] = "Geflüsterte Ausgaben"

L["Received"] = "Erhalten"
L["Whisper to player if bid was received"] = "Spieler anflüstern wenn sein Gebot eingegangen ist"
L["No rolls"] = "Kein würfeln"
L["Tells the player to bid if he rolls during bidding"] = "Den Spieler darauf hinweisen, dass er bieten und nicht würfeln muss"

L["Presets"] = "Voreinstellungen"

L["Open Bidding"] = "Offene Aktion"
L["Open bidding in raid chat, with max & low announces, same bidding allowed, bid again allowed"] = "Offenes bieten im Raidchat, Ansagen für Höchstgebote und zu niedrige Gebote; gleiche Gebote erlaubt, Erhöhungen erlaubt."
L["Silent Bidding"] = "Stilles Bieten"
L["Silent bidding by whisper, no max / low announces, first bid wins"] = "Stilles Bieten per Flüstern, keine Ansagen zu Höchstgeboten oder zu niedrigen Geboten, nur einmal bieten, erstes Höchstgebot gewinnt"

L["Miscellaneous"] = "Verschiedenes"

L["Enable additional usage of /bid"] = "Aktiviere zusätzlich Nutzung von /bid"
L["Enable additional usage of /sls"] = "Aktiviere zusätzlich Nutzung von /sls"
L["List to you"] = "Liste an dich"
L["Outputs full list to you on finish (disables output to raid/party)"] = "Gibt eine volle Liste der Gebote dich aus (deaktiviert -Liste an Raid-)"

L["Language"] = "Sprache"
L["Language for outputs"] = "Ausgabesprache"


L["Debug"] = "Debug"

-- notifications

L["Usage: |cFF00CCFF/csls |cFFA335EE[Sword of a Thousand Truths]|r to start a bid"] = "Benutzung: |cFF00CCFF/csls |cFFA335EE[Schwert der 1000 Wahrheiten]|r startet die Gebote"
L["Usage: |cFF00CCFF/csls config|r to open the configuration window"] = "Benutzung: |cFF00CCFF/csls config|r öffnet das Konfigurationsmenü"

L["Bidding for itemLink still running, cannot start new bidding now!"] = function(itemLink) return "Gebote für " .. itemLink .. " laufen noch, es kann noch keine neue Versteigerung beginnen!" end
L["You don't have assist, so I cannot put out Raid Warnings"] = "Du hast kein Assist, kann keine Raid-Warnung senden"
L["You are not in a party or raid. So here we go: Have fun bidding for itemLink against yourself."] = function(itemLink) return "Du bist nicht in einer Gruppe oder Raid. Also dann viel Spaß, du kannst jetzt gegen dich selbst auf " .. itemLink .. " bieten." end


-- load default outputs 
for k,v in pairs(CheeseSLS.outputLocales["deDE"]) do L[k] = v end

end -- if L then
