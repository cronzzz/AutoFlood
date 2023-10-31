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
	AutoFlood_Frame.currentProfile = 1
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

function AutoFlood_State(profileId)
	if tonumber(profileId) == nil then
		AutoFlood_Info()
		return
	end

	if AF_characterConfig[tonumber(profileId)] == nil then
		say("Profile does not exists")
		return
	end

	if AutoFlood_Frame.profiles[tonumber(profileId)] == nil then
		AutoFlood_Frame.profiles[tonumber(profileId)] = {
			timeSinceLastUpdate = '0',
			isActive = '0'
		}
	end

	if AutoFlood_Frame.profiles[tonumber(profileId)].isActive == '1' then
		AutoFlood_Frame.profiles[tonumber(profileId)].timeSinceLastUpdate = '0'
		AutoFlood_Frame.profiles[tonumber(profileId)].isActive = '0'
		say("Profile " .. profileId .. " is disabled")
	else
		AutoFlood_Frame.profiles[tonumber(profileId)].timeSinceLastUpdate = AF_characterConfig[tonumber(profileId)].rate
		AutoFlood_Frame.profiles[tonumber(profileId)].isActive = '1'
		say("Profile " .. profileId .. " is enabled")
	end
end

--- Frame update handler
--
function AutoFlood_OnUpdate(self, elapsed)
	if MessageQueue.GetNumPendingMessages() > 0 then return end
	for profileId, _ in ipairs(AutoFlood_Frame.profiles) do
		if AutoFlood_Frame.profiles[tonumber(profileId)].isActive == "1" then
			AutoFlood_Frame.profiles[tonumber(profileId)].timeSinceLastUpdate = AutoFlood_Frame.profiles[tonumber(profileId)].timeSinceLastUpdate + elapsed
			if AutoFlood_Frame.profiles[tonumber(profileId)].timeSinceLastUpdate > AF_characterConfig[tonumber(profileId)].rate then
				for _, channel in ipairs(AF_characterConfig[tonumber(profileId)].channels) do
					local system, channelNumber = AutoFlood_GetChannel(channel)
					if system == nil then
						local s = string.gsub("[AutoFlood] " .. AUTOFLOOD_ERR_CHAN, "CHANNEL", message)
						DEFAULT_CHAT_FRAME:AddMessage(s, 1, 0, 0)
					else
						for _, message in pairs(AF_characterConfig[tonumber(profileId)].messages) do
							MessageQueue.SendChatMessage(message, system, nil, channelNumber)
						end
					end
				end
				AutoFlood_Frame.profiles[tonumber(profileId)].timeSinceLastUpdate = 0
			end
		end
	end
end

