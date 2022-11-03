local L = LibStub("AceLocale-3.0"):GetLocale("CheeseSLS", true)

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
    CheeseSLS:SendCommMessage(CheeseSLS.commPrefix, CheeseSLS:Serialize(commmsg), "RAID", nil, "ALERT")
end

function CheeseSLS:sendBiddingStop(itemLink)
	local commmsg = { command = "BIDDING_STOP", version = CheeseSLS.commVersion, itemLink = itemLink }
	CheeseSLS:SendCommMessage(CheeseSLS.commPrefix, CheeseSLS:Serialize(commmsg), "RAID", nil, "NORMAL")
end


-- send out "new" loot to CheeseSLSClients

function CheeseSLS:sendLootQueued(itemLink)
	local commmsg = { command = "LOOT_QUEUED", version = CheeseSLS.commVersion, itemLink = itemLink }
	CheeseSLS:SendCommMessage(CheeseSLS.commPrefix, CheeseSLS:Serialize(commmsg), "RAID", nil, "BULK")
end

function CheeseSLS:CHAT_MSG_LOOT(event, text, sender)
	-- text - e.g. "You receive loot: |cffffffff|Hitem:2589::::::::20:257::::::|h[Linen Cloth]|h|rx2."

	-- TODO: localization
	beginning = "You receive loot: "
	ending = "."

	if not (text:sub(1, #beginning) == beginning) then return end
	if not (text:sub(-#ending) == ending) then return end

	local itemLink = text:sub((#beginning+1), -(#ending+1))
	
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

