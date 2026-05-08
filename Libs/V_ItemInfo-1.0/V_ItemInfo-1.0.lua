local V_ItemInfo = LibStub:NewLibrary("V_ItemInfo-1.0", 0)
if ( not V_ItemInfo ) then return end
local V_Runtime = LibStub("V_Runtime-1.0")
local V_Pattern = LibStub("V_Pattern-1.0")
--------------------------------------------------------------------------------

do

    local ITEM_CLASS_IDS = {}
    local ITEM_CLASS_NAMES = {}
    local ITEM_SUBCLASS_IDS = {}
    local ITEM_SUBCLASS_NAMES = {}

    local itemClasses = { GetAuctionItemClasses() }
    for classID, className in ipairs(itemClasses) do
        ITEM_CLASS_IDS[className] = classID
        ITEM_CLASS_NAMES[classID] = className
        ITEM_SUBCLASS_IDS[className] = {}
        ITEM_SUBCLASS_NAMES[classID] = {}
        local subClasses = { GetAuctionItemSubClasses(classID) }
        for subClassID, subClassName in ipairs(subClasses) do
            ITEM_SUBCLASS_IDS[className][subClassName] = subClassID
            ITEM_SUBCLASS_NAMES[classID][subClassID] = subClassName
        end
    end

    V_ItemInfo.GetItemClass = function(itemID)
        local itemType, itemSubType = select(6, GetItemInfo(itemID))
        if ( not itemType ) then
            return nil
        end
        local classID = ITEM_CLASS_IDS[itemType]
        local subClassID = classID and ITEM_SUBCLASS_IDS[itemType] and ITEM_SUBCLASS_IDS[itemType][itemSubType] or nil
        return classID, subClassID
    end

    V_ItemInfo.GetItemClassID = function(itemType)
        return itemType and ITEM_CLASS_IDS[itemType] or nil
    end

    V_ItemInfo.GetItemSubClassID = function(itemType, itemSubType)
        return itemType and ITEM_SUBCLASS_IDS[itemType] and itemSubType and ITEM_SUBCLASS_IDS[itemType][itemSubType] or nil
    end

    V_ItemInfo.GetItemClassName = function(classID)
        return classID and ITEM_CLASS_NAMES[classID] or nil
    end

    V_ItemInfo.GetItemSubClassName = function(classID, subClassID)
        return classID and ITEM_SUBCLASS_NAMES[classID] and subClassID and ITEM_SUBCLASS_NAMES[classID][subClassID] or nil
    end

    V_ItemInfo.PrintItemClasses = function()
        for classID, className in ipairs(ITEM_CLASS_NAMES) do
            print(classID .. " " .. className)
            for subClassID, subClassName in ipairs(ITEM_SUBCLASS_NAMES[classID]) do
                print(classID .. "." .. subClassID .. " " .. subClassName)
            end
        end
    end

end

--------------------------------------------------------------------------------

local ITEM_TYPE_WEAPON      = V_ItemInfo.GetItemClassName(1)
local ITEM_TYPE_ARMOR       = V_ItemInfo.GetItemClassName(2)
local ITEM_TYPE_BAG         = V_ItemInfo.GetItemClassName(3)
local ITEM_TYPE_RECIPE      = V_ItemInfo.GetItemClassName(9)
local ITEM_TYPE_MISC        = V_ItemInfo.GetItemClassName(11)
local ITEM_SUBTYPE_MOUNT    = V_ItemInfo.GetItemSubClassName(11, 6)
local ITEM_SUBTYPE_PET      = V_ItemInfo.GetItemSubClassName(11, 3)
--local ITEM_SUBTYPE_PLUNDER  = V_ItemInfo.GetItemSubClassName(11, 1)

V_ItemInfo.GetItemExpansion = function(itemID)
    if ( type(itemID) ~= "number" ) then
        return nil
    end
    if ( itemID <= 23320 ) then return 0 end
    if ( itemID <= 35557 ) then return 1 end
    return 2
end

V_ItemInfo.GetItemType = function(item)
    local t1, t2 = select(6, GetItemInfo(item))
    return t1, t2
end

V_ItemInfo.IsLearnableItem = function(item)
    local t1, t2 = select(6, GetItemInfo(item))
    local isRecipe = t1 == ITEM_TYPE_RECIPE
    local isMountOrPet = t1 == ITEM_TYPE_MISC and ( t2 == ITEM_SUBTYPE_MOUNT or t2 == ITEM_SUBTYPE_PET )
    return isRecipe or isMountOrPet
end

