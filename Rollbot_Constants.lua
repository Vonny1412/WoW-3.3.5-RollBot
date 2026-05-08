local ADDON_NAME, ADDON = ...

local ADDON_C = ADDON.Constants

local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true)
local V_Pattern = LibStub("V_Pattern-1.0")

-----------------------------------------------------------------------------------

ADDON_C.ROLLBOT_TITLE = "|cFFFFCC00Rollbot|r"

-- 0=basic, 1=tbc, 2=wotlk
local accExp = GetAccountExpansionLevel()
ADDON_C.EXPANSIONS = math.min(2, accExp) 

ADDON_C.HISTORY_MAX_COUNT = 20
ADDON_C.LAST_ITEMS_MAX_COUNT = 20

-- always let user decide, dont save rolls
ADDON_C.ALWAYS_ASK_ITEMS = {
    [52019] = true, -- Precious' Ribbon (ICC)
    [50274] = true, -- Shadowfrost Shard (ICC)
    [50379] = true, -- Battered Hilt (WotLK Alliance)
    [50380] = true, -- Battered Hilt (WotLK Horde)
    [49294] = true, -- Ashen Sack of Gems (Onyxia)
    [43347] = true, -- Satchel of Spoils (Sartharion)
    [43297] = true, -- Damaged Necklace (WotLK Random Drop)
    [45912] = true, -- Book of Glyph Mastery (WotLK Random Drop)
    [22559] = true, -- Formula: Enchant Weapon - Mongoose
    [33307] = true, -- Formula: Enchant Weapon - Executioner
    [49908] = true, -- Primordial Saronite (ICC)
    [45038] = true, -- Fragment of Val'anyr (Ulduar)
}

ADDON_C.QUALITY_GREEN_UNCOMMON    = 2 -- wow default
ADDON_C.QUALITY_BLUE_RARE         = 3 -- wow default
ADDON_C.QUALITY_PURPLE_EPIC       = 4 -- wow default
ADDON_C.QUALITY_ORANGE_LEGENDARY  = 5 -- wow default

ADDON_C.ROLLS = {}
ADDON_C.ROLLS.PASS          = 0 -- wow default
ADDON_C.ROLLS.NEED          = 1 -- wow default
ADDON_C.ROLLS.GREED         = 2 -- wow default
ADDON_C.ROLLS.DISENCHANT    = 3 -- wow default
ADDON_C.ROLLS.IGNORE        = 10 -- rollbot
ADDON_C.ROLLS.REMOVE        = 11 -- rollbot

ADDON_C.ROLL_NAMES = {}
ADDON_C.ROLL_NAMES[ADDON_C.ROLLS.PASS]        = PASS
ADDON_C.ROLL_NAMES[ADDON_C.ROLLS.NEED]        = NEED
ADDON_C.ROLL_NAMES[ADDON_C.ROLLS.GREED]       = GREED
ADDON_C.ROLL_NAMES[ADDON_C.ROLLS.DISENCHANT]  = ROLL_DISENCHANT
ADDON_C.ROLL_NAMES[ADDON_C.ROLLS.IGNORE]      = L["status_ignored"]
ADDON_C.ROLL_NAMES[ADDON_C.ROLLS.REMOVE]      = L["status_removed"]

ADDON_C.REASON_ITEM_WON           = 6
ADDON_C.REASON_NO_INTEREST        = 7
ADDON_C.REASON_IN_AUTO_LIST       = 8
ADDON_C.REASON_ITEM_IS_BOE        = 9
ADDON_C.REASON_IN_RAID            = 10
ADDON_C.REASON_LEGENDARY_ITEM     = 11
ADDON_C.REASON_ITEM_NEEDED        = 12
ADDON_C.REASON_NOT_QUALIFIED      = 13
ADDON_C.REASON_SPECIAL_ITEM       = 14
ADDON_C.REASON_ITEM_SKILL_KNOWN   = 15
ADDON_C.REASON_ITEM_UNKNOWN       = 16
ADDON_C.REASON_ADDED_BY_USER      = 17
ADDON_C.REASON_REMOVED_BY_USER    = 18
ADDON_C.REASON_SKILL_TOO_LOW      = 19
ADDON_C.REASON_LEARNABLE_ITEM     = 20

