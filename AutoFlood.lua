--[[
	AutoFlood
	Author : LenweSaralonde
]]

local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata

-- ===========================================
-- Main code functions
-- ===========================================

local MAX_RATE = 10

--- Main script initialization
--
function AutoFlood_OnLoad()
	AutoFlood_Frame:RegisterEvent("VARIABLES_LOADED")
	AutoFlood_Frame.profiles = {}
	AutoFlood_Frame:SetScript("OnEvent", AutoFlood_OnEvent)
	AutoFlood_Frame:SetScript("OnUpdate", AutoFlood_OnUpdate)
end

--- Clean the old account-wide config table
-- @param characterId (string)
local function cleanOldConfig(characterId)
	if AF_config and AF_config[characterId] then
		AF_config[characterId] = nil
		if next(AF_config) == nil then
			AF_config = nil
		end
	end
end

--- Event handler function
--
function AutoFlood_OnEvent(self, event)
	-- Init saved variables
	if event == "VARIABLES_LOADED" then

		-- Add-on version
		local version = GetAddOnMetadata("AutoFlood", "Version")

		-- Config key used for the old account-wide configuration table
		local characterId = GetRealmName() .. '-' .. UnitName("player")
		local oldConfig = AF_config and AF_config[characterId] or {}

		-- Init configuration
		AF_characterConfig = Mixin({
			{
				rate = 60,
				messages = {
					"AutoFlood " .. version, "is running"
				},
				channels = {
					"say",
					"party"
				}
			}
		}, oldConfig, AF_characterConfig or {})

		-- Erase old configuration
		AF_characterConfig.system = nil
		AF_characterConfig.idChannel = nil
		AF_characterConfig.rate = nil
		AF_characterConfig.message = nil
		AF_characterConfig.channel = nil
		cleanOldConfig(characterId)

		-- Display welcome message
		local s = string.gsub(AUTOFLOOD_LOAD, "VERSION", version)
		DEFAULT_CHAT_FRAME:AddMessage(s, 1, 1, 1)
	end
end

--- Enable flood!
--
function AutoFlood_On()
	AutoFlood_Info()
	for k, v in pairs(AF_characterConfig) do
		AutoFlood_Frame[k]['timeSinceLastUpdate'] = v.rate
		AutoFlood_Frame[k]['isActive'] = v.rate
	end
end

--- Stop flood
--
function AutoFlood_Off()
	DEFAULT_CHAT_FRAME:AddMessage(AUTOFLOOD_INACTIVE, 1, 1, 1)
end

--- Frame update handler
--
function AutoFlood_OnUpdate(self, elapsed)
	if MessageQueue.GetNumPendingMessages() > 0 then return end
	for profileId, _ in pairs(AutoFlood_Frame.profiles) do
		if AutoFlood_Frame[profileId].isActive then
			AutoFlood_Frame[profileId].timeSinceLastUpdate = AutoFlood_Frame[profileId].timeSinceLastUpdate + elapsed
			if AutoFlood_Frame[profileId].timeSinceLastUpdate > AF_characterConfig[profileId].rate then
				for _, channel in pairs(AF_characterConfig[profileId].channels) do
					local system, channelNumber = AutoFlood_GetChannel(channel)
					if system == nil then
						local s = string.gsub("[AutoFlood] " .. AUTOFLOOD_ERR_CHAN, "CHANNEL", message)
						DEFAULT_CHAT_FRAME:AddMessage(s, 1, 0, 0)
					else
						for _, message in pairs(AF_characterConfig[profileId].messages) do
							MessageQueue.SendChatMessage(message, system, nil, channelNumber)
						end
					end
				end
				AutoFlood_Frame[profileId].timeSinceLastUpdate = 0
			end
		end
	end
end

