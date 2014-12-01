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
            error("10 not implemented")
        end, function() -- 11
            error("11 not implemented")
        end, function() -- 12
            error("12 not implemented")
        end, function() -- 13
            error("13 not implemented")
        end, function() -- 14
            error("14 not implemented")
        end, function() -- 15
            error("15 not implemented")
        end, function() -- 16
            error("16 not implemented")
        end, function() -- 17
            error("17 not implemented")
        end, function() -- 18
            error("18 not implemented")
        end, function() -- 19
            error("19 not implemented")
        end, function() -- 1A
            error("1A not implemented")
        end, function() -- 1B
            error("1B not implemented")
        end, function() -- 1C
            error("1C not implemented")
        end, function() -- 1D
            error("1D not implemented")
        end, function() -- 1E
            error("1E not implemented")
        end, function() -- 1F
            error("1F not implemented")
        end, function() -- 20
            error("20 not implemented")
        end, function() -- 21
            error("21 not implemented")
        end, function() -- 22
            error("22 not implemented")
        end, function() -- 23
            error("23 not implemented")
        end, function() -- 24
            error("24 not implemented")
        end, function() -- 25
            error("25 not implemented")
        end, function() -- 26
            error("26 not implemented")
        end, function() -- 27
            error("27 not implemented")
        end, function() -- 28
            error("28 not implemented")
        end, function() -- 29
            error("29 not implemented")
        end, function() -- 2A
            error("2A not implemented")
        end, function() -- 2B
            error("2B not implemented")
        end, function() -- 2C
            error("2C not implemented")
        end, function() -- 2D
            error("2D not implemented")
        end, function() -- 2E
            error("2E not implemented")
        end, function() -- 2F
            error("2F not implemented")
        end, function() -- 30
            error("30 not implemented")
        end, function() -- 31
            error("31 not implemented")
        end, function() -- 32
            error("32 not implemented")
        end, function() -- 33
            error("33 not implemented")
        end, function() -- 34
            error("34 not implemented")
        end, function() -- 35
            error("35 not implemented")
        end, function() -- 36
            error("36 not implemented")
        end, function() -- 37
            error("37 not implemented")
        end, function() -- 38
            error("38 not implemented")
        end, function() -- 39
            error("39 not implemented")
        end, function() -- 3A
            error("3A not implemented")
        end, function() -- 3B
            error("3B not implemented")
        end, function() -- 3C
            error("3C not implemented")
        end, function() -- 3D
            error("3D not implemented")
        end, function() -- 3E
            error("3E not implemented")
        end, function() -- 3F
            error("3F not implemented")
        end, function() -- 40
            error("40 not implemented")
        end, function() -- 41
            error("41 not implemented")
        end, function() -- 42
            error("42 not implemented")
        end, function() -- 43
            error("43 not implemented")
        end, function() -- 44
            error("44 not implemented")
        end, function() -- 45
            error("45 not implemented")
        end, function() -- 46
            error("46 not implemented")
        end, function() -- 47
            error("47 not implemented")
        end, function() -- 48
            error("48 not implemented")
        end, function() -- 49
            error("49 not implemented")
        end, function() -- 4A
            error("4A not implemented")
        end, function() -- 4B
            error("4B not implemented")
        end, function() -- 4C
            error("4C not implemented")
        end, function() -- 4D
            error("4D not implemented")
        end, function() -- 4E
            error("4E not implemented")
        end, function() -- 4F
            error("4F not implemented")
        end, function() -- 50
            error("50 not implemented")
        end, function() -- 51
            error("51 not implemented")
        end, function() -- 52
            error("52 not implemented")
        end, function() -- 53
            error("53 not implemented")
        end, function() -- 54
            error("54 not implemented")
        end, function() -- 55
            error("55 not implemented")
        end, function() -- 56
            error("56 not implemented")
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