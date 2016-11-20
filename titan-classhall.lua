-- Titan [Class Hall]
-- Description: Titan plug-in to open your Order Hall
-- Author: r1fT
-- Version: @project-version@

local _G = getfenv(0);
local TITAN_ClassHall_ID = "ClassHall";
local TITAN_ClassHall_VER = "@project-version@";
local updateTable = {TITAN_ClassHall_ID, TITAN_PANEL_UPDATE_BUTTON};
local buttonlabel = "Titan Panel [|cff008cffClass Hall|r]"
local L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)
local AceTimer = LibStub("AceTimer-3.0")
local ClassHallProfile = UnitName("player").."-"..GetRealmName()

function ClassHallGetIcon()
	ClassIcon = UnitClass("player")
	ClassIcon = ClassIcon:gsub("%s+", "")
	return ClassIcon
end

function ClassHallInitDB()
	if type(TPClassHall) ~= "table" then
		TPClassHall = {}
	end
	if type(TPClassHall.profiles) ~= "table" then
		TPClassHall.profiles = {}
	end
	if type(TPClassHall.ignores) ~= "table" then
		TPClassHall.ignores = {}
	end
	if type(TPClassHall.profiles[ClassHallProfile]) ~= "table" then
		TPClassHall.profiles[ClassHallProfile] = {}
	end
	for name, missions in pairs(TPClassHall.profiles) do
		for i, mission in ipairs(missions) do
			if type(mission) == "table" and not mission.missionEndTime then
				mission.missionEndTime = mission.timeComplete
			end
		end
	end
end

