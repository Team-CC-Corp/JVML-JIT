local Op = { }
Op.MOVE         = 0
Op.LOADK        = 1
Op.LOADBOOL     = 2
Op.LOADNIL      = 3
Op.GETUPVAL     = 4
Op.GETGLOBAL    = 5
Op.GETTABLE     = 6
Op.SETGLOBAL    = 7
Op.SETUPVAL     = 8
Op.SETTABLE     = 9
Op.NEWTABLE     = 10
Op.SELF         = 11
Op.ADD          = 12
Op.SUB          = 13
Op.MUL          = 14
Op.DIV          = 15
Op.MOD          = 16
Op.POW          = 17
Op.UNM          = 18
Op.NOT          = 19
Op.LEN          = 20
Op.CONCAT       = 21
Op.JMP          = 22
Op.EQ           = 23
Op.LT           = 24
Op.LE           = 25
Op.TEST         = 26
Op.TESTSET      = 27
Op.CALL         = 28
Op.TAILCALL     = 29
Op.RETURN       = 30
Op.FORLOOP      = 31
Op.FORPREP      = 32
Op.TFORLOOP     = 33
Op.SETLIST      = 34
Op.CLOSE        = 35
Op.CLOSURE      = 36
Op.VARARG       = 37

local Type = { }
Type.REGISTER   = 1
Type.CONSTANT   = 2
Type.INTEGER    = 3

local typeNames = { "REGISTER", "CONSTANT", "INTEGER" }

function makeChunkStream()
    local stream = { }

    local lastIndex = 0
    local constants = { }
    local nilIndex = nil
    local instns = { }

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
        local args = { ... }

        local lookup = {
            function()
                -- MOVE     R(A) R(B)
                instns[#instns + 1] = { op, args[1].value, args[2].value }
            end, function()
                -- LOADK    R(A) K(B)
                instns[#instns + 1] = { op, args[1].value, getConstant(args[2].value) }
            end, function()
                -- LOADBOOL R(A) I(B) I(C)
                instns[#instns + 1] = { op, args[1].value, args[2].value, args[3].value }
            end, function()
                -- LOADNIL  R(A) R(B)
                instns[#instns + 1] = { op, args[1].value, args[2].value }
            end,            
        }

        lookup[op]()
    end

    function stream.compile()
        
    end

    return stream
end