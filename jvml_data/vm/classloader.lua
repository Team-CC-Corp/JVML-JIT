--This will load class files and will register them--
natives = {["java.lang.Object"]={
    ["registerNatives()V"] = function()
        local path = resolvePath("java/lang/native")
        for i,v in ipairs(fs.list(path)) do
            dofile(fs.combine(path, v))
        end
    end
}}

staticMethods = { }

function isPrimitive(value)
    return PRIMITIVE_WRAPPERS[value[1]] ~= nil
end

function wrapPrimitive(value, type)
    local wrapperName = PRIMITIVE_WRAPPERS[type]
    local wrapper = classByName(wrapperName)
    return findMethod(wrapper, "valueOf(" .. type .. ")L" .. (wrapper.name:gsub("%.", "/")) .. ";")[1](value)
end

function toJString(str)
    local stringClass = classByName("java.lang.String")
    local obj = { stringClass, { #str, "C", { } } }
    local charArray = obj[2][3]
    for i = 1, #str do
        charArray[i] = str:sub(i, i):byte()
    end
    findMethod(stringClass, "<init>([C)V")[1](obj, charArray)
    return obj
end

function toLString(str)
    local stringClass = classByName("java.lang.String")
    local strArray = { }
    local charArrayRef = str[2][stringClass.fieldIndexByName["value"]]
    local len = charArrayRef[1]
    local charArray = charArrayRef[3]

    for i = 1, len do
        strArray[i] = string.char(charArray[i])
    end
    return table.concat(strArray)
end

function fieldByName(class, name)
    for i = 1, #class.fields do
        if class.fields[i].name == name then
            return i
        end
    end
end

local function u2ToSignedShort(i)
    if i > 2^15 - 1 then
        return -(2^16 - i)
    end
    return i
end
local function u1ToSignedByte(i)
    if i > 2^7 - 1 then
        return -(2^8 - i)
    end
    return i
end

PRIMITIVE_WRAPPERS = {
    Z = "java.lang.Boolean",
    C = "java.lang.Character",
    F = "java.lang.Float",
    D = "java.lang.Double",
    B = "java.lang.Byte",
    S = "java.lang.Short",
    I = "java.lang.Integer",
    J = "java.lang.Long"
}

ARRAY_TYPES = {
    Z=4,
    C=5,
    F=6,
    D=7,
    B=8,
    S=9,
    I=10,
    J=11
}

do
    local t = {}
    for k,v in pairs(ARRAY_TYPES) do
        t[v] = k
    end
    ARRAY_TYPES = t
end

TYPELOOKUP = {
    Integer=10,
    Float=6,
    Long=11,
    Double=7
}

CONSTANT = {
    Class=7,
    Fieldref=9,
    Methodref=10,
    InterfaceMethodref=11,
    String=8,
    Integer=3,
    Float=4,
    Long=5,
    Double=6,
    NameAndType=12,
    Utf8=1,
    MethodHandle=15,
    MethodType=16,
    InvokeDynamic=18
}

local CONSTANTLOOKUP = {}
for i, v in pairs(CONSTANT) do CONSTANTLOOKUP[v] = i end

local nan = -(0/0)

METHOD_ACC = {
    PUBLIC=0x0001,
    PRIVATE=0x0002,
    PROTECTED=0x0004,
    STATIC=0x0008,
    FINAL=0x0010,
    SYNCHRONIZED=0x0020,
    BRIDGE=0x0040,
    VARARGS=0x0080,
    NATIVE=0x0100,
    ABSTRACT=0x0400,
    STRICT=0x0800,
    SYNTHETIC=0x1000,
}

CLASS_ACC = {
    PUBLIC=0x0001,
    FINAL=0x0010,
    SUPER=0x0020,
    INTERFACE=0x0200,
    ABSTRACT=0x0400,
    SYNTHETIC=0x1000,
    ANNOTATION=0x2000,
    ENUM=0x4000,
}

local debugMode = false
local _pr = print
local function print(...)
    if debugMode then
        _pr(...)
    end
end
local debugH = {}
local _dbf
if debugMode then
    _dbf = fs.open(fs.combine(jcd, 'debug'), 'w')
end
function debugH.write(...)
    if debugMode then
        _dbf.write(...)
    end
end

function debugH.flush(...)
    if debugMode then
        _dbf.flush(...)
    end
end

function loadJavaClass(file)
    if not fs.exists(file) then return false end
    local fh = fs.open(file,"rb")
    local cn
    local cp = {}
    local i = 0
    
    local u1 = fh.read--function() i=i+1 print("at ",i-1) return fh.read() end
    local function u2()
        return bit.blshift(u1(),8) + u1()
    end
    
    local function u4()
        return bit.blshift(u1(),24) + bit.blshift(u1(),16) + bit.blshift(u1(),8) + u1()
    end

    local function isIndirectEqual(typed, superd)
        local i = 1
        while true do
            local typec = typed:sub(i, i)
            local superc = superd:sub(i, i)

            if typec == "[" then
                if superc ~= "[" then
                    return false
                end
                i = i + 1
            elseif typec == "L" then
                if superc ~= "L" then
                    return false
                end
                local typeName = typed:sub(i + 1, -2):gsub("/", ".")
                local superName = superd:sub(i + 1, -2):gsub("/", ".")
                local type = classByName(typeName)
                local super = classByName(superName)
                local class = type
                while class do
                    if class == super then
                        return true
                    end
                    class = class.super
                end
                return false
            else
                -- TEST
                --[[if superc == "L" and superd:sub(i) == "Ljava/lang/Object;" then
                    return true
                end

                if typed == "B" or typed == "C" or typed == "S" then
                    return true
                end
                return typec == superc]]
                return true
            end
        end
    end

    local function parse_descriptor(desc,descriptor)
        --parse descriptor
        local i = 1
        local cur = {}
        cur.array_depth = 0 -- not an array
        while i <= #descriptor do
            local c = descriptor:sub(i,i)
            if c == "(" or c == ")" then
                --arglst start
            else
                if c == "[" then
                    cur.array_depth = cur.array_depth + 1 -- one deeper for each dimension
                elseif c == "L" then
                    --im guessing ref or something
                    cur.type = "L"
                    i = i+1
                    c = descriptor:sub(i,i)
                    while c ~= ";" and c do
                        cur.type = cur.type..c
                        i = i+1
                        c = descriptor:sub(i,i)
                    end
                    table.insert(desc,cur)
                    cur = {}
                    cur.array_depth = 0
                else
                    cur.type = c
                    table.insert(desc,cur)
                    cur = {}
                    cur.array_depth = 0
                end
            end
            i = i+1
        end
    end
    
    local function cp_class_info(c)
        c.name_index = u2() --name index
    end

    local function cp_ref_info(c)
        c.class_index = u2()
        c.name_and_type_index = u2()
    end

    local function cp_string_info(c)
        c.string_index= u2()
    end

    local function cp_intfloat_info(c)
        c.bytes = u4()
    end

    local function cp_longdouble_info(c)
        c.high_bytes = u4()
        c.low_bytes = u4()
    end

    local function cp_nameandtype_info(c)
        c.name_index = u2()
        c.descriptor_index = u2()
    end

    local function cp_utf8_info(c)
        c.length = u2()
        c.bytes = ""
        for i=1, c.length do
            c.bytes = c.bytes..string.char(u1()) --UTF8? Fuck that!
        end
    end

    local function cp_methodhandle_info(c)
        c.reference_kind = u1()
        c.reference_index = u2()
    end

    local function cp_methodtype_info(c)
        c.descriptor_index = u2()
    end

    local function cp_invokedynamic_info(c)
        c.bootstrap_method_attr_index = u2()
        c.name_and_type_index = u2()
    end

    local function parse_float(bits)
        if bits == 0x7f800000 then
            return math.huge
        elseif bits == 0xff800000 then
            return -math.huge
        elseif bits >= 0x7f800001 and bits <= 0x7fffffff and bits >= 0xff800001 and bits <= 0xffffffff then
            return nan
        else
            local s = (bit.brshift(bits, 31) == 0) and 1 or -1;
            local e = bit.band(bit.brshift(bits, 23), 0xff);
            local m = (e == 0) and
                      bit.blshift(bit.band(bits, 0x7fffff), 1) or
                      bit.band(bits, 0x7fffff) + 0x800000
            return s*m*(2^(e-150))
        end
    end

    local function parse_long(high_bytes,low_bytes)
        return { high_bytes, low_bytes }
    end

    local function parse_double(high_bytes,low_bytes)
        local x = ""
        x = x..string.char(bit.band(low_bytes,0xFF))
        x = x..string.char(bit.band(bit.brshift(low_bytes,8),0xFF))
        x = x..string.char(bit.band(bit.brshift(low_bytes,16),0xFF))
        x = x..string.char(bit.band(bit.brshift(low_bytes,24),0xFF))

        x = x..string.char(bit.band(high_bytes,0xFF))
        x = x..string.char(bit.band(bit.brshift(high_bytes,8),0xFF))
        x = x..string.char(bit.band(bit.brshift(high_bytes,16),0xFF))
        x = x..string.char(bit.band(bit.brshift(high_bytes,24),0xFF))
        --x = string.reverse(x)
        local sign = 1
        local mantissa = string.byte(x, 7) % 16
        for i = 6, 1, -1 do mantissa = mantissa * 256 + string.byte(x, i) end
        if string.byte(x, 8) > 127 then sign = -1 end
        local exponent = (string.byte(x, 8) % 128) * 16 +math.floor(string.byte(x, 7) / 16)
        if exponent == 0 then return 0 end
        mantissa = (math.ldexp(mantissa, -52) + 1) * sign
        return math.ldexp(mantissa, exponent - 1023)
    end

    local function cp_entry(ei)
        local c = {}
        c.tag = u1()
        c.cl = ARRAY_TYPES[TYPELOOKUP[CONSTANTLOOKUP[c.tag]]] or CONSTANTLOOKUP[c.tag]
        local ct = c.tag
        if ct == CONSTANT.Class then
            cp_class_info(c)
        elseif ct == CONSTANT.Fieldref or ct == CONSTANT.Methodref or ct == CONSTANT.InterfaceMethodref then
            cp_ref_info(c)
        elseif ct == CONSTANT.String then
            cp_string_info(c)
        elseif ct == CONSTANT.Integer then
            cp_intfloat_info(c)
        elseif ct == CONSTANT.Float then
            cp_intfloat_info(c)
            c.bytes = parse_float(c.bytes)
        elseif ct == CONSTANT.Long then
            print("warning: longs are not supported")
            cp_longdouble_info(c)
            c.bytes = parse_long(c.high_bytes,c.low_bytes)
        elseif ct == CONSTANT.Double then
            cp_longdouble_info(c)
            c.bytes = parse_double(c.high_bytes,c.low_bytes)
        elseif ct == CONSTANT.NameAndType then
            cp_nameandtype_info(c)
        elseif ct == CONSTANT.Utf8 then
            cp_utf8_info(c)
        elseif ct == CONSTANT.MethodHandle then
            cp_methodhandle_info(c)
        elseif ct == CONSTANT.MethodType then
            cp_methodtype_info(c)
        elseif ct == CONSTANT.InvokeDynamic then
            cp_invokedynamic_info(c)
        else
            error("Mindfuck in ConstantPool: "..ct)
        end
        return c
    end

    local function attribute()
        local attrib = {}
        attrib.attribute_name_index = u2()
        attrib.attribute_length = u4()
        attrib.name = cp[attrib.attribute_name_index].bytes
        local an = attrib.name
        if an == "ConstantValue" then
            attrib.constantvalue_index = u2()
        elseif an == "Code" then
            attrib.max_stack = u2()
            attrib.max_locals = u2()
            attrib.code_length = u4()
            attrib.code = {}
            for i=0, attrib.code_length-1 do
                attrib.code[i] = u1()
            end
            attrib.exception_table_length = u2()
            attrib.exception_table = {}
            for i=0, attrib.exception_table_length-1 do
                attrib.exception_table[i] = {
                    start_pc = u2(),
                    end_pc = u2(),
                    handler_pc = u2(),
                    catch_type = u2()
                }
            end
            attrib.attributes_count = u2()
            attrib.attributes = {}
            for i=0, attrib.attributes_count-1 do
                attrib.attributes[i] = attribute()
            end
        elseif an == "Exceptions" then
            attrib.number_of_exceptions = u2()
            attrib.exception_index_table = {}
            for i=0, attrib.number_of_exceptions-1 do
                attrib.exception_index_table[i] = u2()
            end
        elseif an == "InnerClasses" then
            attrib.number_of_classes = u2()
            attrib.classes = {}
            for i=0, attrib.number_of_classes-1 do
                attrib.classes[i] = {
                    inner_class_info_index = u2(),
                    outer_class_info_index = u2(),
                    inner_name_index = u2(),
                    inner_class_access_flags = u2()
                }
            end
        elseif an == "EnclosingMethod" then
            attrib.class_index = u2()
            attrib.method_index = u2()
        elseif an == "Synthetic" then
            error("Fuck that, Synthetic attributes are not supported",0)
        elseif an == "Signature" then
            attrib.signature_index = u2()
        elseif an == "SourceDebugExtension" then
            error("SourceDebugExtension? LELHUEHUEHUELELELELELHUE",0)
        elseif an == "LineNumberTable" then
            attrib.line_number_table_length = u2()
            attrib.line_number_table = {}
            for i=0, attrib.line_number_table_length-1 do
                attrib.line_number_table[i] = {
                    start_pc = u2(),
                    line_number = u2()
                }
            end
        elseif an == "LocalVariableTable" then
            attrib.local_variable_table_length = u2()
            attrib.local_variable_table = {}
            for i=0, attrib.local_variable_table_length-1 do
                attrib.local_variable_table[i] = {
                    start_pc = u2(),
                    length = u2(),
                    name_index = u2(),
                    descriptor_index = u2(),
                    index = u2()
                }
            end
        elseif an == "LocalVariableTypeTable" then
            error("LVTT is so mainstream",0)
        elseif an == "Deprecated" then
            --lel, this doesn't have content in it--
        elseif an == "SourceFile" then
            attrib.source_file_index = u2()
        else
            --print("Unhandled Attrib: "..an)
            attrib.bytes = {}
            for i=1, attrib.attribute_length do
                attrib.bytes[i] = u1()
            end
        end
        return attrib
    end

    local function field_info()
        local field = {
            access_flags = u2(),
            name = cp[u2()].bytes,
            descriptor = cp[u2()].bytes,
            attributes_count = u2(),
            attributes = {}
        }
        for i=0, field.attributes_count-1 do
            field.attributes[i] = attribute()
        end
        return field
    end

    local function resolveClass(c)
        local cn = cp[c.name_index].bytes:gsub("/",".")
        return classByName(cn)
    end

    local function createCodeFunction(class, method, codeAttr, name)
        local code = codeAttr.code
        local asm = { }

        local asmPC = 1
        local function emit(str, ...)
            local _, err = pcall(function(...)
                asmPC = asmPC + 1
                asm[#asm + 1] = string.format(str, ...) .. "\n"
            end, ...)
            if err then
                error("asd", 2)
            end
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

        local function peek(n)
            return reg - n
        end

        local rti = { }
        local reverseRTI = { }
        local function info(obj)
            local i = reverseRTI[obj]
            if i then
                return i
            end
            local p = #rti + 1
            rti[p] = obj
            reverseRTI[obj] = p
            return p
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

        local function asmGetRTInfo(r, i)
            emit("gettable %i 0 k(%i) ", r, i)
        end

        local function asmNewInstance(robj, class)
            local rclass, rfields = alloc(2)
            asmGetRTInfo(rclass, info(class))
            emit("newtable %i 2 0", robj)
            emit("newtable %i %i 0", rfields, #class.fields)
            emit("settable %i k(1) %i", robj, rclass)
            emit("settable %i k(2) %i", robj, rfields)
            free(2)
        end

        local function asmPrintReg(r)
            local rprint, rparam = alloc(2)
            emit("getglobal %i 'print'", rprint)
            emit("move %i %i", rparam, r)
            emit("call %i 2 1", rprint)
            free(2)
        end

        local function asmPrintString(str)
            local rprint, rparam = alloc(2)
            emit("getglobal %i 'print'", rprint)
            emit("loadk %i '%s'", rparam, str)
            emit("call %i 2 1", rprint)
            free(2)
        end

        -- Expects method at register rmt followed by args.
        -- Result is stored in rmt + 1.
        local function asmInvokeMethod(rmt, argslen, results)
            emit("gettable %i %i k(1)", rmt, rmt)
            emit("call %i %i %i", rmt, argslen + 1, results + 1)
        end

        local function asmRun(func)
            local rfunc = alloc()
            asmGetRTInfo(rfunc, info(func))
            emit("call %i %i %i", rfunc, 1, 1)
            free()
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
                emit("newtable %i 2 0", r)          -- r = { nil, nil }
                emit("settable %i k(1) k(0)", r)    -- r[1] = 0
                emit("settable %i k(2) k(0)", r)    -- r[2] = 0
            end, function() -- 0A
                local r = alloc()
                emit("newtable %i 2 0", r)          -- r = { nil, nil }
                emit("settable %i k(1) k(0)", r)    -- r[1] = 0
                emit("settable %i k(2) k(1)", r)    -- r[2] = 1
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
                else
                    local stringClass = classByName("java.lang.String")
                    local str = cp[s.string_index].bytes
                    local rmt, robj, rcharref, rchars = alloc(4)
                    asmGetRTInfo(rmt, info(findMethod(stringClass, "<init>([C)V")))
                    asmNewInstance(robj, stringClass)

                    -- Create the char array ref. Holds array length, primitive type, and the actual array.
                    emit("newtable %i 3 0", rcharref)
                    emit("settable %i k(1) k(%i)", rcharref, #str)
                    emit("settable %i k(2) '%s'", rcharref, "C")

                    -- Create the array and save it in the ref.
                    emit("newtable %i 0 0", rchars)
                    emit("settable %i k(3) %i", rcharref, rchars)

                    -- TODO: Don't use an unrolled loop for very large strings.
                    -- Fill the char array.
                    for i = 1, #str do
                        emit("settable %i k(%i) k(%i)", rchars, i, str:sub(i, i):byte())
                    end

                    -- Invoke java.lang.String constructor.
                    -- Current stack: rmt, robj, rcharref
                    asmInvokeMethod(rmt, 2, 0)

                    -- Need to move the object back in place. Overwrite rmt.
                    emit("move %i %i", rmt, robj)

                    free(3)
                end
            end, function() -- 13
                --ldc_w
                --push constant
                local s = cp[u2()]
                if s.bytes then
                    emit("loadk %i k(%s)", alloc(), s.bytes)
                else
                    local stringClass = classByName("java.lang.String")
                    local str = cp[s.string_index].bytes
                    local rmt, robj, rcharref, rchars = alloc(4)
                    asmGetRTInfo(rmt, info(findMethod(stringClass, "<init>([C)V")))
                    asmNewInstance(robj, stringClass)

                    -- Create the char array ref. Holds array length, primitive type, and the actual array.
                    emit("newtable %i 3 0", rcharref)
                    emit("settable %i k(1) k(%i)", rcharref, #str)
                    emit("settable %i k(2) '%s'", rcharref, "C")

                    -- Create the array and save it in the ref.
                    emit("newtable %i 0 0", rchars)
                    emit("settable %i k(3) %i", rcharref, rchars)

                    -- TODO: Don't use an unrolled loop for very large strings.
                    -- Fill the char array.
                    for i = 1, #str do
                        emit("settable %i k(%i) k(%i)", rchars, i, str:sub(i, i):byte())
                    end

                    -- Invoke java.lang.String constructor.
                    -- Current stack: rmt, robj, rcharref
                    asmInvokeMethod(rmt, 2, 0)

                    -- Need to move the object back in place. Overwrite rmt.
                    emit("move %i %i", rmt, robj)

                    free(3)
                end
            end, function() -- 14
                --ldc2_w
                --push constant
                local s = cp[u2()]
                if s.cl == "D" then
                    emit("loadk %i k(%f)", alloc(), s.bytes)
                elseif s.cl == "J" then
                    print(s.bytes)
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
                --aaload
                local rarr = peek(1)
                local ri = peek(0)
                emit("add %i %i k(1)", ri, ri)
                emit("gettable %i %i k(3)", rarr, rarr)
                emit("gettable %i %i %i", rarr, rarr, ri)
                free()
            end, function() -- 2F
                --aaload
                local rarr = peek(1)
                local ri = peek(0)
                emit("add %i %i k(1)", ri, ri)
                emit("gettable %i %i k(3)", rarr, rarr)
                emit("gettable %i %i %i", rarr, rarr, ri)
                free()
            end, function() -- 30
                --aaload
                local rarr = peek(1)
                local ri = peek(0)
                emit("add %i %i k(1)", ri, ri)
                emit("gettable %i %i k(3)", rarr, rarr)
                emit("gettable %i %i %i", rarr, rarr, ri)
                free()
            end, function() -- 31
                --aaload
                local rarr = peek(1)
                local ri = peek(0)
                emit("add %i %i k(1)", ri, ri)
                emit("gettable %i %i k(3)", rarr, rarr)
                emit("gettable %i %i %i", rarr, rarr, ri)
                free()
            end, function() -- 32
                --aaload
                local rarr = peek(1)
                local ri = peek(0)
                emit("add %i %i k(1)", ri, ri)
                emit("gettable %i %i k(3)", rarr, rarr)
                emit("gettable %i %i %i", rarr, rarr, ri)
                free()
            end, function() -- 33
                --aaload
                local rarr = peek(1)
                local ri = peek(0)
                emit("add %i %i k(1)", ri, ri)
                emit("gettable %i %i k(3)", rarr, rarr)
                emit("gettable %i %i %i", rarr, rarr, ri)
                free()
            end, function() -- 34
                --aaload
                -- TODO: Throw IndexOutOfBoundsException if index is >= len.
                local rarr = peek(1)
                local ri = peek(0)
                emit("add %i %i k(1)", ri, ri)
                emit("gettable %i %i k(3)", rarr, rarr)
                emit("gettable %i %i %i", rarr, rarr, ri)
                free()
            end, function() -- 35
                --aaload
                local rarr = peek(1)
                local ri = peek(0)
                emit("add %i %i k(1)", ri, ri)
                emit("gettable %i %i k(3)", rarr, rarr)
                emit("gettable %i %i %i", rarr, rarr, ri)
                free()
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
                local rarr, ri, rval = free(3)
                emit("add %i %i k(1)", ri, ri)
                emit("gettable %i %i k(3)", rarr, rarr)
                emit("settable %i %i %i", rarr, ri, rval)
            end, function() -- 50
                --aastore
                local rarr, ri, rval = free(3)
                emit("add %i %i k(1)", ri, ri)
                emit("gettable %i %i k(3)", rarr, rarr)
                emit("settable %i %i %i", rarr, ri, rval)
            end, function() -- 51
                --aastore
                local rarr, ri, rval = free(3)
                emit("add %i %i k(1)", ri, ri)
                emit("gettable %i %i k(3)", rarr, rarr)
                emit("settable %i %i %i", rarr, ri, rval)
            end, function() -- 52
                --aastore
                local rarr, ri, rval = free(3)
                emit("add %i %i k(1)", ri, ri)
                emit("gettable %i %i k(3)", rarr, rarr)
                emit("settable %i %i %i", rarr, ri, rval)
            end, function() -- 53
                --aastore
                local rarr, ri, rval = free(3)
                --asmPrintReg(rarr - 1)
                --asmPrintReg(ri - 1)
                --asmPrintReg(rval - 1)
                emit("add %i %i k(1)", ri, ri)
                emit("gettable %i %i k(3)", rarr, rarr)
                emit("settable %i %i %i", rarr, ri, rval)
            end, function() -- 54
                --aastore
                local rarr, ri, rval = free(3)
                emit("add %i %i k(1)", ri, ri)
                emit("gettable %i %i k(3)", rarr, rarr)
                emit("settable %i %i %i", rarr, ri, rval)
            end, function() -- 55
                --aastore
                local rarr, ri, rval = free(3)
                emit("add %i %i k(1)", ri, ri)
                emit("gettable %i %i k(3)", rarr, rarr)
                emit("settable %i %i %i", rarr, ri, rval)
            end, function() -- 56
                --aastore
                local rarr, ri, rval = free(3)
                emit("add %i %i k(1)", ri, ri)
                emit("gettable %i %i k(3)", rarr, rarr)
                emit("settable %i %i %i", rarr, ri, rval)
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
                local v = pop()
                push(v)
                table.insert(stack,sp-2,{v[1], v[2]})
                sp = sp+1
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

                -- {high, low} + {high, low}
                local r1 = peek(1)
                local r2 = peek(0)
                local r1h, r1l, r2h, r2l = alloc(4)

                emit("gettable %i %i k(1)", r1h, r1)        -- r1h = r1[1]
                emit("gettable %i %i k(2)", r1l, r1)        -- r1l = r1[2]
                emit("gettable %i %i k(1)", r2h, r2)        -- r2h = r2[1]
                emit("gettable %i %i k(2)", r2l, r2)        -- r2l = r2[2]

                emit("add %i %i %i", r1l, r1l, r2l)         -- r1l = r1l + r2l
                emit("lt 0 %i k(2147483648)", r1l)          -- if r1l >= 2^31 then jmp 2
                emit("jmp 2")

                emit("add %i %i %i", r1h, r1h, r2h)         -- r1h = r1h + r2h
                emit("jmp 2")

                -- overflow
                emit("add %i %i k(1)", r1h, r1h)            -- r1h = r1h + 1
                emit("sub %i %i k(2147483648)", r1l, r1l)   -- r1l = r1l - 2^31

                free(5)

                emit("settable %i k(1) %i", r1, r1h)        -- r1[1] = r1h
                emit("settable %i k(2) %i", r1, r1l)        -- r1[2] = r1l
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
                emit("sub %i %i %i", r1, r1, r2)
                free(1)
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
                emit("mul %i %i %i", r1, r1, r2)
                free(1)
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
                local r1 = peek(1)
                local r2 = peek(0)
                emit("div %i %i %i", r1, r1, r2)
                free(1)
            end, function() -- 6D
                --div
                local r1 = peek(1)
                local r2 = peek(0)
                emit("div %i %i %i", r1, r1, r2)
                free(1)
            end, function() -- 6E
                --div
                local r1 = peek(1)
                local r2 = peek(0)
                emit("div %i %i %i", r1, r1, r2)
                free(1)
            end, function() -- 6F
                --div
                local r1 = peek(1)
                local r2 = peek(0)
                emit("div %i %i %i", r1, r1, r2)
                free(1)
            end, function() -- 70
                --rem
                local r1 = peek(1)
                local r2 = peek(0)
                emit("mod %i %i %i", r1, r1, r2)
                free(1)
            end, function() -- 71
                --rem
                local r1 = peek(1)
                local r2 = peek(0)
                emit("mod %i %i %i", r1, r1, r2)
                free(1)
            end, function() -- 72
                --rem
                local r1 = peek(1)
                local r2 = peek(0)
                emit("mod %i %i %i", r1, r1, r2)
                free(1)
            end, function() -- 73
                --rem
                local r1 = peek(1)
                local r2 = peek(0)
                emit("mod %i %i %i", r1, r1, r2)
                free(1)
            end, function() -- 74
                --neg
                local r1 = peek(0)
                emit("mul %i %i k(-1)", r1, r1)
            end, function() -- 75
                --neg
                local r1 = peek(0)
                emit("mul %i %i k(-1)", r1, r1)
            end, function() -- 76
                --neg
                local r1 = peek(0)
                emit("mul %i %i k(-1)", r1, r1)
            end, function() -- 77
                --neg
                local r1 = peek(0)
                emit("mul %i %i k(-1)", r1, r1)
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
                emit("add %i %i k(%i)", idx, idx, c)
            end, function() -- 85
                --i2l
                --push(asLong(bigInt.toBigInt(pop()[2])))
            end, function() -- 86
                --i2f
                --push(asFloat(pop()[2]))
            end, function() -- 87
                --i2d
                --push(asDouble(pop()[2]))
            end, function() -- 88
                --l2i
                --push(asInt(bigInt.fromBigInt(pop()[2])))
            end, function() -- 89
                --l2f
                --push(asFloat(bigInt.fromBigInt(pop()[2])))
            end, function() -- 8A
                --l2d
                --push(asDouble(bigInt.fromBigInt(pop()[2])))
            end, function() -- 8B
                --f2i
                --push(asInt(math.floor(pop()[2])))
            end, function() -- 8C
                --f2l
                --push(asLong(bigInt.toBigInt(math.floor(pop()[2]))))
            end, function() -- 8D
                --f2d
                --push(asDouble(pop()[2]))
            end, function() -- 8E
                --d2i
                --push(asInt(math.floor(pop()[2])))
            end, function() -- 8F
                --d2l
                --push(asLong(bigInt.toBigInt(math.floor(pop()[2]))))
            end, function() -- 90
                --d2f
                --push(asFloat(pop()[2]))
            end, function() -- 91
                --i2b
                --push(asByte(pop()[2]))
            end, function() -- 92
                --i2c
                --push(asChar(string.char(pop()[2])))
            end, function() -- 93
                --i2s
                --push(asShort(pop()[2]))
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
                emit("eq 1 %i k(0)", free())
                emit("#jmp %i %i", joffset, 1)
            end, function() -- 9A
                --ifne
                local joffset = u2ToSignedShort(u2())
                emit("eq 0 %i k(0)", free())
                emit("#jmp %i %i", joffset, 1)
            end, function() -- 9B
                --iflt
                local joffset = u2ToSignedShort(u2())
                emit("lt 1 %i k(0)", free())
                emit("#jmp %i %i", joffset, 1)
            end, function() -- 9C
                --ifge
                local joffset = u2ToSignedShort(u2())
                emit("lt 0 %i k(0)", free())
                emit("#jmp %i %i", joffset, 1)
            end, function() -- 9D
                --ifgt
                local joffset = u2ToSignedShort(u2())
                emit("le 0 %i k(0)", free())
                emit("#jmp %i %i", joffset, 1)
            end, function() -- 9E
                --ifle
                local joffset = u2ToSignedShort(u2())
                emit("le 1 %i k(0)", free())
                emit("#jmp %i %i", joffset, 1)
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
                --ifle
                local joffset = u2ToSignedShort(u2())
                emit("le 1 %i k(0)", free())
                emit("#jmp %i %i", joffset, 1)
            end, function() -- A6
                --if_icmpeq
                local joffset = u2ToSignedShort(u2())
                emit("eq 1 %i %i", free(2))
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
            end, function() -- AB
            end, function() -- AC
                emit("return %i 2", free())
            end, function() -- AD
                emit("return %i 2", free())
            end, function() -- AE
                emit("return %i 2", free())
            end, function() -- AF
                emit("return %i 2", free())
            end, function() -- B0
                emit("return %i 2", free())
            end, function() -- B1
                emit("return 0 1")
            end, function() -- B2
                --getstatic
                local fr = cp[u2()]
                local cl = resolveClass(cp[fr.class_index])
                local name = cp[cp[fr.name_and_type_index].name_index].bytes
                local fi = cl.fieldIndexByName[name]
                local r = alloc()
                asmGetRTInfo(r, info(cl.fields))
                emit("gettable %i %i k(%i)", r, r, fi)
            end, function() -- B3
                --putstatic
                local fr = cp[u2()]
                local cl = resolveClass(cp[fr.class_index])
                local name = cp[cp[fr.name_and_type_index].name_index].bytes
                local fi = class.fieldIndexByName[name]
                local value = peek(0)
                local r = alloc()
                asmGetRTInfo(r, info(cl.fields))
                emit("settable %i k(%i) %i", r, fi, value)
                free(2)
            end, function() -- B4
                --getfield
                local fr = cp[u2()]
                local name = cp[cp[fr.name_and_type_index].name_index].bytes
                local fi = class.fieldIndexByName[name]
                local r = peek(0)
                emit("gettable %i %i k(2)", r, r)
                emit("gettable %i %i k(%i)", r, r, fi)
            end, function() -- B5
                --putfield
                local fr = cp[u2()]
                local name = cp[cp[fr.name_and_type_index].name_index].bytes
                local fi = class.fieldIndexByName[name]
                local robj = peek(1)
                local rval = peek(0)
                local rfields = alloc()
                emit("gettable %i %i k(2)", rfields, robj)
                emit("settable %i k(%i) %i", rfields, fi, rval)
                free(3)
            end, function() -- B6
                --invokevirtual
                local mr = cp[u2()]
                local cl = resolveClass(cp[mr.class_index])
                local name = cp[cp[mr.name_and_type_index].name_index].bytes .. cp[cp[mr.name_and_type_index].descriptor_index].bytes
                local mt = findMethod(cl, name)
                local argslen = #mt.desc

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
                emit("gettable %i %i k(1)", rmt, rmt)
                emit("call %i %i 2", rmt, argslen + 1)

                if mt.desc[#mt.desc].type ~= "V" then
                    free(argslen)
                else
                    free(argslen + 1)
                end
            end, function() -- B7
                --invokespecial
                local mr = cp[u2()]
                local cl = resolveClass(cp[mr.class_index])
                local name = cp[cp[mr.name_and_type_index].name_index].bytes .. cp[cp[mr.name_and_type_index].descriptor_index].bytes
                local mt = findMethod(cl, name)
                local argslen = #mt.desc

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
                emit("gettable %i %i k(1)", rmt, rmt)
                emit("call %i %i 2", rmt, argslen + 1)

                if mt.desc[#mt.desc].type ~= "V" then
                    free(argslen)
                else
                    free(argslen + 1)
                end
            end, function() -- B8
                --invokestatic
                local mr = cp[u2()]
                local cl = resolveClass(cp[mr.class_index])
                local name = cp[cp[mr.name_and_type_index].name_index].bytes .. cp[cp[mr.name_and_type_index].descriptor_index].bytes
                local mt = findMethod(cl, name)
                print(name)
                local argslen = #mt.desc - 1

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
                emit("gettable %i %i k(1)", rmt, rmt)
                emit("call %i %i 2", rmt, argslen + 1)

                if mt.desc[#mt.desc].type ~= "V" then
                    free(argslen)
                else
                    free(argslen + 1)
                end
            end, function() -- B9
                --invokeinterface
                local mr = cp[u2()]
                u2() -- two dead bytes in invokeinterface
                local cl = resolveClass(cp[mr.class_index])
                local name = cp[cp[mr.name_and_type_index].name_index].bytes .. cp[cp[mr.name_and_type_index].descriptor_index].bytes
                local mt = findMethod(cl, name)
                local argslen = #mt.desc

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
                emit("gettable %i %i k(1)", rmt, rmt)
                emit("call %i %i 2", rmt, argslen + 1)

                free(argslen)
            end, function() -- BA
            end, function() -- BB
                --new
                local cr = cp[u2()]
                local c = resolveClass(cr)
                local robj = alloc()
                asmNewInstance(robj, c)
            end, function() -- BC
                --newarray
                local type = u1()
                local r = peek(0)
                local rlen = alloc()

                -- Length is occupying the space we need to put the new array, so copy it to a new register.
                emit("move %i %i", rlen, r)

                -- Create the array ref. Holds array length, primitive type, and the actual array.
                emit("newtable %i 0 0", r)
                emit("settable %i k(1) %i", r, rlen)
                emit("settable %i k(2) k(%i)", r, type)

                -- Overwrite len with array to save a register and set the array.
                emit("newtable %i 0 0", rlen)
                emit("settable %i k(3) %i", r, rlen)

                free()
            end, function() -- BD
                --anewarray
                local c = resolveClass(cp[u2()])
                local r = peek(0)
                local rn = alloc()

                -- Length is occupying the space we need to put the new array, so copy it to a new register.
                emit("move %i %i", rn, r)

                -- Create the array ref. Holds array length, primitive type, and the actual array.
                emit("newtable %i 0 0", r)
                emit("settable %i k(1) %i", r, rn)
                asmGetRTInfo(rn, info(c))
                emit("settable %i k(2) %i", r, rn)

                -- Create the array.
                emit("newtable %i 0 0", rn)
                emit("settable %i k(3) %i", r, rn)

                free()
            end, function() -- BE
                --arraylength
                local r = peek(0)
                emit("gettable %i %i k(1)", r, r)
            end, function() -- BF
            end, function() -- C0
                local cl = "L"..cp[cp[u2()].name_index].bytes..";"
                -- TODO: Check the cast.
            end, function() -- C1
            end, function() -- C2
            end, function() -- C3
            end, function() -- C4
            end, function() -- C5
            end, function() -- C6
            end, function() -- C7
            end, function() -- C8
            end, function() -- C9
            end, function() -- CA
            end, function() -- CB
            end, function() -- CC
            end, function() -- CD
            end, function() -- CE
            end, function() -- CF
            end, function() -- D0
            end, function() -- D1
            end, function() -- D2
            end, function() -- D3
            end, function() -- D4
            end, function() -- D5
            end, function() -- D6
            end, function() -- D7
            end, function() -- D8
            end, function() -- D9
            end, function() -- DA
            end, function() -- DB
            end, function() -- DC
            end, function() -- DD
            end, function() -- DE
            end, function() -- DF
            end, function() -- E0
            end, function() -- E1
            end, function() -- E2
            end, function() -- E3
            end, function() -- E4
            end, function() -- E5
            end, function() -- E6
            end, function() -- E7
            end, function() -- E8
            end, function() -- E9
            end, function() -- EA
            end, function() -- EB
            end, function() -- EC
            end, function() -- ED
            end, function() -- EE
            end, function() -- EF
            end, function() -- F0
            end, function() -- F1
            end, function() -- F2
            end, function() -- F3
            end, function() -- F4
            end, function() -- F5
            end, function() -- F6
            end, function() -- F7
            end, function() -- F8
            end, function() -- F9
            end, function() -- FA
            end, function() -- FB
            end, function() -- FC
            end, function() -- FD
            end, function() -- FE
            end, function() -- FF
            end
        }
        
        print("Loading: " .. name)
        print("Length: " .. #code)
        print("max_locals: " .. codeAttr.max_locals)

        inst = u1()
        while inst do
            print(string.format("%X", inst))
            pcMapLJ[asmPC] = pc()
            pcMapJL[pc()] = asmPC
            oplookup[inst]()
            inst = u1()
        end

        for i = 1, #asm do
            local inst = asm[i]
            if inst:sub(1, 4) == "#jmp" then
                -- Java offset
                local i1 = inst:find("%s") + 1
                local i2 = inst:find("%s", i1) + 1
                local joffset = tonumber(inst:sub(i1, i2 - 2))
                local jmpLOffset = tonumber(inst:sub(i2, -2))
                -- Java instruction to jump to
                local jpc = pcMapLJ[i - jmpLOffset] + joffset
                -- Lua instruction to jump to
                local lpc = pcMapJL[jpc] -- + jmpLOffset
                -- Lua offset
                local loffset = lpc - i - 1
                --if loffset < 0 then loffset = loffset - 1 end
                --if loffset > 0 then loffset = loffset - 1 end
                asm[i] = "jmp " .. loffset .. "\n"
            end
        end

        debugH.write(name .. "\n")
        debugH.write("Length: " .. (asmPC - 1) .. "\n")
        debugH.write("Locals: " .. codeAttr.max_locals .. "\n")
        for i = 1, #asm do
            if pcMapLJ[i] then
                debugH.write(string.format("%X:\n", code[pcMapLJ[i]]))
            end
            debugH.write(string.format("[%i] %s", i, asm[i]))
        end
        debugH.write("\n")
        debugH.flush()
        --print(table.concat(asm))

        print("Loading and verifying bytecode for " .. name)
        local p = LAT.Lua51.Parser:new()
        local file = p:Parse(".options 0 " .. (codeAttr.max_locals + 1) .. table.concat(asm), "bytecode")
        --file:StripDebugInfo()
        local bc = file:Compile()
        local f = loadstring(bc)
        --print(table.concat(asm))

        return function(...)
            pushStackTrace(name)
            local ret = f(rti, ...)
            popStackTrace()
            return ret
        end
        --popStackTrace()
    end
    
    local function method_info()
        local a,n = u2(),u2()
        local method = {
            acc = a,
            name = cp[n].bytes,
            descriptor = cp[u2()].bytes,
            attributes_count = u2(),
            attributes = {}
        }
        method.attrByName = { }
        for i=0, method.attributes_count-1 do
            method.attributes[i] = attribute()
            method.attrByName[method.attributes[i].name] = method.attributes[i]
        end
        method.desc = {}
        parse_descriptor(method.desc,method.descriptor)
        method.name = method.name..method.descriptor
        return method
    end

    local s, e = pcall(function()
        assert(u1() == 0xCA and u1() == 0xFE and u1() == 0xBA and u1() == 0xBE,"invalid magic header")
        u2()u2()
        local cplen = u2()
        local prev
        for i=1, cplen-1 do
            if prev and (prev.cl == "D" or prev.cl == "J") then
                prev = nil
            else
                cp[i] = cp_entry()
                prev = cp[i]
            end
        end
        local access_flags = u2()
        local this_class = u2()
        local super_class = u2()

        cn = cp[cp[this_class].name_index].bytes:gsub("/",".")
        local super
        if cp[super_class] then -- Object.class won't
            super = cp[cp[super_class].name_index].bytes:gsub("/",".")
        end
        local Class = createClass(super, cn)
        if not Class then
            return false
        end
        Class.constantPool = cp

        --start processing the data
        Class.name = cn
        Class.acc = access_flags
        Class.fieldIndexByName = { }

        local interfaces_count = u2()
        Class.interfaces = {}
        for i=0, interfaces_count-1 do
            Class.interfaces[i] = u2()
        end
        local fields_count = u2()
        for i=0, fields_count-1 do
            Class.fields[i] = field_info()
            Class.fieldIndexByName[Class.fields[i].name] = i
        end
        local methods_count = u2()
        local initialCount = #Class.methods
        local subtractor = 0
        local doAfter = { }
        for index=1, methods_count do
            local i = index + initialCount - subtractor

            local m = method_info()
            for i2,v in ipairs(Class.methods) do
                --print(v.name)
                if v.name == m.name then
                    i = i2
                    subtractor = subtractor + 1
                end
            end

            Class.methods[i] = m
            --find code attrib
            local ca
            for _, v in pairs(m.attributes) do
                --print(v.name)
                if v.code then ca = v end
            end

            local mt_name = Class.name.."."..m.name

            table.insert(doAfter, function()
                if ca then
                    m[1] = createCodeFunction(Class, m, ca, mt_name)
                elseif bit.band(m.acc,METHOD_ACC.NATIVE) == METHOD_ACC.NATIVE then
                    if not natives[cn] then natives[cn] = {} end
                    m[1] = function(...)
                        pushStackTrace(mt_name, function() error('',0) end)
                        if not natives[cn][m.name] then
                            error("Native not implemented: " .. Class.name .. "." .. m.name, 0)
                        end
                        local ret = natives[cn][m.name](...)
                        popStackTrace()
                        return ret
                    end
                else
                    --print(m.name," doesn't have code")
                end
            end)
        end

        for i, v in pairs(doAfter) do
            v()
        end

        local attrib_count = u2()
        Class.attributes = {}
        for i=0, attrib_count-1 do
            Class.attributes[i] = attribute()
        end

        local staticmr = findMethod(Class, "<clinit>()V")[1]
        staticMethods[#staticMethods + 1] = staticmr
    end)

    fh.close()
    if not s then error(e,0) end
    return cn
end