function ClassHallSaveToonData()
	ClassHallInitDB()
	local ClassHallProfile_Save = UnitName("player").."-"..GetRealmName()
	local currencyId = C_Garrison.GetCurrencyTypes(LE_GARRISON_TYPE_7_0)
	local follower_categoryInfo = {}
	do
		if C_Garrison.GetLandingPageGarrisonType() ~= LE_GARRISON_TYPE_7_0 then return end
		follower_categoryInfo = C_Garrison.GetClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
		C_Garrison.RequestClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
	end
	local followershipment_categoryInfo = {}
	do
		if C_Garrison.GetLandingPageGarrisonType() ~= LE_GARRISON_TYPE_7_0 then return end
		followershipment_categoryInfo = C_Garrison.GetFollowerShipments(LE_GARRISON_TYPE_7_0)
	end
	local mission_categoryInfo = {}
	do
		if C_Garrison.GetLandingPageGarrisonType() ~= LE_GARRISON_TYPE_7_0 then return end
		mission_categoryInfo = C_Garrison.GetInProgressMissions(LE_FOLLOWER_TYPE_GARRISON_7_0)
	end
	local research_categoryInfo = {}
	do
		if C_Garrison.GetLandingPageGarrisonType() ~= LE_GARRISON_TYPE_7_0 then return end
		research_categoryInfo = C_Garrison.GetLooseShipments(C_Garrison.GetLandingPageGarrisonType(LE_GARRISON_TYPE_7_0))
	end
	local talent_categoryInfo = {}
	do
		if C_Garrison.GetLandingPageGarrisonType() ~= LE_GARRISON_TYPE_7_0 then return end
		talent_categoryInfo = C_Garrison.GetTalentTrees(LE_GARRISON_TYPE_7_0, select(C_Garrison.GetLandingPageGarrisonType(LE_GARRISON_TYPE_7_0), UnitClass("player")))
	end
	local currency_categoryInfo = {}
	do
		if C_Garrison.GetLandingPageGarrisonType() ~= LE_GARRISON_TYPE_7_0 then return end
		currency_categoryInfo = GetCurrencyInfo(currencyId)
	end
	GetCurrencyInfo(currencyId)
	wipe(TPClassHall.profiles[ClassHallProfile_Save])
	
	if follower_categoryInfo ~= nil then
		if TPClassHall.profiles[ClassHallProfile_Save].follower ~= table then
			TPClassHall.profiles[ClassHallProfile_Save].follower = {}
		else
			wipe(TPClassHall.profiles[ClassHallProfile_Save].follower)
		end
		for _, info in ipairs(follower_categoryInfo) do
			tinsert(TPClassHall.profiles[ClassHallProfile_Save].follower, info)
		end
	end
	if followershipment_categoryInfo ~= nil then
		if TPClassHall.profiles[ClassHallProfile_Save].followershipment ~= table then
			TPClassHall.profiles[ClassHallProfile_Save].followershipment = {}
		else
			wipe(TPClassHall.profiles[ClassHallProfile_Save].followershipment)
		end
		local info
		local name, texture, shipmentCapacity, shipmentsReady, shipmentsTotal, creationTime, duration, timeleftString, itemName, itemTexture, _, itemID
		for _, v in ipairs(followershipment_categoryInfo) do
			name, texture, shipmentCapacity, shipmentsReady, shipmentsTotal, creationTime, duration, timeleftString, itemName, itemTexture, _, itemID = C_Garrison.GetLandingPageShipmentInfoByContainerID(v)
			info = {}
			info.name = name
			info.shipmentsReady = shipmentsReady
			info.shipmentsTotal = shipmentsTotal
			info.missionEndTime = creationTime + duration
			tinsert(TPClassHall.profiles[ClassHallProfile_Save].followershipment, info)
		end
	end
	if mission_categoryInfo ~= nil then
		if TPClassHall.profiles[ClassHallProfile_Save].mission ~= table then
			TPClassHall.profiles[ClassHallProfile_Save].mission = {}
		else
			wipe(TPClassHall.profiles[ClassHallProfile_Save].mission)
		end
		for _, info in ipairs(mission_categoryInfo) do
			tinsert(TPClassHall.profiles[ClassHallProfile_Save].mission, info)
		end
	end
	if research_categoryInfo ~= nil then
		if TPClassHall.profiles[ClassHallProfile_Save].research ~= table then
			TPClassHall.profiles[ClassHallProfile_Save].research = {}
		else
			wipe(TPClassHall.profiles[ClassHallProfile_Save].research)
		end
		for _, info in ipairs(research_categoryInfo) do
			local info
			local name, texture, shipmentCapacity, shipmentsReady, shipmentsTotal, creationTime, duration, timeleftString, itemName, itemTexture, _, itemID
			for k, v in pairs(C_Garrison.GetLooseShipments(3) or {}) do
				name, texture, shipmentCapacity, shipmentsReady, shipmentsTotal, creationTime, duration, timeleftString, itemName, itemTexture, _, itemID = C_Garrison.GetLandingPageShipmentInfoByContainerID(v)
				if itemID == 139390 and creationTime and duration and name then
					if not info then
						info = {rewards = {{}}}
					end
					info.isArtifact = true
					info.name = name
					info.missionEndTime = creationTime + duration
					if GetServerTime() >= info.missionEndTime then
						info.isComplete = true
						shipmentsReady = shipmentsReady + 1
						if shipmentsReady > shipmentsTotal then
							shipmentsReady = shipmentsTotal
						end
					elseif shipmentsReady > 0 then
						info.isComplete = true
					else
						info.isComplete = nil
					end
					info.artifactReady = shipmentsReady
					info.artifactTotal = shipmentsTotal
					info.followerTypeID = LE_FOLLOWER_TYPE_GARRISON_7_0
					info.typeIcon = texture
					info.rewards[1].itemID = itemID
					info.rewards[1].quantity = 1
					tinsert(TPClassHall.profiles[ClassHallProfile_Save].research, info)
					break
				end
			end
		end
	end
	if talent_categoryInfo ~= nil then
		if TPClassHall.profiles[ClassHallProfile_Save].talent ~= table then
			TPClassHall.profiles[ClassHallProfile_Save].talent = {}
		else
			wipe(TPClassHall.profiles[ClassHallProfile_Save].talent)
		end
		for _, info in ipairs(talent_categoryInfo) do
			tinsert(TPClassHall.profiles[ClassHallProfile_Save].talent, info)
		end
	end
	if talent_categoryInfo ~= nil then
		if TPClassHall.profiles[ClassHallProfile_Save].talent ~= table then
			TPClassHall.profiles[ClassHallProfile_Save].talent = {}
		else
			wipe(TPClassHall.profiles[ClassHallProfile_Save].talent)
		end
		for _, info in ipairs(talent_categoryInfo) do
			tinsert(TPClassHall.profiles[ClassHallProfile_Save].talent, info)
		end
	end
	if currency_categoryInfo ~= nil then
		if TPClassHall.profiles[ClassHallProfile_Save].currency ~= table then
			TPClassHall.profiles[ClassHallProfile_Save].currency = {}
		else
			wipe(TPClassHall.profiles[ClassHallProfile_Save].currency)
		end
		local currency, amount, icon = GetCurrencyInfo(currencyId)
		tinsert(TPClassHall.profiles[ClassHallProfile_Save].currency, currency)
		tinsert(TPClassHall.profiles[ClassHallProfile_Save].currency, amount)
		tinsert(TPClassHall.profiles[ClassHallProfile_Save].currency, icon)
	end
