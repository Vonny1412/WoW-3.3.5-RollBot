local ADDON_NAME, ADDON = ...
local ADDON_C = ADDON.Constants
local ADDON_Core = ADDON.Core
local ADDON_DB = ADDON.Database
local ADDON_Dialogs = ADDON.Dialogs
local ADDON_History = ADDON.History
local ADDON_Menu = ADDON.Menu
local ADDON_Learning = ADDON.Learning
local ADDON_Utils = ADDON.Utils
local ADDON_RollFrame = ADDON.RollFrame
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true)
local V_Runtime = LibStub("V_Runtime-1.0")
-----------------------------------------------------------------------------------

local select = select
local GetItemInfo = GetItemInfo
local GetLootRollItemInfo = GetLootRollItemInfo
local GetLootRollItemLink = GetLootRollItemLink
local RollOnLoot = RollOnLoot
local NUM_GROUP_LOOT_FRAMES = NUM_GROUP_LOOT_FRAMES
local ConfirmLootRoll = ConfirmLootRoll
local GetNumRaidMembers = GetNumRaidMembers
local tonumber, tostring = tonumber, tostring

-----------------------------------------------------------------------------------

function ADDON_Core.SetItem(itemID, roll)
    local itemLink = select(2, GetItemInfo(itemID))
    if ( itemLink ) then
        ADDON_DB.SetItemRoll(itemID, roll)
        ADDON_DB.RemoveLastItem(itemID)
        ADDON_DB.AddLastItem(itemID)
        ADDON_Utils.message(L["message_item_saved"], ADDON_C.ROLL_NAMES[roll], itemLink)
        ADDON_History.ItemRolledByUser(itemID, roll)
        if ( ADDON_Menu.IsLearning() ) then
            ADDON_Learning.SetItem(itemID, roll)
        end
    end
end

function ADDON_Core.RemoveItem(itemID, reason)
    ADDON_DB.RemoveLastItem(itemID) -- always remove, just in case
    if ( ADDON_DB.GetItemRoll(itemID) ) then
        ADDON_DB.RemoveItemRoll(itemID)
        ADDON_History.ItemRollRemoved(itemID, reason)

        local itemLink = select(2, GetItemInfo(itemID))
        ADDON_Utils.message(L["message_item_removed"], itemLink or ( "#"..itemID ))
    end
end

-----------------------------------------------------------------------------------

function ADDON_Core.RollRnd(itemID, roll)
    if ( roll == nil ) then
        return
    end
    local eyes = ADDON_DB.GetRndEyes(roll)
    if ( eyes ) then
        SlashCmdList["RANDOM"](eyes)
    end
end

function ADDON_Core.ShowRndFrame(itemID, showCount)
    -- todo: check if number, otherwise error
    ADDON_RollFrame.Show(itemID, 0, "RED", false, showCount, ADDON_Core.RollRnd)
end

-----------------------------------------------------------------------------------

local rollPendingGate = V_Runtime.CreatePendingGate()

local function OnItemRolled(itemID, roll)
    ADDON_Dialogs.EnableConfirmDialog()

    if ( rollPendingGate:Consume(itemID) ) then
        return
    end

    if ( ADDON_Menu.IsInactive() ) then
        return
    end
    ADDON_Core.SetItem(itemID, roll)
end

local function OnItemWon(itemID)
    if ( ADDON_DB.GetItemRoll(itemID) ~= ADDON_C.ROLLS.NEED ) then
        return
    end
    --local alwaysAsk = ADDON_Utils.AlwaysAskItem(itemID)
    local isEquip = ADDON_Utils.IsEquipableItem(itemID)
    local isLearnable = ADDON_Utils.IsLearnableItem(itemID)
    if ( isEquip or isLearnable ) then
        ADDON_Core.RemoveItem(itemID, ADDON_C.REASON_ITEM_WON)
    end
end

