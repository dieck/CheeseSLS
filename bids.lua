local L = LibStub("AceLocale-3.0"):GetLocale("CheeseSLS", true)

-- Output to Raid chat, Party chat or chat window
function CheeseSLS:CanDoRaidWarning() 
	for i = 1, MAX_RAID_MEMBERS do
		local name, rank = GetRaidRosterInfo(i)
		if name == UnitName("player") then
			return (rank >= 1)
		end
	end
	return false
end

function CheeseSLS:OutputWithWarning(msg)
	if UnitInRaid("player") then
		if CheeseSLS:CanDoRaidWarning() then
			SendChatMessage(msg, "RAID_WARNING")
		else
			SendChatMessage(msg, "RAID")
		end
	else
		if UnitInParty("player") then
			SendChatMessage(msg, "PARTY")
		else
			CheeseSLS:Print(msg)
		end
	end
end

function CheeseSLS:Output(msg)
	if UnitInRaid("player") then
		SendChatMessage(msg, "RAID")
	else
		if UnitInParty("player") then
			SendChatMessage(msg, "PARTY")
		else
			CheeseSLS:Print(msg)
		end
	end
end

function pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
     end
     return iter
end

function CheeseSLS:OutputFullList(lst)
	o = nil
	if CheeseSLS.db.profile.outputfull_raid then o = function(txt) CheeseSLS:Output(txt) end end
	if CheeseSLS.db.profile.outputfull_user then o = function(txt) CheeseSLS:Print(txt) end end
	if o == nil then return nil end

	if lst == nil then 
		lst = CheeseSLS.db.profile.currentbidding.bids
	end

	-- still nil? then there are no current bids. Use last bids
	if lst == nil then
		lst = CheeseSLS.db.profile.lastbidding.bids
	end

	-- really? still nil? ok, so there are no biddings recorded at all. You must be new here.
	if lst == nil then
		-- nothing to output
		return nil
	end


	-- transpose table
	bidsbybids = {}
	for player,bid in pairs(lst) do
		if bidsbybids[bid] == nil then bidsbybids[bid] = {} end
		table.insert(bidsbybids[bid], player)
	end

	for bid,users in pairsByKeys(bidsbybids) do
		players = table.concat(users, ", ")
		o(L["Bid bid from players"](bid, players))
	end
end

function CheeseSLS:StartBidding(itemLink)

	if not (CheeseSLS.db.profile.currentbidding.itemLink == nil) then
		CheeseSLS:Print(L["Bidding for itemLink still running, cannot start new bidding now!"](CheeseSLS.db.profile.currentbidding.itemLink))
		return nil
	end
	
	-- ensure cached GetItemInfo for gui later
	local d, itemId, enchantId, jewelId1, jewelId2, jewelId3, jewelId4, suffixId, uniqueId, linkLevel, specializationID, reforgeId, unknown1, unknown2 = strsplit(":", itemLink)	
	GetItemInfo(itemId)
	
	startnotice = L["Start Bidding now: itemLink"](itemLink)
	
	if UnitInRaid("player") then
	
		if CheeseSLS:CanDoRaidWarning() then
			SendChatMessage(startnotice, "RAID_WARNING")
		else
			if not CheeseSLS.onetimes["assist"] then
				CheeseSLS:Print(L["You don't have assist, so I cannot put out Raid Warnings"])
				CheeseSLS.onetimes["assist"] = true
			end
			SendChatMessage(startnotice, "RAID")
		end

		SendChatMessage("Say + for main bid (half your DKP) or f for fixed bid (" .. CheeseSLS.db.profile.fixcosts .. "DKP)", "RAID")

	else
		if UnitInParty("player") then
			SendChatMessage(startnotice, "PARTY")
		else
			CheeseSLS:Print(L["You are not in a party or raid. So here we go: Have fun bidding for itemLink against yourself."](itemLink))
		end
	end
	
	CheeseSLS.db.profile.currentbidding = {}
	CheeseSLS.db.profile.currentbidding["itemLink"] = itemLink
	CheeseSLS.db.profile.currentbidding["endTime"] = time() + CheeseSLS.db.profile.bidduration
	
	CheeseSLS.db.profile.currentbidding["bids"] = {}
	
	CheeseSLS.biddingTimer = CheeseSLS:ScheduleRepeatingTimer("BidTimerHandler", 1)
	