end

function TitanPanelClassHallButton_OnLoad(self)
	
	self.registry = {
		id = TITAN_ClassHall_ID,
		version = TITAN_ClassHall_VER,
		category = "Information",
		menuText = "Titan Panel [|cff008cffClass Hall|r]",
		buttonTextFunction = "TitanPanelClassHallButton_GetButtonText", 
		tooltipCustomFunction = ClassHallMakeToolTip,
		icon = "Interface\\Addons\\titan-classhall\\Icons\\"..ClassHallGetIcon(),
		iconWidth = 16,
		controlVariables = {
			ShowIcon = true,
			ShowLabelText = true,
			DisplayOnRightSide = true
		},
		savedVariables = {
			ShowIcon = 1,
			DisplayOnRightSide = true
		}
	};
	ClassHallSaveToonData()
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function TitanPanelClassHallButton_OnEvent(self, event, ...)
	if (event == "PLAYER_ENTERING_WORLD") then
		ClassHallSaveToonData()
		self:RegisterEvent("PLAYER_LEAVING_WORLD");
	end

	if event == "PLAYER_LEAVING_WORLD" then
		ClassHallSaveToonData()
	end
end

function TitanPanelClassHallButton_OnClick(self, button)
	if (button == "LeftButton") then
		GarrisonLandingPage_Toggle()
	end
end

function TitanPanelClassHallButton_GetButtonText(id)
	return buttonlabel, "|r"
end

