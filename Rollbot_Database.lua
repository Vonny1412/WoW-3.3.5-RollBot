local ADDON_NAME, ADDON = ...
local ADDON_C = ADDON.Constants
local ADDON_DB = ADDON.Database
local ADDON_Utils = ADDON.Utils
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true)
local V_Table = LibStub("V_Table-1.0")
-----------------------------------------------------------------------------------

local DATABASE_DEFAULT = {
    autoRolls = {},
    lastItems = {},
    settings = {
        dbv = 4,
        state = 1, -- STATE_ACTIVE
        cfg = {
            rollNeed = true,
            rollNeed_exp0 = false,
            rollNeed_exp1 = false,
            rollNeed_exp2 = true,
            rollNeed_qual2 = false,
            rollNeed_qual3 = false,
            rollNeed_qual4 = true,
            rollNeedBoE = true,
            rollNeedBoE_exp0 = true,
            rollNeedBoE_exp1 = true,
            rollNeedBoE_exp2 = true,
            rollNeedBoE_qual2 = false,
            rollNeedBoE_qual3 = true,
            rollNeedBoE_qual4 = true,
            rollGreed = true,
            rollGreedOnlySellable = true,
            rollDisenchant = true,
            rollDisenchant_BoE = false,
            rollDisenchant_exp0 = false,
            rollDisenchant_exp1 = false,
            rollDisenchant_exp2 = true,
            showRndFrame = true,
            filterMessages = true,
            manualSetItemWarned = false,
        },
        rndEyes = {
            [ADDON_C.ROLLS.NEED] = 100,
            [ADDON_C.ROLLS.GREED] = 99,
            [ADDON_C.ROLLS.DISENCHANT] = 25,
        },
        messageFilters = {

            LOOT_ROLL_NEED_SELF         = false,
            LOOT_ROLL_GREED_SELF        = false,
            LOOT_ROLL_DISENCHANT_SELF   = false,
            LOOT_ROLL_PASSED_SELF       = false,
            LOOT_ROLL_YOU_WON           = true,

            LOOT_ROLL_NEED              = false,
            LOOT_ROLL_GREED             = false,
            LOOT_ROLL_DISENCHANT        = false,
            LOOT_ROLL_PASSED            = false,
            LOOT_ROLL_WON               = true,

            LOOT_ROLL_ROLLED_NEED       = true,
            LOOT_ROLL_ROLLED_GREED      = false,
            LOOT_ROLL_ROLLED_DE         = false,

            LOOT_ITEM                   = false,
            LOOT_ITEM_MULTIPLE          = false,
            LOOT_ITEM_SELF              = true,
            LOOT_ITEM_SELF_MULTIPLE     = true,

        },
        minimap = {
        },
    }
}

-----------------------------------------------------------------------------------

function ADDON_DB.Initialize()
    if ( RollbotDB == nil ) then
        RollbotDB = V_Table.CopyTable(DATABASE_DEFAULT)
    else
        RollbotDB = V_Table.ApplyDefaults(RollbotDB, DATABASE_DEFAULT)
    end
    --if ( ADDON_DB.UpdateToVersion(12345) ) then
    --end
end

-----------------------------------------------------------------------------------

function ADDON_DB.GetDefaultVersion()
    return DATABASE_DEFAULT.settings.dbv
end

function ADDON_DB.GetCurrentVersion()
    return RollbotDB.settings.dbv
end

function ADDON_DB.SetCurrentVersion(v)
    RollbotDB.settings.dbv = v
end

function ADDON_DB.UpdateToVersion(toVersion)
    if ( ADDON_DB.GetCurrentVersion() < toVersion ) then
        ADDON_DB.SetCurrentVersion(toVersion)
        ADDON_Utils.message(L["message_updating_database"], toVersion)
        return true
    end
    return false
end

-----------------------------------------------------------------------------------

function ADDON_DB.SetItemRoll(itemID, roll)
    RollbotDB.autoRolls[itemID] = roll
end

function ADDON_DB.GetItemRoll(itemID)
    return RollbotDB.autoRolls[itemID]
end

function ADDON_DB.RemoveItemRoll(itemID)
    RollbotDB.autoRolls[itemID] = nil
end

function ADDON_DB.IterItemRolls()
    return pairs(RollbotDB.autoRolls)
end

function ADDON_DB.ClearItemRolls()
    RollbotDB.autoRolls = {}
    RollbotDB.lastItems = {}
end

function ADDON_DB.CountItemRolls()
    local count = 0
    for _ in pairs(RollbotDB.autoRolls) do count = count + 1 end
    return count
end

-----------------------------------------------------------------------------------

function ADDON_DB.AddLastItem(itemID)
    local list = RollbotDB.lastItems
    tinsert(list, itemID)
    while ( #list > ADDON_C.LAST_ITEMS_MAX_COUNT ) do
        tremove(list, 1)
    end
    RollbotDB.lastItems = list
end

function ADDON_DB.RemoveLastItem(itemID)
    local temp = {}
    for i, id in pairs(RollbotDB.lastItems) do
        if ( id ~= itemID ) then
            tinsert(temp, id)
        end
    end
    RollbotDB.lastItems = temp
end

function ADDON_DB.GetLastItemsList()
    local temp = {}
    for i, itemID in pairs(RollbotDB.lastItems) do
        tinsert(temp, itemID)
    end
    return temp
end

-----------------------------------------------------------------------------------

function ADDON_DB.SetConfig(k, v)
    RollbotDB.settings.cfg[k] = v
end

function ADDON_DB.GetConfig(k)
    return RollbotDB.settings.cfg[k]
end

function ADDON_DB.SetState(v)
    RollbotDB.settings.state = v
end

function ADDON_DB.GetState()
    return RollbotDB.settings.state
end

function ADDON_DB.SetMessageFilter(msg, v)
    RollbotDB.settings.messageFilters[msg] = v
end

function ADDON_DB.GetMessageFilter(msg)
    return RollbotDB.settings.messageFilters[msg]
end

function ADDON_DB.SetRndEyes(roll, v)
    RollbotDB.settings.rndEyes[roll] = v
end

function ADDON_DB.GetRndEyes(roll)
    return RollbotDB.settings.rndEyes[roll]
end

-----------------------------------------------------------------------------------
