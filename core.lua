local L = LibStub("AceLocale-3.0"):GetLocale("CheeseSLS", true)

local defaults = {
  profile = {
    debug = false,
	handle_bid = false,
	handle_sls = false,
	bidduration = 15,
	bidprolong = 5,
	bidprolongchange = 5,
	acceptraid = true,
	acceptwhisper = true,
	acceptrevoke = true,
	acceptrolls = false,
	showcountdown = true,
	whisperreceived = true,
	whispernoroll = true,
	outputfull_raid = false,
	outputfull_user = true,
	outputlanguage = GetLocale(),
	fixcosts = 10,
  }
}

CheeseSLS.optionsTable = {
  type = "group",
  args = {
	txttime = { type = "header", name = L["Timings"], order = 100},
	
	duration = {
		name = L["Bid duration"],
		desc = L["Initial time for a bid"],
		type = "range",
		min = 0,
		softMax = 60,
		step = 1,
		order = 110,
		set = function(info,val) CheeseSLS.db.profile.bidduration = val end,
		get = function(info) return CheeseSLS.db.profile.bidduration end,
	},
	newline111 = { name="", type="description", order=111 },

	prolong = {
		name = L["Bids prolong on new"],
		desc = L["If a new bid came in, prolong time to end if necessary"],
		type = "range",
		min = 0,
		softMax = 30,
		step = 1,
		order = 120,
		set = function(info,val) CheeseSLS.db.profile.bidprolong = val end,
		get = function(info) return CheeseSLS.db.profile.bidprolong end,
	},
    prolongchange = {
		name = L["Bids prolong on change"],
		desc = L["If a bid was changed, prolong time to end if necessary"],
		type = "range",
		min = 0,
		softMax = 30,
		step = 1,
		order = 121,
		set = function(info,val) CheeseSLS.db.profile.bidprolongchange = val end,
		get = function(info) return CheeseSLS.db.profile.bidprolongchange end,
	},
	newline122 = { name="", type="description", order=122 },

	
	txtaccepts = { type = "header", name = L["Accept bids"], order = 200 },

	fcost = {
		name = "Fix cost",
		desc = "Cost for fix bids",
		type = "input",
		order = 201,
		validate = function(i,v) if tonumber(v) == nil then return "Enter a number" elseif tonumber(v) <=0 then return "Enter a positive number" else return true end end,
		set = function(info,val) CheeseSLS.db.profile.fixcosts = val end,
		get = function(info) return CheeseSLS.db.profile.fixcosts end,
	},
	newline202 = { name="", type="description", order=202 },

	
	bidraid = {
		name = L["Raid"],
		desc = L["Accept bidding in party/raidchat"],
		type = "toggle",
		order = 210,
		set = function(info,val)
			CheeseSLS.db.profile.acceptraid = val 
			if not CheeseSLS.db.profile.acceptraid then CheeseSLS.db.profile.acceptwhisper = true end
		end,
		get = function(info) return CheeseSLS.db.profile.acceptraid end,
	},
	newline211 = { name="", type="description", order=211 },

	bidwhisper = {
		name = L["Whisper"],
		desc = L["Accept bidding by whisper"],
		type = "toggle",
		order = 220,
		set = function(info,val)
			CheeseSLS.db.profile.acceptwhisper = val
			if not CheeseSLS.db.profile.acceptwhisper then CheeseSLS.db.profile.acceptraid = true end
		end,
		get = function(info) return CheeseSLS.db.profile.acceptwhisper end,
	},
	newline221 = { name="", type="description", order=221 },

	bidrolls = {
		name = L["Rolls"],
		desc = L["Accept bidding by rolls"],
		type = "toggle",
		order = 230,
		set = function(info,val)
			CheeseSLS.db.profile.acceptrolls = val
			if CheeseSLS.db.profile.whispernoroll then CheeseSLS.db.profile.whispernoroll = false end
		end,
		get = function(info) return CheeseSLS.db.profile.acceptrolls end,
	},
	newline231 = { name="", type="description", order=231 },


	revoke = {
		name = L["Revoke bid"],
		desc = L["Allows users to revoke bid"],
		type = "toggle",
		order = 250,
		set = function(info,val) CheeseSLS.db.profile.acceptrevoke = val end,
		get = function(info) return CheeseSLS.db.profile.acceptrevoke end,
	},
	change = {
		name = L["Change bid"],
		desc = L["Allows users to change bid"],
		type = "toggle",
		order = 251,
		set = function(info,val) CheeseSLS.db.profile.acceptchange = val end,
		get = function(info) return CheeseSLS.db.profile.acceptchange end,
	},
	newline252 = { name="", type="description", order=252 },

	txtoutput = { type = "header", name = L["Raid announces"], order = 300 },
	
	countdown = {
		name = L["Countdown"],
		desc = L["Give Countdown in raid/party chat"],
		type = "toggle",
		order = 310,
		set = function(info,val) CheeseSLS.db.profile.showcountdown = val end,
		get = function(info) return CheeseSLS.db.profile.showcountdown end,
	},
	newline311 = { name="", type="description", order=311 },
	
	outputfullraid = {
		name = L["List to Raid"],
		desc = L["Outputs full list to raid/party on finish (disables output to user)"],
		type = "toggle",
		order = 330,
		set = function(info,val)
			CheeseSLS.db.profile.outputfull_raid = val 
			if CheeseSLS.db.profile.outputfull_raid then CheeseSLS.db.profile.outputfull_user = false end
		end,
		get = function(info) return CheeseSLS.db.profile.outputfull_raid end,
	},
	newline331 = { name="", type="description", order=331 },
	
	txtwhispers = { type = "header", name = "Whisper announces", order = 400 },

	received = {
		name = L["Received"],
		desc = L["Whisper to player if bid was received"],
		type = "toggle",
		order = 410,
		set = function(info,val) CheeseSLS.db.profile.whisperreceived = val end,
		get = function(info) return CheeseSLS.db.profile.whisperreceived end,
	},
	newline411 = { name="", type="description", order=411 },

	norolls = {
		name = L["No rolls"],
		desc = L["Tells the player to bid if he rolls during bidding"],
		type = "toggle",
		order = 450,
		set = function(info,val)
			CheeseSLS.db.profile.whispernoroll = val
			if CheeseSLS.db.profile.acceptrolls then CheeseSLS.db.profile.acceptrolls = false end
		end,
		get = function(info) return CheeseSLS.db.profile.whispernoroll end,
	},
	newline451 = { name="", type="description", order=451 },

	txtdebug = { type = "header", name = L["Miscellaneous"], order = 900 },
	
    bidhandler = {
      name = "/bid",
	  desc = L["Enable additional usage of /bid"],
      type = "toggle",
      order = 910,
      set = function(info,val)
		CheeseSLS.db.profile.handle_bid = val 
		if CheeseSLS.db.profile.handle_bid then
			CheeseSLS:RegisterChatCommand('bid', 'ChatCommand');
		else
			CheeseSLS:UnregisterChatCommand('bid');
		end

	  end,
      get = function(info) return CheeseSLS.db.profile.handle_bid end,
    },
	newline911 = { name="", type="description", order=911 },

    slshandler = {
      name = "/sls",
	  desc = L["Enable additional usage of /sls"],
      type = "toggle",
      order = 920,
      set = function(info,val)
		CheeseSLS.db.profile.handle_sls = val 
		if CheeseSLS.db.profile.handle_sls then
			CheeseSLS:RegisterChatCommand('sls', 'ChatCommand');
		else
			CheeseSLS:UnregisterChatCommand('sls');
		end

	  end,
      get = function(info) return CheeseSLS.db.profile.handle_sls end,
    },
	newline921 = { name="", type="description", order=921 },

	outputfulluser = {
		name = L["List to you"],
		desc = L["Outputs full list to you on finish (disables output to raid/party)"],
		type = "toggle",
		order = 930,
		set = function(info,val)
			CheeseSLS.db.profile.outputfull_user = val 
			if CheeseSLS.db.profile.outputfull_user then CheeseSLS.db.profile.outputfull_raid = false end
		end,
		get = function(info) return CheeseSLS.db.profile.outputfull_user end,
	},
	newline931 = { name="", type="description", order=931 },


	outputlanguage = {
		name = L["Language"],
		desc = L["Language for outputs"],
		type = "select",
		order = 940,
		values = function()
			r = {}
			for k,v in pairs(CheeseSLS.outputLocales) do r[k] = k end
			return r
		end,
		set = function(info,val)
			CheeseSLS.db.profile.outputlanguage = val 
			for k,v in pairs(CheeseSLS.outputLocales[val]) do L[k] = v end
		end,
		get = function(info) return CheeseSLS.db.profile.outputlanguage end,
	},
	newline941 = { name="", type="description", order=941 },

    debugging = {
      name = L["Debug"],
      type = "toggle",
      order = 990,
      set = function(info,val) CheeseSLS.db.profile.debug = val end,
      get = function(info) return CheeseSLS.db.profile.debug end,
    },
	newline991 = { name="", type="description", order=991 },

  }
}