--- Show parameters
--
function AutoFlood_Info()
	local s = AUTOFLOOD_STATS_PROFILE
	s = string.gsub(s, "PROFILES_AMOUNT", #AF_characterConfig)
	s = string.gsub(s, "CURRENT_PROFILE", AutoFlood_Frame.currentProfile or "0")
	say(s, "false")

	local channels = ""
	local state = "not running"
	for profileId, config in ipairs(AF_characterConfig) do
		if AutoFlood_Frame.profiles[tonumber(profileId)] == nil then
			AutoFlood_Frame.profiles[tonumber(profileId)] = {
				isActive = "0",
				timeSinceLastUpdate = 0
			}
		end

		if AutoFlood_Frame.profiles[tonumber(profileId)].isActive == "1" then
			state = " (running) "
		else
			state = " (not running) "
		end
		say("Profile " .. profileId .. state .. ":", "false")
		channels = ""
		for _, channel in pairs(config.channels) do
			channels = channels .. channel .. ", "
		end
		s = AUTOFLOOD_STATS
		s = string.gsub(s, "CHANNELS", channels)
		s = string.gsub(s, "RATE", config.rate)
		say(s, "false")
		for messageNumber, message in pairs(config.messages) do
			say(messageNumber .. ": " .. message, "false")
		end
	end
	say("")
end

function AutoFlood_SelectProfile(profileId)
	if AF_characterConfig[tonumber(profileId)] == nil then
		say("Profile " .. profileId .. " does not exists")
		return
	end
	AutoFlood_Frame.currentProfile = profileId
	say("Current profile is " .. profileId)
end

function AutoFlood_AddProfile()
	table.insert(
		AF_characterConfig,
		{
			rate = 60,
			messages = {
				"AutoFlood ",
				"is running"
			},
			channels = {
				"say",
				"party"
			}
		}
	)
	say("Added")
end

function say(text, nl)
	nl = (nl == true)
	DEFAULT_CHAT_FRAME:AddMessage(text, 1, 1, 1)
	if nl then
		DEFAULT_CHAT_FRAME:AddMessage("", 1, 1, 1)
	end
end

function AutoFlood_RemoveProfile(id)
	if AF_characterConfig[tonumber(id)] == nil then
		say("Profile does not exists")
		return
	end
	AF_characterConfig[tonumber(id)] = nil
	AutoFlood_Frame.profiles[tonumber(id)] = nil
	if AutoFlood_Frame.currentProfile == id then
		AutoFlood_Frame.currentProfile = nil
	end
	say("Done")
end

function AutoFlood_ListProfileMessages()
	for messageNumber, messageText in pairs(AF_characterConfig[tonumber(AutoFlood_Frame.currentProfile)].messages) do
		say(messageNumber .. ": " .. messageText, "false")
	end
	say("")
end

function AutoFlood_AddMessageToProfile(messageText)
	if #AF_characterConfig[tonumber(AutoFlood_Frame.currentProfile)].messages > 1 then
		say("Profile " .. AutoFlood_Frame.currentProfile .. " already has 2 messages", "false")
		return
	end

	table.insert(
		AF_characterConfig[tonumber(AutoFlood_Frame.currentProfile)].messages,
		messageText
	)
	say("Added")
end

function AutoFlood_RemoveMessageFromProfile(messageId)
	if AF_characterConfig[tonumber(AutoFlood_Frame.currentProfile)].messages[tonumber(messageId)] == nil then
		say("Message does not exists")
		return
	end
	AF_characterConfig[tonumber(AutoFlood_Frame.currentProfile)].messages[tonumber(messageId)] = nil
	say("Done")
end

function AutoFlood_ListProfileChannels()
	for channelId, channelNumber in pairs(AF_characterConfig[tonumber(AutoFlood_Frame.currentProfile)].channels) do
		say(channelId .. ": " .. channelNumber, "false")
	end
	say("")
end

function AutoFlood_AddChannelToProfile(channelNumber)
	table.insert(
		AF_characterConfig[tonumber(AutoFlood_Frame.currentProfile)].channels,
		channelNumber
	)
	say("Channel " .. channelNumber .. " added to profile " .. AutoFlood_Frame.currentProfile)
end

function AutoFlood_RemoveChannelFromProfile(channelNumber)
	if AF_characterConfig[tonumber(AutoFlood_Frame.currentProfile)].channels[tonumber(channelNumber)] == nil then
		say("Channel does not exists in this profile")
		return
	end
	AF_characterConfig[tonumber(AutoFlood_Frame.currentProfile)].channels[tonumber(channelNumber)] = nil
	say("Done")
end

function AutoFlood_SetRate(rate)
	if rate ~= nil and tonumber(rate) > 0 and rate ~= "" then rate = tonumber(rate) end
	if rate >= MAX_RATE then
		AF_characterConfig[tonumber(AutoFlood_Frame.currentProfile)].rate = rate
		local s = string.gsub(AUTOFLOOD_RATE, "RATE", AF_characterConfig[tonumber(AutoFlood_Frame.currentProfile)].rate)
		say(s)
	else
		local s = string.gsub(AUTOFLOOD_ERR_RATE, "RATE", MAX_RATE)
		say(s)
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

--- /fl <profile_number>
-- @param s (string)
SlashCmdList["AUTOFLOOD"] = AutoFlood_State
-- /floodinfo
-- Display the parameters in chat window
SlashCmdList["AUTOFLOODINFO"] = AutoFlood_Info

-- /flpselect
SlashCmdList["AUTOFLOODPSELECT"] = AutoFlood_SelectProfile
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

SLASH_AUTOFLOODINFO1 = "/flinfo"

SLASH_AUTOFLOODPSELECT1 = "/flpselect"
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
