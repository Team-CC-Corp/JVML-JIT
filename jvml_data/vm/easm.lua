-- Chunk stream with extensions for null checks and other JVML specific things
function makeExtendedChunkStream(class, method, codeAttr, cp)
    local maxLocals = codeAttr.max_locals
    local code = codeAttr.code
    local stream = asm.makeChunkStream(maxLocals + 1) -- locals + rti

    -- Get attribute data
    local lineNumberAttribute
    local stackMapAttribute
    local sourceFileName

    for i=0,codeAttr.attributes_count-1 do
        if codeAttr.attributes[i].name == "LineNumberTable" then
            lineNumberAttribute = codeAttr.attributes[i]
        elseif codeAttr.attributes[i].name == "StackMapTable" then
            stackMapAttribute = codeAttr.attributes[i]
        end
    end

    for i=0,class.attributes_count-1 do
        if class.attributes[i].name == "SourceFile" then
            sourceFileName = cp[class.attributes[i].source_file_index].bytes
        end
    end

    function getLineNumberAttribute()
        return lineNumberAttribute
    end
    function getStackMapAttribute()
        return stackMapAttribute
    end
    function getSourceFileName()
        return sourceFileName
    end

    -- RTI
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

    -- java code functions
    local _pc = 0
    local currentInstructionPC

    function stream.u1()
        _pc = _pc+1
        return code[_pc-1]
    end
    function stream.pc(i)
        _pc = i or _pc
        return _pc - 1
    end

    function stream.u2()
        return bit.blshift(stream.u1(),8) + stream.u1()
    end

    function stream.u4()
        return bit.blshift(stream.u1(),24) + bit.blshift(stream.u1(),16) + bit.blshift(stream.u1(),8) + stream.u1()
    end

    function stream.s4()
        local u = stream.u4()
        if u < 2147483648 then
            return u
        end
        return u - 4294967296
    end

    function stream.resolveClass(cr)
        local cn = cp[cp[cr].name_index].bytes:gsub("/",".")
        return classByName(cn)
    end

    function stream.getCurrentLineNumber()
        local ln
        if lineNumberAttribute then
            local len = lineNumberAttribute.line_number_table_length
            for i = 0, len - 1 do
                local entry = lineNumberAttribute.line_number_table[i]
                if entry.start_pc > stream.pc() then
                    ln = lineNumberAttribute.line_number_table[i - 1].line_number
                    break
                end
            end
        end
        return ln
    end

    function stream.getCurrentInstructionPC()
        return currentInstructionPC
    end

    -- bridging java and lua instruction stuff
    local l2jMap = { }
    local j2lMap = { }
    local jumpsToFix = {}
    local entryIndex = 0
    local offset = -1

    local oldEmit = stream.emit
    function stream.emit(...)
        local ok, index = pcall(oldEmit, ...)
        assert(ok, index, 2)
        l2jMap[index] = currentInstructionPC
        return index
    end

    function stream.beginJavaInstruction(op) -- fixes jumps and stack map stuff
        currentInstructionPC = stream.pc()
        j2lMap[currentInstructionPC] = stream.getInstructionCount()
        if jumpsToFix[currentInstructionPC] then
            for i,v in ipairs(jumpsToFix[currentInstructionPC]) do
                stream.fixJump(v)
            end
        end

        if stackMapAttribute and stackMapAttribute.entries[entryIndex] then
            local entry = stackMapAttribute.entries[entryIndex]
            local newOffset = offset + entry.offset_delta + 1
            if stream.pc() == newOffset then
                entryIndex = entryIndex + 1
                offset = newOffset

                stream.alignToRegister(entry.stack_items + maxLocals)
                stream.clearValuePools() -- this should not survive things like if blocks
            end
        end
    end

    function stream.jumpByJOffset(joffset)
        if joffset > 0 then
            local jInstruction = currentInstructionPC + joffset
            jumpsToFix[jInstruction] = jumpsToFix[jInstruction] or {}
            table.insert(jumpsToFix[jInstruction], stream.startJump())
        else
            local jumpToJ = currentInstructionPC + joffset
            local jumpToL = j2lMap[jumpToJ]
            local jid = stream.startBackwardJump(jumpToL)
            stream.fixJump(jid)
        end
    end

    -- asm utility functions
    function stream.asmGetObj(r, obj)
        local rk = stream.allocRK(info(obj))
        stream.GETTABLE(r, 0, rk)
        stream.freeRK(rk)
    end

    function stream.asmNewInstance(robj, class, customObjectSize)
        stream.comment("Creating new instance: " .. class.name)
        local rclass, rfields, rmethods = stream.alloc(3)
        stream.asmGetObj(rclass, class)
        stream.asmGetObj(rmethods, class.methods)
        stream.NEWTABLE(robj, customObjectSize or 3, 0)
        stream.NEWTABLE(rfields, #class.field_info, 0)
        for i = 1, #class.field_info do
            local fi = class.field_info[i]
            local rki = stream.allocRK(i)
            local rkDefault
            if PRIMITIVE_WRAPPERS[fi.descriptor] then
                rkDefault = stream.allocRK(0)
            else
                rkDefault = stream.allocNilRK()
            end
            stream.SETTABLE(rfields, rki, rkDefault)
            stream.freeRK(rki, rkDefault)
        end
        local classIndex, fieldsIndex, methodsIndex = stream.allocRK(1, 2, 3)
        stream.SETTABLE(robj, classIndex, rclass)
        stream.SETTABLE(robj, fieldsIndex, rfields)
        stream.SETTABLE(robj, methodsIndex, rmethods)
        stream.freeRK(classIndex, fieldsIndex, methodsIndex)
        stream.free(3)

        stream.getPool(robj).nullChecked = true
    end

    function stream.asmNewArray(robj, rlength, class)
        stream.comment("Creating new array")

        local rarray = stream.alloc()
        stream.NEWTABLE(rarray, 0, 0)
        stream.asmNewInstance(robj, class, 5) -- creates new object
        local lengthIndex, arrayIndex = stream.allocRK(4, 5)
        stream.SETTABLE(robj, lengthIndex, rlength)
        stream.SETTABLE(robj, arrayIndex, rarray)
        stream.freeRK(lengthIndex, arrayIndex)
        stream.free()

        stream.getPool(robj).nullChecked = true
    end

    function stream.asmNewPrimitiveArray(robj, rlength, class)
        stream.comment("Creating new primitive array")

        local rarray, ri = stream.alloc(2)

        stream.NEWTABLE(rarray, 0, 0)
        stream.LOADK(ri, stream.getConstant(1))
        stream.LE(0, ri, rlength)
        stream.JMP(3)
        local rkDefault, rkIter = stream.allocRK(0, 1) -- all primitives are represented by integers and default to 0 -- TODO: Except longs.
        stream.SETTABLE(rarray, ri, rkDefault)
        stream.ADD(ri, ri, rkIter)
        stream.freeRK(rkDefault, rkIter)
        stream.JMP(-5)

        stream.asmNewInstance(robj, class, 5) -- creates new object
        local lengthIndex, arrayIndex = stream.allocRK(4, 5)
        stream.SETTABLE(robj, lengthIndex, rlength)
        stream.SETTABLE(robj, arrayIndex, rarray)
        stream.freeRK(lengthIndex, arrayIndex)
        stream.free(2)

        stream.getPool(robj).nullChecked = true
    end

    function stream.asmLoadAndCall(nReturns, f, ...)
        stream.comment("Loading and calling function")

        local rf = stream.alloc()
        local rargs = {stream.alloc(#{...})}
        stream.asmGetObj(rf, f)
        for i,v in ipairs{...} do
            stream.asmGetObj(rargs[i], v)
        end
        stream.CALL(rf, #rargs + 1, nReturns + 1)
        stream.free(#rargs + 1)
        return stream.alloc(nReturns)
    end

    function stream.asmPushStackTrace()
        stream.comment("Pushing stacktrace")
        stream.asmLoadAndCall(0, pushStackTrace, class.name, method.name:sub(1, method.name:find("%(") - 1), sourceFileName or "", 0)
    end

    function stream.asmPopStackTrace()
        stream.comment("Popping stacktrace")
        stream.asmLoadAndCall(0, popStackTrace)
    end

    function stream.asmSetStackTraceLineNumber(ln)
        stream.comment("Setting line number")
        stream.asmLoadAndCall(0, setStackTraceLineNumber, ln)
    end

    function stream.asmInstanceOf(robj, class)
        stream.comment("Instance of: " .. class.name)
        local rinstanceof, rNewObj, rClass = stream.alloc(3)

        stream.asmGetObj(rinstanceof, jInstanceof)
        stream.MOVE(rNewObj, robj)
        stream.asmGetObj(rClass, class)
        stream.CALL(rinstanceof, 3, 2)
        stream.MOVE(robj, rinstanceof)

        stream.free(3)
    end

    function stream.asmThrow(rexception)
        stream.comment("Throw")

        local exceptionHandlers = {}
        for i=0, codeAttr.exception_table_length-1 do
            local handler = codeAttr.exception_table[i]
            if handler.start_pc <= currentInstructionPC and handler.end_pc > currentInstructionPC then
                table.insert(exceptionHandlers, handler)
            end
        end
        for i=1, #exceptionHandlers do
            local handler = exceptionHandlers[i]
            if handler.catch_type == 0 then
                stream.jumpByJOffset(handler.handler_pc - currentInstructionPC)
            else
                local c = stream.resolveClass(handler.catch_type)
                local rtest = stream.alloc()
                stream.MOVE(rtest, rexception)
                stream.asmInstanceOf(rtest, c)

                local zero = stream.allocRK(0)
                stream.EQ(1, rtest, zero)
                stream.freeRK(zero)


                local jid = stream.startJump()
                stream.MOVE(maxLocals + 1, rexception)
                stream.jumpByJOffset(handler.handler_pc - currentInstructionPC)
                stream.fixJump(jid)
                stream.free()
            end
        end
        stream.asmPopStackTrace()
        local rnil, rexc = stream.alloc(2)
        stream.LOADNIL(rnil, rnil)
        stream.MOVE(rexc, rexception)
        stream.RETURN(rnil, 3)
        stream.free(2)
    end

    function stream.asmCheckThrow(rexception)
        stream.comment("Check throw")
        stream.TEST(rexception, 0)
        local jid = stream.startJump()
        stream.asmThrow(rexception)
        stream.fixJump(jid)
    end

    function stream.asmRefillStackTrace(rexception)
        stream.asmSetStackTraceLineNumber(stream.getCurrentLineNumber() or 0)

        local rfill, rexc = stream.alloc(2)

        local fillInStackTrace = findMethod(classByName("java.lang.Throwable"), "fillInStackTrace()Ljava/lang/Throwable;")

        stream.asmGetObj(rfill, fillInStackTrace[1])
        stream.MOVE(rexc, rexception)
        stream.CALL(rfill, 2, 1)

        stream.free(2)
    end

    function stream.asmCheckNullPointer(robj)
        if stream.getPool(robj).nullChecked then
            return
        end

        stream.comment("Checking null pointer")

        local npException = classByName("java.lang.NullPointerException")
        local con = findMethod(npException, "<init>()V")

        stream.TEST(robj, 1)
        local jid = stream.startJump()
        
        local rexc, rcon, rexcDup = stream.alloc(3)
        stream.asmNewInstance(rexc, npException)
        stream.asmGetObj(rcon, con[1])
        stream.MOVE(rexcDup, rexc)
        stream.CALL(rcon, 2, 1)
        stream.free(2)

        stream.asmRefillStackTrace(rexc)
        stream.asmThrow(rexc)

        stream.fixJump(jid)

        stream.free(1)

        stream.getPool(robj).nullChecked = true
    end

    function stream.asmCheckArrayIndexOutOfBounds(rarr, ri)
        local oobException = classByName("java.lang.ArrayIndexOutOfBoundsException")
        local con = findMethod(oobException, "<init>(I)V")

        local rlen, rexc, rcon, rpexc, rpi = stream.alloc(5)
        local lengthIndex = stream.allocRK(4)

        stream.GETTABLE(rlen, rarr, lengthIndex)
        stream.LT(1, ri, rlen)
        local jid = stream.startJump()

        stream.asmNewInstance(rexc, oobException)
        stream.asmGetObj(rcon, con[1])
        stream.MOVE(rpi, ri)
        stream.MOVE(rpexc, rexc)
        stream.CALL(rcon, 3, 3)
        stream.asmRefillStackTrace(rexc)
        stream.asmThrow(rexc)
        stream.fixJump(jid)

        stream.freeRK(lengthIndex)
        stream.free(5)
    end

    function stream.asmAALoad() -- does do memory management
        stream.comment("Array load")
        local rarr, ri = stream.peek(1), stream.peek(0)

        stream.asmCheckNullPointer(rarr)
        stream.asmCheckArrayIndexOutOfBounds(rarr, ri)

        local j2lOffset, arrayIndex = stream.allocRK(1, 5)

        stream.ADD(ri, ri, j2lOffset)
        stream.GETTABLE(rarr, rarr, arrayIndex)
        stream.GETTABLE(rarr, rarr, ri)

        stream.freeRK(j2lOffset, arrayIndex)
        stream.free()
    end

    function stream.asmAAStore() -- does do memory management
        stream.comment("Array store")
        local rarr, ri, rval = stream.peek(2), stream.peek(1), stream.peek(0)

        stream.asmCheckNullPointer(rarr)
        stream.asmCheckArrayIndexOutOfBounds(rarr, ri)

        local j2lOffset, arrayIndex = stream.allocRK(1, 5)

        stream.ADD(ri, ri, j2lOffset)
        stream.GETTABLE(rarr, rarr, arrayIndex)
        stream.SETTABLE(rarr, ri, rval)

        stream.freeRK(j2lOffset, arrayIndex)
        stream.free(3)
    end

    local divByZeroJString
    function stream.asmDivCheck(r1, r2)
        if stream.getPool(r2).zeroChecked then
            return
        end
        if not divByZeroJString then
            divByZeroJString = toJString("/ by zero")
        end

        stream.comment("Div check")

        local arithException = classByName("java.lang.ArithmeticException")
        local con = findMethod(arithException, "<init>(Ljava/lang/String;)V")

        local rexc, rcon, rpexc, rmsg = stream.alloc(4)
        local zero = stream.allocRK(0)

        stream.EQ(0, r2, zero)            -- Check for / by zero.
        local jid = stream.startJump()

        stream.asmNewInstance(rexc, arithException)
        stream.asmGetObj(rmsg, divByZeroJString)
        stream.asmGetObj(rcon, con[1])
        stream.MOVE(rpexc, rexc)
        stream.CALL(rcon, 3, 3)

        stream.asmRefillStackTrace(rexc)
        stream.asmThrow(rexc)

        stream.fixJump(jid)

        stream.freeRK(zero)
        stream.free(4)

        stream.getPool(r2).zeroChecked = true
    end

    function stream.asmLongDivCheck(r1, r2)
        if stream.getPool(r2).zeroChecked then
            return
        end
        if not divByZeroJString then
            divByZeroJString = toJString("/ by zero")
        end

        stream.comment("Long div check")

        local arithException = classByName("java.lang.ArithmeticException")
        local con = findMethod(arithException, "<init>(Ljava/lang/String;)V")

        local req, rp2, rzero = stream.alloc(3)        -- Check for / by zero.
        stream.asmGetObj(req, bigintEQ)
        stream.MOVE(rp2, r2)
        stream.asmGetObj(rzero, bigint(0))
        stream.CALL(req, 3, 2)
        stream.free(2)

        local rexc, rcon, rpexc, rmsg = stream.alloc(4)

        stream.TEST(req, 0)                  -- Check result.
        local jid = stream.startJump()

        stream.asmNewInstance(rexc, arithException)
        stream.asmGetObj(rmsg, divByZeroJString)
        stream.asmGetObj(rcon, con[1])
        stream.MOVE(rpexc, rexc)
        stream.CALL(rcon, 3, 3)
        stream.asmRefillStackTrace(rexc)
        stream.asmThrow(rexc)

        stream.fixJump(jid)

        stream.free(5)

        stream.getPool(r2).zeroChecked = true
    end

    function stream.asmIntDiv() -- does memory management
        stream.comment("Int div")
        local r1, r2 = stream.peek(1), stream.peek(0)
        stream.asmDivCheck(r1, r2)

        local one = stream.allocRK(1)
        stream.DIV(r1, r1, r2)
        stream.MOD(r2, r1, one)      -- Floor the value.
        stream.SUB(r1, r1, r2)
        stream.freeRK(one)
        stream.free(1)
    end

    function stream.asmFloatDiv()
        stream.comment("Int div")
        local r1, r2 = stream.peek(1), stream.peek(0)
        stream.asmDivCheck(r1, r2)

        stream.DIV(r1, r1, r2)
        stream.free(1)
    end

    function stream.asmMod()
        stream.comment("Modulo")
        local r1, r2 = stream.peek(1), stream.peek(0)
        stream.asmDivCheck(r1, r2)

        stream.MOD(r1, r1, r2)
        stream.free(1)
    end

    function stream.asmNumericCompare() -- does memory management
        stream.comment("Numeric compare")
        local r1, r2 = stream.peek(1), stream.peek(0)
        stream.EQ(0, r1, r2)
        stream.JMP(2)
        stream.LOADK(r1, stream.getConstant(0))
        local eqjmp = stream.startJump()
        stream.LT(0, r1, r2)
        stream.JMP(2)
        stream.LOADK(r1, stream.getConstant(-1))
        local ltjmp = stream.startJump()
        stream.LOADK(r1, stream.getConstant(1))


        stream.fixJump(eqjmp)
        stream.fixJump(ltjmp)
        stream.free()
    end

    function stream.asmLongDiv()
        stream.comment("Long div")

        local r1, r2 = stream.peek(1), stream.peek(0)
        stream.asmLongDivCheck(r1, r2)
        local newR1, newR2 = r2, stream.alloc()
        stream.MOVE(newR2, r2)
        stream.MOVE(newR1, r1)
        local rdiv = r1
        stream.asmGetObj(rdiv, bigintDiv)

        stream.CALL(rdiv, 3, 2)
        stream.free(2)
    end

    function stream.asmLongMod()
        stream.comment("Long mod")

        local r1, r2 = stream.peek(1), stream.peek(0)
        stream.asmLongDivCheck(r1, r2)
        local newR1, newR2 = r2, stream.alloc()
        stream.MOVE(newR2, r2)
        stream.MOVE(newR1, r1)
        local rmod = r1
        stream.asmGetObj(rmod, bigintMod)

        stream.CALL(rmod, 3, 2)
        stream.free(2)
    end

    function stream.asmLongCompare()
        stream.comment("Long compare")

        local r1, r2 = stream.peek(1), stream.peek(0)
        local newR1, newR2 = r2, stream.alloc()
        stream.MOVE(newR2, r2)
        stream.MOVE(newR1, r1)
        local rcmp = r1
        stream.asmGetObj(rcmp, bigintCompare) -- Luckily, bigintCompare returns -1,0,1 as expected by the JVM

        stream.CALL(rcmp, 3, 2)
        stream.free(2)
    end

    function stream.asmLoadJString(reg, str)
        local jstr = cp.jitStrings[str]
        if not jstr then
            cp.jitStrings[str] = toJString(str)
            jstr = cp.jitStrings[str]
        end
        
        stream.asmGetObj(reg, jstr)
    end

    function stream.asmFixLongOverflow(r)
        local rop, rnum, rarg = stream.alloc(3)

        stream.MOVE(rnum, r)
        stream.asmGetObj(rop, bigintAdd)
        stream.asmGetObj(rarg, bigint("9223372036854775808"))
        stream.CALL(rop, 3, 2)

        stream.MOVE(rnum, rop)
        stream.asmGetObj(rop, bigintMod)
        stream.asmGetObj(rarg, bigint("18446744073709551616"))
        stream.CALL(rop, 3, 2)

        stream.MOVE(rnum, rop)
        stream.asmGetObj(rop, bigintSub)
        stream.asmGetObj(rarg, bigint("9223372036854775808"))
        stream.CALL(rop, 3, 2)

        stream.MOVE(r, rop)

        stream.free(3)
    end

    function stream.asmInvoke(numArgs, name, void, asmMethodGet)
        local rx = stream.peek(numArgs)
        local rmt, rsave
        if rx <= maxLocals then
            -- Can't be moving locals or RTI.
            -- Stack needs to be moved up.

            for i=stream.alloc(), stream.peek(numArgs) + 1, -1 do
                stream.MOVE(i, i - 1)
            end
            rmt = stream.peek(numArgs)

            if not (stream.peek(0) > rmt) then
                -- no room above rmt for (rret, rexc)
                stream.alignToRegister(rmt + 1)
            end
        else
            rmt = rx
            if not (stream.peek(0) > rmt) then
                -- no room above rmt for (rret, rexc)
                stream.alignToRegister(rmt + 1)
            end
            rsave = stream.alloc()

            stream.MOVE(rsave, rx)
        end

        stream.asmSetStackTraceLineNumber(stream.getCurrentLineNumber() or 0)

        asmMethodGet(rmt)

        stream.comment(name)
        stream.CALL(rmt, numArgs + 1, 3)

        local rret, rexc = rmt, rmt + 1
        stream.asmCheckThrow(rexc)

        if rsave then
            stream.MOVE(rexc, rret)
            rret = rexc
            stream.MOVE(rx, rsave)
        end

        -- Free down to ret
        stream.alignToRegister(rret)         
        if void then
            stream.free()                    
        end
    end

    return stream
end