end

function CheeseSLS:GetRaiderList(bids)
	local names = {}

	if GetNumGroupMembers() == 0 then 
		names[UnitName("player")] = UnitName("player")
		return names 
	end

	for i = 1, GetNumGroupMembers() do
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
	
		local dkp = GoogleSheetDKP:GetDKP(name)
		if dkp == nil then dkp = 0 end

		names[name] = name .. " (" .. dkp .. " DKP)"
					
		if bids[name] ~= nil then
			names[name] = names[name] .. " [Bid: " .. bids[name] .. "]"
		end
		
	end

	return names
end

function CheeseSLS:BidTimerHandler()
	
	-- look if timer expired
	if CheeseSLS.db.profile.currentbidding["endTime"] < time() then
		CheeseSLS:Output(L["Bidding ended!"])

		bids = CheeseSLS.db.profile.currentbidding.bids

		if tempty(bids) then
			CheeseSLS:OutputWithWarning(L["No one bid on itemLink"](CheeseSLS.db.profile.currentbidding.itemLink))
		else
	
			-- find highest bidder(s)
			local maxbid = -1
			local maxplayers = {}
			
			for name,bid in pairs(bids) do 
				if bid > maxbid then 
					maxplayers = {}
					maxbid = bid
				end
				if bid == maxbid then
					tinsert(maxplayers, name)
				end
			end

			-- show rounding to players (in case of arguments)
			newmaxrounded = math.floor(maxbid)
			bidtext = newmaxrounded
			if newmaxrounded ~= maxbid then bidtext = newmaxrounded .. " (" .. maxbid .. ")" end


			if #maxplayers == 1 then
				CheeseSLS:OutputWithWarning(L["Congratulations! maxplayers won itemLink for maxbid"](maxplayers,CheeseSLS.db.profile.currentbidding.itemLink,bidtext))
				for _,name in pairs(maxplayers) do
					-- is only one, but using pairs iterator seems the simpliest approach
					local raiders = CheeseSLS:GetRaiderList(CheeseSLS.db.profile.currentbidding.bids)
					local f = CheeseSLS:createRequestDialogFrame(name, -newmaxrounded, CheeseSLS.db.profile.currentbidding.itemLink, raiders)
					f:Show()
				end
			else

				CheeseSLS:OutputWithWarning(L["Tie! maxplayers please roll on itemLink for maxbid"](maxplayers,CheeseSLS.db.profile.currentbidding.itemLink,bidtext))
				CheeseSLS:Print("TODO: I don't handle roll results yet. Use /gsdkp item NAME -" .. newmaxrounded .. " ITEMLINK!")
			end
			
		end
		
		CheeseSLS.db.profile.lastbidding = CheeseSLS.db.profile.currentbidding
		
		CheeseSLS:OutputFullList()
		
		CheeseSLS.db.profile.currentbidding = {}
		CheeseSLS:CancelTimer(CheeseSLS.biddingTimer)
		return nil
	end
	
	-- if timer didn't expire yet, count down the last seconds
	rest = CheeseSLS.db.profile.currentbidding["endTime"] - time() 

	if rest <= 3 then
		if (rest > 0) then
			CheeseSLS:Output(L["Bidding ends in sec"](rest))
		end
		return nil
	end
	
end