function ClassHallMakeToolTip(self)
	ClassHallSaveToonData()
	GameTooltip:ClearLines()
	GameTooltip:AddLine("Class Hall |cFF0000FF[|cFFFFFFFF"..ClassHallProfile.."|cFF0000FF]")
	GameTooltip:AddLine("\n")
	local NoResearch = true
	local currencyId = C_Garrison.GetCurrencyTypes(LE_GARRISON_TYPE_7_0)
	if C_Garrison.GetLandingPageGarrisonType() ~= LE_GARRISON_TYPE_7_0 then return end

		local currency = TPClassHall.profiles[ClassHallProfile].currency[1]
		local amount = TPClassHall.profiles[ClassHallProfile].currency[2]
		local icon = TPClassHall.profiles[ClassHallProfile].currency[3]
		GameTooltip:AddDoubleLine(" |T"..icon..":0:0:0:2:64:64:4:60:4:60|t |cFFFFE000"..currency..":", "|cFFFFFFFF"..amount,1,1,1, 1,1,1)

		if #TPClassHall.profiles[ClassHallProfile].follower > 0 then
			GameTooltip:AddLine("\n")
			for _, info in ipairs(TPClassHall.profiles[ClassHallProfile].follower) do
				GameTooltip:AddDoubleLine("|T"..info.icon..":0|t |cFFFFFFFF"..info.name..":", "|cFFFFFFFF"..info.count.."/"..info.limit,1,1,1, 1,1,1)
			end
		end
		
		if #TPClassHall.profiles[ClassHallProfile].mission > 0 then
			GameTooltip:AddLine("\n")
			GameTooltip:AddLine("|cFF00FF00Current Missions")
			for _, info in ipairs(TPClassHall.profiles[ClassHallProfile].mission) do
				local timeremaining = info.missionEndTime-GetServerTime()
				if timeremaining > 0 then
					local missiontimeremaining = ClassHallTimeFormat(timeremaining)
					GameTooltip:AddDoubleLine("|cFFFFE000"..info.name..":", "|cFFFFFFFF"..missiontimeremaining,1,1,1, 1,1,1)
				else
					GameTooltip:AddDoubleLine("|cFFFFE000"..info.name..":", "|cFF00FF00Compleated",1,1,1, 1,1,1)
				end
			end
		end
		
		GameTooltip:AddLine("\n")
		GameTooltip:AddLine("|cFF00FF00Current Research")
		
		
		if #TPClassHall.profiles[ClassHallProfile].followershipment > 0 then
			for _, info in ipairs(TPClassHall.profiles[ClassHallProfile].followershipment) do
				if info.missionEndTime ~= 0 then
					local timeremaining = info.missionEndTime-GetServerTime()
					local missiontimeremaining = ClassHallTimeFormat(timeremaining)
					GameTooltip:AddDoubleLine("|cFFFFE000"..info.name.." ("..info.shipmentsReady.."/"..info.shipmentsTotal.."):", "|cFFFFFFFF"..missiontimeremaining,1,1,1, 1,1,1)
				end
			end
		end	
		
		if #TPClassHall.profiles[ClassHallProfile].research > 0 then
			for _, info in ipairs(TPClassHall.profiles[ClassHallProfile].research) do
				if info.missionEndTime ~= nil then
					if info.missionEndTime > 0 then
						local timeremaining = info.missionEndTime-GetServerTime()
						local missiontimeremaining = ClassHallTimeFormat(timeremaining)
						GameTooltip:AddDoubleLine("|cFFFFE000"..info.name.." ("..info.artifactReady.."/"..info.artifactTotal.."):", "|cFFFFFFFF"..missiontimeremaining,1,1,1, 1,1,1)
					end
				end
			end
		end
		
		if #TPClassHall.profiles[ClassHallProfile].talent > 0 then
			for _, tree in ipairs(TPClassHall.profiles[ClassHallProfile].talent) do
				for _, info in ipairs(tree) do
					if info.selected == true then
						if info.researched == false then
							NoResearch = false
							local timeremaining = (info.researchDuration+info.researchStartTime)-GetServerTime()
							local missiontimeremaining = ClassHallTimeFormat(timeremaining)
							GameTooltip:AddDoubleLine("|cFFFFE000"..info.name..":", "|cFFFFFFFF"..missiontimeremaining,1,1,1, 1,1,1)
						end
					end
					if info.tier == 5 then
						if info.researched == true then
							NoResearch = false
						end
					end
				end
				if NoResearch == true then
					GameTooltip:AddLine("|cFFFF0000No Class Hall Talent Research")
				end
			end
		end

	GameTooltip:AddLine("\n")			
	GameTooltip:AddLine("|cff00ff00Left click for Class Hall report")
	GameTooltip:AddLine("|cff00ff00Right click to view other characters")
	GameTooltip:Show()
	return 
end

function TitanPanelRightClickMenu_PrepareClassHallMenu()
	TitanPanelRightClickMenu_AddTitle(TitanPlugins[TITAN_ClassHall_ID].menuText);
	TitanPanelRightClickMenu_AddSpacer();
	
	for name, _ in pairs(TPClassHall.profiles) do
		local info = {};
		info.text = name;
		if name == ClassHallProfile then 
			info.checked = true;
		else
			info.checked = false;
		end
		info.func = function()
			ClassHallProfile = name
		end
		UIDropDownMenu_AddButton(info, _G["UIDROPDOWNMENU_MENU_LEVEL"]);
	end
	TitanPanelRightClickMenu_AddSpacer();
	TitanPanelRightClickMenu_AddCommand(L["TITAN_PANEL_MENU_HIDE"], TITAN_ClassHall_ID, TITAN_PANEL_MENU_FUNC_HIDE);
end


function ClassHallTimeFormat(remaining)
	local seconds = remaining % 60
	remaining = (remaining - seconds) / 60
	local minutes = remaining % 60
	remaining = (remaining - minutes) / 60
	local hours = remaining % 24
	local days = (remaining - hours) / 24
	if days > 0 then
		time_formated = days.." day "..hours.." hr"
	else
		if hours > 0 then
			time_formated = hours.." hr "..minutes.." min"
		else
			time_formated = minutes.." min"
		end
	end
	return time_formated
end

function mysplit(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end