--- Show parameters
--
function AutoFlood_Info()
	if isFloodActive then
		DEFAULT_CHAT_FRAME:AddMessage(AUTOFLOOD_ACTIVE, 1, 1, 1)
	else
		DEFAULT_CHAT_FRAME:AddMessage(AUTOFLOOD_INACTIVE, 1, 1, 1)
	end

	local s = AUTOFLOOD_STATS_PROFILE
	s = string.gsub(s, "PROFILES_AMOUNT", #AF_characterConfig)
	DEFAULT_CHAT_FRAME:AddMessage(s, 1, 1, 1)

	local channels = ""
	for _, config in pairs(AF_characterConfig) do
		channels = ""
		for _, channel in pairs(config.channels) do
			channels = channels .. channel .. ", "
		end
		s = AUTOFLOOD_STATS
		s = string.gsub(s, "CHANNELS", channels)
		s = string.gsub(s, "RATE", config.rate)
		DEFAULT_CHAT_FRAME:AddMessage(s, 1, 1, 1)
		for _, message in pairs(config.messages) do
			DEFAULT_CHAT_FRAME:AddMessage(message, 1, 1, 1)
		end
	end
end

function AutoFlood_AddProfile()
	table.insert(
		AF_characterConfig,
		{
			rate = 60,
			messages = {
				"AutoFlood " .. version, "is running"
			},
			channels = {
				"say",
				"party"
			}
		}
	)
end

function AutoFlood_RemoveProfile(id)
	AF_characterConfig[id] = nil
end

function AutoFlood_ListProfileMessages(profileId)
	if AF_characterConfig[profileId] == nil then
		DEFAULT_CHAT_FRAME:AddMessage("Profile " .. profileId .. " does not exists", 1, 1, 1)
		return
	end

	for messageNumber, messageText in pairs(AF_characterConfig[profileId].messages) do
		DEFAULT_CHAT_FRAME:AddMessage(messageNumber .. ": " .. messageText, 1, 1, 1)
	end
end

function AutoFlood_AddMessageToProfile(profileId, messageText)
	if AF_characterConfig[profileId] == nil then
		DEFAULT_CHAT_FRAME:AddMessage("Profile " .. profileId .. " does not exists", 1, 1, 1)
		return
	end

	if #AF_characterConfig[profileId].messages > 1 then
		DEFAULT_CHAT_FRAME:AddMessage("Profile " .. profileId .. " already have 2 messages", 1, 1, 1)
		return
	end

	table.insert(
		AF_characterConfig[profileId].messages,
		messageText
	)
end

function AutoFlood_RemoveMessageFromProfile(profileId, messageId)
	if AF_characterConfig[profileId] == nil then
		DEFAULT_CHAT_FRAME:AddMessage("Profile " .. profileId .. " does not exists", 1, 1, 1)
		return
	end

	AF_characterConfig[profileId].messages[messageId] = nil
end

function AutoFlood_ListProfileChannels(profileId)
	if AF_characterConfig[profileId] == nil then
		DEFAULT_CHAT_FRAME:AddMessage("Profile " .. profileId .. " does not exists", 1, 1, 1)
		return
	end

	for channelId, channelNumber in pairs(AF_characterConfig[profileId].channels) do
		DEFAULT_CHAT_FRAME:AddMessage(channelId .. ": " .. channelNumber, 1, 1, 1)
	end
end

function AutoFlood_AddChannelToProfile(profileId, channelNumber)
	if AF_characterConfig[profileId] == nil then
		DEFAULT_CHAT_FRAME:AddMessage("Profile " .. profileId .. " does not exists", 1, 1, 1)
		return
	end

	table.insert(
			AF_characterConfig[profileId].channels,
			channelNumber
	)
end

function AutoFlood_RemoveChannelFromProfile(profileId, channelNumber)
	if AF_characterConfig[profileId] == nil then
		DEFAULT_CHAT_FRAME:AddMessage("Profile " .. profileId .. " does not exists", 1, 1, 1)
		return
	end

	AF_characterConfig[profileId].channels[channelNumber] = nil
end

function AutoFlood_SetRate(profileId, rate)
	if AF_characterConfig[profileId] == nil then
		DEFAULT_CHAT_FRAME:AddMessage("Profile " .. profileId .. " does not exists", 1, 1, 1)
		return
	end

	if rate ~= nil and tonumber(rate) > 0 and rate ~= "" then rate = tonumber(rate) end
	if rate >= MAX_RATE then
		AF_characterConfig[profileId].rate = rate
		local s = string.gsub(AUTOFLOOD_RATE, "RATE", AF_characterConfig.rate)
		DEFAULT_CHAT_FRAME:AddMessage(s, 1, 1, 1)
	else
		local s = string.gsub(AUTOFLOOD_ERR_RATE, "RATE", MAX_RATE)
		DEFAULT_CHAT_FRAME:AddMessage(s, 1, 0, 0)
	end
end

--- Return channel system and number
-- @param channel (string) Channel name, as prefixed by the slash.
-- @return system (string|nil)
-- @return channelNumber (int|nil)
-- @return channelName (string|nil)
function AutoFlood_GetChannel(channel)
	local ch = strlower(strtrim(channel))
	if ch == "say" or ch == "s" then
		return "SAY", nil, ch
	elseif ch == "guild" or ch == "g" then
		return "GUILD", nil, ch
	elseif ch == "raid" or ch == "ra" then
		return "RAID", nil, ch
	elseif ch == "party" or ch == "p" or ch == "gr" then
		return "PARTY", nil, ch
	elseif ch == "i" then
		return "INSTANCE_CHAT", nil, ch
	elseif ch == "bg" then
		return "BATTLEGROUND", nil, ch
	elseif GetChannelName(channel) ~= 0 then
		return "CHANNEL", (GetChannelName(channel)), channel
	end
	return nil, nil, nil
end

-- ===========================================
-- Slash command aliases
-- ===========================================

--- /fl [on|off]
-- Start / stop flood
-- @param s (string)
SlashCmdList["AUTOFLOOD"] = AutoFlood_Info
-- /floodinfo
-- Display the parameters in chat window
SlashCmdList["AUTOFLOODINFO"] = AutoFlood_Info

-- /flpadd
SlashCmdList["AUTOFLOODPADD"] = AutoFlood_AddProfile
-- /flprm <profile_number>
SlashCmdList["AUTOFLOODPRM"] = AutoFlood_RemoveProfile

-- /flmlist <profile_number>
SlashCmdList["AUTOFLOODMLIST"] = AutoFlood_ListProfileMessages
-- /flmadd <profile_number> <message_text>
SlashCmdList["AUTOFLOODMADD"] = AutoFlood_AddMessageToProfile
-- /flmrm <profile_number> <message_id>
SlashCmdList["AUTOFLOODMRM"] = AutoFlood_RemoveMessageFromProfile

-- /flchanlist <profile_number>
SlashCmdList["AUTOFLOODCHANLIST"] = AutoFlood_ListProfileChannels
-- /flchanadd <profile_number> <channel>
SlashCmdList["AUTOFLOODCHANADD"] = AutoFlood_AddChannelToProfile
-- /flchanrm <profile_number> <channel>
SlashCmdList["AUTOFLOODCHANRM"] = AutoFlood_RemoveChannelFromProfile

-- /flrate <profile_number> <duration>
SlashCmdList["AUTOFLOODSETRATE"] = AutoFlood_SetRate

-- /floodhelp
-- Display help in chat window
SlashCmdList["AUTOFLOODHELP"] = function()
	for _, l in pairs(AUTOFLOOD_HELP) do
		DEFAULT_CHAT_FRAME:AddMessage(l, 1, 1, 1)
	end
end

-- Command aliases
SLASH_AUTOFLOOD1 = "/fl"

SLASH_AUTOFLOODINFO1 = "/floodinfo"

SLASH_AUTOFLOODPADD1 = "/flpadd"
SLASH_AUTOFLOODPRM1 = "/flprm"

SLASH_AUTOFLOODMLIST1 = "/flmlist"
SLASH_AUTOFLOODMADD1 = "/flmadd"
SLASH_AUTOFLOODMRM1 = "/flmrm"

SLASH_AUTOFLOODCHANLIST1 = "/flchanlist"
SLASH_AUTOFLOODCHANADD1 = "/flchanadd"
SLASH_AUTOFLOODCHANRM1 = "/flchanrm"

SLASH_AUTOFLOODSETRATE1 = "/flrate"

SLASH_AUTOFLOODHELP1 = "/floodhelp"
SLASH_AUTOFLOODHELP2 = "/floodman"
