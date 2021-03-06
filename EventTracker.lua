--[[ =================================================================
    Description:
        EventTracker is a simple AddOn that informs, by means of a
        chat message, when specific events are triggered within the
        game.

        The main purpose is to determine which events get triggered
        at what stage, to ultimately get a better understanding about
        the internals of the game, and hopefully help out in identifying
        why certain things happen or things might be failing all together.

        Update the file EventTracker_events.lua to specify which events
        need to be tracked.

    Dependencies:
        None

    Credits:
        A big 'Thank You' to all the people at Blizzard Entertainment
        for making World of Warcraft.
    ================================================================= --]]

-- local variables
	local ET_FILTER = nil;
	

-- Local table functions
    local tinsert, wipe = table.insert, table.wipe;
    local lower, upper, substr = string.lower, string.upper, string.sub;
	
-- Stolen from Rivers
	function EventTracker_tconcat(t1, t2)
	  for _, v in ipairs(t2) do
		table.insert(t1, v)
	  end
	end
	
-- Send message to the default chat frame
    function EventTracker_Message( msg, prefix )
        -- Initialize
        local prefixText = "";

        -- Add application prefix
        if ( prefix and true ) then
            prefixText = C_GREEN..ET_NAME..": "..C_CLOSE;
        end;

        -- Send message to chatframe
        DEFAULT_CHAT_FRAME:AddMessage( prefixText..( msg or "" ) );
    end;

-- Handle EventTracker initialization
    function EventTracker_Init()
        -- Initiliaze all parts of the saved variable
        if ( not ET_Data ) then ET_Data = {}; end;
        if ( not ET_Data["active"] ) then ET_Data["active"] = true; end;
        if ( not ET_Data["events"] ) then ET_Data["events"] = {}; end;

        -- Register slash commands
        SlashCmdList["EVENTTRACKER"] = EventTracker_SlashHandler;
        SLASH_EVENTTRACKER1 = "/et";
        SLASH_EVENTTRACKER2 = "/eventtracker";
		
		-- Fill up the Array with the argument names
		EventTracker_GenerateEventArray()
    end;

-- Register events
    function EventTracker_RegisterEvents( self )
        -- Always track VARIABLES_LOADED
        self:RegisterEvent( "VARIABLES_LOADED" );

        -- Track other events
        for key, value in pairs( ET_TRACKED_EVENTS ) do
            self:RegisterEvent( strtrim( upper( value ) ) );
        end;
    end;

-- Remove the events listed to be ignored
    function EventTracker_RemoveIgnoredEvents()
        -- Track other events
        for key, value in pairs( ET_IGNORED_EVENTS ) do
            EventTracker:UnregisterEvent( strtrim( upper( value ) ) );
        end;
    end;

