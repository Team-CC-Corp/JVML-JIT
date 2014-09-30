local function compile(class, method, codeAttr, cp)
    checkIn()
    local function resolveClass(c)
        local cn = cp[c.name_index].bytes:gsub("/",".")
        return classByName(cn)
    end

    local lineNumberAttribute
    local stackMapAttribute
    for i=0,codeAttr.attributes_count-1 do
        if codeAttr.attributes[i].name == "LineNumberTable" then
            lineNumberAttribute = codeAttr.attributes[i]
        elseif codeAttr.attributes[i].name == "StackMapTable" then
            stackMapAttribute = codeAttr.attributes[i]
        end
    end

    local sourceFileName
    for i=0,class.attributes_count-1 do
        if class.attributes[i].name == "SourceFile" then
            sourceFileName = cp[class.attributes[i].source_file_index].bytes
        end
    end

    -- Forward declarations
    local getCurrentLineNumber

    local code = codeAttr.code
    local asm = { }

    local comments = { }
    local asmPC = 1
    local function emitWithComment(comment, str, ...)
        if comment then
            comments[asmPC] = "\t\t\t; " .. comment
        end
        local _, err = pcall(function(...)
            asmPC = asmPC + 1
            asm[#asm + 1] = string.format(str, ...) .. "\n"
        end, ...)
        if err then
            error(err, 2)
        end
        return asmPC
    end

    local function emit(str, ...)
        return emitWithComment(nil, str, ...)
    end

    local function emitInsert(pc, str, ...)
        local _, err = pcall(function(...)
            asm[pc] = string.format(str, ...) .. "\n"
        end, ...)
        if err then
            error(err, 2)
        end
        return pc
    end

    local reg = codeAttr.max_locals
    local function alloc(n)
        if not n then n = 1 end
        local ret = { }
        for i = 1, n do
            reg = reg + 1
            ret[i] = reg
        end
        return unpack(ret)
    end

    local function free(n)
        if not n then n = 1 end
        local ret = { }
        for i = n, 1, -1 do
            ret[i] = reg
            reg = reg - 1
        end
        return unpack(ret)
    end

    -- freeTo IS NOW DECEPTIVELY NAMED
    -- It is also capable of allocating memory if n > current stack!
    local function freeTo(n)
        n = (n or 0) + codeAttr.max_locals
        if n <= reg then
            return free(reg - n)
        else
            return alloc(n - reg)
        end
    end

    local function peek(n)
        return reg - n
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

    local function loadStringConst(str)
        local ret = cp.jitStrings[str]
        if not ret then
            cp.jitStrings[str] = toJString(str)
            return cp.jitStrings[str]
        end
        return ret
    end

    local _pc = 0
    local function u1()
        _pc = _pc+1
        return code[_pc-1]
    end
    local function pc(i)
        _pc = i or _pc
        return _pc - 1
    end

    local pcMapLJ = { }
    local pcMapJL = { }

    local function u2()
        return bit.blshift(u1(),8) + u1()
    end

    local function u4()
        return bit.blshift(u1(),24) + bit.blshift(u1(),16) + bit.blshift(u1(),8) + u1()
    end

    local function s4()
        local u = u4()
        if u < 2147483648 then
            return u
        end
        return u - 4294967296
    end

    local constants = {}
    local topConstant = 1
    local function k(c)
        c = c == nil and "nil" or c
        local kBracket = "k(" .. c .. ")"
        if constants[c] or topConstant < 255 then
            if not constants[c] then
                constants[c] = true
                topConstant = topConstant + 1
            end
            return kBracket
        else
            local rc = alloc()
            emitWithComment("Automatically generated loadk", "loadk %i " .. kBracket, rc)
            return string.format("%i", free())
        end
    end

    local function asmGetRTInfo(r, i)
        emit("gettable %i 0 %s ", r, k(i))
    end

    local function asmNewInstance(robj, class, customObjectSize)
        local rclass, rfields, rmethods = alloc(3)
        asmGetRTInfo(rclass, info(class))
        asmGetRTInfo(rmethods, info(class.methods))
        emit("newtable %i %i 0", robj, customObjectSize or 3)
        emit("newtable %i %i 0", rfields, #class.field_info)
        for i = 1, #class.field_info do
            local fi = class.field_info[i]
            if bit.band(fi.access_flags, FIELD_ACC.STATIC) == 0 then
                emit("settable %i %s %s", rfields, k(i), PRIMITIVE_WRAPPERS[fi.descriptor] and k(0) or k(nil))
            end
        end
        emit("settable %i %s %i", robj, k(1), rclass)
        emit("settable %i %s %i", robj, k(2), rfields)
        emit("settable %i %s %i", robj, k(3), rmethods)
        free(3)
    end

    local function asmNewArray(robj, rlength, class)
        local rarray = alloc()
        emit("newtable %i 0 0", rarray)
        asmNewInstance(robj, class, 5)
        emit("settable %i %s %i", robj, k(4), rlength)
        emit("settable %i %s %i", robj, k(5), rarray)
        free()
    end

    local function asmNewPrimitiveArray(robj, rlength, class)
        local rarray, ri = alloc(2)

        emit("newtable %i 0 0", rarray)
        emit("loadk %i %s", ri, k(1))
        emit("le 0 %i %i", ri, rlength)
        emit("jmp 3")
        emit("settable %i %i %s", rarray, ri, k(0)) -- all primitives are represented by integers and default to 0
        emit("add %i %i %s", ri, ri, k(1))
        emit("jmp -5")

        asmNewInstance(robj, class, 5)
        emit("settable %i %s %i", robj, k(4), rlength)
        emit("settable %i %s %i", robj, k(5), rarray)
        free(2)
    end

    local function asmPrintReg(r)
        local rprint, rparam = alloc(2)
        asmGetRTInfo(rprint, info(print))
        emit("move %i %i", rparam, r)
        emit("call %i 2 1", rprint)
        free(2)
    end

    local function asmPrintString(str)
        local rprint, rparam = alloc(2)
        asmGetRTInfo(rprint, info(print))
        emit("loadk %i '%s'", rparam, str)
        emit("call %i 2 1", rprint)
        free(2)
    end

    -- Expects method at register rmt followed by args.
    -- Result is stored in rmt + 1.
    local function asmInvokeMethod(rmt, argslen, results)
        emit("gettable %i %i %s", rmt, rmt, k(1))
        emit("call %i %i %i", rmt, argslen + 1, results + 1)
    end

    local function asmRun(func)
        local rfunc = alloc()
        asmGetRTInfo(rfunc, info(func))
        emit("call %i %i %i", rfunc, 1, 1)
        free()
    end

    local function asmPushStackTrace()
        local rpush, rClassName, rMethodName, rFileName, rLineNumber = alloc(5)
        asmGetRTInfo(rpush, info(pushStackTrace))
        asmGetRTInfo(rClassName, info(class.name))
        asmGetRTInfo(rMethodName, info(method.name:sub(1, method.name:find("%(") - 1)))
        asmGetRTInfo(rFileName, info(sourceFileName or ""))
        asmGetRTInfo(rLineNumber, info(0))
        emit("call %i 5 1", rpush)
        free(5)
    end

    local function asmPopStackTrace()
        local rpop = alloc()
        asmGetRTInfo(rpop, info(popStackTrace))
        emit("call %i 1 1", rpop)
        free()
    end

    local function asmSetStackTraceLineNumber(ln)
        local rset, rln = alloc(2)
        asmGetRTInfo(rset, info(setStackTraceLineNumber))
        asmGetRTInfo(rln, info(ln))
        emit("call %i 2 1", rset)
        free(2)
    end

    local function asmInstanceOf(c)
        local r = peek(0)
        local robj, rclass = alloc(2)
        emit("move %i %i", robj, r)
        asmGetRTInfo(rclass, info(c))
        asmGetRTInfo(r, info(jInstanceof))
        emit("call %i 3 2", r)
        free(2)
    end

    local function asmThrow(rexception)
        local exceptionHandlers = {}
        for i=0, codeAttr.exception_table_length-1 do
            local handler = codeAttr.exception_table[i]
            if handler.start_pc <= pc() and handler.end_pc > pc() then
                table.insert(exceptionHandlers, handler)
            end
        end
        for i=1, #exceptionHandlers do
            local handler = exceptionHandlers[i]
            if handler.catch_type == 0 then
                emit("#jmp (%i)", handler.handler_pc)
            else
                local c = resolveClass(cp[handler.catch_type])
                local rtest = alloc()
                emit("move %i %i", rtest, rexception)
                asmInstanceOf(c)
                emit("test %i 0", rtest)
                emit("jmp 2")
                emit("move %i %i", codeAttr.max_locals + 1, rexception)
                emit("#jmp (%i)", handler.handler_pc)
                free()
            end
        end
        asmPopStackTrace()
        local rnil, rexc = alloc(2)
        emit("loadnil %i %i", rnil, rnil)
        emit("move %i %i", rexc, rexception)
        emit("return %i 3", rnil)
        free(2)
    end

    local function asmCheckThrow(rexception)
        emit("test %i 0", rexception)
        -- It's expected that no more reading is done after calling asmCheckThrow
        -- TODO: Come up with a better solution tahn expecting that
        emit("#jmp (%i)", pc() + 1)

        asmThrow(rexception)
    end

    -- was forward declared
    function getCurrentLineNumber()
        local ln
        if lineNumberAttribute then
            local len = lineNumberAttribute.line_number_table_length
            for i = 0, len - 1 do
                local entry = lineNumberAttribute.line_number_table[i]
                if entry.start_pc > pc() then
                    ln = lineNumberAttribute.line_number_table[i - 1].line_number
                    break
                end
            end
        end
        return ln
    end

    local function asmRefillStackTrace(rexception)
        asmSetStackTraceLineNumber(getCurrentLineNumber() or 0)

        local rfill, rexc = alloc(2)

        local fillInStackTrace = findMethod(classByName("java.lang.Throwable"), "fillInStackTrace()Ljava/lang/Throwable;")

        asmGetRTInfo(rfill, info(fillInStackTrace[1]))
        emit("move %i %i", rexc, rexception)
        emit("call %i 2 1", rfill)

        free(2)
    end

    local function asmCheckNullPointer(robj)
        local npException = classByName("java.lang.NullPointerException")
        local con = findMethod(npException, "<init>()V")

        emit("test %i 1", robj)
        local jmpPC1 = emit("")
        
        local rexc, rcon, rexcDup = alloc(3)
        asmNewInstance(rexc, npException)
        asmGetRTInfo(rcon, info(con[1]))
        emit("move %i %i", rexcDup, rexc)
        emit("call %i 2 1", rcon)
        free(2)
        asmRefillStackTrace(rexc)
        asmThrow(rexc)

        local jmpPC2 = asmPC
        emitInsert(jmpPC1 - 1, "jmp %i", jmpPC2 - jmpPC1)

        free(1)
    end

    local function asmAALoad()
        --aaload
        local oobException = classByName("java.lang.ArrayIndexOutOfBoundsException")
        local con = findMethod(oobException, "<init>(I)V")

        local rarr = peek(1)
        local ri = peek(0)

        asmCheckNullPointer(rarr)

        local rlen, rexc, rcon, rpexc, rpi = alloc(5)
        emit("gettable %i %i %s", rlen, rarr, k(4))
        emit("lt 1 %i %i", ri, rlen)
        local p1 = emit("")                                    -- Placeholder for jump.

        asmNewInstance(rexc, oobException)
        asmGetRTInfo(rcon, info(con[1]))
        emit("move %i %i", rpi, ri)
        emit("move %i %i", rpexc, rexc)
        emit("call %i 3 3", rcon)
        asmRefillStackTrace(rexc)
        asmThrow(rexc)
        local p2 = asmPC
        emitInsert(p1 - 1, "jmp %i", p2 - p1)           -- Insert calculated jump.
        emit("add %i %i %s", ri, ri, k(1))
        emit("gettable %i %i %s", rarr, rarr, k(5))
        emit("gettable %i %i %i", rarr, rarr, ri)

        free(6)
    end

    local function asmAAStore()
        local oobException = classByName("java.lang.ArrayIndexOutOfBoundsException")
        local con = findMethod(oobException, "<init>(I)V")

        local rarr = peek(2)
        local ri = peek(1)
        local rval = peek(0)

        asmCheckNullPointer(rarr)

        local rlen, rexc, rcon, rpexc, rpi = alloc(5)
        emit("gettable %i %i %s", rlen, rarr, k(4))
        emit("lt 1 %i %i", ri, rlen)
        local p1 = emit("")                                    -- Placeholder for jump.

        asmNewInstance(rexc, oobException)
        asmGetRTInfo(rcon, info(con[1]))
        emit("move %i %i", rpi, ri)
        emit("move %i %i", rpexc, rexc)
        emit("call %i 3 3", rcon)
        asmRefillStackTrace(rexc)
        asmThrow(rexc)
        local p2 = asmPC
        emitInsert(p1 - 1, "jmp %i", p2 - p1)           -- Insert calculated jump.
        emit("add %i %i %s", ri, ri, k(1))
        emit("gettable %i %i %s", rarr, rarr, k(5))
        emit("settable %i %i %i", rarr, ri, rval)

        free(8)
    end

    local function asmDivCheck()
        local r1 = peek(1)
        local r2 = peek(0)

        local arithException = classByName("java.lang.ArithmeticException")
        local con = findMethod(arithException, "<init>(Ljava/lang/String;)V")

        local rexc, rcon, rpexc, rmsg = alloc(4)

        emit("eq 0 %i %s", r2, k(0))            -- Check for / by zero.
        local p1 = emit("")
        asmNewInstance(rexc, arithException)
        asmGetRTInfo(rmsg, info(toJString("/ by zero")))
        asmGetRTInfo(rcon, info(con[1]))
        emit("move %i %i", rpexc, rexc)
        emit("call %i 3 3", rcon)
        asmRefillStackTrace(rexc)
        asmThrow(rexc)
        local p2 = asmPC
        emitInsert(p1 - 1, "jmp %i", p2 - p1)   -- Insert calculated jump.

        return r1, r2
    end

    local function asmLongDivCheck()
        local r1 = peek(1)
        local r2 = peek(0)

        local arithException = classByName("java.lang.ArithmeticException")
        local con = findMethod(arithException, "<init>(Ljava/lang/String;)V")

        local req, rp2, rzero = alloc(3)        -- Check for / by zero.
        asmGetRTInfo(req, info(bigintEQ))
        emit("move %i %i", rp2, r2)
        asmGetRTInfo(rzero, info(bigint(0)))
        emit("call %i 3 2", req)
        free(2)

        local rexc, rcon, rpexc, rmsg = alloc(4)

        emit("test %i 0", req)                  -- Check result.
        local p1 = emit("")
        asmNewInstance(rexc, arithException)
        asmGetRTInfo(rmsg, info(toJString("/ by zero")))
        asmGetRTInfo(rcon, info(con[1]))
        emit("move %i %i", rpexc, rexc)
        emit("call %i 3 3", rcon)
        asmRefillStackTrace(rexc)
        asmThrow(rexc)
        local p2 = asmPC
        emitInsert(p1 - 1, "jmp %i", p2 - p1)   -- Insert calculated jump.

        return r1, r2
    end

    local function asmIntDiv()
        local r1, r2 = asmDivCheck()
        emit("div %i %i %i", r1, r1, r2)
        emit("mod %i %i %s", r2, r1, k(1))      -- Floor the value.
        emit("sub %i %i %i", r1, r1, r2)
        free(5)
    end

    local function asmFloatDiv()
        local r1, r2 = asmDivCheck()
        emit("div %i %i %i", r1, r1, r2)
        free(5)
    end

    local function asmMod()
        local r1, r2 = asmDivCheck()
        emit("mod %i %i %i", r1, r1, r2)
    end

    local function jbInstanceof(...)
        return jInstanceof(...) == 1
    end

    local inst

    local oplookup = {
        function()      -- 01
            --null
            local r = alloc()
            emit("loadnil %i %i", r, r)
        end, function() -- 02
            local r = alloc()
            emit("loadk %i k(-1)", r)
        end, function() -- 03
            local r = alloc()
            emit("loadk %i k(0)", r)
        end, function() -- 04
            local r = alloc()
            emit("loadk %i k(1)", r)
        end, function() -- 05
            local r = alloc()
            emit("loadk %i k(2)", r)
        end, function() -- 06
            local r = alloc()
            emit("loadk %i k(3)", r)
        end, function() -- 07
            local r = alloc()
            emit("loadk %i k(4)", r)
        end, function() -- 08
            local r = alloc()
            emit("loadk %i k(5)", r)
        end, function() -- 09
            local r = alloc()
            asmGetRTInfo(r, info(bigint(0)))
        end, function() -- 0A
            local r = alloc()
            asmGetRTInfo(r, info(bigint(1)))
        end, function() -- 0B
            local r = alloc()
            emit("loadk %i k(0)", r)
        end, function() -- 0C
            local r = alloc()
            emit("loadk %i k(1)", r)
        end, function() -- 0D
            local r = alloc()
            emit("loadk %i k(2)", r)
        end, function() -- 0E
            local r = alloc()
            emit("loadk %i k(0)", r)
        end, function() -- 0F
            local r = alloc()
            emit("loadk %i k(1)", r)
        end, function() -- 10
            --push imm byte
            emit("loadk %i k(%i)", alloc(), u1())
        end, function() -- 11
            --push imm short
            emit("loadk %i k(%i)", alloc(), u2())
        end, function() -- 12
            local s = cp[u1()]
            if s.bytes then
                emit("loadk %i k(%s)", alloc(), s.bytes)
            elseif s.tag == CONSTANT.Class then
                local r = alloc()
                asmGetRTInfo(r, info(getJClass(cp[s.name_index].bytes:gsub("/", "."))))
            else
                local rStr = alloc()
                asmGetRTInfo(rStr, info(loadStringConst(cp[s.string_index].bytes)))
            end
        end, function() -- 13
            --ldc_w
            --push constant
            local s = cp[u2()]
            if s.bytes then
                emit("loadk %i k(%s)", alloc(), s.bytes)
            elseif s.tag == CONSTANT.Class then
                local r = alloc()
                asmGetRTInfo(r, info(getJClass(cp[s.name_index].bytes:gsub("/", "."))))
            else
                local rStr = alloc()
                asmGetRTInfo(rStr, info(loadStringConst(cp[s.string_index].bytes)))
            end
        end, function() -- 14
            --ldc2_w
            --push constant
            local s = cp[u2()]
            if s.cl == "D" then
                emit("loadk %i k(%f)", alloc(), s.bytes)
            elseif s.cl == "J" then
                asmGetRTInfo(alloc(), info(s.bytes))
            else
                error("Unknown wide constant type.")
            end
        end, function() -- 15
            --loads
            local l = u1()
            local r = alloc()
            emit("move %i %i", r, l + 1)
        end, function() -- 16
            --loads
            local l = u1()
            local r = alloc()
            emit("move %i %i", r, l + 1)
        end, function() -- 17
            --loads
            local l = u1()
            local r = alloc()
            emit("move %i %i", r, l + 1)
        end, function() -- 18
            --loads
            local l = u1()
            local r = alloc()
            emit("move %i %i", r, l + 1)
        end, function() -- 19
            --loads
            local l = u1()
            local r = alloc()
            emit("move %i %i", r, l + 1)
        end, function() -- 1A
            --load_0
            local r = alloc()
            emit("move %i 1", r)
        end, function() -- 1B
            --load_1
            local r = alloc()
            emit("move %i 2", r)
        end, function() -- 1C
            --load_2
            local r = alloc()
            emit("move %i 3", r)
        end, function() -- 1D
            --load_3
            local r = alloc()
            emit("move %i 4", r)
        end, function() -- 1E
            --load_0
            local r = alloc()
            emit("move %i 1", r)
        end, function() -- 1F
            --load_1
            local r = alloc()
            emit("move %i 2", r)
        end, function() -- 20
            --load_2
            local r = alloc()
            emit("move %i 3", r)
        end, function() -- 21
            --load_3
            local r = alloc()
            emit("move %i 4", r)
        end, function() -- 22
            --load_0
            local r = alloc()
            emit("move %i 1", r)
        end, function() -- 23
            --load_1
            local r = alloc()
            emit("move %i 2", r)
        end, function() -- 24
            --load_2
            local r = alloc()
            emit("move %i 3", r)
        end, function() -- 25
            --load_3
            local r = alloc()
            emit("move %i 4", r)
        end, function() -- 26
            --load_0
            local r = alloc()
            emit("move %i 1", r)
        end, function() -- 27
            --load_1
            local r = alloc()
            emit("move %i 2", r)
        end, function() -- 28
            --load_2
            local r = alloc()
            emit("move %i 3", r)
        end, function() -- 29
            --load_3
            local r = alloc()
            emit("move %i 4", r)
        end, function() -- 2A
            --load_0
            local r = alloc()
            emit("move %i 1", r)
        end, function() -- 2B
            --load_1
            local r = alloc()
            emit("move %i 2", r)
        end, function() -- 2C
            --load_2
            local r = alloc()
            emit("move %i 3", r)
        end, function() -- 2D
            --load_3
            local r = alloc()
            emit("move %i 4", r)
        end, function() -- 2E
            asmAALoad()
        end, function() -- 2F
            asmAALoad()
        end, function() -- 30
            asmAALoad()
        end, function() -- 31
            asmAALoad()
        end, function() -- 32
            asmAALoad()
        end, function() -- 33
            asmAALoad()
        end, function() -- 34
            asmAALoad()
        end, function() -- 35
            asmAALoad()
        end, function() -- 36
            --stores
            --lvars[u1()] = pop()
            local l = u1()
            local r = free()
            emit("move %i %i", l + 1, r)
        end, function() -- 37
            --stores
            local l = u1()
            local r = free()
            emit("move %i %i", l + 1, r)
        end, function() -- 38
            --stores
            local l = u1()
            local r = free()
            emit("move %i %i", l + 1, r)
        end, function() -- 39
            --stores
            local l = u1()
            local r = free()
            emit("move %i %i", l + 1, r)
        end, function() -- 3A
            --stores
            local l = u1()
            local r = free()
            emit("move %i %i", l + 1, r)
        end, function() -- 3B
            local r = free()
            emit("move 1 %i", r)
        end, function() -- 3C
            local r = free()
            emit("move 2 %i", r)
        end, function() -- 3D
            local r = free()
            emit("move 3 %i", r)
        end, function() -- 3E
            local r = free()
            emit("move 4 %i", r)
        end, function() -- 3F
            local r = free()
            emit("move 1 %i", r)
        end, function() -- 40
            local r = free()
            emit("move 2 %i", r)
        end, function() -- 41
            local r = free()
            emit("move 3 %i", r)
        end, function() -- 42
            local r = free()
            emit("move 4 %i", r)
        end, function() -- 43
            local r = free()
            emit("move 1 %i", r)
        end, function() -- 44
            local r = free()
            emit("move 2 %i", r)
        end, function() -- 45
            local r = free()
            emit("move 3 %i", r)
        end, function() -- 46
            local r = free()
            emit("move 4 %i", r)
        end, function() -- 47
            local r = free()
            emit("move 1 %i", r)
        end, function() -- 48
            local r = free()
            emit("move 2 %i", r)
        end, function() -- 49
            local r = free()
            emit("move 3 %i", r)
        end, function() -- 4A
            local r = free()
            emit("move 4 %i", r)
        end, function() -- 4B
            local r = free()
            emit("move 1 %i", r)
        end, function() -- 4C
            local r = free()
            emit("move 2 %i", r)
        end, function() -- 4D
            local r = free()
            emit("move 3 %i", r)
        end, function() -- 4E
            local r = free()
            emit("move 4 %i", r)
        end, function() -- 4F
            --aastore
            asmAAStore()
        end, function() -- 50
            --aastore
            asmAAStore()
        end, function() -- 51
            --aastore
            asmAAStore()
        end, function() -- 52
            --aastore
            asmAAStore()
        end, function() -- 53
            --aastore
            asmAAStore()
        end, function() -- 54
            --aastore
            asmAAStore()
        end, function() -- 55
            --aastore
            asmAAStore()
        end, function() -- 56
            --aastore
            asmAAStore()
        end, function() -- 57
            free()
        end, function() -- 58
            local pv = pop()
            if pv[1] ~= "D" and pv[1] ~= "J" then
                pop()
            end
        end, function() -- 59
            local r = peek(0)
            local rd = alloc(1)
            emit("move %i %i", rd, r)
        end, function() -- 5A
            local r2, r1 = peek(0), peek(1)
            local r3 = alloc(1)
            emit("move %i %i", r3, r2)
            emit("move %i %i", r2, r1)
            emit("move %i %i", r1, r3)
        end, function() -- 5B
            local v = pop()
            push(v)
            table.insert(stack,sp-(pv[1] == "D" or pv[1] == "J" and 2 or 3),{v[1], v[2]})
            sp = sp+1
        end, function() -- 5C
            local a = pop()
            if a[1] ~= "D" and a[1] ~= "J" then
                local b = pop()
                push(b)
                push(a)
                push({b[1], b[2]})
                push({a[1], a[2]})
            else
                push(a)
                push({a[1], a[2]})
            end
        end, function() -- 5D
            error("swap2_x1 is bullshit and you know it")
        end, function() -- 5E
            error("swap2_x2 is bullshit and you know it")
        end, function() -- 5F
            local a = pop()
            local b = pop()
            push(a)
            push(b)
        end, function() -- 60
            --add
            local r1 = peek(1)
            local r2 = peek(0)
            emit("add %i %i %i", r1, r1, r2)
            free(1)
        end, function() -- 61
            --ladd
            local r1 = peek(1)
            local r2 = peek(0)
            alloc()
            local radd = r1
            emit("move %i %i", r2 + 1, r1)
            r1 = r2 + 1
            asmGetRTInfo(radd, info(bigintAdd))
            emit("call %i 3 2", radd)
            emit("move %i %i", r1, radd)            -- Over/underflow.
            asmGetRTInfo(radd, info(bigintAdd))
            asmGetRTInfo(r2, info(bigint("9223372036854775808")))
            emit("call %i 3 2", radd)               -- Align to range 0 to 2^64-1
            emit("move %i %i", r2, radd)
            asmGetRTInfo(radd, info(bigintMod))
            asmGetRTInfo(r1, info(bigint("18446744073709551616")))
            emit("call %i 3 2", radd)               -- Wrap value.
            emit("move %i %i", r2, radd)
            asmGetRTInfo(radd, info(bigintSub))
            asmGetRTInfo(r1, info(bigint("9223372036854775808")))
            emit("call %i 3 2", radd)               -- Align to range -2^63 to 2^63-1
            free(2)
        end, function() -- 62
            --add
            local r1 = peek(1)
            local r2 = peek(0)
            emit("add %i %i %i", r1, r1, r2)
            free(1)
        end, function() -- 63
            --add
            local r1 = peek(1)
            local r2 = peek(0)
            emit("add %i %i %i", r1, r1, r2)
            free(1)
        end, function() -- 64
            --sub
            local r1 = peek(1)
            local r2 = peek(0)
            emit("sub %i %i %i", r1, r1, r2)
            free(1)
        end, function() -- 65
            --sub
            local r1 = peek(1)
            local r2 = peek(0)
            alloc()
            local rsub = r1
            local rdiv = r1
            emit("move %i %i", r2 + 1, r2)
            emit("move %i %i", r2, r1)
            r1 = r2 + 1
            asmGetRTInfo(rsub, info(bigintSub))
            emit("call %i 3 2", rsub)
            emit("move %i %i", r1, rsub)            -- Over/underflow.
            asmGetRTInfo(rsub, info(bigintAdd))
            asmGetRTInfo(r2, info(bigint("9223372036854775808")))
            emit("call %i 3 2", rsub)               -- Align to range 0 to 2^64-1
            emit("move %i %i", r2, rsub)
            asmGetRTInfo(rsub, info(bigintMod))
            asmGetRTInfo(r1, info(bigint("18446744073709551616")))
            emit("call %i 3 2", rsub)               -- Wrap value.
            emit("move %i %i", r2, rsub)
            asmGetRTInfo(rsub, info(bigintSub))
            asmGetRTInfo(r1, info(bigint("9223372036854775808")))
            emit("call %i 3 2", rsub)               -- Align to range -2^63 to 2^63-1
            free(2)
        end, function() -- 66
            --sub
            local r1 = peek(1)
            local r2 = peek(0)
            emit("sub %i %i %i", r1, r1, r2)
            free(1)
        end, function() -- 67
            --sub
            local r1 = peek(1)
            local r2 = peek(0)
            emit("sub %i %i %i", r1, r1, r2)
            free(1)
        end, function() -- 68
            --mul
            local r1 = peek(1)
            local r2 = peek(0)
            emit("mul %i %i %i", r1, r1, r2)
            free(1)
        end, function() -- 69
            --mul
            local r1 = peek(1)
            local r2 = peek(0)
            alloc()
            local rmul = r1
            emit("move %i %i", r2 + 1, r1)
            r1 = r2 + 1
            asmGetRTInfo(rmul, info(bigintMul))
            emit("call %i 3 2", rmul)
            emit("move %i %i", r1, rmul)            -- Over/underflow.
            asmGetRTInfo(rmul, info(bigintAdd))
            asmGetRTInfo(r2, info(bigint("9223372036854775808")))
            emit("call %i 3 2", rmul)               -- Align to range 0 to 2^64-1
            emit("move %i %i", r2, rmul)
            asmGetRTInfo(rmul, info(bigintMod))
            asmGetRTInfo(r1, info(bigint("18446744073709551616")))
            emit("call %i 3 2", rmul)               -- Wrap value.
            emit("move %i %i", r2, rmul)
            asmGetRTInfo(rmul, info(bigintSub))
            asmGetRTInfo(r1, info(bigint("9223372036854775808")))
            emit("call %i 3 2", rmul)               -- Align to range -2^63 to 2^63-1
            free(2)
        end, function() -- 6A
            --mul
            local r1 = peek(1)
            local r2 = peek(0)
            emit("mul %i %i %i", r1, r1, r2)
            free(1)
        end, function() -- 6B
            --mul
            local r1 = peek(1)
            local r2 = peek(0)
            emit("mul %i %i %i", r1, r1, r2)
            free(1)
        end, function() -- 6C
            --div
            asmIntDiv()
        end, function() -- 6D
            --div
            local r1, r2 = asmLongDivCheck()
            free(5)
            alloc()
            local rdiv = r1
            emit("move %i %i", r2 + 1, r2)
            emit("move %i %i", r2, r1)
            asmGetRTInfo(rdiv, info(bigintDiv))
            emit("call %i 3 2", rdiv)
            free(2)
            --asmPrintReg(rdiv)
        end, function() -- 6E
            --div
            asmFloatDiv()
        end, function() -- 6F
            --div
            asmFloatDiv()
        end, function() -- 70
            --rem
            asmMod()
        end, function() -- 71
            --rem
            asmLongDivCheck()

        end, function() -- 72
            --rem
            asmMod()
        end, function() -- 73
            --rem
            asmMod()
        end, function() -- 74
            --neg
            local r1 = peek(0)
            emit("mul %i %i %s", r1, r1, k(-1))
        end, function() -- 75
            --neg
            local r1 = peek(0)
            emit("mul %i %i %s", r1, r1, k(-1))
        end, function() -- 76
            --neg
            local r1 = peek(0)
            emit("mul %i %i %s", r1, r1, k(-1))
        end, function() -- 77
            --neg
            local r1 = peek(0)
            emit("mul %i %i %s", r1, r1, k(-1))
        end, function() -- 78
            --shl
            local r1 = peek(1)
            local r2 = peek(0)
            local r3 = alloc()
            emit("move %i %i", r3, r1)
            asmGetRTInfo(r1, info(bit.blshift))
            emit("call %i 3 2", r1)
            emit("move %i %i", r1, r2)
            free(2)
        end, function() -- 79
            --shl
            local r1 = peek(1)
            local r2 = peek(0)
            local r3 = alloc()
            emit("move %i %i", r3, r1)
            asmGetRTInfo(r1, info(bit.blshift))
            emit("call %i 3 2", r1)
            emit("move %i %i", r1, r2)
            free(2)
        end, function() -- 7A
            --shr
            local r1 = peek(1)
            local r2 = peek(0)
            local r3 = alloc()
            emit("move %i %i", r3, r1)
            asmGetRTInfo(r1, info(bit.brshift))
            emit("call %i 3 2", r1)
            emit("move %i %i", r1, r2)
            free(2)
        end, function() -- 7B
            --shr
            local r1 = peek(1)
            local r2 = peek(0)
            local r3 = alloc()
            emit("move %i %i", r3, r1)
            asmGetRTInfo(r1, info(bit.brshift))
            emit("call %i 3 2", r1)
            emit("move %i %i", r1, r2)
            free(2)
        end, function() -- 7C
            --shlr
            local r1 = peek(1)
            local r2 = peek(0)
            local r3 = alloc()
            emit("move %i %i", r3, r1)
            asmGetRTInfo(r1, info(bit.blogic_rshift))
            emit("call %i 3 2", r1)
            emit("move %i %i", r1, r2)
            free(2)
        end, function() -- 7D
            --shlr
            local r1 = peek(1)
            local r2 = peek(0)
            local r3 = alloc()
            emit("move %i %i", r3, r1)
            asmGetRTInfo(r1, info(bit.blogic_rshift))
            emit("call %i 3 2", r1)
            emit("move %i %i", r1, r2)
            free(2)
        end, function() -- 7E
            --and
            local r1 = peek(1)
            local r2 = peek(0)
            local r3 = alloc()
            emit("move %i %i", r3, r1)
            asmGetRTInfo(r1, info(bit.band))
            emit("call %i 3 2", r1)
            emit("move %i %i", r1, r2)
            free(2)
        end, function() -- 7F
            --and
            local r1 = peek(1)
            local r2 = peek(0)
            local r3 = alloc()
            emit("move %i %i", r3, r1)
            asmGetRTInfo(r1, info(bit.band))
            emit("call %i 3 2", r1)
            emit("move %i %i", r1, r2)
            free(2)
        end, function() -- 80
            --or
            local r1 = peek(1)
            local r2 = peek(0)
            local r3 = alloc()
            emit("move %i %i", r3, r1)
            asmGetRTInfo(r1, info(bit.bor))
            emit("call %i 3 2", r1)
            emit("move %i %i", r1, r2)
            free(2)
        end, function() -- 81
            --or
            local r1 = peek(1)
            local r2 = peek(0)
            local r3 = alloc()
            emit("move %i %i", r3, r1)
            asmGetRTInfo(r1, info(bit.bor))
            emit("call %i 3 2", r1)
            emit("move %i %i", r1, r2)
            free(2)
        end, function() -- 82
            --xor
            local r1 = peek(1)
            local r2 = peek(0)
            local r3 = alloc()
            emit("move %i %i", r3, r1)
            asmGetRTInfo(r1, info(bit.bxor))
            emit("call %i 3 2", r1)
            emit("move %i %i", r1, r2)
            free(2)
        end, function() -- 83
            --xor
            local r1 = peek(1)
            local r2 = peek(0)
            local r3 = alloc()
            emit("move %i %i", r3, r1)
            asmGetRTInfo(r1, info(bit.bxor))
            emit("call %i 3 2", r1)
            emit("move %i %i", r1, r2)
            free(2)
        end, function() -- 84
            --iinc
            local idx = u1() + 1
            local c = u1ToSignedByte(u1())
            emit("add %i %i %s", idx, idx, k(c))
        end, function() -- 85
            --i2l
            local rconv = peek(0)
            local r = alloc()
            emit("move %i %i", r, rconv)
            asmGetRTInfo(rconv, info(bigint))
            emit("call %i 2 2", rconv)
            free()
        end, function() -- 86
            --i2f
        end, function() -- 87
            --i2d
        end, function() -- 88
            --l2i
            local rconv = peek(0)
            local r1, r2 = alloc(2)
            emit("move %i %i", r1, rconv)           -- Over/underflow.
            asmGetRTInfo(rconv, info(bigintAdd))
            asmGetRTInfo(r2, info(bigint("2147483648")))
            emit("call %i 3 2", rconv)              -- Align to range 0 to 2^32-1
            emit("move %i %i", r1, rconv)
            asmGetRTInfo(rconv, info(bigintMod))
            asmGetRTInfo(r2, info(bigint("4294967296")))
            emit("call %i 3 2", rconv)              -- Wrap value.
            emit("move %i %i", r1, rconv)
            asmGetRTInfo(rconv, info(bigintSub))
            asmGetRTInfo(r2, info(bigint("2147483648")))
            emit("call %i 3 2", rconv)              -- Align to range -2^31 to 2^31-1
            emit("move %i %i", r1, rconv)
            asmGetRTInfo(rconv, info(bigintToDouble))
            emit("call %i 2 2", rconv)
            free(2)
        end, function() -- 89
            --l2f
            local rconv = peek(0)
            local r = alloc()
            emit("move %i %i", r, rconv)
            asmGetRTInfo(rconv, info(bigintToDouble))
            emit("call %i 2 2", rconv)
            free()
        end, function() -- 8A
            --l2d
            local rconv = peek(0)
            local r = alloc()
            emit("move %i %i", r, rconv)
            asmGetRTInfo(rconv, info(bigintToDouble))
            emit("call %i 2 2", rconv)
            free()
        end, function() -- 8B
            --f2i
            local rconv = peek(0)
            local r = alloc()
            emit("move %i %i", r, rconv)
            asmGetRTInfo(rconv, info(math.floor))
            emit("call %i 2 2", rconv)
            free()
        end, function() -- 8C
            --f2l
            local rconv = peek(0)
            local r = alloc()
            emit("move %i %i", r, rconv)
            asmGetRTInfo(rconv, info(bigint))
            emit("call %i 2 2", rconv)
            free()
        end, function() -- 8D
            --f2d
        end, function() -- 8E
            --d2i
            local rconv = peek(0)
            local r = alloc()
            emit("move %i %i", r, rconv)
            asmGetRTInfo(rconv, info(math.floor))
            emit("call %i 2 2", rconv)
            free()
        end, function() -- 8F
            --d2l
            local rconv = peek(0)
            local r = alloc()
            emit("move %i %i", r, rconv)
            asmGetRTInfo(rconv, info(bigint))
            emit("call %i 2 2", rconv)
            free()
        end, function() -- 90
            --d2f
        end, function() -- 91
            --i2b
            local r = peek(0)
            emit("add %i %i %s", r, r, k(128))
            emit("mod %i %i %s", r, r, k(256))
            emit("sub %i %i %s", r, r, k(128))
        end, function() -- 92
            --i2c
            local r = peek(0)
            emit("mod %i %i %s", r, r, k(65536))
        end, function() -- 93
            --i2s
            local r = peek(0)
            emit("add %i %i %s", r, r, k(32768))
            emit("mod %i %i %s", r, r, k(65536))
            emit("sub %i %i %s", r, r, k(32768))
        end, function() -- 94
            --lcmp
            local a, b = pop()[2], pop()[2]
            if bigInt.cmp_eq(a, b) then
                push(asInt(0))
            elseif bigInt.cmp_lt(a, b) then
                push(asInt(1))
            else
                push(asInt(-1))
            end
        end, function() -- 95
            --fcmpl/g
            local a, b = pop()[2], pop()[2]
            if a == b then
                push(asInt(0))
            elseif a < b then
                push(asInt(1))
            else
                push(asInt(-1))
            end
        end, function() -- 96
            --fcmpl/g
            local a, b = pop()[2], pop()[2]
            if a == b then
                push(asInt(0))
            elseif a < b then
                push(asInt(1))
            else
                push(asInt(-1))
            end
        end, function() -- 97
            --fcmpl/g
            local a, b = pop()[2], pop()[2]
            if a == b then
                push(asInt(0))
            elseif a < b then
                push(asInt(1))
            else
                push(asInt(-1))
            end
        end, function() -- 98
            --fcmpl/g
            local a, b = pop()[2], pop()[2]
            if a == b then
                push(asInt(0))
            elseif a < b then
                push(asInt(1))
            else
                push(asInt(-1))
            end
        end, function() -- 99
            --ifeq
            local joffset = u2ToSignedShort(u2())
            local k = alloc()
            emit("loadk %i k(0)", k)
            free()
            emit("eq 1 %i %i", free(), k)
            emit("#jmp %i %i", joffset, 2)
        end, function() -- 9A
            --ifne
            local joffset = u2ToSignedShort(u2())
            local k = alloc()
            emit("loadk %i k(0)", k)
            free()
            emit("eq 0 %i %i", free(), k)
            emit("#jmp %i %i", joffset, 2)
        end, function() -- 9B
            --iflt
            local joffset = u2ToSignedShort(u2())
            local k = alloc()
            emit("loadk %i k(0)", k)
            free()
            emit("lt 1 %i %i", free(), k)
            emit("#jmp %i %i", joffset, 2)
        end, function() -- 9C
            --ifge
            local joffset = u2ToSignedShort(u2())
            local k = alloc()
            emit("loadk %i k(0)", k)
            free()
            emit("lt 0 %i %i", free(), k)
            emit("#jmp %i %i", joffset, 2)
        end, function() -- 9D
            --ifgt
            local joffset = u2ToSignedShort(u2())
            local k = alloc()
            emit("loadk %i k(0)", k)
            free()
            emit("le 0 %i %i", free(), k)
            emit("#jmp %i %i", joffset, 2)
        end, function() -- 9E
            --ifle
            local joffset = u2ToSignedShort(u2())
            local k = alloc()
            emit("loadk %i k(0)", k)
            free()
            emit("le 1 %i %i", free(), k)
            emit("#jmp %i %i", joffset, 2)
        end, function() -- 9F
            --if_icmpeq
            local joffset = u2ToSignedShort(u2())
            emit("eq 1 %i %i", free(2))
            emit("#jmp %i %i", joffset, 1)
        end, function() -- A0
            --if_icmpne
            local joffset = u2ToSignedShort(u2())
            emit("eq 0 %i %i", free(2))
            emit("#jmp %i %i", joffset, 1)
        end, function() -- A1
            --if_icmplt
            local joffset = u2ToSignedShort(u2())
            emit("lt 1 %i %i", free(2))
            emit("#jmp %i %i", joffset, 1)
        end, function() -- A2
            --if_icmpge
            local joffset = u2ToSignedShort(u2())
            emit("lt 0 %i %i", free(2))
            emit("#jmp %i %i", joffset, 1)
        end, function() -- A3
            --if_icmpgt
            local joffset = u2ToSignedShort(u2())
            emit("le 0 %i %i", free(2))
            emit("#jmp %i %i", joffset, 1)
        end, function() -- A4
            --if_icmple
            local joffset = u2ToSignedShort(u2())
            emit("le 1 %i %i", free(2))
            emit("#jmp %i %i", joffset, 1)
        end, function() -- A5
            --if_acmpeq
            local joffset = u2ToSignedShort(u2())
            emit("eq 1 %i %i", free(2))
            emit("#jmp %i %i", joffset, 1)
        end, function() -- A6
            --if_acmpne
            local joffset = u2ToSignedShort(u2())
            emit("eq 0 %i %i", free(2))
            emit("#jmp %i %i", joffset, 1)
        end, function() -- A7
            --goto
            local joffset = u2ToSignedShort(u2())
            emit("#jmp %i %i", joffset, 0)
        end, function() -- A8
            --jsr
            error()
            local addr = pc() + 3
            local offset = u2ToSignedShort(u2())
            push({"address", addr})
            pc(pc() + offset - 2)
        end, function() -- A9
            --ret
            error()
            local index = u1()
            local addr = lvars[index]
            if addr[1] ~= "address" then
                error("Not an address", 0)
            end
            pc(addr[2])
        end, function() -- AA
            -- Unfortunately can't do any jump table optimization here since Lua doesn't
            -- have a dynamic jump instruction...
            local rkey = peek(0)

            -- Align to 4 bytes.
            local padding = 4 - pc() % 4
            pc(pc() + padding)

            local default = s4()
            local low = s4()
            local high = s4()
            local noffsets = high - low + 1

            for i = 1, noffsets do
                local offset = s4()     -- offset to jump to if rkey == match
                local k = alloc()
                emit("loadk %i k(%i)", k, low + i - 1)
                emit("eq 1 %i %i", k, rkey)
                emit("#jmp %i %i", offset, (i - 1) * 3 + 2)
                free()
            end

            emit("#jmp %i %i", default, noffsets * 3)
        end, function() -- AB
            local rkey = free()

            -- Align to 4 bytes.
            local padding = 4 - pc() % 4
            pc(pc() + padding)

            local default = s4()        -- default jump
            local npairs = s4()         -- number of cases

            for i = 1, npairs do
                local match = s4()      -- try to match this to the key
                local offset = s4()     -- offset to jump to if rkey == match
                local k = alloc()
                emit("loadk %i k(%i)", k, match)
                emit("eq 1 %i %i", k, rkey)
                emit("#jmp %i %i", offset, (i - 1) * 3 + 2)
                free()
            end

            emit("#jmp %i %i", default, npairs * 3)
        end, function() -- AC
            asmPopStackTrace()
            emit("return %i 2", free())
        end, function() -- AD
            asmPopStackTrace()
            emit("return %i 2", free())
        end, function() -- AE
            asmPopStackTrace()
            emit("return %i 2", free())
        end, function() -- AF
            asmPopStackTrace()
            emit("return %i 2", free())
        end, function() -- B0
            asmPopStackTrace()
            emit("return %i 2", free())
        end, function() -- B1
            asmPopStackTrace()
            emit("return 0 1")
        end, function() -- B2
            --getstatic
            local fr = cp[u2()]
            local class = resolveClass(cp[fr.class_index])
            local name = cp[cp[fr.name_and_type_index].name_index].bytes
            local fi = class.fieldIndexByName[name]
            local r = alloc()
            asmGetRTInfo(r, info(class.fields))
            emitWithComment(class.name.."."..name, "gettable %i %i %s", r, r, k(fi))
        end, function() -- B3
            --putstatic
            local fr = cp[u2()]
            local class = resolveClass(cp[fr.class_index])
            local name = cp[cp[fr.name_and_type_index].name_index].bytes
            local fi = class.fieldIndexByName[name]
            local value = peek(0)
            local r = alloc()
            asmGetRTInfo(r, info(class.fields))
            emitWithComment(class.name.."."..name, "settable %i %s %i", r, k(fi), value)
            free(2)
        end, function() -- B4
            --getfield
            local fr = cp[u2()]
            local name = cp[cp[fr.name_and_type_index].name_index].bytes
            local class = resolveClass(cp[fr.class_index])
            local fi = class.fieldIndexByName[name]
            local r = peek(0)

            asmCheckNullPointer(r)

            emit("gettable %i %i %s", r, r, k(2))
            emitWithComment(class.name.."."..name, "gettable %i %i %s", r, r, k(fi))
        end, function() -- B5
            --putfield
            local fr = cp[u2()]
            local name = cp[cp[fr.name_and_type_index].name_index].bytes
            local class = resolveClass(cp[fr.class_index])
            local fi = class.fieldIndexByName[name]
            local robj = peek(1)
            local rval = peek(0)

            asmCheckNullPointer(robj)

            local rfields = alloc()
            emit("gettable %i %i %s", rfields, robj, k(2))
            emitWithComment(class.name.."."..name, "settable %i %s %i", rfields, k(fi), rval)
            free(3)
        end, function() -- B6
            --invokevirtual
            local mr = cp[u2()]
            local cl = resolveClass(cp[mr.class_index])
            local name = cp[cp[mr.name_and_type_index].name_index].bytes .. cp[cp[mr.name_and_type_index].descriptor_index].bytes
            local mt, mIndex = findMethod(cl, name)
            local argslen = #mt.desc

            asmSetStackTraceLineNumber(getCurrentLineNumber() or 0)
            asmCheckNullPointer(peek(argslen - 1))

            -- Need 1 extra register for last argument.
            alloc()

            -- Move the arguments up.
            for i = 1, argslen do
                emit("move %i %i", peek(i - 1), peek(i))
            end

            -- Inject the method under the parameters.
            local rmt = peek(argslen)
            local objIndex = peek(argslen - 1)
            local methodTableEntry = alloc()

            asmGetRTInfo(methodTableEntry, info(mIndex))
            -- Get the methods table from the object
            emit("gettable %i %i %s", rmt, objIndex, k(3))
            emit("gettable %i %i %i", rmt, rmt, methodTableEntry)
            free(1)
            emit("gettable %i %i %s", rmt, rmt, k(1))
            -- Invoke the method. Result is right after the method.
            emitWithComment(cl.name.."."..name, "call %i %i 3", rmt, argslen + 1)

            -- Free down to ret, exception
            -- Same as freeing all arguments except the argument representing the object
            free(argslen - 1)
            local ret, exception = rmt, rmt + 1
            asmCheckThrow(exception)

            if mt.desc[#mt.desc].type ~= "V" then
                -- free exception
                free()
            else
                -- free nil, exception
                free(2)
            end
        end, function() -- B7
            --invokespecial
            local mr = cp[u2()]
            local cl = resolveClass(cp[mr.class_index])
            local name = cp[cp[mr.name_and_type_index].name_index].bytes .. cp[cp[mr.name_and_type_index].descriptor_index].bytes
            local mt = findMethod(cl, name)
            local argslen = #mt.desc

            asmSetStackTraceLineNumber(getCurrentLineNumber() or 0)
            --asmCheckNullPointer(peek(argslen - 1))        -- in no case should invokespecial need null checking

            -- Need 1 extra register for last argument. 
            alloc()

            -- Move the arguments up.
            for i = 1, argslen do
                emit("move %i %i", peek(i - 1), peek(i))
            end

            -- Inject the method under the parameters.
            local rmt = peek(argslen)
            asmGetRTInfo(rmt, info(mt))

            -- Invoke the method. Result is right after the method.
            emit("gettable %i %i %s", rmt, rmt, k(1))
            emitWithComment(cl.name.."."..name, "call %i %i 3", rmt, argslen + 1)

            -- Free down to ret, exception
            -- Same as freeing all arguments except the argument representing the object
            free(argslen - 1)
            local ret, exception = rmt, rmt + 1
            asmCheckThrow(exception)

            if mt.desc[#mt.desc].type ~= "V" then
                -- free exception
                free()
            else
                -- free nil, exception
                free(2)
            end
        end, function() -- B8
            --invokestatic
            local mr = cp[u2()]
            local cl = resolveClass(cp[mr.class_index])
            local name = cp[cp[mr.name_and_type_index].name_index].bytes .. cp[cp[mr.name_and_type_index].descriptor_index].bytes
            local mt = findMethod(cl, name)
            local argslen = #mt.desc - 1

            asmSetStackTraceLineNumber(getCurrentLineNumber() or 0)

            -- Need 1 extra register for last argument. 
            alloc()

            -- Move the arguments up.
            for i = 1, argslen do
                emit("move %i %i", peek(i - 1), peek(i))
            end

            -- Inject the method under the parameters.
            local rmt = peek(argslen)
            asmGetRTInfo(rmt, info(mt))

            -- Invoke the method. Result is right after the method.
            emit("gettable %i %i %s", rmt, rmt, k(1))
            emitWithComment(cl.name.."."..name, "call %i %i 3", rmt, argslen + 1)

            -- Free down to ret, exception
            -- More complicated than other invokes
            -- Might actually need to allocate a slot if the method had no arguments
            if argslen == 0 then
                alloc()
            else
                free(argslen - 1)
            end
            local ret, exception = rmt, rmt + 1
            asmCheckThrow(exception)

            if mt.desc[#mt.desc].type ~= "V" then
                -- free exception
                free()
            else
                -- free nil, exception
                free(2)
            end
        end, function() -- B9
            --invokeinterface
            local mr = cp[u2()]
            u2() -- two dead bytes in invokeinterface
            local cl = resolveClass(cp[mr.class_index])
            local name = cp[cp[mr.name_and_type_index].name_index].bytes .. cp[cp[mr.name_and_type_index].descriptor_index].bytes
            local mt = findMethod(cl, name)
            local argslen = #mt.desc

            asmSetStackTraceLineNumber(getCurrentLineNumber() or 0)
            asmCheckNullPointer(peek(argslen - 1))

            -- Need 1 extra register for last argument.
            alloc()

            -- Move the arguments up.
            for i = 1, argslen do
                emit("move %i %i", peek(i - 1), peek(i))
            end

            -- Inject the method under the parameters.
            local rmt = peek(argslen)
            local obj = peek(argslen - 1)

            -- find the method
            local find, rcl, rname = alloc(3)
            asmGetRTInfo(find, info(findMethod))
            emit("gettable %i %i %s", rcl, obj, k(1))
            asmGetRTInfo(rname, info(name))
            emit("call %i 3 2", find)
            emit("move %i %i", rmt, find)
            free(3)

            -- Invoke the method. Result is right after the method.
            emit("gettable %i %i %s", rmt, rmt, k(1))
            emitWithComment(cl.name.."."..name, "call %i %i 3", rmt, argslen + 1)

            -- Free down to ret, exception
            -- Same as freeing all arguments except the argument representing the object
            free(argslen - 1)
            local ret, exception = rmt, rmt + 1
            asmCheckThrow(exception)

            if mt.desc[#mt.desc].type ~= "V" then
                -- free exception
                free()
            else
                -- free nil, exception
                free(2)
            end
        end, function() -- BA
            error("BA not implemented.") -- TODO
        end, function() -- BB
            --new
            local cr = cp[u2()]
            local c = resolveClass(cr)
            local robj = alloc()
            asmNewInstance(robj, c)
        end, function() -- BC
            --newarray
            local cn = "["..ARRAY_TYPES[u1()]
            local class = getArrayClass(cn)

            local rlength = peek(0)
            local robj = alloc()
            asmNewPrimitiveArray(robj, rlength, class)
            --put array in expected register
            emit("move %i %i", rlength, robj)
            free()
        end, function() -- BD
            --anewarray
            local cn = "[L"..cp[cp[u2()].name_index].bytes:gsub("/",".")..";"
            local class = getArrayClass(cn)

            local rlength = peek(0)
            local robj = alloc()
            asmNewArray(robj, rlength, class)
            --put array in expected register
            emit("move %i %i", rlength, robj)
            free()
        end, function() -- BE
            --arraylength
            local r = peek(0)
            emit("gettable %i %i %s", r, r, k(4))
        end, function() -- BF
            local rexception = peek(0)
            asmRefillStackTrace(rexception)
            asmThrow(rexception)
        end, function() -- C0
            local c = resolveClass(cp[u2()])
            local r = peek(0)
            local rjInstanceof, robj, rclass = alloc(3)
            local ccException = classByName("java.lang.ClassCastException")
            local con = findMethod(ccException, "<init>(Ljava/lang/String;)V")
            emit("move %i %i", robj, r)
            asmGetRTInfo(rclass, info(c))
            asmGetRTInfo(rjInstanceof, info(jbInstanceof))
            emit("call %i 3 2", rjInstanceof)
            free(2)

            local rexc, rcon, rpexc, rmsg = alloc(4)

            emit("test %i 1", rjInstanceof)         -- Check result.
            local p1 = emit("")
            asmNewInstance(rexc, ccException)
            asmGetRTInfo(rmsg, info(toJString(" cannot be cast to " .. c.name)))
            asmGetRTInfo(rcon, info(con[1]))
            emit("move %i %i", rpexc, rexc)
            emit("call %i 3 3", rcon)
            asmRefillStackTrace(rexc)
            asmThrow(rexc)
            local p2 = asmPC
            emitInsert(p1 - 1, "jmp %i", p2 - p1)   -- Insert calculated jump.
            free(5)
        end, function() -- C1
            local c = resolveClass(cp[u2()])
            asmInstanceOf(c)
        end, function() -- C2
            error("C2 not implemented.") -- TODO
        end, function() -- C3
            error("C3 not implemented.") -- TODO
        end, function() -- C4
            error("C4 not implemented.") -- TODO
        end, function() -- C5
            error("C5 not implemented.") -- TODO
        end, function() -- C6
            local joffset = u2ToSignedShort(u2())
            local rvalue = free()
            emit("eq 1 %i nil", rvalue)
            emit("#jmp %i %i", joffset, 1)
        end, function() -- C7
            local joffset = u2ToSignedShort(u2())
            local rvalue = free()
            emit("eq 0 %i nil", rvalue)
            emit("#jmp %i %i", joffset, 1)
        end, function() -- C8
            error("C8 not implemented.") -- TODO
        end, function() -- C9
            error("C9 not implemented.") -- TODO
        end, function() -- CA
            error("CA not implemented.") -- TODO
        end, function() -- CB
            error("CB not implemented.") -- TODO
        end, function() -- CC
            error("CC not implemented.") -- TODO
        end, function() -- CD
            error("CD not implemented.") -- TODO
        end, function() -- CE
            error("CE not implemented.") -- TODO
        end, function() -- CF
            error("CF not implemented.") -- TODO
        end, function() -- D0
            error("D0 not implemented.") -- TODO
        end, function() -- D1
            error("D1 not implemented.") -- TODO
        end, function() -- D2
            error("D2 not implemented.") -- TODO
        end, function() -- D3
            error("D3 not implemented.") -- TODO
        end, function() -- D4
            error("D4 not implemented.") -- TODO
        end, function() -- D5
            error("D5 not implemented.") -- TODO
        end, function() -- D6
            error("D6 not implemented.") -- TODO
        end, function() -- D7
            error("D7 not implemented.") -- TODO
        end, function() -- D8
            error("D8 not implemented.") -- TODO
        end, function() -- D9
            error("D9 not implemented.") -- TODO
        end, function() -- DA
            error("DA not implemented.") -- TODO
        end, function() -- DB
            error("DB not implemented.") -- TODO
        end, function() -- DC
            error("DC not implemented.") -- TODO
        end, function() -- DD
            error("DD not implemented.") -- TODO
        end, function() -- DE
            error("DE not implemented.") -- TODO
        end, function() -- DF
            error("DF not implemented.") -- TODO
        end, function() -- E0
            error("E0 not implemented.") -- TODO
        end, function() -- E1
            error("E1 not implemented.") -- TODO
        end, function() -- E2
            error("E2 not implemented.") -- TODO
        end, function() -- E3
            error("E3 not implemented.") -- TODO
        end, function() -- E4
            error("E4 not implemented.") -- TODO
        end, function() -- E5
            error("E5 not implemented.") -- TODO
        end, function() -- E6
            error("E6 not implemented.") -- TODO
        end, function() -- E7
            error("E7 not implemented.") -- TODO
        end, function() -- E8
            error("E8 not implemented.") -- TODO
        end, function() -- E9
            error("E9 not implemented.") -- TODO
        end, function() -- EA
            error("EA not implemented.") -- TODO
        end, function() -- EB
            error("EB not implemented.") -- TODO
        end, function() -- EC
            error("EC not implemented.") -- TODO
        end, function() -- ED
            error("ED not implemented.") -- TODO
        end, function() -- EE
            error("EE not implemented.") -- TODO
        end, function() -- EF
            error("EF not implemented.") -- TODO
        end, function() -- F0
            error("F0 not implemented.") -- TODO
        end, function() -- F1
            error("F1 not implemented.") -- TODO
        end, function() -- F2
            error("F2 not implemented.") -- TODO
        end, function() -- F3
            error("F3 not implemented.") -- TODO
        end, function() -- F4
            error("F4 not implemented.") -- TODO
        end, function() -- F5
            error("F5 not implemented.") -- TODO
        end, function() -- F6
            error("F6 not implemented.") -- TODO
        end, function() -- F7
            error("F7 not implemented.") -- TODO
        end, function() -- F8
            error("F8 not implemented.") -- TODO
        end, function() -- F9
            error("F9 not implemented.") -- TODO
        end, function() -- FA
            error("FA not implemented.") -- TODO
        end, function() -- FB
            error("FB not implemented.") -- TODO
        end, function() -- FC
            error("FC not implemented.") -- TODO
        end, function() -- FD
            error("FD not implemented.") -- TODO
        end, function() -- FE
            error("FE not implemented.") -- TODO
        end, function() -- FF
            error("FF not implemented.") -- TODO
        end
    }

    local offset = -1
    local entryIndex = 0
    inst = u1()
    asmPushStackTrace()
    while inst do
        checkIn()
        -- check the stack map
        if stackMapAttribute and stackMapAttribute.entries[entryIndex] then
            local entry = stackMapAttribute.entries[entryIndex]
            local newOffset = offset + entry.offset_delta + 1
            if pc() == newOffset then
                entryIndex = entryIndex + 1
                offset = newOffset

                freeTo(entry.stack_items)
            end
        end

        -- compile the instruction
        pcMapLJ[asmPC] = pc()
        pcMapJL[pc()] = asmPC
        oplookup[inst]()
        inst = u1()
    end

    debugH.write(class.name .. "." .. method.name .. "\n")
    debugH.write("Length: " .. (asmPC - 1) .. "\n")
    debugH.write("Locals: " .. codeAttr.max_locals .. "\n")
    for i = 1, #asm do
        local inst = asm[i]
        local ok, err = pcall(function()
            if inst:sub(1, 4) == "#jmp" then
                local _, _, sjoffset, sjmpLOffset = inst:find("^#jmp ([+-]?%d+) ([+-]?%d+)")

                -- Java instruction to jump to
                local jpc
                if sjoffset and sjmpLOffset then
                    local joffset, jmpLOffset = tonumber(sjoffset), tonumber(sjmpLOffset)
                    jpc = pcMapLJ[i - jmpLOffset] + joffset
                else
                    local _, _, sjpc = inst:find("^#jmp %((%d+)%)")
                    jpc = tonumber(sjpc)
                end

                -- Lua instruction to jump to
                local lpc = pcMapJL[jpc]
                -- Lua offset
                local loffset = lpc - i - 1
                asm[i] = "jmp " .. loffset .. "\n"
            end
        end)

        if not ok then
            debugH.flush()
            error("Invalid #jmp: " .. inst .. "\nCause: " .. err)
        end

        if pcMapLJ[i] then
            debugH.write(string.format("[%i] %X:\n", pcMapLJ[i], code[pcMapLJ[i]]))
        end
        debugH.write(string.format("\t[%i] %s", i, inst:gsub("\n$", function()
            return (comments[i] or "") .. "\n"
        end)))
    end
    debugH.write("\n")
    debugH.flush()
    --print(table.concat(asm))

    --print("Loading and verifying bytecode for " .. name)
    local p = LAT.Lua51.Parser:new()
    local file = p:Parse(".options 0 " .. (codeAttr.max_locals + 1) .. table.concat(asm), class.name .. "." .. method.name.."/bytecode")
    --file:StripDebugInfo()
    local ok, bc = pcall(file.Compile, file)
    assert(ok, class.name .. "." .. method.name:sub(1, method.name:find("%(") - 1) .. " failed to compile: \n" .. bc)
    local f = loadstring(bc)
    --print(table.concat(asm))

    return f, rti
    --popStackTrace()
end

function createCodeFunction(class, method, codeAttr, cp)
    local f
    local rti
    return function(...)
        if not f then
            f, rti = compile(class, method, codeAttr, cp)
        end
        return f(rti, ...)
    end
end