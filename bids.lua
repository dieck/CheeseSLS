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
		if self:CanDoRaidWarning() then
			SendChatMessage(msg, "RAID_WARNING")
		else
			SendChatMessage(msg, "RAID")
		end
	else
		if UnitInParty("player") then
			SendChatMessage(msg, "PARTY")
		else
			self:Print(msg)
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
			self:Print(msg)
		end
	end
end

local function pairsByKeys (t, f)
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
	local o = nil
	if self.db.profile.outputfull_raid then o = function(txt) CheeseSLS:Output(txt) end end
	if self.db.profile.outputfull_user then o = function(txt) CheeseSLS:Print(txt) end end
	if o == nil then return nil end

	if lst == nil then
		lst = self.db.profile.currentbidding.bids
	end

	-- still nil? then there are no current bids. Use last bids
	if lst == nil then
		lst = self.db.profile.lastbidding.bids
	end

	-- really? still nil? ok, so there are no biddings recorded at all. You must be new here.
	if lst == nil then
		-- nothing to output
		return nil
	end

	-- transpose table, split to bids and rolls
	local bidsbybids = {}
	local bidsbyrolls = {}

	for player,bid in pairs(lst) do
		if bid < 0 then
			if bidsbyrolls[-bid] == nil then bidsbyrolls[-bid] = {} end
			table.insert(bidsbyrolls[-bid], player)
		else
			if bidsbybids[bid] == nil then bidsbybids[bid] = {} end
			table.insert(bidsbybids[bid], player)
		end
	end

	for bid,users in pairsByKeys(bidsbybids) do
		local players = table.concat(users, ", ")
		o(L["Bid bid from players"](bid, players))
	end
	for bid,users in pairsByKeys(bidsbyrolls) do
		local players = table.concat(users, ", ")
		o(L["Roll roll from players"](bid, players))
	end
end

function CheeseSLS:StartBidding(itemLink, holdingPlayer, lootTrackerId)

	if self.db.profile.currentbidding.itemLink ~= nil then
		self:Print(L["Bidding for itemLink still running, cannot start new bidding now!"](self.db.profile.currentbidding.itemLink))
		return nil
	end

	-- ensure cached GetItemInfo for gui later
	local d, itemId, enchantId, jewelId1, jewelId2, jewelId3, jewelId4, suffixId, uniqueId, linkLevel, specializationID, reforgeId, unknown1, unknown2 = strsplit(":", itemLink)
	GetItemInfo(itemId)

	local startnotice = L["Start Bidding now: itemLink"](itemLink)

	-- turn on Need and Greed modus of RTC, needed for output validation to book on rolls
	RollTrackerClassic_Addon.DB.NeedAndGreed = true
	-- clear old roll from before the bidding
	RollTrackerClassic_Addon.ClearRolls()

	if UnitInRaid("player") then

		if self:CanDoRaidWarning() then
			SendChatMessage(startnotice, "RAID_WARNING")
		else
			if not self.onetimes["assist"] then
				self:Print(L["You don't have assist, so I cannot put out Raid Warnings"])
				self.onetimes["assist"] = true
			end
			SendChatMessage(startnotice, "RAID")
		end

		SendChatMessage("Say + for main bid (half your DKP) or f for fixed bid (" .. self.db.profile.fixcosts .. "DKP)", "RAID")

	else
		if UnitInParty("player") then
			SendChatMessage(startnotice, "PARTY")
		else
			self:Print(L["You are not in a party or raid. So here we go: Have fun bidding for itemLink against yourself."](itemLink))
		end
	end

	-- send out comms to CheeseSLSClient
	self:sendBiddingStart(itemLink)

	self.db.profile.currentbidding = {}
	self.db.profile.currentbidding["itemLink"] = itemLink
	self.db.profile.currentbidding["holdingPlayer"] = holdingPlayer
	self.db.profile.currentbidding["lootTrackerId"] = lootTrackerId
	self.db.profile.currentbidding["endTime"] = time() + self.db.profile.bidduration

	self.db.profile.currentbidding["bids"] = {}

	self.biddingTimer = self:ScheduleRepeatingTimer("BidTimerHandler", 1)

	return true
