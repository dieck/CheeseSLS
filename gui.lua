local L = LibStub("AceLocale-3.0"):GetLocale("CheeseSLS", true)

function CheeseSLS:createRequestDialogFrame(user, dkp, itemlink, raiderlist)
	local AceGUI = LibStub("AceGUI-3.0")
	
	if CheeseSLS.slsdatastore == nil then CheeseSLS.slsdatastore = {} end
	local guiid = "itemlink" .. time()
	local slsdata = { user=user, dkp=dkp, itemlink=itemlink }
	CheeseSLS.slsdatastore[guiid] = slsdata

	local f = AceGUI:Create("Window")
	f:SetTitle("CheeseSLS DKP charge")
	f:SetStatusText("")
	f:SetLayout("Flow")
	f:SetWidth(300)
	f:SetHeight(165)
	f:SetCallback("OnClose",function(widget) AceGUI:Release(widget) end)

	-- the item should be in cache now, was requested when bidding started
	local d, itemId, enchantId, jewelId1, jewelId2, jewelId3, jewelId4, suffixId, uniqueId, linkLevel, specializationID, reforgeId, unknown1, unknown2 = strsplit(":", itemlink)
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice =
	GetItemInfo(itemId)

	local lbIcon = AceGUI:Create("Icon")
	lbIcon:SetRelativeWidth(0.3)
	lbIcon:SetImage(itemTexture)
	lbIcon:SetImageSize(15,15)
	lbIcon:SetCallback("OnEnter", function(widget)
		GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPRIGHT")
		GameTooltip:SetHyperlink(itemLink)
		GameTooltip:Show()
	end)
	lbIcon:SetCallback("OnLeave", function(widget)
		GameTooltip:Hide()
	end)
	f:AddChild(lbIcon)

	local lbText = AceGUI:Create("InteractiveLabel")
	lbText:SetText(itemLink)
	lbText:SetRelativeWidth(0.7)
	f:AddChild(lbText)
	
	local edDKP = AceGUI:Create("EditBox")
	edDKP.guiid = guiid
	edDKP:SetText(-dkp)
	edDKP:SetLabel("DKP charge")
	edDKP:SetRelativeWidth(0.5)
	edDKP:SetCallback("OnEnterPressed", function(widget)
		local newdkp = widget:GetText()

		if newdkp == nil then 
			CheeseSLS:Print("Can only set numeric values for DKP")
			widget:SetText(-CheeseSLS.slsdatastore[widget.guiid].dkp)
			widget:ClearFocus()
			return nil
		end
		
		newdkp = tonumber(newdkp)
		if newdkp == nil then 
			CheeseSLS:Print("Can only set numeric values for DKP")
			widget:SetText(-CheeseSLS.slsdatastore[widget.guiid].dkp)
			widget:ClearFocus()
			return nil
		end
		
		CheeseSLS.slsdatastore[widget.guiid].dkp = -newdkp
		widget:ClearFocus()
	end)
	f:AddChild(edDKP)
		
	local ddChar = AceGUI:Create("Dropdown")
	ddChar.guiid = guiid
	ddChar:SetList(raiderlist)
	ddChar:SetValue(user)
	ddChar:SetText(raiderlist[user])
	ddChar:SetLabel("Character")
	ddChar:SetRelativeWidth(0.5)
	ddChar:SetCallback("OnValueChanged", function(widget, key)
		if key == nil then
			CheeseSLS:Print("You need to choose a user")
			widget:SetValue(CheeseSLS.slsdatastore[widget.guiid].user)
			widget:SetText(CheeseSLS.slsdatastore[widget.guiid].user)
			widget:ClearFocus()
			return nil
		end
		CheeseSLS.slsdatastore[widget.guiid].user = key
	end)
	f:AddChild(ddChar)
	
	local button1 = AceGUI:Create("Button")
	button1.guiid = guiid
	button1.slsframe = f
	button1:SetText("Yes")
	button1:SetRelativeWidth(0.5)
	button1:SetCallback("OnClick", function(widget)
		local slsdata = CheeseSLS.slsdatastore[widget.guiid]
		GoogleSheetDKP:Item(slsdata.user, slsdata.dkp, slsdata.itemlink)
		widget.slsframe:Hide()
	end)
	f:AddChild(button1)

	local button2 = AceGUI:Create("Button")
	button2.guiid = guiid
	button2.slsframe = f
	button2:SetText("No")
	button2:SetRelativeWidth(0.5)
	button2:SetCallback("OnClick", function(widget)
		local slsdata = CheeseSLS.slsdatastore[widget.guiid]
		CheeseSLS:Print("Will NOT book " .. slsdata.dkp .. "DKP to " .. slsdata.user .. " for " .. slsdata.itemlink .. ", so take care of that yourself, e.g. by /gsdkp item")
		widget.slsframe:Hide()
	end)
	f:AddChild(button2)

	return f	
end
