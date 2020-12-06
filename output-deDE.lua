local L = {}


-- raid / party

L["Start Bidding now: itemLink"] = function(itemLink) return "Jetzt bieten für " .. itemLink end
L["Current highest bid for itemLink is maxbid"] = function(itemLink, maxbid) return "Aktuell höchstes Gebot für " .. itemLink .. " ist " .. maxbid end
L["Bidding ended!"] = "Bieten beendet!"
L["No one bid on itemLink"] = function (itemLink) return "Niemand hat für " .. itemLink .. " geboten" end
L["Congratulations! maxplayers won itemLink for maxbid"] = function(maxplayers,itemLink,maxbid) return "Glückwunsch! " .. table.concat(maxplayers, ", ") .. " hat " .. itemLink .. " gewonnen für " ..  maxbid end
L["Tie! maxplayers please roll on itemLink for maxbid"] = function (maxplayers,itemLink,maxbid) return "Gleichstand! " .. table.concat(maxplayers, ", ") .. " rollen jetzt auf " .. itemLink .. " für " ..  maxbid end
L["Bidding ends in sec"] = function (s) return "Gebote enden in " .. s end

-- lists

L["Bid bid from players"] = function(bid,players) return "Geboten: " .. bid .. " von " .. players end

-- whispers

L["You passed on itemLink"] = function (itemLink) return "Du hast auf " .. itemLink .. " gepasst" end
L["Received your bid bid for itemLink"] = function (bid, itemLink) return "Dein Gebot " .. bid .. " für " .. itemLink .. " ist angekommen." end -- Denk dran, du kannst jederzeit passen mit -" end
L["Can not accept your bid bid for itemLink"] = function(bid, itemLink) return "Ich kann dein Gebot " .. bid .. " für " .. itemLink .. " nicht akzeptieren" end
L["Accepted your bid bid for itemLink"] = function (bid, itemLink) return "Dein Gebot " .. bid .. " für " .. itemLink .. " wurde akzeptiert." end -- Denk dran, du kannst jederzeit passen mit -" end
L["You already bid bid for itemLink"] = function (bid, itemLink) return "Du hast bereits " .. bid .. " geboten für " .. itemLink .. "." end -- Denk dran, du kannst jederzeit passen mit -" end
L["LOW BID! Your bid of bid for itemLink is NOT current max bid!"] = function (bid, itemLink) return "NIEDRIGES GEBOT! Dein Gebot " .. bid .. " für " .. itemLink .. " ist NICHT das höchste Gebot jetzt!" end

-- rules

L["Rules:"] = "Regeln:"

L["Bidding runs s sec"] = function(s) return "Gebote laufen " .. s .. "sec" end
L["Bids extend time by s sec"] = function(s) return "Neues Gebot verlängert um " .. s .. "sec" end
	
L["Bids accepted"] = "Akzeptiere Gebote"

L["in Chat or by Whisper to p"] = function(p) return "im Raidchat oder geflüstert an " .. p end
L["only in Chat"] = "nur im Raidchat"
L["only by Whisper to p"] = function(p) return "nur geflüstert an " .. p end

L["Single bid per user (no increase)"] = "Nur ein Gebot pro Person (kein Erhöhen)"
L["Full auction, increases allowed"] = "Volle Auktion (Erhöhen erlaubt)"

L["Same bids allowed"] = "Gleiche Gebote erlaubt"
L["No same bids allowed (first bid counts)"] = "Keine gleichen Gebote (erstes zählt)"

L["Revoke by - possible"] = "Rücknahme mit - möglich"
L["No revocation of bids"] = "Keine Rücknahme von Geboten"

L["We are bidding, not rolling. Please state your bid where"] = function(w) return "Wir bieten, es wird nicht gewürfelt. Bitte gibt dein Gebot ab " .. w end

-- end
CheeseSLS.outputLocales["deDE"] = L
