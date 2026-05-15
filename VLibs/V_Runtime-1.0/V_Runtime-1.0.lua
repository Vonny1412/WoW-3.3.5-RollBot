local V_Runtime = LibStub:NewLibrary("V_Runtime-1.0", 1)
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

do

    local timerFrame = CreateFrame("Frame")
    local timers = {}

    local function OnUpdate(self, elapsed)
        for i = #timers, 1, -1 do
            local timer = timers[i]
            timer.delay = timer.delay - elapsed
            if ( timer.delay <= 0 ) then
                table.remove(timers, i)
                timer.func(unpack(timer.args))
            end
        end
        if ( #timers == 0 ) then
            self:SetScript("OnUpdate", nil)
        end
    end

    function V_Runtime.SetTimeout(delay, func, ...)
        table.insert(timers, {
            delay = delay,
            func = func,
            args = { ... },
        })
        if ( not timerFrame:GetScript("OnUpdate") ) then
            timerFrame:SetScript("OnUpdate", OnUpdate)
        end
    end

end

--------------------------------------------------------------------------------