end

function CheeseSLS:GetRaiderList(bids)
	local names = {}
	if bids == nil then bids = {} end

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

local function tcopy(src)
	local dest = {}
	for idx, val in pairs(src) do
		if type(val) == "table" then
			dest[idx] = tcopy(val)
		else
			dest[idx] = val
		end
	end
	return dest
end

function CheeseSLS:SecondBidder()
	if self.db.profile.currentbidding.itemLink ~= nil then
		self:Print(L["Bidding for itemLink still running, cannot start new bidding now!"](self.db.profile.currentbidding.itemLink))
		return nil
	end

	if self.db.profile.lastbidding == nil or self.db.profile.lastbidding.itemLink == nil then
		self:Print("No last recorded bidding, cannot get second bidder")
		return nil
	end

	local itemLink = self.db.profile.lastbidding.itemLink

	if itemLink == nil then
		GoogleSheetDKP:Debug("No Itemlink given for requesting last item")
		return nil
	end

	local id = itemLink:match("|Hitem:(%d+):")
	if id then

		local lasthistory =  GoogleSheetDKP:FindLastItem(itemLink)

		if self:tempty(lasthistory) then
			GoogleSheetDKP:Debug("Cannot find last history entry for " .. itemLink)
			return nil
		end

		-- copy table (do not link by pointer only)
		self.db.profile.currentbidding = tcopy(self.db.profile.lastbidding)

		-- remove user who got last loot from bidding
		self.db.profile.currentbidding.bids[lasthistory.name] = nil

		-- no need for a bid timer, that already happened. So just work with the data
		self:BidTimerHandler()

	end

end

function CheeseSLS:BidTimerHandler()

	-- look if timer expired
	if self.db.profile.currentbidding["endTime"] < time() then
		self:Output(L["Bidding ended!"])

		-- send to CheeseSLSClient
		self:sendBiddingStop(self.db.profile.currentbidding.itemLink)

		local bids = self.db.profile.currentbidding.bids

		if self:tempty(bids) then
			self:OutputWithWarning(L["No one bid on itemLink"](self.db.profile.currentbidding.itemLink))
		else

			-- find highest bidder(s)
			local maxbid = 0
			local maxplayers = {}

			-- negative bids: rolls
			local minbid = 0
			local minplayers = {}

			for name,bid in pairs(bids) do
				if bid > maxbid then
					maxplayers = {}
					maxbid = bid
				end
				if bid == maxbid then
					tinsert(maxplayers, name)
				end

				if bid < minbid then
					minplayers = {}
					minbid = bid
				end
				if bid == minbid then
					tinsert(minplayers, name)
				end
			end

			-- show rounding to players (in case of arguments)
			local newmaxrounded = math.floor(maxbid)
			local bidtext = newmaxrounded
			if newmaxrounded ~= maxbid then bidtext = newmaxrounded .. " (" .. maxbid .. ")" end

			if #maxplayers == 1 then
				self:OutputWithWarning(L["Congratulations! maxplayers won itemLink for maxbid"](maxplayers,self.db.profile.currentbidding.itemLink,bidtext))
				for _,name in pairs(maxplayers) do
					-- is only one, but using pairs iterator seems the simpliest approach
					local raiders = self:GetRaiderList(self.db.profile.currentbidding.bids)
					if self.db.profile.currentbidding["holdingPlayer"] then
						SendChatMessage(L["Please collect your item from"](self.db.profile.currentbidding["holdingPlayer"]), "WHISPER", nil, name)
					end
					if self.db.profile.currentbidding["lootTrackerId"] then
						self:sendWinningNotification(self.db.profile.currentbidding["lootTrackerId"], name)
					end
					self:createRequestDialogFrame(name, -newmaxrounded, self.db.profile.currentbidding.itemLink, raiders)
self:Debug("BidTimerHandler maxplayers1 createRequestDialogFrame")
				end
			elseif #maxplayers > 1 then
				self:OutputWithWarning(L["Tie! maxplayers please roll on itemLink for maxbid"](maxplayers,self.db.profile.currentbidding.itemLink,bidtext))