-- hardcoding all the wonderful CLEU event arguments
	function EventTracker_GenerateCombatlogArray()
		-- this arguments are the same for all CLEU events
		ET_Static['COMBAT_LOG_EVENT_UNFILTERED'] = {"timestamp", "subEvent", "hideCaster", "sourceGUID", "sourceName", "sourceFlags", "sourceRaidFlags", "destGUID", "destName", "destFlags", "destRaidFlags"}
	
		-- known SubEvent prefixes and arguments they add
		local Prefix = {
		["SWING"] = {},
		["RANGE"] = {"spellId", "spellName", "spellSchool"},
		["SPELL"] = {"spellId", "spellName", "spellSchool"},
		["SPELL_PERIODIC"] = {"spellId", "spellName", "spellSchool"},
		["SPELL_BUILDIUNG"] = {"spellId", "spellName", "spellSchool"},
		["ENVIROMENTAL"] = {"enviromentalType"}
		}
		-- known SubEvent suffixes and arguments they add
		local Suffix = {
		["_DAMAGE"] = {"amount", "overkill", "school", "resisted", "blocked", "absorbed", "critical", "glancing", "crushing", "isOffHand"},
		["_MISSED"] = {"missType", "isOffHand", "amountMissed"},
		["_HEAL"] = {"amount", "overhealing", "absorbed", "critical"},
		["_ENERGIZE"] = {"amount", "overEnergize", "powerType", "alternatePowerType"},
		["_DRAIN"] = {"amount", "powerType", "extraAmount"},
		["_LEECH"] = {"amount", "powerType", "extraAmount"},
		["_INTERRUPT"] = {"extraSpellId", "extraSpellName", "extraSchool"},
		["_DISPEL"] = {"extraSpellId", "extraSpellName", "extraSchool", "auraType"},
		["_DISPEL_FAILED"] = {"extraSpellId", "extraSpellName", "extraSchool"},
		["_STOLEN"] = {"extraSpellId", "extraSpellName", "extraSchool", "auraType"},
		["_EXTRA_ATTACKS"] = {"amount"},
		["_AURA_APPLIED"] = {"auraType", "amount"},
		["_AURA_REMOVED"] = {"auraType", "amount"},
		["_AURA_APPLIED_DOSE"] = {"auraType", "amount"},
		["_AURA_REMOVED_DOSE"] = {"auraType", "amount"},
		["_AURA_REFRESH"] = {"auraType", "amount"},
		["_AURA_BROKEN"] = {"auraType"},
		["_AURA_BROKEN_SPELL"] = {"extraSpellId", "extraSpellName", "extraSchool", "auraType"},
		["_CAST_START"] = {},
		["_CAST_SUCCESS"] = {},
		["_CAST_FAILED"] = {"failedType"},
		["_INSTAKILL"] = {},
		["_DURABILITY_DAMAGE"] = {},
		["_DURABILITY_DAMAGE_ALL"] = {},
		["_CREATE"] = {},
		["_SUMMON"] = {},
		["_RESURRECT"] = {}
		}
		
		local Parameters = {}
		-- now use the Hardcoded Arrays to fill up the Event Array with the CLEU event arguments
		for pre,params1 in pairs(Prefix) do
			for suf, params2 in pairs(Suffix) do
				Parameters = CopyTable(params1)
				EventTracker_tconcat(Parameters, CopyTable(params2))
				ET_Static["COMBAT_LOG_EVENT_UNFILTERED_" .. pre .. suf] = CopyTable(ET_Static["COMBAT_LOG_EVENT_UNFILTERED"])
				EventTracker_tconcat(ET_Static["COMBAT_LOG_EVENT_UNFILTERED_" .. pre .. suf], CopyTable(Parameters))
			end
		end
		
		--non base SubEvents
		ET_Static["COMBAT_LOG_EVENT_UNFILTERED_DAMAGE_SHIELD"] = ET_Static["COMBAT_LOG_EVENT_UNFILTERED_SPELL_DAMAGE"]
		ET_Static["COMBAT_LOG_EVENT_UNFILTERED_DAMAGE_SPLIT"] = ET_Static["COMBAT_LOG_EVENT_UNFILTERED_SPELL_DAMAGE"]
		ET_Static["COMBAT_LOG_EVENT_UNFILTERED_DAMAGE_MISSED"] = ET_Static["COMBAT_LOG_EVENT_UNFILTERED_SPELL_MISSED"]
		ET_Static["COMBAT_LOG_EVENT_UNFILTERED_PARTY_KILL"] = ET_Static["COMBAT_LOG_EVENT_UNFILTERED"]
		
		ET_Static["COMBAT_LOG_EVENT_UNFILTERED_ENCHANT_APPLIED"] = CopyTable(ET_Static["COMBAT_LOG_EVENT_UNFILTERED"])
		EventTracker_tconcat(ET_Static["COMBAT_LOG_EVENT_UNFILTERED_ENCHANT_APPLIED"], {"spellName", "itemID", "itemName"})
		
		ET_Static["COMBAT_LOG_EVENT_UNFILTERED_ENCHANT_REMOVED"] = CopyTable(ET_Static["COMBAT_LOG_EVENT_UNFILTERED"])
		EventTracker_tconcat(ET_Static["COMBAT_LOG_EVENT_UNFILTERED_ENCHANT_REMOVED"], {"spellName", "itemID", "itemName"})
		
		ET_Static["COMBAT_LOG_EVENT_UNFILTERED_UNIT_DIED"] = CopyTable(ET_Static["COMBAT_LOG_EVENT_UNFILTERED"])
		EventTracker_tconcat(ET_Static["COMBAT_LOG_EVENT_UNFILTERED_UNIT_DIED"], {"recapID", "unconsciousOnDeath"})
		
		ET_Static["COMBAT_LOG_EVENT_UNFILTERED_UNIT_DESTROYED"] = CopyTable(ET_Static["COMBAT_LOG_EVENT_UNFILTERED"])
		EventTracker_tconcat(ET_Static["COMBAT_LOG_EVENT_UNFILTERED_UNIT_DESTROYED"], {"recapID", "unconsciousOnDeath"})
		
		ET_Static["COMBAT_LOG_EVENT_UNFILTERED_UNIT_DISSIPATES"] = CopyTable(ET_Static["COMBAT_LOG_EVENT_UNFILTERED"])
		EventTracker_tconcat(ET_Static["COMBAT_LOG_EVENT_UNFILTERED_UNIT_DISSIPATES"], {"recapID", "unconsciousOnDeath"})
		
		-- Fallback
		EventTracker_tconcat(ET_Static["COMBAT_LOG_EVENT_UNFILTERED"], {"Arg 11","Arg 12","Arg 13","Arg 14","Arg 15","Arg 16","Arg 17","Arg 18","Arg 19","Arg 20","Arg 21","Arg 22","Arg 23","Arg 24"})
	end
	
