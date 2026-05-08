local ADDON_NAME, ADDON = ...
local ADDON_History = ADDON.History
local ADDON_C = ADDON.Constants
local ADDON_Utils = ADDON.Utils
-----------------------------------------------------------------------------------

local tinsert, tremove = tinsert, tremove

-----------------------------------------------------------------------------------

local temporaryHistory = {}

local function _Truncate()
    while ( #temporaryHistory > ADDON_C.HISTORY_MAX_COUNT ) do
        tremove(temporaryHistory, 1)
    end
end

local function _GetReasonString(reason)
    if ( reason and ADDON_C.REASON_STRINGS[reason] ) then
        return " (" .. ADDON_C.REASON_STRINGS[reason] .. ")"
    else
        return ""
    end
end

local function _ColorizedRollName(roll)
    return "|cFFFFCC00("..ADDON_C.ROLL_NAMES[roll]..")|r"
end

-----------------------------------------------------------------------------------

function ADDON_History.ItemRolled(itemID, roll, reason)
    local itemName = ADDON_Utils.GetColoredItemName(itemID)
    if ( itemName ) then
        roll = _ColorizedRollName(roll)
        reason = _GetReasonString(reason)
        tinsert(temporaryHistory, "#"..itemID.." "..itemName.." "..roll..reason)
        _Truncate()
    end
end

function ADDON_History.ItemRolledByUser(itemID, roll)
    ADDON_History.ItemRolled(itemID, roll, ADDON_C.REASON_ADDED_BY_USER)
end

function ADDON_History.ItemRollChanged(itemID, rollFrom, rollTo, reason)
    local itemName = ADDON_Utils.GetColoredItemName(itemID)
    if ( itemName ) then
        rollFrom = _ColorizedRollName(rollFrom)
        rollTo = _ColorizedRollName(rollTo)
        reason = _GetReasonString(reason)
        tinsert(temporaryHistory, "#"..itemID.." "..itemName.." "..rollFrom.." -> "..rollTo..reason)
        _Truncate()
    end
end

function ADDON_History.ItemRollRemoved(itemID, reason)
    local itemName = ADDON_Utils.GetColoredItemName(itemID)
    if ( itemName ) then
        roll = _ColorizedRollName(ADDON_C.ROLLS.REMOVE)
        reason = _GetReasonString(reason)
        tinsert(temporaryHistory, "#"..itemID.." "..itemName.." "..roll..reason)
        _Truncate()
    end
end

function ADDON_History.GetCount()
    return #temporaryHistory
end

function ADDON_History.GetAt(i)
    return temporaryHistory[i]
end

-----------------------------------------------------------------------------------