local function DoRoll(rollID, itemRoll, reason)
    local itemLink = GetLootRollItemLink(rollID)
    local itemID = ADDON_Utils.GetItemLinkInfo(itemLink)
    if ( itemID == nil ) then
        return
    end

    ADDON_History.ItemRolled(itemID, itemRoll, reason)
    if ( itemRoll ~= ADDON_C.ROLLS.IGNORE ) then

        -- handle if saved roll apparently not available
        local canNeed, canGreed, canDisenchant, reasonNeed, reasonGreed, reasonDisenchant = select(6, GetLootRollItemInfo(rollID))
        if ( itemRoll == ADDON_C.ROLLS.NEED and not canNeed ) then
            itemRoll = ADDON_C.ROLLS.GREED
            ADDON_History.ItemRollChanged(itemID, ADDON_C.ROLLS.NEED, ADDON_C.ROLLS.GREED, reasonNeed)
        end
        if ( itemRoll == ADDON_C.ROLLS.DISENCHANT and not canDisenchant ) then
            itemRoll = ADDON_C.ROLLS.GREED
            ADDON_History.ItemRollChanged(itemID, ADDON_C.ROLLS.DISENCHANT, ADDON_C.ROLLS.GREED, reasonDisenchant)
        end
        if ( itemRoll == ADDON_C.ROLLS.GREED and not canGreed ) then
            itemRoll = ADDON_C.ROLLS.PASS
            ADDON_History.ItemRollChanged(itemID, ADDON_C.ROLLS.GREED, ADDON_C.ROLLS.PASS, reasonGreed)
        end

        ADDON_Utils.message(L["rolling_on_item"], ADDON_C.ROLL_NAMES[itemRoll], itemLink)
        for i=1, NUM_GROUP_LOOT_FRAMES do
            local frame = _G["GroupLootFrame"..i]
            if ( frame.rollID ~= nil and frame:IsShown() ) then
                local link = GetLootRollItemLink(frame.rollID)
                if ( itemID == ADDON_Utils.GetItemLinkInfo(link) ) then
                    ADDON_Dialogs.DisableConfirmDialog()
                    rollPendingGate:Mark(itemID)
                    RollOnLoot(frame.rollID, itemRoll)
                    return
                end
            end
        end
        ADDON_Utils.message("No matching GroupLootFrame found for item "..tostring(itemID)) -- todo: localize me... some day
    else
        rollPendingGate:Mark(itemID)
        ADDON_Utils.message(L["rolling_ignored"], itemLink)
    end
end

-----------------------------------------------------------------------------------

local lootMessageHandlers = {}

lootMessageHandlers.LOOT_ROLL_DISENCHANT_SELF = function(itemID)
    OnItemRolled(itemID, ADDON_C.ROLLS.DISENCHANT)
end

lootMessageHandlers.LOOT_ROLL_GREED_SELF = function(itemID)
    OnItemRolled(itemID, ADDON_C.ROLLS.GREED)
end

lootMessageHandlers.LOOT_ROLL_NEED_SELF = function(itemID)
    OnItemRolled(itemID, ADDON_C.ROLLS.NEED)
end

lootMessageHandlers.LOOT_ROLL_PASSED_SELF = function(itemID)
    OnItemRolled(itemID, ADDON_C.ROLLS.PASS)
end

lootMessageHandlers.LOOT_ROLL_YOU_WON = function(itemID)
    OnItemWon(itemID)
end

lootMessageHandlers.LOOT_ITEM = function(itemID)
    -- not used
end

lootMessageHandlers.LOOT_ITEM_MULTIPLE = function(itemID)
    -- not used
end

lootMessageHandlers.LOOT_ITEM_SELF = function(itemID)
    -- not used
end

lootMessageHandlers.LOOT_ITEM_SELF_MULTIPLE = function(itemID)
    -- not used
end

local MESSAGES_ORDERED_KEYS = {

    "LOOT_ROLL_NEED_SELF",
    "LOOT_ROLL_GREED_SELF",
    "LOOT_ROLL_DISENCHANT_SELF",
    "LOOT_ROLL_PASSED_SELF",
    "LOOT_ROLL_YOU_WON",

    "LOOT_ROLL_NEED",
    "LOOT_ROLL_GREED",
    "LOOT_ROLL_DISENCHANT",
    "LOOT_ROLL_PASSED",
    "LOOT_ROLL_WON",

    "LOOT_ROLL_ROLLED_NEED",
    "LOOT_ROLL_ROLLED_GREED",
    "LOOT_ROLL_ROLLED_DE",

    "LOOT_ITEM_SELF_MULTIPLE",
    "LOOT_ITEM_SELF",
    "LOOT_ITEM_MULTIPLE",
    "LOOT_ITEM",
}

-----------------------------------------------------------------------------------