function CheeseSLS:OnInitialize()
  -- Code that you want to run when the addon is first loaded goes here.
  self.db = LibStub("AceDB-3.0"):New("CheeseSLSDB", defaults)

  LibStub("AceConfig-3.0"):RegisterOptionsTable("CheeseSLS", self.optionsTable)
  self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CheeseSLS", "CheeseSLS")
  
  -- interaction from raid members
  self:RegisterEvent("CHAT_MSG_WHISPER")
  self:RegisterEvent("CHAT_MSG_PARTY")
  self:RegisterEvent("CHAT_MSG_PARTY_LEADER")
  self:RegisterEvent("CHAT_MSG_RAID")
  self:RegisterEvent("CHAT_MSG_RAID_LEADER")
  self:RegisterEvent("CHAT_MSG_RAID_WARNING")
  self:RegisterEvent("CHAT_MSG_SYSTEM")
 
  self:RegisterChatCommand("csls", "ChatCommand")
  
  if self.db.profile.handle_bid then
	self:RegisterChatCommand("bid", "ChatCommand");
  end

  if self.db.profile.handle_sls then
	self:RegisterChatCommand("sls", "ChatCommand");
  end
  
  self.onetimes = {}
  
  -- resetting possible old rolls
  self.db.profile.currentbidding = {}
  

  -- change default output language if configured
  if CheeseSLS.outputLocales[CheeseSLS.db.profile.outputlanguage] ~= nil then
	for k,v in pairs(CheeseSLS.outputLocales[CheeseSLS.db.profile.outputlanguage]) do L[k] = v end
  end
  
