local InstructionTypes = { }

local sbxBias = 131,071 -- (2^18 - 1) >> 1

function InstructionTypes.ABC(opcode, a, b, c)
    a = bit.blshift(a, 6)
    b = bit.blshift(b, 14)
    c = bit.blshift(c, 23)
    return bit.band(opcode + a + b + c, 2^32 - 1)
end

function InstructionTypes.ABx(opcode, a, bx)
    a = bit.blshift(a, 6)
    bx = bit.blshift(bx, 14)
    return bit.band(opcode + a + bx, 2^32 - 1)
end

function InstructionTypes.AsBx(opcode, a, sbx)
    a = bit.blshift(a, 6)
    sbx = sbx + sbxBias
    sbx = bit.blshift(sbx, 14)
    return bit.band(opcode + a + sbx, 2^32 - 1)
end

function InstructionTypes.AB(opcode, a, b)
    return InstructionTypes.ABC(opcode, a, b, 0)
end

function InstructionTypes.AC(opcode, a, c)
    return InstructionTypes.ABC(opcode, a, 0, c)
end

function InstructionTypes.A(opcode, a)
    return InstructionTypes.ABC(opcode, a, 0, 0)
end

function InstructionTypes.sBx(opcode, sbx)
    return InstructionTypes.AsBx(opcode, 0, sbx)
end

local Op = { }
Op.MOVE         = {opcode = 0, type = InstructionTypes.AB   }
Op.LOADK        = {opcode = 1, type = InstructionTypes.ABx  }
Op.LOADBOOL     = {opcode = 2, type = InstructionTypes.ABC  }
Op.LOADNIL      = {opcode = 3, type = InstructionTypes.AB   }
Op.GETUPVAL     = {opcode = 4, type = InstructionTypes.AB   }
Op.GETGLOBAL    = {opcode = 5, type = InstructionTypes.ABx  }
Op.GETTABLE     = {opcode = 6, type = InstructionTypes.ABC  }
Op.SETGLOBAL    = {opcode = 7, type = InstructionTypes.ABx  }
Op.SETUPVAL     = {opcode = 8, type = InstructionTypes.AB   }
Op.SETTABLE     = {opcode = 9, type = InstructionTypes.ABC  }
Op.NEWTABLE     = {opcode = 10, type = InstructionTypes.ABC }
Op.SELF         = {opcode = 11, type = InstructionTypes.ABC }
Op.ADD          = {opcode = 12, type = InstructionTypes.ABC }
Op.SUB          = {opcode = 13, type = InstructionTypes.ABC }
Op.MUL          = {opcode = 14, type = InstructionTypes.ABC }
Op.DIV          = {opcode = 15, type = InstructionTypes.ABC }
Op.MOD          = {opcode = 16, type = InstructionTypes.ABC }
Op.POW          = {opcode = 17, type = InstructionTypes.ABC }
Op.UNM          = {opcode = 18, type = InstructionTypes.AB  }
Op.NOT          = {opcode = 19, type = InstructionTypes.AB  }
Op.LEN          = {opcode = 20, type = InstructionTypes.AB  }
Op.CONCAT       = {opcode = 21, type = InstructionTypes.ABC }
Op.JMP          = {opcode = 22, type = InstructionTypes.sBx }
Op.EQ           = {opcode = 23, type = InstructionTypes.ABC }
Op.LT           = {opcode = 24, type = InstructionTypes.ABC }
Op.LE           = {opcode = 25, type = InstructionTypes.ABC }
Op.TEST         = {opcode = 26, type = InstructionTypes.AC  }
Op.TESTSET      = {opcode = 27, type = InstructionTypes.ABC }
Op.CALL         = {opcode = 28, type = InstructionTypes.ABC }
Op.TAILCALL     = {opcode = 29, type = InstructionTypes.ABC }
Op.RETURN       = {opcode = 30, type = InstructionTypes.AB  }
Op.FORLOOP      = {opcode = 31, type = InstructionTypes.AsBx}
Op.FORPREP      = {opcode = 32, type = InstructionTypes.AsBx}
Op.TFORLOOP     = {opcode = 33, type = InstructionTypes.AC  }
Op.SETLIST      = {opcode = 34, type = InstructionTypes.ABC }
Op.CLOSE        = {opcode = 35, type = InstructionTypes.A   }
Op.CLOSURE      = {opcode = 36, type = InstructionTypes.ABx }
Op.VARARG       = {opcode = 37, type = InstructionTypes.AB  }

function makeChunkStream(maxLocals)
    local stream = { }

    local lastIndex = 0
    local constants = { }
    local nilIndex = nil
    local instns = { }
    local register = maxLocals
    local maxRegister = maxLocals -- just tracking the highest we go

    local function getMaxRegister()
        return maxRegister
    end

    local function getConstant(value)
        local index
        if value == nil then
            if not nilIndex then
                nilIndex = lastIndex
                lastIndex = lastIndex + 1
            else
                index = nilIndex
            end
        else
            index = constants[value]
            if not index then
                constants[value] = lastIndex
                index = constants[value]
                lastIndex = lastIndex + 1
            end
        end
        return index
    end

    function stream.emit(op, ...)
        local ok, inst = pcall(op.type, op.opcode, ...)
        assert(ok, inst, 2)
        table.insert(instns, inst)
        return #instns
    end

    function stream.startJump()
        table.insert(instns, 0)
        return #instns
    end

    function stream.fixJump(jumpID)
        instns[jumpID] = Op.JMP.type(Op.JMP.opcode, #instns - jumpID)
    end

    function stream.alloc(n)
        n = n or 1
        local ret = { }
        for i = 1, n do
            register = register + 1
            maxRegister = math.max(register, maxRegister)
            ret[i] = register
        end
        return unpack(ret)
    end

    function stream.free(n)
        n = n or 1
        local ret = { }
        for i = n, 1, -1 do
            ret[i] = register
            register = register - 1
        end
        return unpack(ret)
    end

    for k,op in pairs(Op) do
        stream[k] = function(...)
            return stream.emit(op, ...)
        end
    end

    function stream.compile()
        
    end

    return stream
end