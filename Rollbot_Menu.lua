local ADDON_NAME, ADDON = ...
local ADDON_C = ADDON.Constants
local ADDON_Core = ADDON.Core
local ADDON_DB = ADDON.Database
local ADDON_History = ADDON.History
local ADDON_Learning = ADDON.Learning
local ADDON_Menu = ADDON.Menu
local ADDON_Utils = ADDON.Utils
local ADDON_RollFrame = ADDON.RollFrame
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true)
local V_Runtime = LibStub("V_Runtime-1.0")
local V_MenuBuilder = LibStub("V_MenuBuilder-1.0")
-----------------------------------------------------------------------------------

local format, select = format, select
local GetItemInfo, GetItemQualityColor = GetItemInfo, GetItemQualityColor

--[[
READY_CHECK_WAITING_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-Waiting";
READY_CHECK_READY_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-Ready";
READY_CHECK_NOT_READY_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-NotReady";
READY_CHECK_AFK_TEXTURE = "Interface\\RaidFrame\\ReadyCheck-NotReady";
local crossIcon = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:0|t"
local unknownIcon = "|TInterface\\Icons\\Inv_misc_questionmark:0|t"
]]--

local ICON_CROSS = "|T"..READY_CHECK_NOT_READY_TEXTURE..":0|t"
local ICON_QMARK = "|T"..READY_CHECK_WAITING_TEXTURE..":0|t"
local EMPTY = EMPTY

local BUTTON_OPEN_MENU   = "RightButton"
local BUTTON_TOGGLE_MODE = "LeftButton"

local DICE_ICONS = {}
DICE_ICONS.grey = [[Interface\Addons\RollBot\Textures\Icons\dice_gray]]
DICE_ICONS.green = [[Interface\Addons\RollBot\Textures\Icons\dice_green]]
DICE_ICONS.yellow = [[Interface\Addons\RollBot\Textures\Icons\dice_yellow]]
DICE_ICONS.red = [[Interface\Addons\RollBot\Textures\Icons\dice_red]]

local STATE_ACTIVE = 1
local STATE_INACTIVE = 2
local STATE_LEARNING = 3
local STATES_LIST = {
    [STATE_ACTIVE]   = { icon = DICE_ICONS.green, message = L["state_active"] },
    [STATE_INACTIVE] = { icon = DICE_ICONS.red, message = L["state_inactive"] },
    [STATE_LEARNING] = { icon = DICE_ICONS.yellow, message = L["state_learning"] },
}

local minimapIcon = LibStub("LibDBIcon-1.0")
local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("RollbotIcon", {
    icon = DICE_ICONS.grey,
    OnClick = function(self, button)
        GameTooltip:Hide()
        if ( button == BUTTON_OPEN_MENU ) then
            ADDON_Menu.Show()
        end
        if ( button == BUTTON_TOGGLE_MODE ) then
            ADDON_Menu.CycleState()
        end
    end,
    OnEnter = function(self)
        if ( not _G["DropDownList1"]:IsShown() ) then
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
            GameTooltip:AddLine(format("%1$s (%2$s)", ADDON_C.ROLLBOT_TITLE, GetAddOnMetadata(ADDON_NAME, "Version")))
            GameTooltip:AddLine(L["tooltip_icon_left_click"])
            GameTooltip:AddLine(L["tooltip_icon_right_click"])
            GameTooltip:Show()
        else
            GameTooltip:Hide()
        end
    end,
})

-----------------------------------------------------------------------------------

local menu = V_MenuBuilder.CreateMenu("RollbotMenu")

function ADDON_Menu.Show(path)
    menu:Show(path or {}, minimapIcon.objects["RollbotIcon"])
end

local qualitiesList = {
    ADDON_C.QUALITY_GREEN_UNCOMMON,
    ADDON_C.QUALITY_BLUE_RARE,
    ADDON_C.QUALITY_PURPLE_EPIC,
}

local rollsList = {
    ADDON_C.ROLLS.NEED,
    ADDON_C.ROLLS.GREED,
    ADDON_C.ROLLS.DISENCHANT,
}