end

function CheeseSLS:OnEnable()
    -- Called when the addon is enabled
end

function CheeseSLS:OnDisable()
    -- Called when the addon is disabled
end

function strlt(s)
	return strlower(strtrim(s))
end

function CheeseSLS:ChatCommand(inc)

	if strlt(inc) == "" then
		CheeseSLS:Print(L["Usage: |cFF00CCFF/csls |cFFA335EE[Sword of a Thousand Truths]|r to start a bid"])
		CheeseSLS:Print(L["Usage: |cFF00CCFF/csls config|r to open the configuration window"])
		return nil
	end

	if strlt(inc) == "config" then
		LibStub("AceConfigDialog-3.0"):Open("CheeseSLS")
		return nil
	end

	if strlt(inc) == "rules" then
		CheeseSLS:OutputRules()
		return nil
	end

	if strlt(inc) == "current" or strlt(inc) == "bids" or strlt(inc) == "list" then
		CheeseSLS:OutputFullList(CheeseSLS.db.profile.currentbidding.bids)
		return nil
	end

	if strlt(inc) == "second" or strlt(inc) == "again" then
		CheeseSLS:SecondBidder()
		return nil
	end

	if strlt(inc) == "last" then
		CheeseSLS:OutputFullList(CheeseSLS.db.profile.lastbidding.bids)
		return nil
	end

	-- forward to GoogleSheetDKP
	-- needs to be done before itemLink check below, because gsdkp command "item User -DKP itemlink" would trigger on split below
	local gsret = GoogleSheetDKP:ChatCommand(inc)
	if gsret then return true end

	-- look if we do manual assignment
	-- e.g. "/csls + playername [Sword of a Thousand Truths]" 
	-- or "/csls f playername [Sword of a Thousand Truths]" 
	local cmd,user,item = strsplit(" ", inc, 3)

	if (strlt(cmd) == "+") and (user) and (item) then
		local currentDKP = tonumber(GoogleSheetDKP:GetDKP(user))
		if currentDKP == nil then currentDKP = 0 end
		local halfDKP = math.floor(currentDKP/2)
		local raiders = CheeseSLS:GetRaiderList(CheeseSLS.db.profile.currentbidding.bids)
		local f = CheeseSLS:createRequestDialogFrame(name, -halfDKP, item, raiders)
		f:Show()
		return true
	end
	
	if (strlt(cmd) == "f") and (user) and (item) then
		local currentDKP = tonumber(GoogleSheetDKP:GetDKP(user))
		if currentDKP == nil then currentDKP = 0 end
		bidfix = tonumber(CheeseSLS.db.profile.fixcosts)
		if currentDKP < bidfix then 
			bidfix = currentDKP
			local msg = user .. " does not have enough DKP for Fix Bid. I will bid all remaining DKP."
			CheeseSLS:Print(msg)
		end
		local raiders = CheeseSLS:GetRaiderList(CheeseSLS.db.profile.currentbidding.bids)
		local f = CheeseSLS:createRequestDialogFrame(name, -bidfix, item, raiders)
		f:Show()
		return true
	end

	-- if inc is itemLink: start bidding
	local d, itemId, enchantId, jewelId1, jewelId2, jewelId3, jewelId4, suffixId, uniqueId, linkLevel, specializationID, reforgeId, unknown1, unknown2 = strsplit(":", inc)		
	if itemId then
		CheeseSLS:StartBidding(inc)
		return nil
	end
	