--				self:Print("TODO: I don't handle roll results yet. Use /gsdkp item NAME -" .. newmaxrounded .. " ITEMLINK!")

				-- turn on Need and Greed modus of RTC, needed for output validation to book on rolls
				RollTrackerClassic_Addon.DB.NeedAndGreed = true
				-- clear old roll from before so you only get current rolls for Tie
				RollTrackerClassic_Addon.ClearRolls()

			elseif #minplayers == 1 then
				self:OutputWithWarning(L["Congratulations! maxplayers won itemLink for maxbid"](minplayers,self.db.profile.currentbidding.itemLink,L["Rolls"]))
				for _,name in pairs(minplayers) do
					-- is only one, but using pairs iterator seems the simpliest approach
					if self.db.profile.currentbidding["holdingPlayer"] then
						SendChatMessage(L["Please collect your item from"](self.db.profile.currentbidding["holdingPlayer"]), "WHISPER", nil, name)
					end
					if self.db.profile.currentbidding["lootTrackerId"] then
						self:sendWinningNotification(self.db.profile.currentbidding["lootTrackerId"], name)
					end
					local raiders = self:GetRaiderList(self.db.profile.currentbidding.bids)
					-- requesting storing 0 DKP bid
					self:createRequestDialogFrame(name, 0, self.db.profile.currentbidding.itemLink, raiders)
self:Debug("BidTimerHandler minplayers1 createRequestDialogFrame")
				end

			else -- #minplayers > 1
				self:OutputWithWarning(L["Tie! maxplayers please roll on itemLink for maxbid"](minplayers,self.db.profile.currentbidding.itemLink,L["Rolls"]))
--				self:Print("TODO: I don't handle roll results yet. Use /gsdkp item NAME -" .. newmaxrounded .. " ITEMLINK!")

				-- turn on Need and Greed modus of RTC, needed for output validation to book on rolls
				RollTrackerClassic_Addon.DB.NeedAndGreed = true
				-- clear old roll from before so you only get current rolls for Tie
				RollTrackerClassic_Addon.ClearRolls()

			end

		end

		self.db.profile.lastbidding = self.db.profile.currentbidding

		self:OutputFullList()

		self.db.profile.currentbidding = {}
		self:CancelTimer(self.biddingTimer)
		return nil
	end

	-- if timer didn't expire yet, count down the last seconds
	local rest = self.db.profile.currentbidding["endTime"] - time()

	if rest <= 3 then
		if (rest > 0) then
			self:Output(L["Bidding ends in sec"](rest))
		end
		return nil
	end

end