-- Fill the event Array with the argument names
	function EventTracker_GenerateEventArray()
		-- all the Information needed is in the Blizzard APIDocumentation
		LoadAddOn("Blizzard_APIDocumentation")
		
		for i,v in ipairs(APIDocumentation['events']) do
			ET_Static[v['LiteralName']] = {}
			if (v['Payload']) then
				for j,k in ipairs(v['Payload']) do
					ET_Static[v['LiteralName']][j] = k['Name']
				end
			end
		end
		-- CLEU isn't Documented in the APIDocumentation need to hardcode it
		EventTracker_GenerateCombatlogArray()
		-- ET_Saved[Eventname] = {Parametername, functionname, wantedReturnValue, parameterFromParameter}
		-- ET_Saved["UNIT_SPELLCAST_START"] = {[1] = {"Spellname", "GetSpellInfo", 1, 3}}
		
		local extraArgs = {}
		for i,v in pairs(ET_Saved) do
			extraArgs = {}
			if (v) then
				for j,k in ipairs(v) do
					extraArgs[j] = "FAKE"..k[1]
				end
			end
			EventTracker_tconcat(ET_Static[i], CopyTable(extraArgs))
		end
	end
	
-- Handle startup of the addon
    function EventTracker_OnLoad( self )
		ET_Saved = ET_Saved or {}
        -- Show startup message
        EventTracker_Message( ET_STARTUP_MESSAGE, false );

        -- Register events to be monitored
        EventTracker_RegisterEvents( self );
    end;

-- Show or hide the Main dialog
    function EventTracker_Toggle_Main()
        if(  EventTracker.OptionsFrame:IsVisible() ) then
            EventTracker.OptionsFrame:Hide();
        else
            -- Show the frame
            EventTracker.OptionsFrame:Show();
            --EventTracker.OptionsFrame:SetBackdropColor( 0, 0, 0, .5 );

            -- Update the UI
            EventTracker_UpdateUI();
        end;
    end;

-- Show or hide the event detail dialog
    function EventTracker_Toggle_Details()
        if( EventTracker.OptionsFrame.EventDetail:IsVisible() ) then
            EventTracker.OptionsFrame.EventDetail:Hide();
            EventTracker.OptionsFrame.ExpandCollapseButton:SetText( ET_SHOW_DETAILS );
        else
            -- Show the frame
            EventTracker.OptionsFrame.EventDetail:Show();
            EventTracker.OptionsFrame.ExpandCollapseButton:SetText( ET_HIDE_DETAILS );
        end;
    end;

-- Purge data for specific event
    function EventTracker_PurgeEvent( purgeEvent )
        -- Purge highlevel event info
        ET_Events[purgeEvent].count = 0;

        -- Purge event details
        local length = #ET_EventDetail;

        -- Redraw items
        for index = length, 1, -1 do
            local event, timestamp, data, realevent, time_usage, call_stack = unpack( ET_EventDetail[index] );
            if ( event == purgeEvent ) then
                tremove( ET_EventDetail, index );
            end;
        end;

        -- Update UI elements
        --EventCallStack:SetText( "" );
        EventTracker_Scroll_Details();
        EventTracker_Scroll_Arguments();
        EventTracker_Scroll_Frames();
        EventTracker_UpdateUI();
    end;

