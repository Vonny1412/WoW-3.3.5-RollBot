local ADDON_NAME, ADDON = ...
local ADDON_C = ADDON.Constants
local ADDON_DB = ADDON.Database
local ADDON_Utils = ADDON.Utils
local V_ItemInfo = LibStub("V_ItemInfo-1.0")
-----------------------------------------------------------------------------------

local select, format = select, format
local GetItemQualityColor = GetItemQualityColor

-----------------------------------------------------------------------------------

function ADDON_Utils.message(t, ...)
    print(ADDON_C.ROLLBOT_TITLE .. ": " .. format(t, ...))
end

-----------------------------------------------------------------------------------

function ADDON_Utils.CopyTable(src)
    local dst = {}
    for k, v in pairs(src) do
        if ( type(v) == "table" ) then
            dst[k] = ADDON_Utils.CopyTable(v)
        else
            dst[k] = v
        end
    end
    return dst
end

function ADDON_Utils.ApplyDefaults(dst, defaults)
    if ( type(dst) ~= "table" ) then
        dst = {}
    end
    for key, value in pairs(defaults) do
        if ( type(value) == "table" ) then
            dst[key] = ADDON_Utils.ApplyDefaults(dst[key], value)
        elseif ( dst[key] == nil ) then
            dst[key] = value
        end
    end
    return dst
end

-----------------------------------------------------------------------------------

function ADDON_Utils.GetColoredItemQualityName(q)
    return select(4, GetItemQualityColor(q)) .."[".. _G["ITEM_QUALITY"..q.."_DESC"] .."]|r"
end

function ADDON_Utils.GetColoredItemName(itemID)
    return V_ItemInfo.GetColoredItemName(itemID)
end

function ADDON_Utils.IsEquipableItem(itemID)
    local includeAmmo = false
    return V_ItemInfo.IsEquipableItem(itemID, includeAmmo)
end

function ADDON_Utils.GetItemExpansion(itemID)
    return V_ItemInfo.GetItemExpansion(itemID)
end

function ADDON_Utils.IsLearnableItem(itemID)
    return V_ItemInfo.IsLearnableItem(itemID)
end

function ADDON_Utils.GetItemLinkInfo(itemLink)
    return V_ItemInfo.GetItemLinkInfo(itemLink)
end

function ADDON_Utils.AlwaysAskItem(itemID)
    if ( ADDON_C.ALWAYS_ASK_ITEMS[itemID] ~= nil ) then
        return true
    end
    local itemType, itemSubType = V_ItemInfo.GetItemType(itemID)
    if ( itemType == nil ) then
        return false
    end
    local classID = V_ItemInfo.GetItemClassID(itemType)
    if ( classID == nil ) then
        -- key-items are not known by V_ItemInfo
        return true
    end
    return false
end

function ADDON_Utils.RequestItemInfo(itemID, cb)
    local ok,err = V_ItemInfo.RequestItemInfo(itemID, function(itemID, success)
        if ( success == nil ) then
            ADDON_Utils.message(L["message_requesting_item_info"], itemID)
            return
        end
        if ( success == false ) then
            ADDON_Utils.message(L["message_requesting_item_info_failed"], itemID)
        end
        if ( cb ) then
            cb(itemID, success)
        end
    end)
    if ( not ok ) then
        ADDON_Utils.message(L["message_requesting_item_info_failed_with_reason"], itemID, err)
    end
end

function ADDON_Utils.GetItemUnusableReason(itemID)
    local found, wrongClass, missingWeaponSkill, spellAlreadyKnown, recipeSkill, recipeSkillTooLow  = V_ItemInfo.GetItemRestrictions(itemID)
    if ( not found ) then
        -- no red line found in item tooltip
        -- character seems to be qualified
        return nil
    end

    if ( wrongClass or missingWeaponSkill ) then
        return ADDON_C.REASON_NOT_QUALIFIED
    end
    if ( spellAlreadyKnown ) then
        return ADDON_C.REASON_ITEM_SKILL_KNOWN
    end
    if ( recipeSkill ) then
        if ( recipeSkillTooLow ) then
            return ADDON_C.REASON_SKILL_TOO_LOW
        else
            return ADDON_C.REASON_NOT_QUALIFIED
        end
    end

    -- fallback
    return ADDON_C.REASON_NOT_QUALIFIED
end

-----------------------------------------------------------------------------------

function ADDON_Utils.GetRollMessageItemID(msg, keys)
    for i, k in ipairs(keys) do

        local msgInfo = { ADDON_C.MSG_PATTERNS[k]:GetMatch(msg) }
        if ( #msgInfo > 0 ) then

            local itemID
            for j=1,#msgInfo do
                itemID = ADDON_Utils.GetItemLinkInfo(msgInfo[j])
                if ( itemID ) then
                    return itemID, k, msgInfo
                end
            end

            -- find the damn error!
            print("ERROR in GetRollMessageItemId()")
            print(k..": "..ADDON_C.MSG_PATTERNS[k]:GetPattern())
            print(_G[k])
            print(msg)
            print(#msgInfo)
            print(unpack(msgInfo))
            return nil
        end
    end
    return nil
end

-----------------------------------------------------------------------------------

function ADDON_Utils.Initialize()

    local idsByKey = {}
    for _,itemID in pairs(ADDON_DB.GetLastItemsList()) do
        idsByKey[itemID] = true
    end
    for itemID,_ in ADDON_DB.IterItemRolls() do
        idsByKey[itemID] = true
    end
    for itemID,_ in pairs(ADDON_C.ALWAYS_ASK_ITEMS) do
        idsByKey[itemID] = true
    end

    local idsList = {}
    for itemID in pairs(idsByKey) do
        idsList[#idsList + 1] = itemID
    end

    --ADDON_Utils.message("Requesting missing item infos")
    V_ItemInfo.RequestAllItemInfos(idsList, function(results)
        --ADDON_Utils.message("Finished requesting missing item infos")
    end)

end

-----------------------------------------------------------------------------------
