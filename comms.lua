local L = LibStub("AceLocale-3.0"):GetLocale("CheeseSLS", true)
local deformat = LibStub("LibDeformat-3.0");

CheeseSLS.SENDTO = "RAID"

CheeseSLS.commPrefix = "CheeseSLS-1.0-"
CheeseSLS.commVersion = 20221103

-- send information to CheeseSLSClient

function CheeseSLS:sendBiddingStart(itemLink)
	local commmsg = { command = "BIDDING_START", version = CheeseSLS.commVersion, itemLink = itemLink,
		acceptraid = CheeseSLS.db.profile.acceptraid,
		acceptwhisper = CheeseSLS.db.profile.acceptwhisper,
		acceptrevoke = CheeseSLS.db.profile.acceptrevoke,
		acceptrolls = CheeseSLS.db.profile.acceptrolls
	}
	
	commser = CheeseSLS:Serialize(commmsg)
    CheeseSLS:SendCommMessage(CheeseSLS.commPrefix, commser, CheeseSLS.SENDTO, nil, "ALERT")
end

function CheeseSLS:sendBiddingStop(itemLink)
	local commmsg = { command = "BIDDING_STOP", version = CheeseSLS.commVersion, itemLink = itemLink }
	CheeseSLS:SendCommMessage(CheeseSLS.commPrefix, CheeseSLS:Serialize(commmsg), CheeseSLS.SENDTO, nil, "NORMAL")
end

function CheeseSLS:sendReceivedBid(bidtype)
	local commmsg = { command = "GOT_" .. strupper(bidtype), version = CheeseSLS.commVersion }
	CheeseSLS:SendCommMessage(CheeseSLS.commPrefix, CheeseSLS:Serialize(commmsg), CheeseSLS.SENDTO, nil, "NORMAL")
end


function CheeseSLS:debugBiddingStart()
    itemLink = "\124cffff8000\124Hitem:199914::::::::80:::::\124h[Glowing Pebble]\124h\124r"
	CheeseSLS:sendBiddingStart(itemLink)	
end

function CheeseSLS:debugBiddingStop()
   itemLink = "\124cffff8000\124Hitem:199914::::::::80:::::\124h[Glowing Pebble]\124h\124r"
	CheeseSLS:sendBiddingStop(itemLink)	
end


-- send out "new" loot to CheeseSLSClients

function CheeseSLS:sendLootQueued(itemLink)
	local commmsg = { command = "LOOT_QUEUED", version = CheeseSLS.commVersion, itemLink = itemLink, queueTime = time() }
	CheeseSLS:Print(CheeseSLS:Serialize(commmsg))
	CheeseSLS:SendCommMessage(CheeseSLS.commPrefix, CheeseSLS:Serialize(commmsg), CheeseSLS.SENDTO, nil, "BULK")
end

-- to ignore trade windows, which also give the EXACT SAME CHAT_MSG_LOOT. WTF Blizzard.

function CheeseSLS:TRADE_SHOW()
	CheeseSLS.tradeWindow = true
end

function CheeseSLS:TRADE_CLOSED()
	-- give CHAT_MSG_LOOT about 1 second to catch up before assuming it's not a trade anymore
	CheeseSLS:ScheduleTimer(function() CheeseSLS.tradeWindow = false end, 1)
end


function CheeseSLS:CHAT_MSG_LOOT(event, text, sender)
	-- ignore trade window loot
	if CheeseSLS.tradeWindow then return end

	-- validation code from MizusRaidTracker, under GPL 3.0, Author Mîzukichan@EU-Antonidas
	
	-- patterns LOOT_ITEM / LOOT_ITEM_SELF are also valid for LOOT_ITEM_MULTIPLE / LOOT_ITEM_SELF_MULTIPLE - but not the other way around - try these first
	-- first try: somebody else received multiple loot (most parameters)
	local playerName, itemLink, itemCount = deformat(text, LOOT_ITEM_MULTIPLE)
	
	-- next try: somebody else received single loot
	if (playerName == nil) then
		itemCount = 1
		playerName, itemLink = deformat(text, LOOT_ITEM)
	end
	
	-- if player == nil, then next try: player received multiple loot
	if (playerName == nil) then
		playerName = UnitName("player")
		itemLink, itemCount = deformat(text, LOOT_ITEM_SELF_MULTIPLE)
	end
	
	-- if itemLink == nil, then last try: player received single loot
	if (itemLink == nil) then
		itemCount = 1
		itemLink = deformat(text, LOOT_ITEM_SELF)
	end

	-- if itemLink == nil, then there was neither a LOOT_ITEM, nor a LOOT_ITEM_SELF message
	if (itemLink == nil) then 
		-- No valid loot event received.
		return
	end

	local d, itemId, enchantId, jewelId1, jewelId2, jewelId3, jewelId4, suffixId, uniqueId, linkLevel, specializationID, reforgeId, unknown1, unknown2 = strsplit(":", itemLink)

    -- check for disenchant mats
	local i = tonumber(itemId)
	if i == 20725 or i == 14344 -- Nexus Crystal / Large Briliant Shard
	or i == 22450 or i == 22449 -- Void Crystal / Large Prismatic Shard
	or i == 34057 or i == 34052 -- Abyss Crystal / Dream Shard
	then
		-- ignore
		return
	end

	-- colors: 
	-- if d == "\124cffff8000\124Hitem" then CheeseSLS:Print("LEGENDARY") end -- LEGENDARY
	-- if d == "\124cffa335ee\124Hitem" then CheeseSLS:Print("Epic") end -- Epic
	-- if d == "\124cff0070dd\124Hitem" then CheeseSLS:Print("Rare") end -- Rare
	-- if d == "\124cff1eff00\124Hitem" then CheeseSLS:Print("Uncommon") end -- Uncommon
	-- if d == "\124cffffffff\124Hitem" then CheeseSLS:Print("Common") end -- Common
	-- if d == "\124cff9d9d9d\124Hitem" then CheeseSLS:Print("Trash") end -- Greys
	
	if (d == "\124cffff8000\124Hitem") or (d == "\124cffa335ee\124Hitem") then
		CheeseSLS:sendLootQueued(itemLink)
	end

end