-- Purge event data
    function EventTracker_Purge()
        -- Clear out old data
        wipe( ET_Events );
        wipe( ET_EventDetail );
        wipe( ET_ArgumentInfo );
        wipe( ET_FrameInfo );
        ET_CurrentEvent = nil;

        -- Update UI elements
        --EventCallStack:SetText( "" );
        EventTracker_Scroll_Details();
        EventTracker_Scroll_Arguments();
        EventTracker_Scroll_Frames();
        EventTracker_UpdateUI();
    end;

-- Add data to the tracking stack (for internal usage)
    local function EventTracker_AddInfo( event, data, realevent, time_usage, call_stack )
        -- Track details
        if (not ET_Events[event] ) then
            ET_Events[event] = {};
        end;
		
        ET_Events[event].count = ( ET_Events[event].count or 0 ) + 1;
        if ( time_usage ) then
            ET_Events[event].time = ( ET_Events[event].time or 0 ) + time_usage;
        end;
        tinsert( ET_EventDetail, { event, time(), data, realevent, time_usage, call_stack } );

        -- Update frame
        if(  EventTracker.OptionsFrame:IsVisible() ) then
            EventTracker_Scroll_Details();
            EventTracker_UpdateUI();
        end;
    end;

-- Add data to the tracking stack (for external usage)
    function EventTracker_TrackProc( procname, arginfo )
        -- Store original function
        ET_ProcList[procname] = _G[procname];

        -- Add argument information if provided
        if ( arginfo ) then
            ET_Static[procname] = arginfo;
        end;

        -- Define replacement function (includes timing information)
        _G[procname] = function( ... )
            local start = debugprofilestop();
            local retval = { ET_ProcList[procname]( ... ) };
            local usage = debugprofilestop() - start;
            local call_stack = debugstack( 2 );
            EventTracker_AddInfo( procname, { ... }, false, usage, call_stack );
            if ( retval ) then return unpack( retval ); end;
        end;
    end;

-- Handle events sent to the addon
    function EventTracker_OnEvent( self, event, ... )
		if (not ET_IGNORED_EVENTS[event]) then -- RegisterAllEvents change bfa
			local logEvent = true;
			local args = {}
			
			if ( event == "VARIABLES_LOADED") then
				EventTracker_Init();
			end;

			-- Store event data
			if ( ET_Data["active"] ) then
				if ET_FILTER then
					-- Prevent event from being logged when it does not match the filter
					if not event:find( ET_FILTER, 1, true ) then
						logEvent = false;
					end;

					-- But be sure to include it when it appears within ET_TRACKED_EVENTS
					if tContains( ET_TRACKED_EVENTS, event ) then
						logEvent = true;
					end;
				end;

				if ( logEvent ) then
					-- in case of a CLEU event get the event arguments from the API and add the subEvent to the event name for changing arguments
					if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
						args = {CombatLogGetCurrentEventInfo()}
						if (ET_Static[event .. "_" .. args[2]]) then
							event = event .. "_" .. args[2]
						end
					elseif (...) then
						args = {...}
					end
					if (ET_Saved[event]) then
						for i,v in ipairs(ET_Saved[event]) do
							tinsert(args, (select(v[3], assert(loadstring('return '..v[2]..'(...)'))(args[v[4]]))))
						end
					end
					EventTracker_AddInfo( event, args , true );
				end;
			end;
		end
     end;
-- Build strings for argument names and data (incl proper colors and nil handling)
    function EventTracker_GetStrings( event, index, value )
        local argName, argData;

        if ( ET_Static[event] ) then
            argName = ( ET_Static[event][index] or ET_UNKNOWN );
        else
            argName = index;
        end;

        argData = tostring( value or ET_NIL );

        return C_BLUE..argName..C_CLOSE, C_YELLOW..argData..C_CLOSE;
    end;

