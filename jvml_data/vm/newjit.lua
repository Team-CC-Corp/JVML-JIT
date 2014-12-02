local function compile(class, method, codeAttr, cp)
    -- declarations
    local getCurrentLineNumber

    local code = codeAttr.code
    local stream = makeExtendedChunkStream(class, method, codeAttr, cp)


    local oplookup = {
        function() -- 01
            -- null
            local r = stream.alloc()
            stream.LOADNIL(r, r)
        end, function() -- 02
            -- iconst_m1
            stream.asmLoadk(stream.alloc(), -1)
        end, function() -- 03
            -- iconst_0
            stream.asmLoadk(stream.alloc(), 0)
        end, function() -- 04
            -- iconst_1
            stream.asmLoadk(stream.alloc(), 1)
        end, function() -- 05
            -- iconst_2
            stream.asmLoadk(stream.alloc(), 2)
        end, function() -- 06
            -- iconst_3
            stream.asmLoadk(stream.alloc(), 3)
        end, function() -- 07
            -- iconst_4
            stream.asmLoadk(stream.alloc(), 4)
        end, function() -- 08
            -- iconst_5
            stream.asmLoadk(stream.alloc(), 5)
        end, function() -- 09
            -- lconst_0
            stream.asmGetObj(stream.alloc(), bigint(0))
        end, function() -- 0A
            -- lconst_1
            stream.asmGetObj(stream.alloc(), bigint(1))
        end, function() -- 0B
            -- fconst_0
            stream.asmLoadk(stream.alloc(), 0)
        end, function() -- 0C
            -- fconst_1
            stream.asmLoadk(stream.alloc(), 1)
        end, function() -- 0D
            -- fconst_2
            stream.asmLoadk(stream.alloc(), 2)
        end, function() -- 0E
            -- dconst_0
            stream.asmLoadk(stream.alloc(), 0)
        end, function() -- 0F
            -- dconst_1
            stream.asmLoadk(stream.alloc(), 1)
        end, function() -- 10
            -- bipush
            stream.asmLoadk(stream.alloc(), stream.u1())
        end, function() -- 11
            -- sipush
            stream.asmLoadk(stream.alloc(), stream.u2())
        end, function() -- 12
            -- ldc
            local s = cp[stream.u1()]
            local reg = stream.alloc()
            if s.bytes then
                stream.asmLoadk(reg, s.bytes)
            elseif s.tag == CONSTANT.Class then
                stream.asmGetObj(reg, getJClass(cp[s.name_index].bytes:gsub("/", ".")))
                stream.getPool(reg).nullChecked = true
            else
                stream.asmLoadString(reg, cp[s.string_index].bytes)
                stream.getPool(reg).nullChecked = true
            end
        end, function() -- 13
            -- ldc_w
            local s = cp[stream.u2()]
            local reg = stream.alloc()
            if s.bytes then
                stream.asmLoadk(reg, s.bytes)
            elseif s.tag == CONSTANT.Class then
                stream.asmGetObj(reg, getJClass(cp[s.name_index].bytes:gsub("/", ".")))
                stream.getPool(reg).nullChecked = true
            else
                stream.asmLoadString(reg, cp[s.string_index].bytes)
                stream.getPool(reg).nullChecked = true
            end
        end, function() -- 14
            -- ldc2_w
            local s = cp[stream.u2()]
            if s.cl == "D" then
                stream.asmLoadk(stream.alloc(), s.bytes)
            elseif s.cl == "J" then
                stream.asmGetObj(stream.alloc(), s.bytes)
            else
                error("Unknown wide constant type.")
            end
        end, function() -- 15
            -- loads
            stream.MOVE(stream.alloc(), stream.u1() + 1)
        end, function() -- 16
            -- loads
            stream.MOVE(stream.alloc(), stream.u1() + 1)
        end, function() -- 17
            -- loads
            stream.MOVE(stream.alloc(), stream.u1() + 1)
        end, function() -- 18
            -- loads
            stream.MOVE(stream.alloc(), stream.u1() + 1)
        end, function() -- 19
            -- loads
            stream.MOVE(stream.alloc(), stream.u1() + 1)
        end, function() -- 1A
            -- load_0
            stream.MOVE(stream.alloc(), 1)
        end, function() -- 1B
            -- load_1
            stream.MOVE(stream.alloc(), 2)
        end, function() -- 1C
            -- load_2
            stream.MOVE(stream.alloc(), 3)
        end, function() -- 1D
            -- load_3
            stream.MOVE(stream.alloc(), 4)
        end, function() -- 1E
            -- load_0
            stream.MOVE(stream.alloc(), 1)
        end, function() -- 1F
            -- load_1
            stream.MOVE(stream.alloc(), 2)
        end, function() -- 20
            -- load_2
            stream.MOVE(stream.alloc(), 3)
        end, function() -- 21
            -- load_3
            stream.MOVE(stream.alloc(), 4)
        end, function() -- 22
            -- load_0
            stream.MOVE(stream.alloc(), 1)
        end, function() -- 23
            -- load_1
            stream.MOVE(stream.alloc(), 2)
        end, function() -- 24
            -- load_2
            stream.MOVE(stream.alloc(), 3)
        end, function() -- 25
            -- load_3
            stream.MOVE(stream.alloc(), 4)
        end, function() -- 26
            -- load_0
            stream.MOVE(stream.alloc(), 1)
        end, function() -- 27
            -- load_1
            stream.MOVE(stream.alloc(), 2)
        end, function() -- 28
            -- load_2
            stream.MOVE(stream.alloc(), 3)
        end, function() -- 29
            -- load_3
            stream.MOVE(stream.alloc(), 4)
        end, function() -- 2A
            -- load_0
            stream.MOVE(stream.alloc(), 1)
        end, function() -- 2B
            -- load_1
            stream.MOVE(stream.alloc(), 2)
        end, function() -- 2C
            -- load_2
            stream.MOVE(stream.alloc(), 3)
        end, function() -- 2D
            -- load_3
            stream.MOVE(stream.alloc(), 4)
        end, function() -- 2E
            stream.asmAALoad()
        end, function() -- 2F
            stream.asmAALoad()
        end, function() -- 30
            stream.asmAALoad()
        end, function() -- 31
            stream.asmAALoad()
        end, function() -- 32
            stream.asmAALoad()
        end, function() -- 33
            stream.asmAALoad()
        end, function() -- 34
            stream.asmAALoad()
        end, function() -- 35
            stream.asmAALoad()
        end, function() -- 36
            -- stores
            stream.MOVE(stream.u1() + 1, stream.free())
        end, function() -- 37
            -- stores
            stream.MOVE(stream.u1() + 1, stream.free())
        end, function() -- 38
            -- stores
            stream.MOVE(stream.u1() + 1, stream.free())
        end, function() -- 39
            -- stores
            stream.MOVE(stream.u1() + 1, stream.free())
        end, function() -- 3A
            -- stores
            stream.MOVE(stream.u1() + 1, stream.free())
        end, function() -- 3B
            -- stores
            stream.MOVE(1, stream.free())
        end, function() -- 3C
            -- stores
            stream.MOVE(2, stream.free())
        end, function() -- 3D
            -- stores
            stream.MOVE(3, stream.free())
        end, function() -- 3E
            -- stores
            stream.MOVE(4, stream.free())
        end, function() -- 3F
            -- stores
            stream.MOVE(1, stream.free())
        end, function() -- 40
            -- stores
            stream.MOVE(2, stream.free())
        end, function() -- 41
            -- stores
            stream.MOVE(3, stream.free())
        end, function() -- 42
            -- stores
            stream.MOVE(4, stream.free())
        end, function() -- 43
            -- stores
            stream.MOVE(1, stream.free())
        end, function() -- 44
            -- stores
            stream.MOVE(2, stream.free())
        end, function() -- 45
            -- stores
            stream.MOVE(3, stream.free())
        end, function() -- 46
            -- stores
            stream.MOVE(4, stream.free())
        end, function() -- 47
            -- stores
            stream.MOVE(1, stream.free())
        end, function() -- 48
            -- stores
            stream.MOVE(2, stream.free())
        end, function() -- 49
            -- stores
            stream.MOVE(3, stream.free())
        end, function() -- 4A
            -- stores
            stream.MOVE(4, stream.free())
        end, function() -- 4B
            -- stores
            stream.MOVE(1, stream.free())
        end, function() -- 4C
            -- stores
            stream.MOVE(2, stream.free())
        end, function() -- 4D
            -- stores
            stream.MOVE(3, stream.free())
        end, function() -- 4E
            -- stores
            stream.MOVE(4, stream.free())
        end, function() -- 4F
            -- aastore
            stream.asmAAStore()
        end, function() -- 50
            -- aastore
            stream.asmAAStore()
        end, function() -- 51
            -- aastore
            stream.asmAAStore()
        end, function() -- 52
            -- aastore
            stream.asmAAStore()
        end, function() -- 53
            -- aastore
            stream.asmAAStore()
        end, function() -- 54
            -- aastore
            stream.asmAAStore()
        end, function() -- 55
            -- aastore
            stream.asmAAStore()
        end, function() -- 56
            -- aastore
            stream.asmAAStore()
        end, function() -- 57
            error("57 not implemented")
        end, function() -- 58
            error("58 not implemented")
        end, function() -- 59
            error("59 not implemented")
        end, function() -- 5A
            error("5A not implemented")
        end, function() -- 5B
            error("5B not implemented")
        end, function() -- 5C
            error("5C not implemented")
        end, function() -- 5D
            error("5D not implemented")
        end, function() -- 5E
            error("5E not implemented")
        end, function() -- 5F
            error("5F not implemented")
        end, function() -- 60
            error("60 not implemented")
        end, function() -- 61
            error("61 not implemented")
        end, function() -- 62
            error("62 not implemented")
        end, function() -- 63
            error("63 not implemented")
        end, function() -- 64
            error("64 not implemented")
        end, function() -- 65
            error("65 not implemented")
        end, function() -- 66
            error("66 not implemented")
        end, function() -- 67
            error("67 not implemented")
        end, function() -- 68
            error("68 not implemented")
        end, function() -- 69
            error("69 not implemented")
        end, function() -- 6A
            error("6A not implemented")
        end, function() -- 6B
            error("6B not implemented")
        end, function() -- 6C
            error("6C not implemented")
        end, function() -- 6D
            error("6D not implemented")
        end, function() -- 6E
            error("6E not implemented")
        end, function() -- 6F
            error("6F not implemented")
        end, function() -- 70
            error("70 not implemented")
        end, function() -- 71
            error("71 not implemented")
        end, function() -- 72
            error("72 not implemented")
        end, function() -- 73
            error("73 not implemented")
        end, function() -- 74
            error("74 not implemented")
        end, function() -- 75
            error("75 not implemented")
        end, function() -- 76
            error("76 not implemented")
        end, function() -- 77
            error("77 not implemented")
        end, function() -- 78
            error("78 not implemented")
        end, function() -- 79
            error("79 not implemented")
        end, function() -- 7A
            error("7A not implemented")
        end, function() -- 7B
            error("7B not implemented")
        end, function() -- 7C
            error("7C not implemented")
        end, function() -- 7D
            error("7D not implemented")
        end, function() -- 7E
            error("7E not implemented")
        end, function() -- 7F
            error("7F not implemented")
        end, function() -- 80
            error("80 not implemented")
        end, function() -- 81
            error("81 not implemented")
        end, function() -- 82
            error("82 not implemented")
        end, function() -- 83
            error("83 not implemented")
        end, function() -- 84
            error("84 not implemented")
        end, function() -- 85
            error("85 not implemented")
        end, function() -- 86
            error("86 not implemented")
        end, function() -- 87
            error("87 not implemented")
        end, function() -- 88
            error("88 not implemented")
        end, function() -- 89
            error("89 not implemented")
        end, function() -- 8A
            error("8A not implemented")
        end, function() -- 8B
            error("8B not implemented")
        end, function() -- 8C
            error("8C not implemented")
        end, function() -- 8D
            error("8D not implemented")
        end, function() -- 8E
            error("8E not implemented")
        end, function() -- 8F
            error("8F not implemented")
        end, function() -- 90
            error("90 not implemented")
        end, function() -- 91
            error("91 not implemented")
        end, function() -- 92
            error("92 not implemented")
        end, function() -- 93
            error("93 not implemented")
        end, function() -- 94
            error("94 not implemented")
        end, function() -- 95
            error("95 not implemented")
        end, function() -- 96
            error("96 not implemented")
        end, function() -- 97
            error("97 not implemented")
        end, function() -- 98
            error("98 not implemented")
        end, function() -- 99
            error("99 not implemented")
        end, function() -- 9A
            error("9A not implemented")
        end, function() -- 9B
            error("9B not implemented")
        end, function() -- 9C
            error("9C not implemented")
        end, function() -- 9D
            error("9D not implemented")
        end, function() -- 9E
            error("9E not implemented")
        end, function() -- 9F
            error("9F not implemented")
        end, function() -- A0
            error("A0 not implemented")
        end, function() -- A1
            error("A1 not implemented")
        end, function() -- A2
            error("A2 not implemented")
        end, function() -- A3
            error("A3 not implemented")
        end, function() -- A4
            error("A4 not implemented")
        end, function() -- A5
            error("A5 not implemented")
        end, function() -- A6
            error("A6 not implemented")
        end, function() -- A7
            error("A7 not implemented")
        end, function() -- A8
            error("A8 not implemented")
        end, function() -- A9
            error("A9 not implemented")
        end, function() -- AA
            error("AA not implemented")
        end, function() -- AB
            error("AB not implemented")
        end, function() -- AC
            error("AC not implemented")
        end, function() -- AD
            error("AD not implemented")
        end, function() -- AE
            error("AE not implemented")
        end, function() -- AF
            error("AF not implemented")
        end, function() -- B0
            error("B0 not implemented")
        end, function() -- B1
            error("B1 not implemented")
        end, function() -- B2
            error("B2 not implemented")
        end, function() -- B3
            error("B3 not implemented")
        end, function() -- B4
            error("B4 not implemented")
        end, function() -- B5
            error("B5 not implemented")
        end, function() -- B6
            error("B6 not implemented")
        end, function() -- B7
            error("B7 not implemented")
        end, function() -- B8
            error("B8 not implemented")
        end, function() -- B9
            error("B9 not implemented")
        end, function() -- BA
            error("BA not implemented")
        end, function() -- BB
            error("BB not implemented")
        end, function() -- BC
            error("BC not implemented")
        end, function() -- BD
            error("BD not implemented")
        end, function() -- BE
            error("BE not implemented")
        end, function() -- BF
            error("BF not implemented")
        end, function() -- C0
            error("C0 not implemented")
        end, function() -- C1
            error("C1 not implemented")
        end, function() -- C2
            error("C2 not implemented")
        end, function() -- C3
            error("C3 not implemented")
        end, function() -- C4
            error("C4 not implemented")
        end, function() -- C5
            error("C5 not implemented")
        end, function() -- C6
            error("C6 not implemented")
        end, function() -- C7
            error("C7 not implemented")
        end, function() -- C8
            error("C8 not implemented")
        end, function() -- C9
            error("C9 not implemented")
        end, function() -- CA
            error("CA not implemented")
        end, function() -- CB
            error("CB not implemented")
        end, function() -- CC
            error("CC not implemented")
        end, function() -- CD
            error("CD not implemented")
        end, function() -- CE
            error("CE not implemented")
        end, function() -- CF
            error("CF not implemented")
        end, function() -- D0
            error("D0 not implemented")
        end, function() -- D1
            error("D1 not implemented")
        end, function() -- D2
            error("D2 not implemented")
        end, function() -- D3
            error("D3 not implemented")
        end, function() -- D4
            error("D4 not implemented")
        end, function() -- D5
            error("D5 not implemented")
        end, function() -- D6
            error("D6 not implemented")
        end, function() -- D7
            error("D7 not implemented")
        end, function() -- D8
            error("D8 not implemented")
        end, function() -- D9
            error("D9 not implemented")
        end, function() -- DA
            error("DA not implemented")
        end, function() -- DB
            error("DB not implemented")
        end, function() -- DC
            error("DC not implemented")
        end, function() -- DD
            error("DD not implemented")
        end, function() -- DE
            error("DE not implemented")
        end, function() -- DF
            error("DF not implemented")
        end, function() -- E0
            error("E0 not implemented")
        end, function() -- E1
            error("E1 not implemented")
        end, function() -- E2
            error("E2 not implemented")
        end, function() -- E3
            error("E3 not implemented")
        end, function() -- E4
            error("E4 not implemented")
        end, function() -- E5
            error("E5 not implemented")
        end, function() -- E6
            error("E6 not implemented")
        end, function() -- E7
            error("E7 not implemented")
        end, function() -- E8
            error("E8 not implemented")
        end, function() -- E9
            error("E9 not implemented")
        end, function() -- EA
            error("EA not implemented")
        end, function() -- EB
            error("EB not implemented")
        end, function() -- EC
            error("EC not implemented")
        end, function() -- ED
            error("ED not implemented")
        end, function() -- EE
            error("EE not implemented")
        end, function() -- EF
            error("EF not implemented")
        end, function() -- F0
            error("F0 not implemented")
        end, function() -- F1
            error("F1 not implemented")
        end, function() -- F2
            error("F2 not implemented")
        end, function() -- F3
            error("F3 not implemented")
        end, function() -- F4
            error("F4 not implemented")
        end, function() -- F5
            error("F5 not implemented")
        end, function() -- F6
            error("F6 not implemented")
        end, function() -- F7
            error("F7 not implemented")
        end, function() -- F8
            error("F8 not implemented")
        end, function() -- F9
            error("F9 not implemented")
        end, function() -- FA
            error("FA not implemented")
        end, function() -- FB
            error("FB not implemented")
        end, function() -- FC
            error("FC not implemented")
        end, function() -- FD
            error("FD not implemented")
        end, function() -- FE
            error("FE not implemented")
        end, function() -- FF
            error("FF not implemented")
        end
    }


    stream.asmPushStackTrace()
    local instruction = stream.u1()
    while instruction do
        stream.beginJavaInstruction(instruction)
        oplookup[instruction]()
    end






    local compiledCode = stream.compile(class.name .. "." .. method.name.."/bytecode")
    local f = loadstring(compiledCode)
    return f, stream.getRTI()
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