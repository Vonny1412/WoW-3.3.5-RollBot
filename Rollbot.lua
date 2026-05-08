local ADDON_NAME, ADDON = ...
-----------------------------------------------------------------------------------

local events = {}
local eventsFrame = CreateFrame("FRAME")
eventsFrame:SetScript("OnEvent", function(self, event, ...)
    local list = events[event] or {}
    for i,func in ipairs(list) do
        func(...)
    end
end)

function ADDON:RegisterEvent(e, f)
    if ( not events[e] ) then
        events[e] = {}
        eventsFrame:RegisterEvent(e)
    end
    tinsert(events[e], f)
end

-----------------------------------------------------------------------------------

local modules = {
    "Constants",
    "Database",
    "Dialogs",
    "History",
    "Learning",
    "Utils",
    "RollFrame",
    "Menu",
    "Core",
}
for i,m in ipairs(modules) do
    ADDON[m] = {}
end
 
ADDON:RegisterEvent("ADDON_LOADED", function(addonName)
    if ( addonName ~= ADDON_NAME ) then
        return
    end

    for i,m in ipairs(modules) do
        local init = ADDON[m].Initialize
        if ( init ) then
            init()
        end
    end
    for i,m in ipairs(modules) do
        ADDON[m].Initialize = nil
    end

end)

-----------------------------------------------------------------------------------
