local L = {}


-- raid / party

L["Start Bidding now: itemLink"] = function(itemLink) return "Start Bidding now: " .. itemLink end
L["Current highest bid for itemLink is maxbid"] = function(itemLink, maxbid) return "Current highest bid for " .. itemLink .. " is " .. maxbid end
L["Bidding ended!"] = "Bidding ended!"
L["No one bid on itemLink"] = function (itemLink) return "No one bid on " .. itemLink end
L["Congratulations! maxplayers won itemLink for maxbid"] = function(maxplayers,itemLink,maxbid) return "Congratulations! " .. table.concat(maxplayers, ", ") .. " won " .. itemLink .. " for " ..  maxbid end
L["Tie! maxplayers please roll on itemLink for maxbid"] = function (maxplayers,itemLink,maxbid) return "Tie! " .. table.concat(maxplayers, ", ") .. " please roll on " .. itemLink .. " for " ..  maxbid end
L["Bidding ends in sec"] = function (s) return "Bidding ends in " .. s end

-- lists

L["Bid bid from players"] = function(bid,players) return "Bid " .. bid .. " from " .. players end
L["Roll roll from players"] = function(roll,players) return "Roll " .. roll .. " from " .. players end

-- whispers

L["You passed on itemLink"] = function (itemLink) return "You passed on " .. itemLink end
L["Received your bid bid for itemLink"] = function (bid, itemLink) return "Received your bid " .. bid .. " for " .. itemLink .. "." end -- Remember you can always pass with -" end
L["Can not accept your bid bid for itemLink"] = function(bid, itemLink) return "Can not accept your bid " .. bid .. " for " .. itemLink end
L["Accepted your bid bid for itemLink"] = function (bid, itemLink) return "Accepted your bid " .. bid .. " for " .. itemLink .. "." end -- Remember you can always pass with -" end
L["You already bid bid for itemLink"] = function (bid, itemLink) return "You already bid " .. bid .. " for " .. itemLink .. "." end -- Remember you can always pass with -" end
L["LOW BID! Your bid of bid for itemLink is NOT current max bid!"] = function (bid, itemLink) return "LOW BID! Your bid of " .. bid .. " for " .. itemLink .. " is NOT current max bid!" end


-- rules

L["Rules:"] = "Rules:"

L["Bidding runs s sec"] = function(s) return "Bidding runs " .. s .. "sec" end
L["Bids extend time by s sec"] = function(s) return "Bids extend time by " .. s .. "sec" end
	
L["Bids accepted"] = "Bids accepted"

L["in Chat or by Whisper to p"] = function(p) return "in Chat or by Whisper to " .. p end
L["only in Chat"] = "only in Chat"
L["only by Whisper to p"] = function(p) return "only by Whisper to " .. p end

L["Single bid per user (no increase)"] = "Single bid per user (no increase)"
L["Full auction, increases allowed"] = "Full auction, increases allowed"

L["Same bids allowed"] = "Same bids allowed"
L["No same bids allowed (first bid counts)"] = "No same bids allowed (first bid counts)"

L["Revoke by - possible"] = "Revoke by - possible"
L["No revocation of bids"] = "No revocation of bids"

L["We are bidding, not rolling. Please state your bid where"] = function(w) return "We are bidding, not rolling. Please state your bid " .. w end

-- end
CheeseSLS.outputLocales["enUS"] = L
