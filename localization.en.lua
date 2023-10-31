-- Version : English (default) ( by @project-author@ )
-- Last Update : 22/05/2006


AUTOFLOOD_LOAD = "AutoFlood (custom) loaded. Type /floodhelp for help."

AUTOFLOOD_STATS_PROFILE = "PROFILES_AMOUNT profiles are set, current profile is: CURRENT_PROFILE"
AUTOFLOOD_STATS = "Following messages are send into CHANNELS every RATE seconds:"

AUTOFLOOD_MESSAGE = "The message is now \"MESSAGE\"."
AUTOFLOOD_RATE = "The message is now sent every RATE seconds."
AUTOFLOOD_CHANNEL = "The message is now sent in channel /CHANNEL."

AUTOFLOOD_ACTIVE = "AutoFlood is enabled."
AUTOFLOOD_INACTIVE = "AutoFlood is disabled."

AUTOFLOOD_ERR_CHAN = "The channel /CHANNEL doesn't exist."
AUTOFLOOD_ERR_RATE = "You can't send messages less than every RATE seconds."

AUTOFLOOD_HELP = {
	"===================== Auto Flood =====================",
	"/fl [on|off] : Start / stops sending all profiles.",
	"/fl [on|off] <profile_number> : Start / stops certain profile.",
	"/floodinfo : Displays the profiles and the parameters.",
	"/flpadd : Add profile.",
	"/flprm <profile_number> : Remove profile.",
	"/flmlist <profile_number> : List messages within profile.",
	"/flmadd <profile_number> <message_text> : Add message to profile. Max 2 messages.",
	"/flmrm <profile_number> <message_id> : Remove message from profile by ID (/flmlist).",
	"/flchanlist <profile_number> : List channels for profile.",
	"/flchanadd <profile_number> <channel> : Add channel to profile.",
	"/flchanrm <profile_number> <channel> : Remove channel from profile by ID.",
	"/flrate <profile_number> <duration> : Set duration for profile.",
	"/floodhelp : Displays this help message."
}