local function OnStartLootRoll(rollID)
    if ( ADDON_Menu.IsInactive() ) then
        return
    end

    local itemLink = GetLootRollItemLink(rollID)
    local itemID = ADDON_Utils.GetItemLinkInfo(itemLink)

    local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, _, _, _, itemSellPrice = GetItemInfo(itemID)
    if ( itemName == nil ) then
        ADDON_Utils.RequestItemInfo(itemID) -- just dont use callback
        return DoRoll(rollID, ADDON_C.ROLLS.IGNORE, ADDON_C.REASON_ITEM_UNKNOWN)
    end

    local bindOnPickUp, canNeed, canGreed, canDisenchant, reasonNeed, reasonGreed, reasonDisenchant = select(5, GetLootRollItemInfo(rollID))

    local itemIsEquip       = ADDON_Utils.IsEquipableItem(itemID)
    local itemIsBoE         = itemIsEquip and not bindOnPickUp
    local itemExpansion     = ADDON_Utils.GetItemExpansion(itemID)
    local itemAlwaysAsk     = ADDON_Utils.AlwaysAskItem(itemID)
    local itemIsLearnable   = ADDON_Utils.IsLearnableItem(itemID)

    local itemRedReason     = ADDON_Utils.GetItemUnusableReason(itemID)
    local notWantNeedReason = ADDON_C.REASON_NO_INTEREST

    local insideRaid        = GetNumRaidMembers() > 0

    local rollNeed              = ADDON_DB.GetConfig("rollNeed")
    local rollNeedBoE           = ADDON_DB.GetConfig("rollNeedBoE")
    local rollGreed             = ADDON_DB.GetConfig("rollGreed")
    local rollGreedOnlySellable = ADDON_DB.GetConfig("rollGreedOnlySellable")
    local rollDisenchant        = ADDON_DB.GetConfig("rollDisenchant")
    local rollDisenchantBoE     = ADDON_DB.GetConfig("rollDisenchant_BoE")

    local needQuality       = ADDON_DB.GetConfig("rollNeed_qual"..itemRarity)
    local needExpansion     = ADDON_DB.GetConfig("rollNeed_exp"..itemExpansion)
    local needBoEQuality    = ADDON_DB.GetConfig("rollNeedBoE_qual"..itemRarity)
    local needBoEExpansion  = ADDON_DB.GetConfig("rollNeedBoE_exp"..itemExpansion)
    local disExpansion      = ADDON_DB.GetConfig("rollDisenchant_exp"..itemExpansion)

    local wantNeed          = rollNeed       and needExpansion and needQuality
    local wantGreed         = rollGreed      and ( itemSellPrice > 0 or not rollGreedOnlySellable )
    local wantDisenchant    = rollDisenchant and disExpansion and ( rollDisenchantBoE or not itemIsBoE )
    local wantBoE           = rollNeedBoE    and itemIsBoE and needBoEQuality and needBoEExpansion

    -- is in auto list
    local autoRoll = ADDON_DB.GetItemRoll(itemID)
    if ( autoRoll ~= nil ) then

        if ( ADDON_Menu.IsLearning() ) then
            if ( ADDON_Learning.GetItem(itemID) == nil ) then
                -- let user decide and save again
                return
            end
        end

        if ( autoRoll == ADDON_C.ROLLS.NEED       and rollNeed )
        or ( autoRoll == ADDON_C.ROLLS.GREED      and rollGreed )
        or ( autoRoll == ADDON_C.ROLLS.DISENCHANT and rollDisenchant )
        or ( autoRoll == ADDON_C.ROLLS.PASS ) then
            return DoRoll(rollID, autoRoll, ADDON_C.REASON_IN_AUTO_LIST)
        end
    end

    if ( itemAlwaysAsk ) then
        return DoRoll(rollID, ADDON_C.ROLLS.IGNORE, ADDON_C.REASON_SPECIAL_ITEM)
    end

    if ( itemRarity == ADDON_C.QUALITY_ORANGE_LEGENDARY ) then
        return DoRoll(rollID, ADDON_C.ROLLS.IGNORE, ADDON_C.REASON_LEGENDARY_ITEM)
    end

    if ( wantBoE ) then
        return DoRoll(rollID, ADDON_C.ROLLS.NEED, ADDON_C.REASON_ITEM_IS_BOE)
    end

    -- inside raid -> special behavior
    if ( insideRaid and itemIsEquip and ( itemRarity >= ADDON_C.QUALITY_PURPLE_EPIC ) ) then
        if ( wantNeed ) then
            if ( canNeed ) then
                return DoRoll(rollID, ADDON_C.ROLLS.IGNORE, ADDON_C.REASON_IN_RAID)
            end
            wantNeed = false
            wantGreed = true
            notWantNeedReason = ADDON_C.REASON_IN_RAID
        end
    end

    if ( not wantNeed ) then
        if ( wantDisenchant and canDisenchant ) then
            return DoRoll(rollID, ADDON_C.ROLLS.DISENCHANT, notWantNeedReason)
        end
        if ( wantGreed and canGreed ) then
            return DoRoll(rollID, ADDON_C.ROLLS.GREED, notWantNeedReason)
        end
        return DoRoll(rollID, ADDON_C.ROLLS.PASS, notWantNeedReason)
    end

    --
    -- wantNeed == true
    --

    if ( canNeed and itemRedReason ) then
        if ( itemRedReason == ADDON_C.REASON_SKILL_TOO_LOW ) then
            -- this should be unneccessary, it should always be a learnable item.. but just in case
            if ( itemIsLearnable ) then
                return DoRoll(rollID, ADDON_C.ROLLS.IGNORE, ADDON_C.REASON_LEARNABLE_ITEM)
            else
                return DoRoll(rollID, ADDON_C.ROLLS.IGNORE, ADDON_C.REASON_SKILL_TOO_LOW)
            end
        end
        canNeed = false
        reasonNeed = itemRedReason
    end
    if ( canNeed and itemIsLearnable ) then
        return DoRoll(rollID, ADDON_C.ROLLS.IGNORE, ADDON_C.REASON_LEARNABLE_ITEM)
    end

    if ( not canNeed ) then
        if ( wantDisenchant and canDisenchant ) then
            return DoRoll(rollID, ADDON_C.ROLLS.DISENCHANT, reasonNeed)
        end
        if ( wantGreed and canGreed ) then
            return DoRoll(rollID, ADDON_C.ROLLS.GREED, reasonNeed)
        end
        return DoRoll(rollID, ADDON_C.ROLLS.PASS, reasonNeed)
    end

    -- need enabled, need possible, item might be useful
    -- user decides and the choice can be saved
    return
