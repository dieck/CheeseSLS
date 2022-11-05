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