-----------------------------------------------------------------------------------
--- OnClick handler

local function _SetItem(btn)
    local editBoxText = nil
    local loop
    loop = function()
        StaticPopup_Show("ROLLBOT_DIALOG_SET_ITEM", nil, nil, {
            editBoxText = editBoxText,
            callback = function(enteredText, itemID)
                if ( enteredText == nil ) then
                    return -- just abort
                end
                if ( itemID ~= nil ) then
                    editBoxText = nil
                    ADDON_RollFrame.Show(itemID, 0, "CYAN", true, nil, function(itemID, roll)
                        if ( roll == 666 ) then
                            ADDON_Core.RemoveItem(itemID, ADDON_C.REASON_REMOVED_BY_USER)
                        else
                            ADDON_Core.SetItem(itemID, roll)
                        end
                        V_Runtime.RunOnNextFrame(loop)
                    end)
                else
                    editBoxText = enteredText
                    V_Runtime.RunOnNextFrame(loop)
                end
            end,
        })
    end
    loop()
end

local function _SetItemWarn(btn)
    local warned = not not ADDON_DB.GetConfig("manualSetItemWarned")
    if ( not warned ) then
        StaticPopup_Show("ROLLBOT_DIALOG_SET_ITEM_WARNING", nil, nil, {
            callback = function()
                ADDON_DB.SetConfig("manualSetItemWarned", true)
                _SetItem(btn)
            end,
        })
    else
        _SetItem(btn)
    end
end

local function _RemoveItem(btn, arg)
    ADDON_Core.RemoveItem(arg.itemID, ADDON_C.REASON_REMOVED_BY_USER)
    ADDON_Menu.Show({"lastItems"})
end

local function _RemoveAllItems(btn)
    StaticPopup_Show("ROLLBOT_DIALOG_CLEAR_ALL", nil, nil, {
        callback = function()
            ADDON_Menu.Show({"lastItems"})
        end
    })
end

local function _SetConfigChecked(btn, arg)
    ADDON_DB.SetConfig(arg.cfgkey, not not btn.checked) -- make sure to use bool
    ADDON_Menu.Show(arg.reopen)
end

local function _SetRndValue(btn, arg)
    StaticPopup_Show("ROLLBOT_DIALOG_SET_RND", nil, nil, {
        roll = arg.roll,
        callback = function()
            ADDON_Menu.Show({"settings","showRndFrame"})
        end,
    })
end

local function _ShowRndTestFrame(btn, arg)
    -- 3895 = TEST Legendary
    ADDON_Utils.RequestItemInfo(3895, function(itemID, itemName, ...)
        if ( itemName ) then
            ADDON_Core.ShowRndFrame(itemID)
            ADDON_Menu.Show({"settings","showRndFrame"})
        else
            -- item info not available yet
        end
    end)
end

local function _SetMessageFilter(btn, arg)
    ADDON_DB.SetMessageFilter(arg.message, not not btn.checked) -- make sure to use bool
    ADDON_Menu.Show(arg.reopen)
end

-----------------------------------------------------------------------------------
--- OnShow handler


menu:Register({}, function(self)
    self:AddButton(L["menu_history"], {
        path = {"history"},
        arrow = true,
    })
    self:AddButton(L["menu_last_saved_items"], {
        path = {"lastItems"},
        arrow = true,
    })
    self:AddButton(L["menu_settings"], {
        path = {"settings"},
        arrow = true,
    })
    self:AddButton(L["menu_behavior"], {
        path = {"behavior"},
        arrow = true,
    })
    self:AddSpacer()
    self:AddButton(L["menu_set_item"], {
        func = _SetItemWarn,
    })
end)

menu:Register({"history"}, function(self)
    local empty = true
    for i=ADDON_History.GetCount(), 1, -1 do
        self:AddSpacer(ADDON_History.GetAt(i))
        empty = false
    end
    if ( empty ) then
        self:AddSpacer(EMPTY)
    end
end)

