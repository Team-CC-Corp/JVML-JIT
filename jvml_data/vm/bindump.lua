function makeDumpster(platform)
    local dump = { }

    local out = ""

    local function dumpNum(n, bytes, forcedEndianness)
        if (platform.endianness == 0 or forcedEndianness == 0) and forcedEndianness ~= 1 then
            for i=bytes-1, 0, -1 do
                dump.dumpByte(bit.band(bit.brshift(n, i * 8), 0xff))
            end
        elseif platform.endianness == 1 or forcedEndianness == 1 then
            for i=0, bytes - 1 do
                dump.dumpByte(bit.band(bit.brshift(n, i * 8), 0xff))
            end
        else
            error("Unsupported endianness:" .. tostring(platform.endianness))
        end
    end

    function dump.dumpByte(b)
        out = out .. string.char(b)
    end

    function dump.dumpInteger(n)
        dumpNum(n, platform.size_int)
    end

    function dump.dumpSize_t(n)
        dumpNum(n, platform.size_t)
    end

    function dump.dumpString(s)
        if s == nil then
            dump.dumpSize_t(0)
        else
            dump.dumpSize_t(#s + 1)
            for i=1, #s do
                dump.dumpByte(s:byte(i,i))
            end
            dump.dumpByte(0)
        end
    end

    function dump.dumpNumber(x)
        --[[
Borrowing this function from LuaLua

==============================================================================
Yueliang Copyright (C) 2005-2008 Kein-Hong Man <khman@users.sf.net>
Lua 5.0.3 Copyright (C) 2003-2006 Tecgraf, PUC-Rio.
Lua 5.1.3 Copyright (C) 1994-2008 Lua.org, PUC-Rio.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
        ]]
        assert(platform.size_number == 8, "Unsupported number size")
        local function grab_byte(v)
            local c = v % 256
            return (v - c) / 256, string.char(c)
        end
        local sign = 0
        if x < 0 then sign = 1; x = -x end
        local mantissa, exponent = math.frexp(x)
        if x == 0 then -- zero
            mantissa, exponent = 0, 0
        elseif x == 1/0 then
            mantissa, exponent = 0, 2047
        else
            mantissa = (mantissa * 2 - 1) * math.ldexp(0.5, 53)
            exponent = exponent + 1022
        end
        local v, byte = "" -- convert to bytes
        x = math.floor(mantissa)
        for i = 1,6 do
            x, byte = grab_byte(x); v = v..byte -- 47:0
        end
        x, byte = grab_byte(exponent * 16 + x); v = v..byte -- 55:48
        x, byte = grab_byte(sign * 128 + x); v = v..byte -- 63:56

        if platform.endianness == 0 then
            v = v:reverse()
        end

        for i=1,#v do
            dump.dumpByte(v:byte(i,i))
        end
    end

    function dump.dumpInstruction(inst)
        dumpNum(inst, platform.size_instruction)
    end

    function dump.dumpConstant(const)
        if type(const) == "nil" then
            dump.dumpByte(0)
        elseif type(const) == "boolean" then
            dump.dumpByte(1)
            if const then
                dump.dumpByte(1)
            else
                dump.dumpByte(0)
            end
        elseif type(const) == "number" then
            dump.dumpByte(3)
            dump.dumpNumber(const)
        elseif type(const) == "string" then
            dump.dumpByte(4)
            dump.dumpString(const)
        else
            error("Uknown constant type: " .. type(const))
        end
    end

    function dump.dumpInstructionsList(instns)
        dump.dumpInteger(#instns)
        for i,v in ipairs(instns) do
            dump.dumpInstruction(v)
        end
    end

    function dump.dumpConstantsList(constants, nilIndex)
        local nilConst = {}
        local constList = {}
        for k,v in pairs(constants) do
            constList[v + 1] = k
        end
        if nilIndex then
            constList[nilIndex + 1] = nilConst
        end

        dump.dumpInteger(#constList)
        for i,v in ipairs(constList) do
            if v == nilConst then
                v = nil
            end
            dump.dumpConstant(v)
        end
    end

    function dump.dumpSourceLinePositions(sourceLinePositions)
        dump.dumpInteger(#sourceLinePositions)
        for i,v in ipairs(sourceLinePositions) do
            dump.dumpInteger(v)
        end
    end

    function dump.toString()
        return out
    end

    -- Create header
    local signature = "\27Lua"
    for i=1,#signature do
        dump.dumpByte(signature:byte(i,i))
    end

    dump.dumpByte(platform.version)
    dump.dumpByte(platform.format)
    dump.dumpByte(platform.endianness)
    dump.dumpByte(platform.size_int)
    dump.dumpByte(platform.size_t)
    dump.dumpByte(platform.size_instruction)
    dump.dumpByte(platform.size_number)
    dump.dumpByte(platform.integral)

    return dump
end