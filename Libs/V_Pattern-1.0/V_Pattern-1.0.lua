local V_Pattern = LibStub:NewLibrary("V_Pattern-1.0", 0)
if ( not V_Pattern ) then return end
--------------------------------------------------------------------------------

V_Pattern.EscapePattern = function(str)
    return string.gsub(str, "[%(%)%.%%%+%-%*%?%[%^%$%]]", "%%%1")
end

--------------------------------------------------------------------------------

do

    --[[ examples:
      LOOT_MONEY = "%1$s plündert %2$s.";
      LOOT_ROLL_ROLLED_DE = "Entzauberungswurf - %d für %s von %s";
    ]]--

    local mTypes = {
        ["s"] = {
            globalStringPattern = "s",
            luaPattern = ".+",
        },
        ["d"] = {
            globalStringPattern = "d",
            luaPattern = "%d+",
        },
        ["f"] = {
            globalStringPattern = "%.%d+f",
            luaPattern = "%d+%.?%d*", -- luaPattern = "%d+%.%d+",
        },
        ["g"] = {
            globalStringPattern = "%.?%d*g",
            luaPattern = "%d+%.?%d*",
        },
    }

    V_Pattern.CreateConstPattern = function(const)
        if ( type(const) ~= "string" ) then
            return nil
        end

        local unpack = unpack
        local escape = V_Pattern.EscapePattern

        -- important: normalize const string first!
        for k,v in pairs(mTypes) do
            const = const:gsub("%%"..v.globalStringPattern, "%%"..k)
            const = const:gsub("%$"..v.globalStringPattern, "%$"..k)
        end

        -- escape the whole const so that normal special characters may not get treated as pattern characters
        local pattern = escape(const)

        -- convert escaped literal percent signs back to Lua pattern percent signs
        pattern = pattern:gsub("%%%%", "%%")

        local ret = {}
        function ret:GetPattern(asOriginal)
            if ( asOriginal ) then
                return pattern
            end
            return pattern:gsub("%%(%p)", "%1") -- remove escape signs
        end

        -- parse ordered groups

        local order = {}
        for k,v in pairs(mTypes) do
            -- note: pattern has already been escaped
            -- so "%1$s" is now "%%1%$s"
            for m in pattern:gmatch("%%[0-9]+%%%$"..k.."") do
                local mOrder, mType = m:match("%%([0-9]+)%%%$("..k..")")
                table.insert(order, tonumber(mOrder))
                pattern = pattern:gsub(escape(m), "("..v.luaPattern:gsub("%%", "%%%%")..")")
            end
        end

        if ( #order ~= 0 ) then
            function ret:GetMatch(subject)
                if ( type(subject) ~= "string" ) then
                    return nil
                end
                local matches = { subject:match("^"..pattern.."$") }
                local ordered = {}
                for i=1,#order do
                    ordered[i] = matches[order[i]]
                end
                return unpack(ordered)
            end
            return ret
        end

        -- fallback for simple groups
        for k,v in pairs(mTypes) do
            pattern = pattern:gsub("%%"..k, "%("..v.luaPattern:gsub("%%", "%%%%").."%)")
        end
        function ret:GetMatch(subject)
            if ( type(subject) ~= "string" ) then
                return nil
            end
            return subject:match("^"..pattern.."$")
        end
        return ret
    end

end

--------------------------------------------------------------------------------
