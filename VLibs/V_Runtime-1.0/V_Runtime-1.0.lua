local V_Runtime = LibStub:NewLibrary("V_Runtime-1.0", 0)
if ( not V_Runtime ) then return end
--------------------------------------------------------------------------------

V_Runtime.CreatePendingGate = function()
    local tokens = {}
    local gate = {}

    function gate:Mark(id)
        tokens[id] = (tokens[id] or 0) + 1
    end

    function gate:Consume(id)
        local count = tokens[id]
        if ( count and count > 0 ) then
            count = count - 1
            if ( count == 0 ) then
                tokens[id] = nil
            else
                tokens[id] = count
            end
            return true
        end
        return false
    end

    function gate:Remove(id)
        tokens[id] = nil
    end

    function gate:Has(id)
        return (tokens[id] or 0) > 0
    end

    function gate:Wipe()
        wipe(tokens)
    end

    return gate
end

--------------------------------------------------------------------------------

V_Runtime.pack = function(...)
    return { n = select("#", ...), ... }
end

V_Runtime.SafeCall = function(func, ...)
    local success, results = pcall(function(...)
        return V_Runtime.pack(func(...))
    end, ...)
    if ( success ) then
        return unpack(results, 1, results.n)
    end
    geterrorhandler()(results)
    return nil
end

--------------------------------------------------------------------------------

do
    local callbacks = {}
    local runner = CreateFrame("Frame")

    local function OnUpdate(self)
        self:SetScript("OnUpdate", nil)
        local pending = callbacks
        callbacks = {}
        for i = 1, #pending do
            local func, args = unpack(pending[i])
            V_Runtime.SafeCall(func, unpack(args))
        end
    end

    function V_Runtime.RunOnNextFrame(func, ...)
        if ( type(func) ~= "function" ) then
            return false
        end
        callbacks[#callbacks + 1] = { func, {...} }
        if ( not runner:GetScript("OnUpdate") ) then
            runner:SetScript("OnUpdate", OnUpdate)
        end
        return true
    end
end

--------------------------------------------------------------------------------