end

local function OnConfirmLootRoll(rollID, roll)
    if ( ADDON_Menu.IsInactive() ) then
        return
    end

    ConfirmLootRoll(rollID, roll)
end

local function OnLootBindConfirm(slot)
    if ( ADDON_Menu.IsInactive() ) then
        return
    end

    -- currently not used
end

local function OnChatMsgRaidWarning(msg, author, language, lineID)
    if ( ADDON_Menu.IsInactive() ) then
        return
    end

    if ( not ADDON_DB.GetConfig("showRndFrame") ) then
        return
    end

    local linkPre, itemID, itemName, linkPost = select(3, msg:find("^(.-)\124[0-9a-fA-F]+\124Hitem:(%d+):.*\124h%[(.-)%]\124h\124r(.-)$"))
    if ( itemID ) then
        ADDON_Core.ShowRndFrame(tonumber(itemID))
    end
end

local function OnChatMsgLoot(msg)
    if ( ADDON_Menu.IsInactive() ) then
        return
    end

    local itemID, rollKey = ADDON_Utils.GetRollMessageItemID(msg, MESSAGES_ORDERED_KEYS)
    if ( itemID ) then
        if ( lootMessageHandlers[rollKey] ) then
            lootMessageHandlers[rollKey](itemID)
        end
    end
end

-----------------------------------------------------------------------------------

ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", function(self, event, msg)
    if ( ADDON_Menu.IsInactive() ) then
        return false
    end
    if ( not ADDON_DB.GetConfig("filterMessages") ) then
        return false
    end
    local itemID, rollKey, msgInfo = ADDON_Utils.GetRollMessageItemID(msg, MESSAGES_ORDERED_KEYS)
    if ( itemID ) then
        return not ADDON_DB.GetMessageFilter(rollKey)
    end
    return false
end)

-----------------------------------------------------------------------------------

function ADDON_Core.Initialize()
    ADDON:RegisterEvent("START_LOOT_ROLL", OnStartLootRoll)
    ADDON:RegisterEvent("CONFIRM_LOOT_ROLL", OnConfirmLootRoll)
    ADDON:RegisterEvent("CONFIRM_DISENCHANT_ROLL", OnConfirmLootRoll)
    ADDON:RegisterEvent("LOOT_BIND_CONFIRM", OnLootBindConfirm)
    ADDON:RegisterEvent("CHAT_MSG_RAID_WARNING", OnChatMsgRaidWarning)
    ADDON:RegisterEvent("CHAT_MSG_LOOT", OnChatMsgLoot)
end

-----------------------------------------------------------------------------------