-- different kinds of incoming messages
function CheeseSLS:CHAT_MSG_WHISPER(event, text, sender)		CheeseSLS:IncomingChat(text, sender, "WHISPER") end
function CheeseSLS:CHAT_MSG_PARTY(event, text, sender)			CheeseSLS:IncomingChat(text, sender, "GRP") end
function CheeseSLS:CHAT_MSG_PARTY_LEADER(event, text, sender)	CheeseSLS:IncomingChat(text, sender, "GRP") end
function CheeseSLS:CHAT_MSG_RAID(event, text, sender)			CheeseSLS:IncomingChat(text, sender, "GRP") end
function CheeseSLS:CHAT_MSG_RAID_LEADER(event, text, sender)	CheeseSLS:IncomingChat(text, sender, "GRP") end
function CheeseSLS:CHAT_MSG_RAID_WARNING(event, text, sender)	CheeseSLS:IncomingChat(text, sender, "GRP") end


function CheeseSLS:IncomingChat(text, sender, orig)

	-- playerName may contain "-REALM"
	sender = strsplit("-", sender)
	
	-- manage roll tracker outputs
	local rtcrgxp = RollTrackerClassic_Addon.GetLocale()["MsgAnnounce"] -- "%s won with a roll of %d."
	rtcrgxp = string.gsub(rtcrgxp, "%%s", "(%%w+)")
	rtcrgxp = string.gsub(rtcrgxp, "%%d", "%%d+")
	rtcrgxp = "RTC: %w+! " .. rtcrgxp -- "RTC: %w+! (%w+) won with a roll of %d+."
	
	-- RTC: Need! Pfennich won with a roll of 99.
	local rtcmatch = string.match(text, rtcrgxp)	
	
	if rtcmatch ~= nil then CheeseSLS:Debug("Found RTC match") end
	
	if rtcmatch ~= nil and CheeseSLS.db.profile.lastbidding ~= nil then
	
		if CheeseSLS.db.profile.lastbidding["bids"] == nil then
			CheeseSLS:Print("Got roll result, but no biddings were recorded for " .. CheeseSLS.db.profile.lastbidding.itemLink .. " at all")
			return nil
		end

		if CheeseSLS.db.profile.lastbidding.bids[rtcmatch] == nil then
			CheeseSLS:Print("Got winning roll result for " .. rtcmatch .. " but no biddings were recorded for " .. CheeseSLS.db.profile.lastbidding.itemLink)
			return nil
		end
		
		-- show rounding to players (in case of arguments)
		bidorig = CheeseSLS.db.profile.lastbidding.bids[rtcmatch]
		bidrounded = math.floor(bidorig)
		bidtext = bidrounded
		if bidrounded ~= bidorig then bidtext = bidrounded .. " (" .. bidorig .. ")" end
		local raiders = CheeseSLS:GetRaiderList(CheeseSLS.db.profile.lastbidding.bids)
		local f = CheeseSLS:createRequestDialogFrame(rtcmatch, -bidrounded, CheeseSLS.db.profile.lastbidding.itemLink, raiders)
	end


	-- no current bidding
	if CheeseSLS.db.profile.currentbidding.itemLink == nil then return nil end
	-- does not accept whisper => ignore
	if orig == "WHISPER" and not CheeseSLS.db.profile.acceptwhisper then return nil end
	-- does not accept in group notes => ignore
	if orig == "GRP" and not CheeseSLS.db.profile.acceptraid then return nil end
	
	-- accept revokes
	if text == "-" and CheeseSLS.db.profile.acceptrevoke then
		CheeseSLS.db.profile.currentbidding.bids[sender] = nil 
		SendChatMessage(L["You passed on itemLink"](CheeseSLS.db.profile.currentbidding.itemLink), "WHISPER", nil, sender)
		return
	end
	
	trimmed = strtrim(text)
	bid = strlower(trimmed)
	
	-- accepting: + for main spec, o/O/f/F for off spec/fix bid
	if not (bid == '+' or bid == 'o' or bid == 'f') then
		-- not a bid, ignoring
		return nil
	end
	
	if CheeseSLS.db.profile.whisperreceived then
		if bid == '+' then
			SendChatMessage(L["Received your bid bid for itemLink"]("Half DKP (main)", CheeseSLS.db.profile.currentbidding.itemLink), "WHISPER", nil, sender)
		elseif bid == 'o' or bid == 'f' then
			SendChatMessage(L["Received your bid bid for itemLink"]("Fix costs (off)", CheeseSLS.db.profile.currentbidding.itemLink), "WHISPER", nil, sender)
		end
	end

	-- always allow overwriting, but not extend time for that
	local newbid = (not CheeseSLS.db.profile.currentbidding.bids[sender])
	
	if bid == "+" then
		local currentDKP = tonumber(GoogleSheetDKP:GetDKP(sender))
		if currentDKP == nil then currentDKP = 0 end
		local halfDKP = currentDKP/2 --no math.floor rounding yet, allow for bidding half points => dkp lead wins
		CheeseSLS.db.profile.currentbidding.bids[sender] = halfDKP
	end
	
	if strlower(bid) == "f" or strlower(bid) == "o" then
		local currentDKP = tonumber(GoogleSheetDKP:GetDKP(sender))
		if currentDKP == nil then currentDKP = 0 end
		bidfix = tonumber(CheeseSLS.db.profile.fixcosts)
		if currentDKP < bidfix then 
			bidfix = currentDKP
			local msg = "You don't have enough DKP for Fix Bid. I will bid all remaining DKP."
			if CheeseSLS.db.profile.acceptrevoke then msg = msg .. " If you don't want this, please retract your bid with '-'." end
			SendChatMessage(msg, "WHISPER", nil, sender)
		end
		CheeseSLS.db.profile.currentbidding.bids[sender] = bidfix
	end
	
	if newbid then
		-- prolong time
		if CheeseSLS.db.profile.currentbidding["endTime"] < time() + CheeseSLS.db.profile.bidprolong then
			CheeseSLS.db.profile.currentbidding["endTime"] = time() + CheeseSLS.db.profile.bidprolong
		end
	end