-- Scroll function for event details
    function EventTracker_Scroll_Details()
        local length = #ET_EventDetail;
        local line, index, button, argInfo, argName, argData;
        local offset = FauxScrollFrame_GetOffset( EventTracker.OptionsFrame.EventScroll );
        local argName, argData;

        -- Update scrollbars
        FauxScrollFrame_Update( EventTracker.OptionsFrame.EventScroll, length+1, ET_DETAILS, 30 );

        -- Redraw items
        for line = 1, ET_DETAILS, 1 do
            index = offset + line;
            button = EventTracker.OptionsFrame.EventItem[line];
            button:SetID( line );
            button:SetAttribute( "index", index );
            if index <= length then
                local event, timestamp, data, realevent, time_usage, call_stack = unpack( ET_EventDetail[index] );
                button.InfoEvent:SetText( event );
                button.InfoTimestamp:SetText( date( "%Y-%m-%d %H:%M:%S", timestamp ) );
                argInfo = "";
				
                for key, value in pairs( data ) do
                    argName, argData = EventTracker_GetStrings( event, key, value );
                    argInfo = argInfo..", "..argName.." = "..argData;
                end;
                button.InfoData:SetText( substr( argInfo, 3 ) );
                button:Show();
                button:Enable();
            else
                button:Hide();
            end;
        end;
    end;

-- Scroll function for event arguments
    function EventTracker_Scroll_Arguments()
        local length = #ET_ArgumentInfo;
        local line, index, button, argName, argData;
        local offset = FauxScrollFrame_GetOffset( EventTracker.OptionsFrame.EventDetail.ArgumentScroll );

        FauxScrollFrame_Update( EventTracker.OptionsFrame.EventDetail.ArgumentScroll, length+1, ET_ARGUMENTS, 16 );

        -- Redraw items
        for line = 1, ET_ARGUMENTS, 1 do
            index = offset + line;
            button = EventTracker.OptionsFrame.EventDetail.EventArgument[line];
            button:SetID( line );
            button:SetAttribute( "index", index );
            if index <= length then
                argName, argData = EventTracker_GetStrings( ET_CurrentEvent, index, ET_ArgumentInfo[index] );
                button.InfoArgument:SetText( argName );
                button.InfoData:SetText( argData );
                button:Show();
                button:Enable();
            else
                button:Hide();
            end;
        end;
    end;

-- Scroll function for frames registered
    function EventTracker_Scroll_Frames()
        local length = #ET_FrameInfo;
        local line, index, button;
        local offset = FauxScrollFrame_GetOffset( EventTracker.OptionsFrame.EventDetail.EventScroll );

        -- Update scrollbars
        FauxScrollFrame_Update( EventTracker.OptionsFrame.EventDetail.EventScroll, length+1, ET_FRAMES, 16 );

        -- Redraw items
        for line = 1, ET_FRAMES, 1 do
            index = offset + line;
            button = EventTracker.OptionsFrame.EventDetail.EventFrame[line];
            button:SetID( line );
            button:SetAttribute( "index", index );
            if index <= length then
                button.InfoFrame:SetText( ( ET_FrameInfo[index]:GetName() or ET_UNNAMED_FRAME ) );
                button:Show();
                button:Enable();
            else
                button:Hide();
            end;
        end;
    end;

