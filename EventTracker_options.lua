--[[ =================================================================
    Description:
        Options Code instaed of XML

    Dependencies:
        None

    Credits:
        A big 'Thank You' to all the people at Blizzard Entertainment
        for making World of Warcraft.
    ================================================================= --]]

    EventTracker = CreateFrame("Frame", "EventTracker", UIParent)
    --EventTracker:SetScript("OnLoad", EventTracker_OnLoad)
    EventTracker:SetScript("OnEvent", EventTracker_OnEvent)
    
    --Dialog template
    local function createFromDialogTemplate(name, ...)
        local frame = CreateFrame("Frame", name, UIParent, BackdropTemplateMixin and "BackdropTemplate", ...);
        
        frame:SetFrameStrata("DIALOG")
        frame:SetSize(700, 410)
        frame:SetBackdrop({
            bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
            edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
            tile = true,
            tileEdge = false,
            tileSize = 32,
            edgeSize = 32,
            insets = {left = 11, right = 12, top = 12, bottom = 11}
        })
        frame:SetPoint("CENTER")
        frame:Hide()
        frame:SetScript("OnMouseDown", function() frame:StartMoving() end)
        frame:SetScript("onMouseUp", function() frame:StopMovingOrSizing() end)
        frame:SetScript("onDragStop", function() frame:StopMovingOrSizing() end)
        return frame
    end

    --Template button for event details
    local function createFromDetailButtonTemplate(name, parent, ...)
        local frame = CreateFrame("Button", name, parent, ...)
        frame:SetSize(645, 30)

        frame.InfoEvent = frame:CreateFontString(nil, "BORDER", "GameFontNormalSmall")
        frame.InfoEvent:SetJustifyH("LEFT")
        frame.InfoEvent:SetPoint("TOPLEFT", 10, -2)
        frame.InfoEvent:SetSize(200, 12)

        frame.InfoTimestamp = frame:CreateFontString(nil, "BORDER", "GameFontHighlightSmall")
        frame.InfoTimestamp:SetJustifyH("LEFT")
        frame.InfoTimestamp:SetPoint("TOPLEFT", frame.InfoEvent, "BOTTOMLEFT")
        frame.InfoTimestamp:SetSize(200, 12)

        frame.InfoData = frame:CreateFontString(nil, "BORDER", "GameFontNormalSmall")
        frame.InfoData:SetJustifyH("LEFT")
        frame.InfoData:SetJustifyV("TOP")
        frame.InfoData:SetPoint("TOPLEFT", frame.InfoEvent, "TOPRIGHT", 5, 2)
        frame.InfoData:SetSize(430, 30)

        frame:RegisterForClicks("LeftButtonUp")
        frame:EnableMouseWheel(false)
        frame:SetScript("onClick", EventTracker_EventOnClick)
        frame:SetHighlightTexture("Interface/QuestFrame/UI-QuestTitleHighlight", "ADD")
        return frame
    end

    --Template button for event arguments
    local function createFromArgumentButtonTemplate(name, parent, ...)
        local frame = CreateFrame("Button", name, parent, ...)
        frame:SetSize(395, 16)

        frame.InfoArgument = frame:CreateFontString(nil, "BORDER", "GameFontNormal")
        frame.InfoArgument:SetJustifyH("LEFT")
        frame.InfoArgument:SetPoint("TOPLEFT", 10, 0)
        frame.InfoArgument:SetSize(150, 16)

        frame.InfoData = frame:CreateFontString(nil, "BORDER", "GameFontNormal")
        frame.InfoData:SetJustifyH("LEFT")
        frame.InfoData:SetPoint("TOPLEFT", frame.InfoArgument, "TOPRIGHT", 5, 0)
        frame.InfoData:SetSize(230, 16)
        frame:EnableMouseWheel(false)

        frame:SetHighlightTexture("Interface/QuestFrame/UI-QuestTitleHighlight", "ADD")
        return frame
    end

    --Template button for event frames
    local function createFromEventButtonTemplate(name, parent, ...)
        local frame = CreateFrame("Button", name, parent, ...)
        frame:SetSize(395, 16)

        frame.InfoFrame = frame:CreateFontString(nil, "BORDER", "GameFontNormal")
        frame.InfoFrame:SetJustifyH("LEFT")
        frame.InfoFrame:SetPoint("TOPLEFT", 10, 0)
        frame.InfoFrame:SetSize(395, 16)
        frame:EnableMouseWheel(false)

        frame:SetHighlightTexture("Interface/QuestFrame/UI-QuestTitleHighlight", "ADD")
        return frame
    end

    --Main EventTracker frame  EventTrackerFrame
    EventTracker.OptionsFrame = createFromDialogTemplate(nil)
    EventTracker.OptionsFrame:SetFrameStrata("MEDIUM")
    EventTracker.OptionsFrame:EnableMouse(true)
    EventTracker.OptionsFrame:SetMovable(true)
    --EventTracker.OptionsFrame:SetResizeable(true)
    EventTracker.OptionsFrame:SetScript("onShow", EventTracker_Scroll_Details)

    --Artwork layer
    --Frame title texture/border
    local tempTexture = EventTracker.OptionsFrame:CreateTexture(nil, "ARTWORK")
    tempTexture:SetSize(400, 64)
    tempTexture:SetTexture("Interface/DialogFrame/UI-DialogBox-Header")
    tempTexture:SetPoint("TOP", 0, 12)

    --Frame title
    local tempFont = EventTracker.OptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    tempFont:SetText(ET_NAME_VERSION)
    tempFont:SetPoint("TOP", 0, -2)

    --Event count
    EventTracker.OptionsFrame.EventsTracked = EventTracker.OptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    EventTracker.OptionsFrame.EventsTracked:SetText(ET_EVENTS_TRACKED)
    EventTracker.OptionsFrame.EventsTracked:SetPoint("TOPLEFT", 18, -16)

    --Event count
    EventTracker.OptionsFrame.EventCount = EventTracker.OptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    EventTracker.OptionsFrame.EventCount:SetText(ET_EVENT_COUNT)
    EventTracker.OptionsFrame.EventCount:SetPoint("TOPLEFT", EventTracker.OptionsFrame.EventsTracked, "BOTTOMLEFT", 0, -2)

    --Memory usage
    EventTracker.OptionsFrame.EventMemory = EventTracker.OptionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    EventTracker.OptionsFrame.EventMemory:SetText(ET_MEMORY)
    EventTracker.OptionsFrame.EventMemory:SetPoint("TOPLEFT", EventTracker.OptionsFrame.EventCount, "BOTTOMLEFT", 0, -2)

    --Frames

    --Detail frame
    EventTracker.OptionsFrame.EventDetail = CreateFrame("Frame", nil, EventTracker.OptionsFrame, BackdropTemplateMixin and "BackdropTemplate")
    EventTracker.OptionsFrame.EventDetail:SetFrameStrata("BACKGROUND")
    
    EventTracker.OptionsFrame.EventDetail:SetSize(450, 392)
    EventTracker.OptionsFrame.EventDetail:SetPoint("LEFT", EventTracker.OptionsFrame, "RIGHT", -12, 0)
    EventTracker.OptionsFrame.EventDetail:SetBackdrop({
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        tile = true,
        tileEdge = false,
        tileSize = 32,
        edgeSize = 32,
        insets = {left = 11, right = 12, top = 12, bottom = 11}
    })
    EventTracker.OptionsFrame.EventDetail:Hide()
    
    --Heading
    EventTracker.OptionsFrame.EventDetail.CurrentEventName = EventTracker.OptionsFrame.EventDetail:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    EventTracker.OptionsFrame.EventDetail.CurrentEventName:SetPoint("TOP", 0, -16)

    --Frames

    --Scroll area for argument information
    local tempFrame = CreateFrame("Frame", nil, EventTracker.OptionsFrame.EventDetail, BackdropTemplateMixin and "BackdropTemplate")
    tempFrame:SetSize(420, 169)
    tempFrame:SetPoint("TOPLEFT", EventTracker.OptionsFrame.EventDetail, "TOPLEFT", 15, -50)
    tempFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = false,
        tileEdge = false,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = 5, right = 5, top = 5, bottom = 5}
    })
    tempFrame:SetBackdropColor(0, 0, 0, 0.5)
    tempFrame:EnableMouseWheel(1)
    tempFrame:SetScript("OnMouseWheel", function(self, delta) 
        local height = 16
        local scrollFrameHeight = (#ET_ArgumentInfo - ET_ARGUMENTS + 1) * height
        local offset = (EventTracker.OptionsFrame.EventDetail.ArgumentScroll.offset - delta) * height
        offset = max(min(offset, scrollFrameHeight), 0)
        FauxScrollFrame_OnVerticalScroll(EventTracker.OptionsFrame.EventDetail.ArgumentScroll, offset, height, EventTracker_Scroll_Arguments)
    end)

    --Heading
    local tempFont = tempFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    tempFont:SetText(ET_ARGUMENTS_TEXT)
    tempFont:SetPoint("TOPLEFT", 4, 14)

    --Timing information
    EventTracker.OptionsFrame.EventDetail.EventTimeCurrent = tempFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    EventTracker.OptionsFrame.EventDetail.EventTimeCurrent:SetText(ET_TIME_CURRENT)
    EventTracker.OptionsFrame.EventDetail.EventTimeCurrent:SetPoint("TOPLEFT", tempFrame, "BOTTOMLEFT", 4, 0)

    EventTracker.OptionsFrame.EventDetail.EventTimeTotal = tempFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    EventTracker.OptionsFrame.EventDetail.EventTimeTotal:SetText(ET_TIME_Total)
    EventTracker.OptionsFrame.EventDetail.EventTimeTotal:SetPoint("TOPRIGHT", tempFrame, "BOTTOMRIGHT", -4, 0)

    --Argument buttons
    EventTracker.OptionsFrame.EventDetail.EventArgument = {}
    EventTracker.OptionsFrame.EventDetail.EventArgument[1] = createFromArgumentButtonTemplate(nil, tempFrame)
    EventTracker.OptionsFrame.EventDetail.EventArgument[1]:SetPoint("TOPLEFT", tempFrame, "TOPLEFT", 0, -5)

    for i=2, ET_ARGUMENTS, 1 do
        EventTracker.OptionsFrame.EventDetail.EventArgument[i] = createFromArgumentButtonTemplate(nil, tempFrame)
        EventTracker.OptionsFrame.EventDetail.EventArgument[i]:SetPoint("TOP", EventTracker.OptionsFrame.EventDetail.EventArgument[i-1], "BOTTOM")
    end

    --Scroll buttons
    EventTracker.OptionsFrame.EventDetail.ArgumentScroll = CreateFrame("ScrollFrame", nil, EventTracker.OptionsFrame.EventDetail, "FauxScrollFrameTemplate")
    
    EventTracker.OptionsFrame.EventDetail.ArgumentScroll:SetSize(16, 159)
    EventTracker.OptionsFrame.EventDetail.ArgumentScroll:SetPoint("TOPRIGHT", tempFrame, "TOPRIGHT", -28, -6)
    EventTracker.OptionsFrame.EventDetail.ArgumentScroll:SetScript("OnVerticalScroll", function(self, offset) FauxScrollFrame_OnVerticalScroll(self, offset, 16, EventTracker_Scroll_Arguments) end)

    -- Scroll area for frame information
    local anchorFrame = tempFrame
    local tempFrame = CreateFrame("Frame", nil, EventTracker.OptionsFrame.EventDetail, BackdropTemplateMixin and "BackdropTemplate")
    tempFrame:EnableMouse(true)
    tempFrame:SetSize(420, 122)
    tempFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -35)
    tempFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = false,
        tileEdge = false,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = 5, right = 5, top = 5, bottom = 5}
    })
    tempFrame:SetBackdropColor(0, 0, 0, 0.5)
    tempFrame:EnableMouseWheel(1)
    tempFrame:SetScript("OnMouseWheel", function(self, delta)
        local height = 16
        local scrollFrameHeight = (#ET_FrameInfo - ET_FRAMES + 1) * height
        local offset = (EventTracker.OptionsFrame.EventDetail.EventScroll.offset - delta) * height
        offset = max(min(offset, scrollFrameHeight), 0)
        FauxScrollFrame_OnVerticalScroll(EventTracker.OptionsFrame.EventDetail.EventScroll, offset, height, EventTracker_Scroll_Frames)
    end)

    EventTracker.OptionsFrame.EventDetail.FrameHeading = tempFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    EventTracker.OptionsFrame.EventDetail.FrameHeading:SetPoint("TOPLEFT", 4, 14)

    --Frame buttons
    EventTracker.OptionsFrame.EventDetail.EventFrame = {}
    EventTracker.OptionsFrame.EventDetail.EventFrame[1] = createFromEventButtonTemplate("EventFrame1", tempFrame)
    EventTracker.OptionsFrame.EventDetail.EventFrame[1]:SetPoint("TOPLEFT", tempFrame, "TOPLEFT", 0, -5)
    for i=2, ET_FRAMES, 1 do
        EventTracker.OptionsFrame.EventDetail.EventFrame[i] = createFromEventButtonTemplate(nil, tempFrame)
        EventTracker.OptionsFrame.EventDetail.EventFrame[i]:SetPoint("TOP", EventTracker.OptionsFrame.EventDetail.EventFrame[i-1], "BOTTOM")
    end

    EventTracker.OptionsFrame.EventDetail.EventScroll = CreateFrame("ScrollFrame", nil, EventTracker.OptionsFrame.EventDetail, "FauxScrollFrameTemplate")
    
    EventTracker.OptionsFrame.EventDetail.EventScroll:SetSize(16, 111)
    EventTracker.OptionsFrame.EventDetail.EventScroll:SetPoint("TOPRIGHT", tempFrame, "TOPRIGHT", -28, -6)
    EventTracker.OptionsFrame.EventDetail.EventScroll:SetScript("OnVerticalScroll", function(self, offset) FauxScrollFrame_OnVerticalScroll(self, offset, 16, EventTracker_Scroll_Frames) end)



    --Scroll area for event details
    local tempFrame = CreateFrame("Frame", nil, EventTracker.OptionsFrame, BackdropTemplateMixin and "BackdropTemplate")
    tempFrame:EnableMouse(true)
    tempFrame:SetSize(670, 310)
    tempFrame:SetPoint("TOPLEFT", EventTracker.OptionsFrame, "TOPLEFT", 15, -60)
    tempFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = false,
        tileEdge = false,
        tileSize = 16,
        edgeSize = 16,
        insets = {left = 5, right = 5, top = 5, bottom = 5}
    })
    tempFrame:SetBackdropColor(0, 0, 0, 0.5)
    tempFrame:EnableMouseWheel(true)
    tempFrame:SetScript("OnMouseWheel", function(self, delta)
        local height = 30
        local scrollFrameHeight = (#ET_EventDetail - ET_DETAILS + 1) * height
        local offset = (EventTracker.OptionsFrame.EventScroll.offset - delta) * height
        offset = max(min(offset, scrollFrameHeight), 0)
        FauxScrollFrame_OnVerticalScroll(EventTracker.OptionsFrame.EventScroll, offset, height, EventTracker_Scroll_Details)
    end)

    EventTracker.OptionsFrame.EventItem = {}
    EventTracker.OptionsFrame.EventItem[1] = createFromDetailButtonTemplate(nil, tempFrame)
    EventTracker.OptionsFrame.EventItem[1]:SetPoint("TOPLEFT", tempFrame, "TOPLEFT", 0, -5)
    for i=2, ET_DETAILS, 1 do
        EventTracker.OptionsFrame.EventItem[i] = createFromDetailButtonTemplate(nil, tempFrame)
        EventTracker.OptionsFrame.EventItem[i]:SetPoint("TOP", EventTracker.OptionsFrame.EventItem[i-1], "BOTTOM")
        if i%2 == 0 then
            local tempTexture = EventTracker.OptionsFrame.EventItem[i]:CreateTexture(nil, "BACKGROUND")
            tempTexture:SetColorTexture(0.2, 0.2, 0.2, 0.5)
            tempTexture:SetAllPoints(EventTracker.OptionsFrame.EventItem[i])
        end
    end

    --Scroll buttons
    EventTracker.OptionsFrame.EventScroll = CreateFrame("ScrollFrame", nil, EventTracker.OptionsFrame, "FauxScrollFrameTemplate")

    EventTracker.OptionsFrame.EventScroll:SetSize(16, 299)
    EventTracker.OptionsFrame.EventScroll:SetPoint("TOPRIGHT", tempFrame, "TOPRIGHT", -28, -6)
    EventTracker.OptionsFrame.EventScroll:SetScript("OnVerticalScroll", function(self, offset) FauxScrollFrame_OnVerticalScroll(self, offset, 30, EventTracker_Scroll_Details) end)
   
   --Expand/Collapse button
    EventTracker.OptionsFrame.ExpandCollapseButton = CreateFrame("Button", nil, EventTracker.OptionsFrame, "UIPanelButtonTemplate")
    EventTracker.OptionsFrame.ExpandCollapseButton:SetText(ET_SHOW_DETAILS)
    EventTracker.OptionsFrame.ExpandCollapseButton:SetSize(130, 21)
    EventTracker.OptionsFrame.ExpandCollapseButton:SetPoint("BOTTOMRIGHT", tempFrame, "TOPRIGHT", 0, 5)
    EventTracker.OptionsFrame.ExpandCollapseButton:SetScript("OnClick", EventTracker_Toggle_Details)

    --Close button
    local closeButton = CreateFrame("Button", nil, EventTracker.OptionsFrame, "UIPanelButtonTemplate")
    closeButton:SetText(ET_CLOSE_BUTTON)
    closeButton:SetSize(100, 21)
    closeButton:SetPoint("BOTTOMRIGHT", EventTracker.OptionsFrame, "BOTTOMRIGHT", -15, 15)
    closeButton:SetScript("OnClick", EventTracker_Toggle_Main)

    --Purge Button
    local purgeButton = CreateFrame("Button", nil, EventTracker.OptionsFrame, "UIPanelButtonTemplate")
    purgeButton:SetText(ET_PURGE_BUTTON)
    purgeButton:SetSize(100, 21)
    purgeButton:SetPoint("TOPRIGHT", closeButton, "TOPLEFT", 0, 0)
    purgeButton:SetScript("OnClick", EventTracker_Purge)

    --OnOff button
    local onOffButton = CreateFrame("Button", nil, EventTracker.OptionsFrame, "UIPanelButtonTemplate")
    onOffButton:SetText(ET_STATE_ONOFF)
    onOffButton:SetSize(100, 21)
    onOffButton:SetPoint("BOTTOMLEFT", EventTracker.OptionsFrame, "BOTTOMLEFT", 15, 15)
    onOffButton:SetScript("OnClick", EventTracker_Toggle)

    --Tracking state
    EventTracker.OptionsFrame.TrackingState = EventTracker.OptionsFrame:CreateFontString(nil, nil, "GameFontHighlightSmall")
    EventTracker.OptionsFrame.TrackingState:SetJustifyH("LEFT")
    EventTracker.OptionsFrame.TrackingState:SetJustifyV("MIDDLE")
    EventTracker.OptionsFrame.TrackingState:SetText(ET_TRACKING)
    EventTracker.OptionsFrame.TrackingState:SetSize(100, 21)
    EventTracker.OptionsFrame.TrackingState:SetPoint("TOPLEFT", onOffButton, "TOPRIGHT", 3, 0)

    EventTracker_OnLoad(EventTracker)