local ADDON_NAME, ADDON = ...
local ADDON_Learning = ADDON.Learning
-----------------------------------------------------------------------------------

local learningList = {}

function ADDON_Learning.SetItem(itemID, roll)
    learningList[itemID] = roll
end

function ADDON_Learning.GetItem(itemID)
    return learningList[itemID]
end

function ADDON_Learning.ClearItems()
    learningList = {}
end

-----------------------------------------------------------------------------------
