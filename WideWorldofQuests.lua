local db
local f = CreateFrame("Frame")
local WIDE_WORLD_OF_QUESTS = 13144

local defaults = {
	db_version = 1,
	quests = {},
}

local mapIds = {
	[862] = true, -- Zuldazar
	[863] = true, -- Nazmir
	[864] = true, -- Vol'dun
	[895] = true, -- Tiragarde Sound
	[896] = true, -- Drustvar
	[942] = true, -- Stormsong Valley
}

function f:ADDON_LOADED(addon)
	if addon == "WideWorldofQuests" then
		if not WideWorldofQuestsDB or WideWorldofQuestsDB.db_version < defaults.db_version then
			WideWorldofQuestsDB = CopyTable(defaults)
		end
		db = WideWorldofQuestsDB
		self:UnregisterEvent("ADDON_LOADED")
	end
end

function f:VARIABLES_LOADED()
	-- not sure when the completed param for achievements is available
	C_Timer.After(1, function()
		local completed = select(4, GetAchievementInfo(WIDE_WORLD_OF_QUESTS))
		if not completed then
			self:RegisterEvent("QUEST_TURNED_IN")
			self:RegisterEvent("QUEST_LOG_UPDATE")
		end
	end)
end

function f:QUEST_TURNED_IN(questID)
	if C_QuestLog.IsWorldQuest(questID) then
		db.quests[questID] = true
	end
end

-- this seems to work fine instead of hooking into the worldmap
function f:QUEST_LOG_UPDATE()
	if WorldMapFrame:IsVisible() and mapIds[WorldMapFrame:GetMapID()] then
		for pin in WorldMapFrame:EnumeratePinsByTemplate("WorldMap_WorldQuestPinTemplate") do
			if db.quests[pin.questID] then
				if pin.Texture then
					pin.Texture:SetVertexColor(.2, .2, .2)
				end
				if pin.Background then
					pin.Background:SetVertexColor(0, 0, 0)
				end
				pin.wideworldofquests = true
			else
				if pin.wideworldofquests then -- restore pin
					if pin.Texture then
						pin.Texture:SetVertexColor(1, 1, 1)
					end
					if pin.Background then
						pin.Background:SetVertexColor(1, 1, 1)
					end
					pin.wideworldofquests = nil
				end
			end
		end
	end
end

function f:OnEvent(event, ...)
	self[event](self, ...)
end

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("VARIABLES_LOADED")
f:SetScript("OnEvent", f.OnEvent)