ADDON_C.REASON_STRINGS = {}
ADDON_C.REASON_STRINGS[1] = _G["LOOT_ROLL_INELIGIBLE_REASON1"]
ADDON_C.REASON_STRINGS[2] = _G["LOOT_ROLL_INELIGIBLE_REASON2"]
ADDON_C.REASON_STRINGS[3] = _G["LOOT_ROLL_INELIGIBLE_REASON3"]
ADDON_C.REASON_STRINGS[4] = _G["LOOT_ROLL_INELIGIBLE_REASON4"]
ADDON_C.REASON_STRINGS[5] = _G["LOOT_ROLL_INELIGIBLE_REASON5"]
ADDON_C.REASON_STRINGS[6] = L["reason_you_won"]
ADDON_C.REASON_STRINGS[7] = L["reason_no_interest"]
ADDON_C.REASON_STRINGS[8] = L["reason_in_auto_list"]
ADDON_C.REASON_STRINGS[9] = L["reason_item_is_boe"]
ADDON_C.REASON_STRINGS[10] = L["reason_in_raid"]
ADDON_C.REASON_STRINGS[11] = L["reason_legendary_item"]
ADDON_C.REASON_STRINGS[12] = L["reason_item_is_needed"]
ADDON_C.REASON_STRINGS[13] = L["reason_not_qualified"]
ADDON_C.REASON_STRINGS[14] = L["reason_special_item"]
ADDON_C.REASON_STRINGS[15] = L["reason_item_skill_known"]
ADDON_C.REASON_STRINGS[16] = L["reason_item_unknown"]
ADDON_C.REASON_STRINGS[17] = L["reason_added_by_user"]
ADDON_C.REASON_STRINGS[18] = L["reason_removed_by_user"]
ADDON_C.REASON_STRINGS[19] = L["reason_skill_too_low"]
ADDON_C.REASON_STRINGS[20] = L["reason_learnable_item"]

ADDON_C.MSG_PATTERNS = {}
ADDON_C.MSG_PATTERNS.LOOT_ROLL_NEED_SELF         = ""
ADDON_C.MSG_PATTERNS.LOOT_ROLL_GREED_SELF        = ""
ADDON_C.MSG_PATTERNS.LOOT_ROLL_DISENCHANT_SELF   = ""
ADDON_C.MSG_PATTERNS.LOOT_ROLL_PASSED_SELF       = ""
ADDON_C.MSG_PATTERNS.LOOT_ROLL_YOU_WON           = ""
ADDON_C.MSG_PATTERNS.LOOT_ROLL_NEED              = ""
ADDON_C.MSG_PATTERNS.LOOT_ROLL_GREED             = ""
ADDON_C.MSG_PATTERNS.LOOT_ROLL_DISENCHANT        = ""
ADDON_C.MSG_PATTERNS.LOOT_ROLL_PASSED            = ""
ADDON_C.MSG_PATTERNS.LOOT_ROLL_WON               = ""
ADDON_C.MSG_PATTERNS.LOOT_ROLL_ROLLED_NEED       = ""
ADDON_C.MSG_PATTERNS.LOOT_ROLL_ROLLED_GREED      = ""
ADDON_C.MSG_PATTERNS.LOOT_ROLL_ROLLED_DE         = ""
ADDON_C.MSG_PATTERNS.LOOT_ITEM                   = ""
ADDON_C.MSG_PATTERNS.LOOT_ITEM_MULTIPLE          = ""
ADDON_C.MSG_PATTERNS.LOOT_ITEM_SELF              = ""
ADDON_C.MSG_PATTERNS.LOOT_ITEM_SELF_MULTIPLE     = ""
for k in pairs(ADDON_C.MSG_PATTERNS) do
    ADDON_C.MSG_PATTERNS[k] = V_Pattern.CreateConstPattern(_G[k])
end

-----------------------------------------------------------------------------------