menu:Register({"lastItems"}, function(self)
    local lastItems = ADDON_DB.GetLastItemsList()
    if ( #lastItems == 0 ) then
        self:AddSpacer(EMPTY)
        return
    end
    self:AddSpacer(format(L["menu_last_saved_items_header"], ADDON_C.LAST_ITEMS_MAX_COUNT))
    self:AddSpacer("")
    for i=#lastItems,1,-1 do
        local itemID = lastItems[i]
        local itemRoll = ADDON_DB.GetItemRoll(itemID)
        local itemName, _, itemQuality = GetItemInfo(itemID)
        if ( itemName ~= nil ) then
            local displayItemId = "|cFF777777#"..itemID.."|r"
            local displayItemName = select(4, GetItemQualityColor(itemQuality)) .. itemName .. "|r"
            local displayRoll = "|cFFFFCC00("..ADDON_C.ROLL_NAMES[itemRoll]..")|r"
            self:AddButton(ICON_CROSS.." "..displayItemId.." "..displayItemName.." "..displayRoll, {
                func = _RemoveItem,
                arg = { itemID = itemID },
            })
        else
            local displayItemId = "|cFFFF0000#"..itemID.."|r"
            local displayItemName = "|cFFFF0000#"..L["unknown_item"].."|r"
            self:AddButton(ICON_CROSS.." "..displayItemId.." "..displayItemName, {
                func = _RemoveItem,
                arg = { itemID = itemID },
            })
        end
    end
    self:AddSpacer("")
    self:AddButton(format(L["menu_clear_saved_items"], ADDON_DB.CountItemRolls()), {
        func = _RemoveAllItems,
    })
end)

menu:Register({"settings"}, function(self)

    local rollNeed = not not ADDON_DB.GetConfig("rollNeed")
    local rollNeedBoE = not not ADDON_DB.GetConfig("rollNeedBoE")
    local rollGreed = not not ADDON_DB.GetConfig("rollGreed")
    local rollDisenchant = not not ADDON_DB.GetConfig("rollDisenchant")
    local showRndFrame = not not ADDON_DB.GetConfig("showRndFrame")
    local filterMessages = not not ADDON_DB.GetConfig("filterMessages")

    self:AddButton(L["menu_roll_need"], {
        path = { "settings", "rollNeed" },
        arrow = rollNeed,
        checked = rollNeed,
        func = _SetConfigChecked,
        arg = { cfgkey = "rollNeed", reopen = { "settings", "rollNeed" } },
    })
    self:AddButton(L["menu_roll_need_boe"], {
        path = { "settings", "rollNeedBoE" },
        arrow = rollNeedBoE,
        checked = rollNeedBoE,
        func = _SetConfigChecked,
        arg = { cfgkey = "rollNeedBoE", reopen = { "settings", "rollNeedBoE" } },
    })
    self:AddButton(L["menu_roll_greed"], {
        path = { "settings", "rollGreed" },
        arrow = rollGreed,
        checked = rollGreed,
        func = _SetConfigChecked,
        arg = { cfgkey = "rollGreed", reopen = { "settings", "rollGreed" } },
    })
    self:AddButton(L["menu_roll_de"], {
        path = { "settings", "rollDisenchant" },
        arrow = rollDisenchant,
        checked = rollDisenchant,
        func = _SetConfigChecked,
        arg = { cfgkey = "rollDisenchant", reopen = { "settings", "rollDisenchant" } },
    })
    self:AddSpacer()
    self:AddButton(L["menu_show_rnd_frame"], {
        path = { "settings", "showRndFrame" },
        arrow = showRndFrame,
        checked = showRndFrame,
        func = _SetConfigChecked,
        arg = { cfgkey = "showRndFrame", reopen = { "settings", "showRndFrame" } },
    })
    self:AddButton(L["menu_filter_messages"], {
        path = { "settings", "filterMessages" },
        arrow = filterMessages,
        checked = filterMessages,
        func = _SetConfigChecked,
        arg = { cfgkey = "filterMessages", reopen = { "settings", "filterMessages" } },
    })
end)

menu:Register({"settings","rollNeed"}, function(self)
    self:AddSpacer("|cFFFFCC00"..L["menu_expansion"].."|r")
    for exp=0,ADDON_C.EXPANSIONS,1 do
        local cfgkey = "rollNeed_exp"..exp
        self:AddButton(_G["EXPANSION_NAME"..exp], {
            checked = not not ADDON_DB.GetConfig(cfgkey),
            func = _SetConfigChecked,
            arg = { cfgkey = cfgkey, reopen = { "settings", "rollNeed" } },
        })
    end
    self:AddSpacer("")
    self:AddSpacer("|cFFFFCC00"..L["menu_quality"].."|r")
    for i, qual in ipairs(qualitiesList) do
        local text = select(4, GetItemQualityColor(qual)) .. _G["ITEM_QUALITY" .. qual .. "_DESC"] .. "|r"
        local cfgkey = "rollNeed_qual"..qual
        self:AddButton(text, {
            checked = not not ADDON_DB.GetConfig(cfgkey),
            func = _SetConfigChecked,
            arg = { cfgkey = cfgkey, reopen = { "settings", "rollNeed" } },
        })
    end
end)

menu:Register({"settings","rollNeedBoE"}, function(self)
    self:AddSpacer("|cFFFFCC00"..L["menu_expansion"].."|r")
    for exp=0,ADDON_C.EXPANSIONS,1 do
        local cfgkey = "rollNeedBoE_exp"..exp
        self:AddButton(_G["EXPANSION_NAME"..exp], {
            checked = not not ADDON_DB.GetConfig(cfgkey),
            func = _SetConfigChecked,
            arg = { cfgkey = cfgkey, reopen = { "settings", "rollNeedBoE" } },
        })
    end
    self:AddSpacer("")
    self:AddSpacer("|cFFFFCC00"..L["menu_quality"].."|r")
    for i, qual in ipairs(qualitiesList) do
        local text = select(4, GetItemQualityColor(qual)) .. _G["ITEM_QUALITY" .. qual .. "_DESC"] .. "|r"
        local cfgkey = "rollNeedBoE_qual"..qual
        self:AddButton(text, {
            checked = not not ADDON_DB.GetConfig(cfgkey),
            func = _SetConfigChecked,
            arg = { cfgkey = cfgkey, reopen = { "settings", "rollNeedBoE" } },
        })
    end
end)

menu:Register({"settings","rollGreed"}, function(self)
    local cfgkey = "rollGreedOnlySellable"
    self:AddButton(L["menu_roll_greed_only_sellable"], {
        checked = not not ADDON_DB.GetConfig(cfgkey),
        func = _SetConfigChecked,
        arg = { cfgkey = cfgkey, reopen = { "settings", "rollGreed" } },
    })
end)

menu:Register({"settings","rollDisenchant"}, function(self)
    self:AddButton(L["menu_roll_de_boe"], {
        checked = not not ADDON_DB.GetConfig("rollDisenchant_BoE"),
        func = _SetConfigChecked,
        arg = { cfgkey = "rollDisenchant_BoE", reopen = { "settings", "rollDisenchant" } },
    })
    self:AddSpacer("")
    self:AddSpacer("|cFFFFCC00"..L["menu_expansion"].."|r")
    for exp=0,ADDON_C.EXPANSIONS,1 do
        local cfgkey = "rollDisenchant_exp"..exp
        self:AddButton(_G["EXPANSION_NAME"..exp], {
            checked = not not ADDON_DB.GetConfig(cfgkey),
            func = _SetConfigChecked,
            arg = { cfgkey = cfgkey, reopen = { "settings", "rollDisenchant" } },
        })
    end
end)

menu:Register({"settings","showRndFrame"}, function(self)
    for i,roll in ipairs(rollsList) do
        local text = ADDON_C.ROLL_NAMES[roll]..": "..ADDON_DB.GetRndEyes(roll)
        self:AddButton(text, {
            func = _SetRndValue,
            arg = { roll = roll },
        })
    end
    self:AddSpacer()
    self:AddButton(L["menu_show_rnd_test_frame"], {
        func = _ShowRndTestFrame,
        arg = {},
    })
end)

local MESSAGES_MENU_LIST = {
    {
        "LOOT_ROLL_NEED",
        "LOOT_ROLL_GREED",
        "LOOT_ROLL_DISENCHANT",
        "LOOT_ROLL_PASSED",
        "LOOT_ROLL_WON",
    },
    {
        "LOOT_ROLL_NEED_SELF",
        "LOOT_ROLL_GREED_SELF",
        "LOOT_ROLL_DISENCHANT_SELF",
        "LOOT_ROLL_PASSED_SELF",
        "LOOT_ROLL_YOU_WON",
    },
    {
        "LOOT_ROLL_ROLLED_NEED",
        "LOOT_ROLL_ROLLED_GREED",
        "LOOT_ROLL_ROLLED_DE",
    },
    {
        "LOOT_ITEM",
        "LOOT_ITEM_MULTIPLE",
        "LOOT_ITEM_SELF",
        "LOOT_ITEM_SELF_MULTIPLE",
    },
}

menu:Register({"settings","filterMessages"}, function(self)
    for i,list in ipairs(MESSAGES_MENU_LIST) do
        if ( i > 1 ) then
            self:AddSpacer("")
        end
        for j,msg in ipairs(list) do
            local text = ADDON_C.MSG_PATTERNS[msg]:GetPattern()
            self:AddButton(text, {
                checked = not not ADDON_DB.GetMessageFilter(msg),
                func = _SetMessageFilter,
                arg = { message = msg, reopen = { "settings", "filterMessages" } },
            })
        end
    end
end)

menu:Register({"behavior"}, function(self)
    self:AddSpacer(L["menu_behavior_header"])
    self:AddSpacer("")
    self:AddButton(L["behavior_ignore_unknown_items"], { checked = true, disabled = true })
    self:AddButton(L["behavior_special_items_manual"], { checked = true, disabled = true })
    self:AddButton(L["behavior_legendary_items_manual"], { checked = true, disabled = true })
    self:AddButton(L["behavior_learnable_items_manual"], { checked = true, disabled = true })
    self:AddButton(L["behavior_token_items_manual"], { checked = true, disabled = true })
    self:AddButton(L["behavior_epic_equip_in_raid_manual"], { checked = true, disabled = true })
    self:AddButton(L["behavior_roll_fallback"], { checked = true, disabled = true })
    self:AddButton(L["behavior_remove_won_relevant_items"], { checked = true, disabled = true })
    self:AddButton(L["behavior_learnable_boe"], { checked = true, disabled = true })
end)

-----------------------------------------------------------------------------------

function ADDON_Menu.SetState(state)
    local stateInfo = STATES_LIST[state]
    if ( stateInfo ~= nil ) then
        ADDON_DB.SetState(state)
        LDB.icon = stateInfo.icon
        ADDON_Utils.message(stateInfo.message)
        ADDON_Learning.ClearItems()
    end
end

function ADDON_Menu.CycleState()
    local state = ADDON_DB.GetState()
    state = state + 1
    if ( STATES_LIST[state] == nil ) then
        state = 1
    end
    ADDON_Menu.SetState(state)
end

function ADDON_Menu.IsActive()
    return ADDON_DB.GetState() == STATE_ACTIVE
end

function ADDON_Menu.IsInactive()
    return ADDON_DB.GetState() == STATE_INACTIVE
end

function ADDON_Menu.IsLearning()
    return ADDON_DB.GetState() == STATE_LEARNING
end

function ADDON_Menu.Initialize()
    menu:Initialize()
    minimapIcon:Register("RollbotIcon", LDB, RollbotDB.settings.minimap) -- todo: unsafe use of RollbotDB, add ADDON_DB.... function instead
    minimapIcon.objects["RollbotIcon"]:SetFrameStrata("LOW")
    ADDON_Menu.SetState(ADDON_DB.GetState())
end

-----------------------------------------------------------------------------------
