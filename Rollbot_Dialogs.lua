local ADDON_NAME, ADDON = ...
local ADDON_C = ADDON.Constants
local ADDON_DB = ADDON.Database
local ADDON_Dialogs = ADDON.Dialogs
local ADDON_Utils = ADDON.Utils
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true)
-----------------------------------------------------------------------------------

local strtrim = strtrim
local GetItemInfo = GetItemInfo
local tostring, tonumber = tostring, tonumber

local function _CallCB(cb, ...)
    if ( cb ) then
        cb(...)
    end
end

-----------------------------------------------------------------------------------

StaticPopupDialogs["ROLLBOT_DIALOG_SET_ITEM_WARNING"] = {
    text = L["dialog_manual_save_warning"],
    button1 = L["common_ok"],
    OnAccept = function(self)
        _CallCB(self.data.callback)
    end,
    showAlert = 1,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
}

StaticPopupDialogs["ROLLBOT_DIALOG_SET_ITEM"] = {
    text = L["dialog_enter_item_id_or_name"],
    hasEditBox = true,
    button1 = L["common_ok"],
    button2 = L["common_cancel"],
    OnShow = function(self)
        if ( self.data.editBoxText ~= nil ) then
            self.editBox:SetText(self.data.editBoxText)
        end
    end,
    OnAccept = function(self)
        local enteredText = strtrim(self.editBox:GetText() or "")

        if ( enteredText == "" ) then
            _CallCB(self.data.callback, nil)
            return
        end

        local itemID = tonumber(enteredText)
        if ( enteredText == tostring(itemID) ) then
            -- is item id
            ADDON_Utils.RequestItemInfo(itemID, function(itemID, itemName, itemLink, itemRarity, ...)
                if ( itemName ) then
                    if ( itemRarity < ADDON_C.QUALITY_GREEN_UNCOMMON ) then
                        ADDON_Utils.message(L["itemQualityTooLow"], itemLink)
                        _CallCB(self.data.callback, "", nil)
                        return
                    end
                    _CallCB(self.data.callback, enteredText, tonumber(itemID))
                else
                    _CallCB(self.data.callback, enteredText, nil)
                end
            end)
        else
            -- fallback with item name, do not request (not working with item names)
            local itemName, itemLink, itemRarity = GetItemInfo(enteredText)
            if ( not itemName ) then
                ADDON_Utils.message(L["message_item_is_unknown"], enteredText)
                _CallCB(self.data.callback, enteredText, nil)
                return
            end
            if ( itemRarity < ADDON_C.QUALITY_GREEN_UNCOMMON ) then
                ADDON_Utils.message(L["message_item_quality_too_low"], itemLink)
                _CallCB(self.data.callback, "", nil)
                return
            end
            local itemID = ADDON_Utils.GetItemLinkInfo(itemLink)
            _CallCB(self.data.callback, enteredText, itemID)
        end

    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
}

StaticPopupDialogs["ROLLBOT_DIALOG_CLEAR_ALL"] = {
    text = L["dialog_clear_all_rolls_question"],
    hasEditBox = false,
    button1 = L["common_yes"],
    button2 = L["common_no"],
    OnShow = function(self)
    end,
    OnAccept = function(self)
        ADDON_DB.ClearItemRolls()
        _CallCB(self.data.callback)
    end,
    OnCancel = function(self)
        _CallCB(self.data.callback)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
}

StaticPopupDialogs["ROLLBOT_DIALOG_SET_RND"] = {
    text = "",
    hasEditBox = true,
    button1 = L["common_ok"],
    button2 = L["common_cancel"],
    OnShow = function(self)
        self.text:SetText(ADDON_C.ROLL_NAMES[self.data.roll])
        self.editBox:SetText(ADDON_DB.GetRndEyes(self.data.roll));
    end,
    OnAccept = function(self)
        local v = tonumber(self.editBox:GetText())
        if ( v ) then
            ADDON_DB.SetRndEyes(self.data.roll, v)
            _CallCB(self.data.callback)
        end
    end,
    OnCancel = function(self)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = false,
    preferredIndex = 3,
}

-----------------------------------------------------------------------------------

local backupConfirmDialog = nil
local disabledConfirmCounts = 0

function ADDON_Dialogs.DisableConfirmDialog()
    disabledConfirmCounts = disabledConfirmCounts + 1
    if ( backupConfirmDialog == nil ) then
        backupConfirmDialog = StaticPopupDialogs["CONFIRM_LOOT_ROLL"]
        StaticPopupDialogs["CONFIRM_LOOT_ROLL"] = nil
    end
end

function ADDON_Dialogs.EnableConfirmDialog()
    if ( disabledConfirmCounts <= 0 ) then
        return
    end
    disabledConfirmCounts = disabledConfirmCounts - 1
    if ( backupConfirmDialog ~= nil and disabledConfirmCounts == 0 ) then
        StaticPopupDialogs["CONFIRM_LOOT_ROLL"] = backupConfirmDialog
        backupConfirmDialog = nil
    end
end

-----------------------------------------------------------------------------------
