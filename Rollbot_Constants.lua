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
ADDON_C.REASON_ITEM_IS_TOKEN      = 21

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
ADDON_C.REASON_STRINGS[21] = L["reason_item_is_token"]

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

-- always let user decide, dont save rolls
ADDON_C.ALWAYS_ASK_ITEMS = {

    [52019] = true, -- Precious' Ribbon (ICC)

    [50274] = true, -- Shadowfrost Shard (ICC)
    [49908] = true, -- Primordial Saronite (ICC)
    [45038] = true, -- Fragment of Val'anyr (Ulduar)

    [50379] = true, -- Battered Hilt (WotLK Alliance)
    [50380] = true, -- Battered Hilt (WotLK Horde)

    [49294] = true, -- Ashen Sack of Gems (Onyxia)
    [34846] = true, -- Black Sack of Gems (Magtheridon)
    [43347] = true, -- Satchel of Spoils (Sartharion)

    [43297] = true, -- Damaged Necklace (WotLK Random Drop)
    [45912] = true, -- Book of Glyph Mastery (WotLK Random Drop)

}

-----------------------------------------------------------------------------------

ADDON_C.TOKEN_ITEMS = {

    -- Ahn'Qiraj
    [20874] = true, -- Idol of the Sun
    [20875] = true, -- Idol of Night
    [20876] = true, -- Idol of Death
    [20877] = true, -- Idol of the Sage
    [20878] = true, -- Idol of Rebirth
    [20879] = true, -- Idol of Life
    [20881] = true, -- Idol of Strife
    [20882] = true, -- Idol of War
    [20926] = true, -- Vek'nilash's Circlet
    [20927] = true, -- Ouro's Intact Hide
    [20928] = true, -- Qiraji Bindings of Command
    [20929] = true, -- Carapace of the Old God
    [20930] = true, -- Vek'lor's Diadem
    [20931] = true, -- Skin of the Great Sandworm
    [20932] = true, -- Qiraji Bindings of Dominance
    [20933] = true, -- Husk of the Old God

    -- Black Temple
    [31089] = true, -- Chestguard of the Forgotten Conqueror
    [31090] = true, -- Chestguard of the Forgotten Vanquisher
    [31091] = true, -- Chestguard of the Forgotten Protector
    [31098] = true, -- Leggings of the Forgotten Conqueror
    [31099] = true, -- Leggings of the Forgotten Vanquisher
    [31100] = true, -- Leggings of the Forgotten Protector
    [31101] = true, -- Pauldrons of the Forgotten Conqueror
    [31102] = true, -- Pauldrons of the Forgotten Vanquisher
    [31103] = true, -- Pauldrons of the Forgotten Protector

    -- Hyjal
    [31092] = true, -- Gloves of the Forgotten Conqueror
    [31093] = true, -- Gloves of the Forgotten Vanquisher
    [31094] = true, -- Gloves of the Forgotten Protector
    [31095] = true, -- Helm of the Forgotten Protector
    [31096] = true, -- Helm of the Forgotten Vanquisher
    [31097] = true, -- Helm of the Forgotten Conqueror

    -- Serpentshrine Cavern
    [30239] = true, -- Gloves of the Vanquished Champion
    [30240] = true, -- Gloves of the Vanquished Defender
    [30241] = true, -- Gloves of the Vanquished Hero
    [30242] = true, -- Helm of the Vanquished Champion
    [30243] = true, -- Helm of the Vanquished Defender
    [30244] = true, -- Helm of the Vanquished Hero
    [30245] = true, -- Leggings of the Vanquished Champion
    [30246] = true, -- Leggings of the Vanquished Defender
    [30247] = true, -- Leggings of the Vanquished Hero

    -- Gruul's Lair
    [29762] = true, -- Pauldrons of the Fallen Hero
    [29763] = true, -- Pauldrons of the Fallen Champion
    [29764] = true, -- Pauldrons of the Fallen Defender
    [29765] = true, -- Leggings of the Fallen Hero
    [29766] = true, -- Leggings of the Fallen Champion
    [29767] = true, -- Leggings of the Fallen Defender

    -- Magtheridon's Lair
    [29753] = true, -- Chestguard of the Fallen Defender
    [29754] = true, -- Chestguard of the Fallen Champion
    [29755] = true, -- Chestguard of the Fallen Hero

    -- Karazhan
    [29756] = true, -- Gloves of the Fallen Hero
    [29757] = true, -- Gloves of the Fallen Champion
    [29758] = true, -- Gloves of the Fallen Defender
    [29759] = true, -- Helm of the Fallen Hero
    [29760] = true, -- Helm of the Fallen Champion
    [29761] = true, -- Helm of the Fallen Defender

    -- Sunwell
    [34848] = true, -- Bracers of the Forgotten Conqueror
    [34851] = true, -- Bracers of the Forgotten Protector
    [34852] = true, -- Bracers of the Forgotten Vanquisher
    [34853] = true, -- Belt of the Forgotten Conqueror
    [34854] = true, -- Belt of the Forgotten Protector
    [34855] = true, -- Belt of the Forgotten Vanquisher
    [34856] = true, -- Boots of the Forgotten Conqueror
    [34857] = true, -- Boots of the Forgotten Protector
    [34858] = true, -- Boots of the Forgotten Vanquisher

    -- Tempest Keep
    [30236] = true, -- Chestguard of the Vanquished Champion
    [30237] = true, -- Chestguard of the Vanquished Defender
    [30238] = true, -- Chestguard of the Vanquished Hero
    [30248] = true, -- Pauldrons of the Vanquished Champion
    [30249] = true, -- Pauldrons of the Vanquished Defender
    [30250] = true, -- Pauldrons of the Vanquished Hero

    -- Icecrown Citadel
    [52025] = true, -- Vanquisher's Mark of Sanctification
    [52026] = true, -- Protector's Mark of Sanctification
    [52027] = true, -- Conqueror's Mark of Sanctification
    [52028] = true, -- Vanquisher's Mark of Sanctification (Heroic)
    [52029] = true, -- Protector's Mark of Sanctification (Heroic)
    [52030] = true, -- Conqueror's Mark of Sanctification (Heroic)

    -- Naxxramas
    [40610] = true, -- Chestguard of the Lost Conqueror
    [40611] = true, -- Chestguard of the Lost Protector
    [40612] = true, -- Chestguard of the Lost Vanquisher
    [40616] = true, -- Helm of the Lost Conqueror
    [40617] = true, -- Helm of the Lost Protector
    [40618] = true, -- Helm of the Lost Vanquisher
    [40619] = true, -- Leggings of the Lost Conqueror
    [40620] = true, -- Leggings of the Lost Protector
    [40621] = true, -- Leggings of the Lost Vanquisher
    [40622] = true, -- Spaulders of the Lost Conqueror
    [40623] = true, -- Spaulders of the Lost Protector
    [40624] = true, -- Spaulders of the Lost Vanquisher
    [40625] = true, -- Breastplate of the Lost Conqueror
    [40626] = true, -- Breastplate of the Lost Protector
    [40627] = true, -- Breastplate of the Lost Vanquisher
    [40631] = true, -- Crown of the Lost Conqueror
    [40632] = true, -- Crown of the Lost Protector
    [40633] = true, -- Crown of the Lost Vanquisher
    [40634] = true, -- Legplates of the Lost Conqueror
    [40635] = true, -- Legplates of the Lost Protector
    [40636] = true, -- Legplates of the Lost Vanquisher
    [40637] = true, -- Mantle of the Lost Conqueror
    [40638] = true, -- Mantle of the Lost Protector
    [40639] = true, -- Mantle of the Lost Vanquisher

    -- The Obsidian Sanctum
    [40613] = true, -- Gloves of the Lost Conqueror
    [40614] = true, -- Gloves of the Lost Protector
    [40615] = true, -- Gloves of the Lost Vanquisher
    [40628] = true, -- Gauntlets of the Lost Conqueror
    [40629] = true, -- Gauntlets of the Lost Protector
    [40630] = true, -- Gauntlets of the Lost Vanquisher

    -- Trial of the Crusader
    [47242] = true, -- Trophy of the Crusade
    -- Trial of the Grand Crusader (Heroic)
    [47557] = true, -- Regalia of the Grand Conqueror
    [47558] = true, -- Regalia of the Grand Protector
    [47559] = true, -- Regalia of the Grand Vanquisher

    -- Ulduar
    [45635] = true, -- Chestguard of the Wayward Conqueror
    [45636] = true, -- Chestguard of the Wayward Protector
    [45637] = true, -- Chestguard of the Wayward Vanquisher
    [45644] = true, -- Gloves of the Wayward Conqueror
    [45645] = true, -- Gloves of the Wayward Protector
    [45646] = true, -- Gloves of the Wayward Vanquisher
    [45647] = true, -- Helm of the Wayward Conqueror
    [45648] = true, -- Helm of the Wayward Protector
    [45649] = true, -- Helm of the Wayward Vanquisher
    [45650] = true, -- Leggings of the Wayward Conqueror
    [45651] = true, -- Leggings of the Wayward Protector
    [45652] = true, -- Leggings of the Wayward Vanquisher
    [45659] = true, -- Spaulders of the Wayward Conqueror
    [45660] = true, -- Spaulders of the Wayward Protector
    [45661] = true, -- Spaulders of the Wayward Vanquisher
    [45632] = true, -- Breastplate of the Wayward Conqueror
    [45633] = true, -- Breastplate of the Wayward Protector
    [45634] = true, -- Breastplate of the Wayward Vanquisher
    [45638] = true, -- Crown of the Wayward Conqueror
    [45639] = true, -- Crown of the Wayward Protector
    [45640] = true, -- Crown of the Wayward Vanquisher
    [45641] = true, -- Gauntlets of the Wayward Conqueror
    [45642] = true, -- Gauntlets of the Wayward Protector
    [45643] = true, -- Gauntlets of the Wayward Vanquisher
    [45653] = true, -- Legplates of the Wayward Conqueror
    [45654] = true, -- Legplates of the Wayward Protector
    [45655] = true, -- Legplates of the Wayward Vanquisher
    [45656] = true, -- Mantle of the Wayward Conqueror
    [45657] = true, -- Mantle of the Wayward Protector
    [45658] = true, -- Mantle of the Wayward Vanquisher

    -- Classic Naxxramas
    [22349] = true, -- Desecrated Breastplate
    [22350] = true, -- Desecrated Tunic
    [22351] = true, -- Desecrated Robe
    [22352] = true, -- Desecrated Legplates
    [22353] = true, -- Desecrated Helmet
    [22354] = true, -- Desecrated Pauldrons
    [22355] = true, -- Desecrated Bracers
    [22356] = true, -- Desecrated Waistguard
    [22357] = true, -- Desecrated Gauntlets
    [22358] = true, -- Desecrated Sabatons
    [22359] = true, -- Desecrated Legguards
    [22360] = true, -- Desecrated Headpiece
    [22361] = true, -- Desecrated Spaulders
    [22362] = true, -- Desecrated Wristguards
    [22363] = true, -- Desecrated Girdle
    [22364] = true, -- Desecrated Handguards
    [22365] = true, -- Desecrated Boots
    [22366] = true, -- Desecrated Leggings
    [22367] = true, -- Desecrated Circlet
    [22368] = true, -- Desecrated Shoulderpads
    [22369] = true, -- Desecrated Bindings
    [22370] = true, -- Desecrated Belt
    [22371] = true, -- Desecrated Gloves
    [22372] = true, -- Desecrated Sandals

}







-----------------------------------------------------------------------------------