V_ItemInfo.IsEquipableItem = function(item, includeAmmo)
    local loc = select(9, GetItemInfo(item))
    if ( loc == nil or loc == "" ) then
        return false
    end
    if ( loc == INVTYPE_AMMO and not includeAmmo ) then
        return false
    end
    return true
end

V_ItemInfo.GetItemLinkInfo = function(itemLink)
    if ( itemLink ) then
        local itemID, itemName = select(3, itemLink:find("\124Hitem:(%d+):.*\124h%[(.-)%]\124h\124r"))
        if ( itemID ) then
            return tonumber(itemID), strtrim(itemName)
        end
    end
    return nil
end

V_ItemInfo.GetColoredItemName = function(itemID)
    local itemName, _, itemQuality = GetItemInfo(itemID)
    if ( not itemName ) then
        return nil
    end
    local color = select(4, GetItemQualityColor(itemQuality or 1))
    return color .. itemName .. "|r"
end

--------------------------------------------------------------------------------

do

    local REQUEST_CHECK_INTERVAL = 0.2
    local REQUEST_TIMEOUT = 3.0
    local MAX_PENDING_REQUESTS = 5

    local runner = CreateFrame("Frame")
    local tooltip = CreateFrame("GameTooltip", "V_ItemInfo_RequestItemInfo_Tooltip", UIParent, "GameTooltipTemplate")

    local pendingRequests = {}
    local pendingQueue = {}
    local lockedItemIDs = {}
    local elapsedInterval = 0
    local elapsedTemp = 0

    local notLoggedIn = true
    runner:RegisterEvent("PLAYER_LOGIN")
    runner:SetScript("OnEvent", function(self, event)
        self:UnregisterEvent(event)
        notLoggedIn = nil
    end)

    local function DoCallBack(cb, success, itemID)
        if ( cb ~= nil ) then
            V_Runtime.SafeCall(cb, success, itemID)
        end
    end

    local function TryGetItemInfo(itemID, callback, callbackOnFail)
        local itemName = GetItemInfo(itemID)
        if ( itemName ~= nil ) then
            DoCallBack(callback, itemID, true)
            return true
        end
        if ( callbackOnFail == true ) then
            DoCallBack(callback, itemID, false)
        end
        return false
    end

    local function OnUpdate(self, elapsed)
        if ( notLoggedIn ) then
            return
        end

        if ( #pendingRequests < MAX_PENDING_REQUESTS ) then
            while ( #pendingQueue > 0 and #pendingRequests < MAX_PENDING_REQUESTS ) do
                local request = tremove(pendingQueue, 1)
                DoCallBack(request.callback, request.itemID, nil)
                tooltip:SetHyperlink("item:" .. request.itemID .. ":0:0:0:0:0:0:0")
                tinsert(pendingRequests, request)
            end
        end
        if ( #pendingRequests == 0 ) then
            self:SetScript("OnUpdate", nil)
            elapsedInterval = 0
            elapsedTemp = 0
            return
        end

        elapsedInterval = elapsedInterval + elapsed
        if ( elapsedInterval < REQUEST_CHECK_INTERVAL ) then
            elapsedTemp = elapsedTemp + elapsed
            return
        end
        elapsedInterval = 0

        local stillPending = {}
        for i, request in pairs(pendingRequests) do
            request.elapsed = request.elapsed + elapsedTemp
            local isTimeout = request.elapsed >= REQUEST_TIMEOUT

            if ( TryGetItemInfo(request.itemID, request.callback, isTimeout ) ) then
                lockedItemIDs[request.itemID] = nil
            else
                if ( isTimeout ) then
                    lockedItemIDs[request.itemID] = nil
                else
                    tinsert(stillPending, request)
                end
            end
        end
        pendingRequests = stillPending
        elapsedTemp = 0
    end

    V_ItemInfo.RequestItemInfo = function(itemID, callback)
        if ( type(itemID) ~= "number" ) then
            return false, "Item ID is not a number"
        end

        if ( TryGetItemInfo(itemID, callback ) ) then
            return true
        end

        if ( lockedItemIDs[itemID] ~= nil ) then
            return false, "Item ID already requested"
        end
        lockedItemIDs[itemID] = true

        tinsert(pendingQueue, {
            itemID = itemID,
            callback = callback,
            elapsed = 0,
        })

        if ( not runner:GetScript("OnUpdate") ) then
            runner:SetScript("OnUpdate", OnUpdate)
        end
        
        return true
    end

    V_ItemInfo.RequestAllItemInfos = function(t, callback)
        local count = #t
        local results = {}
        if ( count == 0 ) then
            V_Runtime.SafeCall(callback, results)
            return
        end
        local check = function()
            for i=1,count do
                if ( results[i] == nil ) then
                    return
                end
            end
            V_Runtime.SafeCall(callback, results)
        end
        for i=1,count do
            local index = i
            local itemID = t[i]
            local requested = V_ItemInfo.RequestItemInfo(itemID, function(itemID, success)
                if ( success ~= nil ) then
                    results[index] = { itemID, success }
                    check()
                end
            end)
            if ( requested ~= true ) then
                results[index] = { itemID, false }
                check()
            end
        end
    end

end

--------------------------------------------------------------------------------

do

    local REQUIREMENT_RED_R = 255
    local REQUIREMENT_RED_G = 32
    local REQUIREMENT_RED_B = 32
    local mfloor = math.floor
    local function IsRequirementRed(fontString)
        local r, g, b = fontString:GetTextColor()
        r = mfloor(r * 255 + 0.5)
        g = mfloor(g * 255 + 0.5)
        b = mfloor(b * 255 + 0.5)
        return r == REQUIREMENT_RED_R
           and g == REQUIREMENT_RED_G
           and b == REQUIREMENT_RED_B
    end

    local function GetTooltipLineText(fontString)
        return fontString and fontString:GetText() or nil
    end

    local function HasSkill(skillName)
        for i=1,GetNumSkillLines(),1 do
            local name, _, _, rank, _, _, rankMax = GetSkillLineInfo(i)
            if ( rankMax > 1 ) then
                -- skillline is not a header and its a skill with progression
                if ( name == skillName ) then
                    -- currently we do not need to check the rank
                    -- but keep the vars, they may be usefull in future
                    return true
                end
            end
        end
        return false
    end

    local tooltip = CreateFrame("GameTooltip", "V_ItemInfo_GetItemUnusableReason_Tooltip", UIParent, "GameTooltipTemplate")

    local itemMinSkillPattern = V_Pattern.CreateConstPattern(ITEM_MIN_SKILL)
    local itemSpellKnownPattern = V_Pattern.CreateConstPattern(ITEM_SPELL_KNOWN)
    local itemClassesAllowedPattern = V_Pattern.CreateConstPattern(ITEM_CLASSES_ALLOWED)

    V_ItemInfo.GetItemRestrictions = function(itemID)
        if ( type(itemID) ~= "number" ) then
            return nil
        end

        tooltip:SetOwner(UIParent, "ANCHOR_TOP")
        tooltip:SetHyperlink("item:" .. itemID)
        tooltip:Show()

        local foundRed = false
        local foundRequiredWeaponSkill = false
        local foundClassRestriction = false
        local foundSpellAlreadyKnown = false
        local foundRequiredRecipeSkill = false
        local foundRequiredRecipeSkillTooLow = false

        for i = 1, tooltip:NumLines() do
            local left = _G[tooltip:GetName() .. "TextLeft" .. i]
            local right = _G[tooltip:GetName() .. "TextRight" .. i]
            local leftText = GetTooltipLineText(left)
            local rightText = GetTooltipLineText(right)

            if ( leftText ) then
                local isUseLine = leftText:sub(1, #ITEM_SPELL_TRIGGER_ONUSE) == ITEM_SPELL_TRIGGER_ONUSE
                if ( isUseLine ) then
                    -- item may be a recipe, break at this point
                    -- because following lines do not belong to the current item but for the item that could be crafted after learning this recipe
                    break
                end
            end

            if ( leftText and IsRequirementRed(left) ) then
                foundRed = true

                local allowedClasses = itemClassesAllowedPattern:GetMatch(leftText)
                if ( allowedClasses ) then
                    foundClassRestriction = true
                end

                local spellKnown = itemSpellKnownPattern:GetMatch(leftText)
                if ( spellKnown ) then
                    foundSpellAlreadyKnown = true
                end

                local minSkillName = itemMinSkillPattern:GetMatch(leftText)
                if ( minSkillName ) then
                    foundRequiredRecipeSkill = true
                    if ( HasSkill(minSkillName) ) then
                        -- could use item, but skill is too low
                        foundRequiredRecipeSkillTooLow = true
                    else
                        -- missing skill, unuseable
                    end
                end

            end

            if ( rightText and IsRequirementRed(right) ) then
                foundRed = true
                foundRequiredWeaponSkill = true
            end
        end

        tooltip:Hide()

        if ( foundRed ) then
            return foundRed, foundClassRestriction, foundRequiredWeaponSkill, foundSpellAlreadyKnown, foundRequiredRecipeSkill, foundRequiredRecipeSkillTooLow
        end
        return nil
    end

end

--------------------------------------------------------------------------------
