--[[ =================================================================
    Description:
        All globals used within EventTracker.

    Revision:
        $Id: EventTracker_globals.lua 772 2013-02-05 15:32:54Z fmeus_lgs $
    ================================================================= --]]

-- Colors used within EventTracker
    C_BLUE   = "|cFF3366FF";
    C_RED    = "|cFFFF5533";
    C_YELLOW = "|cFFFFFF00";
    C_GREEN  = "|cFF00FF00";
    C_CLOSE  = "|r";

-- Global strings
    ET_NAME = GetAddOnMetadata( "EventTracker", "Title" );
    ET_VERSION = GetAddOnMetadata( "EventTracker", "Version" );
    ET_NAME_VERSION = ET_NAME.." - "..ET_VERSION;
    ET_STARTUP_MESSAGE = ET_NAME.." ("..C_GREEN..ET_VERSION..C_CLOSE..") loaded.";
    ET_NIL = "<"..C_RED.."nil"..C_CLOSE..">";
    ET_UNKNOWN = "***";

-- Data arrays
    ET_Events = {};
    ET_EventDetail = {};
    ET_FrameInfo = {};
    ET_ArgumentInfo = {};
    ET_CurrentEvent = nil;
    ET_ProcList = {};

-- Scroll frame
    ET_DETAILS = 10; -- Number of event lines
    ET_ARGUMENTS = 10; -- Number of argument lines
    ET_FRAMES = 7; -- Number of frame lines