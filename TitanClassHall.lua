-- Titan [Class Hall]
-- Description: Titan plug-in to open your Order Hall
-- Author: r1fT
-- Version: 1.0.1.70100

local _G = getfenv(0);
local TITAN_ClassHall_ID = "ClassHall";
local TITAN_ClassHall_VER = "1.0.1.70000";
local updateTable = {TITAN_ClassHall_ID, TITAN_PANEL_UPDATE_BUTTON};
local buttonlabel = "Titan Panel [Class Hall]"
local L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)
local AceTimer = LibStub("AceTimer-3.0")
local currencyId = C_Garrison.GetCurrencyTypes(LE_GARRISON_TYPE_7_0)
local NoResearch = true

function ClassHallGetIcon()
	ClassIcon = UnitClass("player")
	ClassIcon = ClassIcon:gsub("%s+", "")
	return ClassIcon
end

function TitanPanelClassHallButton_OnLoad(self)
	
	self.registry = {
		id = TITAN_ClassHall_ID,
		version = TITAN_ClassHall_VER,
		category = "Information",
		menuText = "Titan Panel [Class Hall]",
		buttonTextFunction = "TitanPanelClassHallButton_GetButtonText", 
		tooltipTitle = "Class Hall",
		tooltipTextFunction = "TitanPanelClassHallButton_GetTooltipText", 
		icon = "Interface\\Addons\\TitanClassHall\\Icons\\"..ClassHallGetIcon(),
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
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function TitanPanelClassHallButton_OnEvent(self, event, ...)
	if (event == "PLAYER_ENTERING_WORLD") then
		self:RegisterEvent("GARRISON_FOLLOWER_CATEGORIES_UPDATED");
		self:RegisterEvent("GARRISON_FOLLOWER_ADDED");
		self:RegisterEvent("GARRISON_FOLLOWER_REMOVED");
		self:RegisterEvent("GARRISON_TALENT_COMPLETE");
		self:RegisterEvent("GARRISON_TALENT_UPDATE");
		self:RegisterEvent("GARRISON_SHOW_LANDING_PAGE");
	end

	if event == "GARRISON_FOLLOWER_CATEGORIES_UPDATED" then
		self:SetScript("OnUpdate", TitanPanelClassHallButton_OnUpdate)
	end
	
	if event == "GARRISON_FOLLOWER_ADDED" then
		self:SetScript("OnUpdate", TitanPanelClassHallButton_OnUpdate)
	end
	
	if event == "GARRISON_FOLLOWER_REMOVED" then
		self:SetScript("OnUpdate", TitanPanelClassHallButton_OnUpdate)
	end
	
	if event == "GARRISON_TALENT_COMPLETE" then
		self:SetScript("OnUpdate", TitanPanelClassHallButton_OnUpdate)
	end
	
	if event == "GARRISON_TALENT_UPDATE" then
		self:SetScript("OnUpdate", TitanPanelClassHallButton_OnUpdate)
	end
	
	if event == "GARRISON_SHOW_LANDING_PAGE" then
		self:SetScript("OnUpdate", TitanPanelClassHallButton_OnUpdate)
	end
end

function TitanPanelClassHallButton_OnUpdate(self)
	TitanPanelPluginHandle_OnUpdate(updateTable)
	local follower_categoryInfo = {}
	do
		if C_Garrison.GetLandingPageGarrisonType() ~= LE_GARRISON_TYPE_7_0 then return end
		follower_categoryInfo = C_Garrison.GetClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
		C_Garrison.RequestClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
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
	self:SetScript("OnUpdate", nil)
end

function TitanPanelClassHallButton_OnClick(self, button)
	if (button == "LeftButton") then
		GarrisonLandingPage_Toggle()
	end
end

function TitanPanelClassHallButton_GetButtonText(id)
	return buttonlabel, "|r"
end

function TitanPanelClassHallButton_GetTooltipText()
	ClassHallButtonToolTip = "\n"
	local currencyId = C_Garrison.GetCurrencyTypes(LE_GARRISON_TYPE_7_0)
	local follower_categoryInfo = {}
	do
		if C_Garrison.GetLandingPageGarrisonType() ~= LE_GARRISON_TYPE_7_0 then return end
		follower_categoryInfo = C_Garrison.GetClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
		C_Garrison.RequestClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
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
	if C_Garrison.GetLandingPageGarrisonType() ~= LE_GARRISON_TYPE_7_0 then return end

		local currency, amount, icon = GetCurrencyInfo(currencyId)
		ClassHallButtonToolTip = ClassHallButtonToolTip.." |T"..icon..":0:0:0:2:64:64:4:60:4:60|t "..currency..":	|cFFFFFFFF"..amount.."\n"

		if #follower_categoryInfo > 0 then
			ClassHallButtonToolTip = ClassHallButtonToolTip.."\n"
			for _, info in ipairs(follower_categoryInfo) do
				ClassHallButtonToolTip = ClassHallButtonToolTip.."|T"..info.icon..":0|t "..info.name..":	|cFFFFFFFF"..info.count.."/"..info.limit.."\n"
			end
		end
		
		if #mission_categoryInfo > 0 then
			ClassHallButtonToolTip = ClassHallButtonToolTip.."\n|cFF00FF00Current Missions\n"
			for _, info in ipairs(mission_categoryInfo) do
				if info.timeLeftSeconds > 0 then
					ClassHallButtonToolTip = ClassHallButtonToolTip..info.name..":	|cFFFFFFFF"..info.timeLeft.."\n"
				else
					ClassHallButtonToolTip = ClassHallButtonToolTip..info.name..":	|cFF00FF00Compleated\n"
				end
			end
		end
		
		if #research_categoryInfo > 0 then
			ClassHallButtonToolTip = ClassHallButtonToolTip.."\n|cFF00FF00Current Research\n"
			for _, info in ipairs(research_categoryInfo) do
				research_string  = string.format("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s",C_Garrison.GetLandingPageShipmentInfoByContainerID(info))
				research_table = mysplit(research_string,",")				
				for key, value in pairs(research_table) do
					if key == 1 then
						ClassHallButtonToolTip = ClassHallButtonToolTip..value..":	|cFFFFFFFF"
					end
					if key == 8 then
						ClassHallButtonToolTip = ClassHallButtonToolTip..value.."\n"
					end
				end
			end
		end
		
		if #talent_categoryInfo > 0 then
			for _, tree in ipairs(talent_categoryInfo) do
				for _, info in ipairs(tree) do
					if info.selected == true then
						if info.researched == false then
							NoResearch = false
							local talenttimeremaing_days = string.format("%.1d", info.researchTimeRemaining/86400)
							local talenttimeremaing_hours = string.format("%.1d", (info.researchTimeRemaining-(talenttimeremaing_days*86400))/3600)
							if tonumber(talenttimeremaing_days) > 0 then
								ClassHallButtonToolTip = ClassHallButtonToolTip..info.name..":	|cFFFFFFFF"..talenttimeremaing_days.." day "..talenttimeremaing_hours.." hr\n"
							else
								talenttimeremaing_min = string.format("%.1d", (info.researchTimeRemaining-(talenttimeremaing_hours*3600))/60)
								if tonumber(talenttimeremaing_hours) > 0 then
									ClassHallButtonToolTip = ClassHallButtonToolTip..info.name..":	|cFFFFFFFF"..talenttimeremaing_hours.." hr "..talenttimeremaing_min.." min\n"
								else
									ClassHallButtonToolTip = ClassHallButtonToolTip..info.name..":	|cFFFFFFFF"..talenttimeremaing_min.." min\n"
								end
							end
						end
					end
					if info.tier == 5 then
						if info.researched == true then
							NoResearch = false
						end
					end
				end
				if NoResearch == true then
					ClassHallButtonToolTip = ClassHallButtonToolTip.."|cFFFF0000No Class Hall Talent Research\n"
				end
			end
		end
				
	ClassHallButtonToolTip = ClassHallButtonToolTip.."\n|cff00ff00Left click for Class Hall report"
	return ClassHallButtonToolTip
end

function TitanPanelRightClickMenu_PrepareClassHallMenu()
	TitanPanelRightClickMenu_AddTitle(TitanPlugins[TITAN_ClassHall_ID].menuText);
	TitanPanelRightClickMenu_AddSpacer();
	TitanPanelRightClickMenu_AddCommand(L["TITAN_PANEL_MENU_HIDE"], TITAN_ClassHall_ID, TITAN_PANEL_MENU_FUNC_HIDE);
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