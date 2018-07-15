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
        ["BAG_UPDATE_COOLDOWN"] = true,
        ["ACTIONBAR_UPDATE_COOLDOWN"] = true,
        ["SPELL_UPDATE_COOLDOWN"] = true,
        ["CURSOR_UPDATE"] = true,
        ["CRITERIA_UPDATE"] = true,
        ["UPDATE_MOUSEOVER_UNIT"] = true,
    };
