local V_Table = LibStub:NewLibrary("V_Table-1.0", 0)
if ( not V_Table ) then return end
--------------------------------------------------------------------------------

function V_Table.ApplyDefaults(dst, defaults)
    if ( type(dst) ~= "table" ) then
        dst = {}
    end
    for key, value in pairs(defaults) do
        if ( type(value) == "table" ) then
            dst[key] = V_Table.ApplyDefaults(dst[key], value)
        elseif ( dst[key] == nil ) then
            dst[key] = value
        end
    end
    return dst
end

function V_Table.CopyTable(src)
    return V_Table.ApplyDefaults(nil, src)
end


--------------------------------------------------------------------------------
