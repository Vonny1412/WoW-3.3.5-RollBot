local V_MenuBuilder = LibStub:NewLibrary("V_MenuBuilder-1.0", 0)
if ( not V_MenuBuilder ) then return end
local V_Runtime = LibStub("V_Runtime-1.0")
--------------------------------------------------------------------------------

local function PathToString(path)
    if ( #path == 0 ) then
        return "<root>"
    end
    local parts = {}
    for i, key in ipairs(path) do
        parts[i] = tostring(key)
    end
    return table.concat(parts, " > ")
end

local function FindTreeNode(tree, path)
    if ( tree == nil or path == nil ) then
        return nil
    end
    local node = tree
    path = path or {}
    for _, key in ipairs(path) do
        if ( not node.subs[key] ) then
            return nil
        end
        node = node.subs[key]
    end
    return node
end

local function PathMatches(buttonPath, targetPath, depth)
    if ( not buttonPath ) then
        return false
    end
    for i = 1, depth do
        if ( buttonPath[i] ~= targetPath[i] ) then
            return false
        end
    end
    return true
end

local function RestoreCheckState(button, checked)
    local checkmark = _G[button:GetName() .. "Check"]
    if ( checkmark ) then
        if ( checked ) then
            checkmark:Show()
        else
            checkmark:Hide()
        end
    end
    button.checked = checked
end

--------------------------------------------------------------------------------

local menus = {}

V_MenuBuilder.CreateMenu = function(name)
    local menu = {}
    menus[name] = menu

    menu.frame = CreateFrame("Frame", name, nil, "UIDropDownMenuTemplate")
    menu.tree = {
        build = nil,
        subs = {},
    }

    function menu:Show(path, anchor, x, y)
        path = path or {}

        local list = _G["DropDownList1"]
        if ( list ) then
            list:Hide()
        end

        ToggleDropDownMenu(1, nil, self.frame, anchor, x or 0, y or 0)

        for i,p in ipairs(path) do
            list = _G["DropDownList"..i]
            if ( not list ) then
                return -- should exist, but safety first
            end
            for j, info in ipairs({list:GetChildren()}) do
                local value = info.value
                --if ( info:IsShown() and info.hasArrow and value and value.path and value.path[i] == p ) then
                if ( info:IsShown() and info.hasArrow and value and value.path and PathMatches(value.path, path, i) ) then
                    ToggleDropDownMenu(i + 1, value, self.frame, nil, 0, 0, nil, info, 3)
                end
            end
        end
    end

    function menu:Register(path, func)
        path = path or {}

        local node = self.tree
        local currentPath = {}

        for i, key in ipairs(path) do
            table.insert(currentPath, key)
            local isLast = i == #path

            if ( not isLast and not node.subs[key] ) then
                error("Menu path does not exist in '" .. name .. "': " .. PathToString(currentPath), 2)
            end

            node.subs[key] = node.subs[key] or {
                build = nil,
                subs = {},
            }
            node = node.subs[key]
        end

        node.build = func
    end

    local function OnClick(button)
        local func = button.value.func
        local arg = button.value.arg
        if ( button.value.notCheckable ) then
            -- screw you "info.notCheckable"!
            RestoreCheckState(button, button.value.checked)
        end
        if ( func ) then
            V_Runtime.SafeCall(func, button, arg)
        end
    end

    menu.frame.initialize = function(dropDown, level)
        local builder = {}
        local tree = menu.tree
        level = level or 1

        function builder:AddSpacer(text)
            local info = UIDropDownMenu_CreateInfo()
            info.hasArrow = false
            info.text = text or ""
            info.keepShownOnClick = true
            info.notCheckable = true
            info.disabled = true
            UIDropDownMenu_AddButton(info, level)
        end

        -- if opts.checked==nil then the button will be uncheckable, use true/false
        function builder:AddButton(text, opts)

            opts = opts or {}

            local info = UIDropDownMenu_CreateInfo()
            info.text = text
            info.func = OnClick
            info.keepShownOnClick = true -- important! without this the check state could not be changed by clicking on it .. just weird
            info.notCheckable = opts.checked == nil -- note: "notCheckable" does not realy disable checking, weird...
            info.checked = opts.checked
            info.disabled = opts.disabled
            info.hasArrow = opts.arrow

            info.value = {
                -- info
                notCheckable = info.notCheckable,
                -- opts
                path = opts.path,
                func = opts.func,
                arg = opts.arg,
                checked = opts.checked,
            }

            UIDropDownMenu_AddButton(info, level)
        end

        local path = {}
        if ( UIDROPDOWNMENU_MENU_VALUE ) then
            path = UIDROPDOWNMENU_MENU_VALUE.path
        end
        local node = FindTreeNode(tree, path)
        if ( node and node.build ) then
            node.build(builder)
        else
            -- error?
        end

    end
    
    function menu:Initialize()
        -- this method is optional. it pre-renders the menu to make it look nice
        UIDropDownMenu_Initialize(self.frame, self.frame.initialize, "MENU")
    end

    return menu
end

--------------------------------------------------------------------------------