-- different kinds of incoming messages
function CheeseSLS:CHAT_MSG_WHISPER(event, text, sender)		self:IncomingChat(text, sender, "WHISPER") end
function CheeseSLS:CHAT_MSG_PARTY(event, text, sender)			self:IncomingChat(text, sender, "GRP") end
function CheeseSLS:CHAT_MSG_PARTY_LEADER(event, text, sender)	self:IncomingChat(text, sender, "GRP") end
function CheeseSLS:CHAT_MSG_RAID(event, text, sender)			self:IncomingChat(text, sender, "GRP") end
function CheeseSLS:CHAT_MSG_RAID_LEADER(event, text, sender)	self:IncomingChat(text, sender, "GRP") end
function CheeseSLS:CHAT_MSG_RAID_WARNING(event, text, sender)	self:IncomingChat(text, sender, "GRP") end


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

	if rtcmatch ~= nil then self:Debug("Found RTC match") end

	if rtcmatch ~= nil and self.db.profile.lastbidding ~= nil then

		if self.db.profile.lastbidding["bids"] == nil then
			self:Print("Got roll result, but no biddings were recorded for " .. self.db.profile.lastbidding.itemLink .. " at all")
			return nil
		end

		if self.db.profile.lastbidding.bids[rtcmatch] == nil then
			self:Print("Got winning roll result for " .. rtcmatch .. " but no biddings were recorded for " .. self.db.profile.lastbidding.itemLink)
			return nil
		end

		-- nothing to show to players here, will just book it. Already shown rounding before to players
		local bidorig = self.db.profile.lastbidding.bids[rtcmatch]
		local bidrounded = math.floor(bidorig)

		if self.db.profile.currentbidding["holdingPlayer"] then
			SendChatMessage(L["Please collect your item from"](self.db.profile.currentbidding["holdingPlayer"]), "WHISPER", nil, rtcmatch)
		end
		if self.db.profile.currentbidding["lootTrackerId"] then
			self:sendWinningNotification(self.db.profile.currentbidding["lootTrackerId"], rtcmatch)
		end
		local raiders = self:GetRaiderList(self.db.profile.lastbidding.bids)
		local f = self:createRequestDialogFrame(rtcmatch, -bidrounded, self.db.profile.lastbidding.itemLink, raiders)
		f:Show()
	end


	-- no current bidding
	if self.db.profile.currentbidding.itemLink == nil then return nil end
	-- does not accept whisper => ignore
	if orig == "WHISPER" and not self.db.profile.acceptwhisper then return nil end
	-- does not accept in group notes => ignore
	if orig == "GRP" and not self.db.profile.acceptraid then return nil end

	-- accept revokes
	if text == "-" and self.db.profile.acceptrevoke then
		self.db.profile.currentbidding.bids[sender] = nil
		SendChatMessage(L["You passed on itemLink"](self.db.profile.currentbidding.itemLink), "WHISPER", nil, sender)
		return
	end

	local trimmed = strtrim(text)
	local bid = strlower(trimmed)

	-- accepting: + for main spec, o/O/f/F for off spec/fix bid
	if not (bid == '+' or bid == 'o' or bid == 'f') then
		-- not a bid, ignoring
		return nil
	end

	-- check for accepting change
	if (not self.db.profile.acceptchange) and (self.db.profile.currentbidding.bids[sender]) then
		self:Debug(sender .. " tried to change bid")
		-- if change is not accepted and bid already received, don't do anything
		return nil;
	end


	if self.db.profile.whisperreceived then
		if bid == '+' then
			SendChatMessage(L["Received your bid bid for itemLink"]("Half DKP (main)", self.db.profile.currentbidding.itemLink), "WHISPER", nil, sender)
			self:sendReceivedBid("FULL")
		elseif bid == 'o' or bid == 'f' then
			SendChatMessage(L["Received your bid bid for itemLink"]("Fix costs (off)", self.db.profile.currentbidding.itemLink), "WHISPER", nil, sender)
			self:sendReceivedBid("FIX")
		end
	end

	-- always allow overwriting, but not extend time for that
	local newbid = (not self.db.profile.currentbidding.bids[sender])
	local oldbid = self.db.profile.currentbidding.bids[sender]

	if bid == "+" then
		local currentDKP = tonumber(GoogleSheetDKP:GetDKP(sender))
		if currentDKP == nil then currentDKP = 0 end
		local halfDKP = currentDKP/2 --no math.floor rounding yet, allow for bidding half points => dkp lead wins
		self.db.profile.currentbidding.bids[sender] = halfDKP
		self:sendReceivedBid("FULL")
	end

	if strlower(bid) == "f" or strlower(bid) == "o" then
		local currentDKP = tonumber(GoogleSheetDKP:GetDKP(sender))
		if currentDKP == nil then currentDKP = 0 end
		local bidfix = tonumber(self.db.profile.fixcosts)
		if currentDKP < bidfix then
			bidfix = currentDKP
			local msg = "You don't have enough DKP for Fix Bid. I will bid all remaining DKP."
			if self.db.profile.acceptrevoke then msg = msg .. " If you don't want this, please retract your bid with '-'." end
			SendChatMessage(msg, "WHISPER", nil, sender)
		end
		self.db.profile.currentbidding.bids[sender] = bidfix
		self:sendReceivedBid("FIX")
	end

	if newbid then
		-- this was a new bid
		if self.db.profile.currentbidding["endTime"] < time() + self.db.profile.bidprolong then
			self.db.profile.currentbidding["endTime"] = time() + self.db.profile.bidprolong
		end
	else
		if self.db.profile.currentbidding.bids[sender] ~= oldbid then
			-- bid was changed
			if self.db.profile.currentbidding["endTime"] < time() + self.db.profile.bidprolongchange then
				self.db.profile.currentbidding["endTime"] = time() + self.db.profile.bidprolongchange
			end
		end
	end

