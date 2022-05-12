local db
local f = CreateFrame("Frame")
local WIDE_WORLD_OF_QUESTS = 13144

local defaults = {
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
		WideWorldofQuestsDB = WideWorldofQuestsDB or {}
		self.db = WideWorldofQuestsDB
		for k, v in pairs(defaults) do
			if self.db[k] == nil then
				self.db[k] = v
			end
		end
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

local function SetPinColor(pin, r1, g1, b1, r2, g2, b2)
	if pin.Texture then
		pin.Texture:SetVertexColor(r1, g1, b1)
	end
	if pin.Background then
		pin.Background:SetVertexColor(r2, g2, b2)
	end
end

-- this seems to work fine instead of hooking into the worldmap
function f:QUEST_LOG_UPDATE()
	if WorldMapFrame:IsVisible() and mapIds[WorldMapFrame:GetMapID()] then
		for pin in WorldMapFrame:EnumeratePinsByTemplate("WorldMap_WorldQuestPinTemplate") do
			if db.quests[pin.questID] then
				SetPinColor(pin, .2, .2, .2, 0, 0, 0)
				pin.wideworldofquests = true
			else
				if pin.wideworldofquests then -- restore pin
					SetPinColor(pin, 1, 1, 1, 1, 1, 1)
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
