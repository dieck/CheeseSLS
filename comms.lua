local L = LibStub("AceLocale-3.0"):GetLocale("CheeseSLS", true)
local deformat = LibStub("LibDeformat-3.0");

CheeseSLS.SENDTO = "RAID"
-- debug: /script CheeseSLS.SENDTO = "SAY"

CheeseSLS.commPrefix = "CheeseSLS-1.0-"
CheeseSLS.commVersion = 20221103

-- send information to CheeseSLSClient

function CheeseSLS:sendBiddingStart(itemLink)
	local commmsg = { command = "BIDDING_START", version = self.commVersion, itemLink = itemLink,
		acceptraid = self.db.profile.acceptraid,
		acceptwhisper = self.db.profile.acceptwhisper,
		acceptrevoke = self.db.profile.acceptrevoke,
		acceptrolls = self.db.profile.acceptrolls
	}

	local commser = self:Serialize(commmsg)
    self:SendCommMessage(self.commPrefix, commser, self.SENDTO, nil, "ALERT")
end

function CheeseSLS:sendBiddingStop(itemLink)
	local commmsg = { command = "BIDDING_STOP", version = self.commVersion, itemLink = itemLink }
	self:SendCommMessage(self.commPrefix, self:Serialize(commmsg), self.SENDTO, nil, "NORMAL")
end

function CheeseSLS:sendReceivedBid(bidtype)
	local commmsg = { command = "GOT_" .. strupper(bidtype), version = self.commVersion }
	self:SendCommMessage(self.commPrefix, self:Serialize(commmsg), self.SENDTO, nil, "NORMAL")
end

function CheeseSLS:sendWinningNotification(lootTrackerId, winner)
	local commmsg = { command = "WINNING_NOTIFICATION", version = self.commVersion, lootTrackerId = lootTrackerId, winner = winner }
	self:SendCommMessage(self.commPrefix, self:Serialize(commmsg), self.SENDTO, nil, "NORMAL")
end


function CheeseSLS:debugBiddingStart()
    local itemLink = "\124cffff8000\124Hitem:199914::::::::80:::::\124h[Glowing Pebble]\124h\124r"
	self:sendBiddingStart(itemLink)
end

function CheeseSLS:debugBiddingStop()
	local itemLink = "\124cffff8000\124Hitem:199914::::::::80:::::\124h[Glowing Pebble]\124h\124r"
	self:sendBiddingStop(itemLink)
end