end

function CheeseSLS:OutputRules()
	r = {}
	
	table.insert(r, L["Bidding runs s sec"](CheeseSLS.db.profile.bidduration))
	if CheeseSLS.db.profile.bidprolong > 0 then table.insert(r, L["Bids extend time by s sec"](CheeseSLS.db.profile.bidprolong)) end
	
	table.insert(r, L["Bids accepted"] .. " " .. CheeseSLS:GetRulesWhere())
	if CheeseSLS.db.profile.acceptrevoke 	then table.insert(r, L["Revoke by - possible"]) 				else table.insert(r, L["No revocation of bids"]) end

	CheeseSLS:Output(L["Rules:"] .. " " .. table.concat(r, " / "))
end

function CheeseSLS:GetRulesWhere()
	if CheeseSLS.db.profile.acceptraid and CheeseSLS.db.profile.acceptwhisper then
		return L["in Chat or by Whisper to p"](UnitName("player"))
	else 
		if CheeseSLS.db.profile.acceptraid then 
			return L["only in Chat"]
		end
		if CheeseSLS.db.profile.acceptwhisper then 
			return L["only by Whisper to p"](UnitName("player"))
		end
	end	
end

function CheeseSLS:CHAT_MSG_SYSTEM (event, text )
	if CheeseSLS.db.profile.whispernoroll then 
		-- seems there is a problem with the german Umlaut
		if GetLocale() == 'deDE' then RANDOM_ROLL_RESULT = "%s w\195\188rfelt. Ergebnis: %d (%d-%d)" end
		local pattern = RANDOM_ROLL_RESULT:gsub( "%%s", "(.+)" ):gsub( "%%d %(%%d%-%%d%)", ".*" )
		local sender = text:match(pattern)
		
		if sender and not (CheeseSLS.db.profile.currentbidding.itemLink == nil) then
			SendChatMessage(L["We are bidding, not rolling. Please state your bid where"](CheeseSLS:GetRulesWhere()), "WHISPER", nil, sender)
		end
	end
end