end

function CheeseSLS:OutputRules()
	local r = {}

	table.insert(r, L["Bidding runs s sec"](self.db.profile.bidduration))
	if self.db.profile.bidprolong > 0 then table.insert(r, L["Bids extend time by s sec"](self.db.profile.bidprolong)) end

	table.insert(r, L["Bids accepted"] .. " " .. self:GetRulesWhere())
	if self.db.profile.acceptrevoke 	then table.insert(r, L["Revoke by - possible"]) 				else table.insert(r, L["No revocation of bids"]) end

	self:Output(L["Rules:"] .. " " .. table.concat(r, " / "))
end

function CheeseSLS:GetRulesWhere()
	if self.db.profile.acceptraid and self.db.profile.acceptwhisper then
		return L["in Chat or by Whisper to p"](UnitName("player"))
	else
		if self.db.profile.acceptraid then
			return L["only in Chat"]
		end
		if self.db.profile.acceptwhisper then
			return L["only by Whisper to p"](UnitName("player"))
		end
	end
end

function CheeseSLS:CHAT_MSG_SYSTEM (event, text)

	-- don't care for rolls if we are not in active bidding
--		if CheeseSLS.db.profile.currentbidding.itemLink == nil then
--			return nil
--		end

	-- seems there is a problem with the german Umlaut
	if GetLocale() == 'deDE' then RANDOM_ROLL_RESULT = "%s w\195\188rfelt. Ergebnis: %d (%d-%d)" end

	-- replace (, ), - by %(, %), %-
	local pattern = string.gsub(RANDOM_ROLL_RESULT, "[%(%)-]", "%%%1")
	-- enclose first %s in (), matching name
	pattern = string.gsub(pattern, "%%s", "(.+)")
	-- enclose first %d in (), matching roll result
	pattern = string.gsub(pattern, "%%d", "%(%%d+%)")

	local sender,roll,rollmin,rollmax = string.match(text,pattern)

	if not sender then
		-- not a roll, must be some other MSG_SYSTEM notification
		return nil
	end

	if self.db.profile.acceptrolls then

		-- not accepting rolls other then 1-100
		if tonumber(rollmin) ~= 1   then return nil end
		if tonumber(rollmax) ~= 100 then return nil end

		if (not self.db.profile.acceptchange) and (((self.db.profile.currentbidding.bids)) and (self.db.profile.currentbidding.bids[sender])) then
			-- if change is not accepted and bid already received, don't do anything
			self:Debug(sender .. " tried to roll, but has already bid " .. self.db.profile.currentbidding.bids[sender])
			return nil
		end

		-- only note bids if bids are running currently (would trigger on requested rolls for same bid otherwise)
		if (self.db.profile.currentbidding.bids) then
			local oldbits = self.db.profile.currentbidding.bids[sender]

			self.db.profile.currentbidding.bids[sender] = -roll
			self:sendReceivedBid("ROLL")

			if oldbits then
				-- this was a change
				if self.db.profile.currentbidding["endTime"] < time() + self.db.profile.bidprolongchange then
					self.db.profile.currentbidding["endTime"] = time() + self.db.profile.bidprolongchange
				end
			else
				-- this was a new bid
				if self.db.profile.currentbidding["endTime"] < time() + self.db.profile.bidprolong then
					self.db.profile.currentbidding["endTime"] = time() + self.db.profile.bidprolong
				end
			end

		end

	else
		-- not accepting rolls
		if self.db.profile.whispernoroll then
			SendChatMessage(L["We are bidding, not rolling. Please state your bid where"](self:GetRulesWhere()), "WHISPER", nil, sender)
		end
	end

end
