AutoFlood
=========
Autoflood periodically sends messages to chat. Profile structure is following:
```
- profile
    - rate
    - messages
      - message1
      - message2
    - channels
      - chan1
      - chan2
      - chan3  
```

Maximum 2 messages per profile, because otherwise you'll get chat restriction.
Make sure that channels do not intersect between profiles, because otherwise you might send more than two messages per channel and get chat restriction. 

* `/fl [on|off]` : Start / stops sending all profiles.
* `/fl [on|off] <profile_number>` : Start / stops certain profile.
* `/floodinfo` : Displays the profiles and the parameters.
* `/flpadd` : Add profile.
* `/flprm <profile_number>` : Remove profile.
* `/flmlist <profile_number>` : List messages within profile.
* `/flmadd <profile_number> <message_text>` : Add message to profile. Max 2 messages.
* `/flmrm <profile_number> <message_id>` : Remove message from profile by ID (/flmlist).
* `/flchanlist <profile_number>` : List channels for profile.
* `/flchanadd <profile_number> <channel>` : Add channel to profile.
* `/flchanrm <profile_number> <channel>` : Remove channel from profile by ID.
* `/flrate <profile_number> <duration>` : Set duration for profile.
* `/floodhelp` : Displays this help message.

The settings are saved per character/realm.
