-- Chunk stream with extensions for null checks and other JVML specific things
function makeExtendedChunkStream(maxLocals)
    local stream = makeChunkStream(maxLocals)

    -- value pools are lists of registers known to share the same value
    local valuePools = { }
    local function getPool(reg)
        for poolIndex,pool in ipairs(valuePools) do
            for registerIndex,r in ipairs(pool) do
                if r == reg then
                    return pool, registerIndex, poolIndex
                end
            end
        end
    end

    local function removeFromPool(reg)
        local pool, registerIndex, poolIndex = getPool(reg)
        if pool then
            table.remove(pool, registerIndex)
            if #pool == 0 then
                table.remove(valuePools, poolIndex)
            end
        end
    end

    local function createPool(reg)
        removeFromPool(reg)
        local pool = {reg}
        table.insert(valuePools, pool)
        return pool
    end

    local function addToPool(r1, r2)
        local pool = getPool(r2)
        if not pool then
            pool = createPool(r2)
        end
        table.insert(pool, r1)
        return pool
    end

    -- overwrite memory management functions
    local oldAlloc = stream.alloc
    local oldFree = stream.free
    function stream.alloc(n)
        local ret = {oldAlloc(n)}
        for i,r in ipairs(ret) do
            createPool(r)
        end
        return unpack(ret)
    end

    function stream.free(n)
        local ret = {oldFree(n)}
        for i,r in ipairs(ret) do
            removeFromPool(r)
        end
        return unpack(ret)
    end

    -- overwrite ops
    local assigners = {
        "LOADK",
        "LOADBOOL",
        "GETUPVAL",
        "GETGLOBAL",
        "GETTABLE",
        "NEWTABLE",
        "ADD",
        "SUB",
        "MUL",
        "DIV",
        "MOD",
        "POW",
        "UNM",
        "NOT",
        "LEN",
        "CONCAT"
    }
    for i,opName in ipairs(assigners) do
        local old = stream[opName]
        stream[opName] = function(rAssignTo, ...)
            removeFromPool(rAssignTo)
            return old(rAssignTo, ...)
        end
    end
    
    local oldMove = stream.MOVE
    function stream.MOVE(a, b)
        removeFromPool(a)
        addToPool(a, b)
        return oldMove(a, b)
    end

    local oldLoadnil = stream.LOADNIL
    function stream.LOADNIL(a, b)
        for r=a,b do
            removeFromPool(r)
        end
        return oldLoadnil(a, b)
    end

    local oldCall = stream.CALL
    function stream.CALL(a, b, c)
        local numArgs = b == 0 and stream.getMaxRegister() - a or b - 1
        for r=a, a + numArgs do
            removeFromPool(r)
        end
        return oldCall(a, b, c)
    end

    local oldClose = stream.CLOSE
    function stream.CLOSE(a)
        for i=a,stream.getMaxRegister() do
            removeFromPool(i)
        end
        return oldClose(a)
    end

    local rti = { }
    local reverseRTI = { }
    local function info(obj)
        if not obj then error("Bad argument. Index expected, got nil\nAt: " .. class.name .. "." .. method.name .. ":" .. getCurrentLineNumber(), 2) end
        local i = reverseRTI[obj]
        if i then
            return i
        end
        local p = #rti + 1
        rti[p] = obj
        reverseRTI[obj] = p
        return p
    end
    function stream.getRTI()
        return rti
    end

    -- asm utility functions
    function stream.asmGetObj(r, obj)
        local rk = stream.allocRK(info(obj))
        stream.GETTABLE(r, 0, rk)
        stream.freeRK(rk)
    end

    return stream
end