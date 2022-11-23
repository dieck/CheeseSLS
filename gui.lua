local L = LibStub("AceLocale-3.0"):GetLocale("CheeseSLS", true)

function CheeseSLS:createRequestDialogFrame(user, dkp, itemlink, raiderlist)
	local AceGUI = LibStub("AceGUI-3.0")

	local frameId = "CheeseSLSRDFrame" .. tostring(time())

	local f = AceGUI:Create("Window")
	f:SetTitle("CheeseSLS DKP charge")
	f:SetStatusText("")
	f:SetLayout("Flow")
	f:SetWidth(350)
	f:SetHeight(165)
	f:SetCallback("OnClose",function(widget) AceGUI:Release(widget) end)

	_G[frameId] = f.frame
	self.frames[frameId] = f
	-- ESC not registered, we don't want to accidentally close

	-- variables for usage in widget functions
	f:SetUserData("user", user)
	f:SetUserData("dkp", dkp)
	f:SetUserData("itemlink", itemlink)

	-- the item should be in cache now, was requested when bidding started
	local d, itemId, enchantId, jewelId1, jewelId2, jewelId3, jewelId4, suffixId, uniqueId, linkLevel, specializationID, reforgeId, unknown1, unknown2 = strsplit(":", itemlink)
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemId)

	local lbIcon = AceGUI:Create("Icon")
	lbIcon:SetRelativeWidth(0.3)
	lbIcon:SetImage(itemTexture)
	lbIcon:SetImageSize(15,15)
	lbIcon:SetCallback("OnEnter", function(widget)
		GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPRIGHT")
		GameTooltip:SetHyperlink(widget.parent:GetUserData("itemlink"))
		GameTooltip:Show()
	end)
	lbIcon:SetCallback("OnLeave", function(widget)
		GameTooltip:Hide()
	end)
	f:AddChild(lbIcon)

	local lbText = AceGUI:Create("InteractiveLabel")
	lbText:SetText(itemlink)
	lbText:SetRelativeWidth(0.7)
	lbText:SetCallback("OnEnter", function(widget)
		GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPRIGHT")
		GameTooltip:SetHyperlink(widget.parent:GetUserData("itemlink"))
		GameTooltip:Show()
	end)
	lbText:SetCallback("OnLeave", function(widget)
		GameTooltip:Hide()
	end)
	f:AddChild(lbText)

	local edDKP = AceGUI:Create("EditBox")
	edDKP:SetText(-dkp)
	edDKP:SetLabel("DKP charge")
	edDKP:SetRelativeWidth(0.20)
	edDKP:SetCallback("OnEnterPressed", function(widget)
		local newdkp = widget:GetText()
		local olddkp = tonumber(widget.parent:GetUserData("dkp"))

		if newdkp == nil then
			CheeseSLS:Print("Can only set numeric values for DKP")
			widget:SetText(-olddkp)
			widget:ClearFocus()
			return nil
		end

		newdkp = tonumber(newdkp)
		if newdkp == nil then
			CheeseSLS:Print("Can only set numeric values for DKP")
			widget:SetText(-olddkp)
			widget:ClearFocus()
			return nil
		end

		widget.parent:SetUserData("dkp", -newdkp)
		widget:ClearFocus()
	end)
	f:AddChild(edDKP)
	f.edDKP = edDKP

	local buttonHalf = AceGUI:Create("Button")
	buttonHalf.edDKP = edDKP
	buttonHalf.slsframe = f
	buttonHalf:SetText("1/2")
	buttonHalf:SetRelativeWidth(0.2)
	buttonHalf:SetCallback("OnClick", function(widget)
		local curDKP = GoogleSheetDKP:GetDKP(widget.parent:GetUserData("user"))
		if curDKP == nil then curDKP = 0 end
		local halfDKP = math.floor(curDKP / 2)
		widget.parent.edDKP:SetText(halfDKP)
		widget.parent:SetUserData("dkp", halfDKP)
	end)
	f:AddChild(buttonHalf)

	local ddChar = AceGUI:Create("Dropdown")
	ddChar:SetList(raiderlist)
	ddChar:SetValue(user)
	ddChar:SetText(raiderlist[user])
	ddChar:SetLabel("Character")
	ddChar:SetRelativeWidth(0.60)
	ddChar:SetCallback("OnValueChanged", function(widget, event, key)
		if key == nil then
			CheeseSLS:Print("You need to choose a user")
			widget:SetValue(widget.parent:GetUserData("user"))
			widget:SetText(widget.parent:GetUserData("user"))
			widget:ClearFocus()
			return nil
		end
		widget.parent:SetUserData("user", key)
	end)
	f:AddChild(ddChar)

	local button1 = AceGUI:Create("Button")
	button1.slsframe = f
	button1:SetText("Yes")
	button1:SetRelativeWidth(0.5)
	button1:SetCallback("OnClick", function(widget)
		GoogleSheetDKP:Item(widget.parent:GetUserData("user"), widget.parent:GetUserData("dkp"), widget.parent:GetUserData("itemlink"))
		widget.parent:Hide()
	end)
	f:AddChild(button1)

	local button2 = AceGUI:Create("Button")
	button2.slsframe = f
	button2:SetText("No")
	button2:SetRelativeWidth(0.5)
	button2:SetCallback("OnClick", function(widget)
		CheeseSLS:Print("Will NOT book " .. tostring(widget.parent:GetUserData("dkp")) .. "DKP to " .. widget.parent:GetUserData("user") .. " for " .. widget.parent:GetUserData("itemlink") .. ", so take care of that yourself, e.g. by /gsdkp item")
		widget.parent:Hide()
	end)
	f:AddChild(button2)

	return f
end