end


function CheeseSLS:Debug(t) 
	if (CheeseSLS.db.profile.debug) then
		CheeseSLS:Print("CheeseSLS DEBUG: " .. t)
	end
end


-- for debug outputs
function tprint (tbl, indent)
  if not indent then indent = 0 end
  local toprint = string.rep(" ", indent) .. "{\r\n"
  indent = indent + 2 
  for k, v in pairs(tbl) do
    toprint = toprint .. string.rep(" ", indent)
    if (type(k) == "number") then
      toprint = toprint .. "[" .. k .. "] = "
    elseif (type(k) == "string") then
      toprint = toprint  .. k ..  "= "   
    end
    if (type(v) == "number") then
      toprint = toprint .. v .. ",\r\n"
    elseif (type(v) == "string") then
      toprint = toprint .. "\"" .. v .. "\",\r\n"
    elseif (type(v) == "table") then
      toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
    else
      toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
    end
  end
  toprint = toprint .. string.rep(" ", indent-2) .. "}"
  return toprint
end

function tsize(t)
	if t == nil then return nil end
	if not type(elem) == "table" then return nil end
	s = 0
	for _,_ in pairs(t) do s = s + 1 end
	return s
end

function tempty(t)
	s = tsize(t)
	if s == nil then return true end
	return (s == 0)
end