-- Update the UI
    function EventTracker_UpdateUI( currenttime )
        -- Number of events caught
        EventTracker.OptionsFrame.EventCount:SetText( ET_EVENT_COUNT:format( #ET_EventDetail ) );

        -- Number of events that are being tracked
        EventTracker.OptionsFrame.EventsTracked:SetText( ET_EVENTS_TRACKED:format( #ET_TRACKED_EVENTS ) );

        -- Memory usage
        EventTracker.OptionsFrame.EventMemory:SetText( ET_MEMORY:format( GetAddOnMemoryUsage( "EventTracker" ) ) );

        -- Update tracking state
        EventTracker.OptionsFrame.TrackingState:SetText( ET_TRACKING:format( lower( gsub( gsub( tostring( ET_Data["active"] ), "true", ET_STATE_ON ), "false", ET_STATE_OFF ) ) ) );

        -- Update current event for details
        if ( ET_CurrentEvent ) then
            EventTracker.OptionsFrame.EventDetail.CurrentEventName:SetText( ET_CurrentEvent.." ["..ET_Events[ET_CurrentEvent].count.."]" );
            EventTracker.OptionsFrame.EventDetail.EventTimeCurrent:SetText( ET_TIME_CURRENT:format( currenttime or 0 ) );
            EventTracker.OptionsFrame.EventDetail.EventTimeTotal:SetText( ET_TIME_TOTAL:format( ET_Events[ET_CurrentEvent].time or 0 ) );
        else
            EventTracker.OptionsFrame.EventDetail.CurrentEventName:SetText( ET_UNKNOWN );
            EventTracker.OptionsFrame.EventDetail.EventTimeCurrent:SetText( ET_TIME_CURRENT:format( 0 ) );
            EventTracker.OptionsFrame.EventDetail.EventTimeTotal:SetText( ET_TIME_TOTAL:format( 0 ) );
        end;
    end;

-- Toggle tracking
    function EventTracker_Toggle()
        ET_Data["active"] = not ET_Data["active"];
        EventTracker_UpdateUI();
    end;

-- Handle click on event item
    function EventTracker_EventOnClick( self, button, down )
        local event, timestamp, data, realevent, time_usage, call_stack = unpack( ET_EventDetail[ FauxScrollFrame_GetOffset( EventTracker.OptionsFrame.EventScroll ) + self:GetID() ] );

        if ( IsShiftKeyDown() ) then
            EventTracker_PurgeEvent( event );
			if (string.find(event, "COMBAT_LOG_EVENT_UNFILTERED")) then
				event = "COMBAT_LOG_EVENT_UNFILTERED"
			end
			ET_IGNORED_EVENTS[event] = true; -- RegisterAllEvents change bfa
            EventTracker:UnregisterEvent( event );
            DEFAULT_CHAT_FRAME:AddMessage( ET_REMOVED:format(event) );
        else
            if ( button == "LeftButton" ) then
                if ( realevent ) then
                    ET_FrameInfo = { GetFramesRegisteredForEvent( event ) };
                    EventTracker.OptionsFrame.EventDetail.FrameHeading:SetText( ET_REGISTERED_TEXT );
                    --EventCallStack:SetText( "" );
                else
                    wipe( ET_FrameInfo );
                    EventTracker.OptionsFrame.EventDetail.FrameHeading:SetText( ET_CALLSTACK_TEXT );
                    --EventCallStack:SetText( call_stack );
                end;
                ET_ArgumentInfo = data;
                ET_CurrentEvent = event;
                EventTracker_Scroll_Arguments();
                EventTracker_Scroll_Frames();
                EventTracker_UpdateUI( time_usage );

                -- Show the detail window if not already showing
                if ( not EventTracker.OptionsFrame.EventDetail:IsVisible() ) then
                    EventTracker_Toggle_Details();
                end;
            end;
        end;
    end;

-- Show help message
    function EventTracker_ShowHelp()
        for key, value in pairs( ET_HELP ) do
            EventTracker_Message( value );
        end;
    end;

-- Handle slash commands
    function EventTracker_SlashHandler( msg, editbox )
        -- arguments should be handled case-insensitve
        local command, event = strsplit( " ", msg );

        command = strlower( command or "" );
        event = strtrim( strupper( event or "" ) );

        -- Handle each individual argument
        if ( command == "" ) then
            -- Show main dialog
            EventTracker_Toggle_Main();

        elseif ( command == "resetpos" ) then
            EventTracker.OptionsFrame:ClearAllPoints();
            EventTracker.OptionsFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0);

        elseif ( command == "add" ) then
            -- Add event to be tracked
            EventTracker:RegisterEvent( event );
			ET_IGNORED_EVENTS[event] = false; -- RegisterAllEvents change bfa

        elseif ( command == "remove" ) then
            -- Remove event to be tracked
            EventTracker:UnregisterEvent( event );
			ET_IGNORED_EVENTS[event] = true; -- RegisterAllEvents change bfa

        elseif ( command == "registerall" ) then
            -- Track all events
            EventTracker:RegisterAllEvents();
			ET_IGNORED_EVENTS = {}; -- RegisterAllEvents change bfa
            -- EventTracker_RemoveIgnoredEvents(); doenst work in bfa

        elseif ( command == "unregisterall" ) then
            -- Track all events
            EventTracker:UnregisterAllEvents();
            EventTracker:RegisterEvent( "VARIABLES_LOADED" );

        elseif ( command == "filter" ) then
            -- Set filter to be applied to registerall events
            ET_FILTER = event;

        elseif ( command == "removefilter" ) then
            -- Remove the filter
            ET_FILTER = nil;

        elseif ( msg == "help" ) or ( msg == "?" ) then
            -- Show help info
            EventTracker_ShowHelp();
        end;
    end;
