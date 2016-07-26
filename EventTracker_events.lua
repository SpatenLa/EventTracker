--[[ =================================================================
    Description:
        Use this file to specify which events need to be tracked.
    ================================================================= --]]

-- Events to be tracked
    ET_TRACKED_EVENTS = {
        "CHAT_MSG_GUILD",
        "PLAYERREAGENTBANKSLOTS_CHANGED",
    };

-- Events to be ignored (applied when using /registerall)
    ET_IGNORED_EVENTS = {
        "BAG_UPDATE_COOLDOWN",
        "ACTIONBAR_UPDATE_COOLDOWN",
        "SPELL_UPDATE_COOLDOWN",
        "CURSOR_UPDATE",
        "CRITERIA_UPDATE",
        "UPDATE_MOUSEOVER_UNIT",
    };
