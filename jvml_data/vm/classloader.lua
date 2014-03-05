--This will load class files and will register them--
natives = {["java.lang.Object"]={
    ["registerNatives()V"] = function()
        local path = resolvePath("java/lang/native")
        for i,v in ipairs(fs.list(path)) do
            dofile(fs.combine(path, v))
        end
    end
}}
os.loadAPI(fs.combine(jcd, "jvml_data/vm/bigInt"))

function asInt(d)
    return {"I", d}
end
function asFloat(d)
    return {"F", d}
end
function asDouble(d)
    return {"D", d}
end
function asLong(d)
    return {"J", d}
end
function asBoolean(d)
    return {"Z", d}
end
function asChar(d)
    return {"C", d}
end
function asByte(d)
    return {"B", d}
end
function asShort(d)
    return {"S", d}
end
function asObjRef(d, type)
    return {type, d}
end

function isPrimitive(value)
    return PRIMITIVE_WRAPPERS[value[1]] ~= nil
end

function wrapPrimitive(value)
    local wrapperName = PRIMITIVE_WRAPPERS[value[1]]
    if wrapperName then
        local wrapper = classByName(wrapperName)
        return findMethod(wrapper, "valueOf(" .. value[1] .. ")L" .. (wrapper.name:gsub("%.", "/")) .. ";")[1](value)
    end
end

function toJString(str)
    local obj = newInstance(classByName("java.lang.String"))
    local charArray = { }
    charArray.length = #str
    for i = 0, #str - 1 do
        charArray[i] = asChar(str:sub(i + 1, i + 1):byte())
    end
    local ref = asObjRef(obj, "Ljava/lang/String;")
    findMethod(obj, "<init>([C)V")[1](ref, asObjRef(charArray, "[C"))
    return ref
end

function toLString(str)
    local strArray = { }
    local charArray = str[2].fields.value.value

    for i = 1, charArray.length do
        strArray[i] = string.char(charArray[i - 1][2])
    end
    return table.concat(strArray)
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
                    cur[1] = "L"
                    i = i+1
                    c = descriptor:sub(i,i)
                    while c ~= ";" and c do
                        cur[1] = cur[1]..c
                        i = i+1
                        c = descriptor:sub(i,i)
                    end
                    table.insert(desc,cur)
                    cur = {}
                    cur.array_depth = 0
                else
                    cur[1] = c
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
        return bigInt.add(bigInt.brshift(high_bytes,32),low_bytes)
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
            print("Mindfuck in ConstantPool: "..ct)
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
            error("LVT is so mainstream",0)
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


    local function createCodeFunction(code, name)
        return function(...)
            pushStackTrace(name)

            local stack = {}
            local lvars = {}
            for i,v in ipairs({...}) do
                lvars[i - 1] = v
            end
            local sp = 1
            local function push(i)
                --print(i)
                stack[sp] = i
                sp = sp+1
            end
            local function pop()
                sp = sp-1
                return stack[sp]
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
            local function u2()
                return bit.blshift(u1(),8) + u1()
            end

            local inst
            local mustRet = false

            local oplookup = {
                function()      -- 01
                    --null
                    push(nil)
                end, function() -- 02
                    push(asInt(-1))
                end, function() -- 03
                    push(asInt(0))
                end, function() -- 04
                    push(asInt(1))
                end, function() -- 05
                    push(asInt(2))
                end, function() -- 06
                    push(asInt(3))
                end, function() -- 07
                    push(asInt(4))
                end, function() -- 08
                    push(asInt(5))
                end, function() -- 09
                    push(asLong(bigInt.toBigInt(0)))
                end, function() -- 0A
                    push(asLong(bigInt.toBigInt(1)))
                end, function() -- 0B
                    push(asFloat(0))
                end, function() -- 0C
                    push(asFloat(1))
                end, function() -- 0D
                    push(asFloat(2))
                end, function() -- 0E
                    push(asDouble(0))
                end, function() -- 0F
                    push(asDouble(1))
                end, function() -- 10
                    --push imm byte
                    push(asInt(u1()))
                end, function() -- 11
                    --push imm short
                    push(asInt(u2()))
                end, function() -- 12
                    --ldc
                    --push constant
                    local s = cp[u1()]
                    if s.bytes then
                        push({s.cl, s.bytes})
                    else
                        local str = cp[s.string_index].bytes
                        local obj = newInstance(classByName("java.lang.String"))
                        local charArray = { }
                        charArray.length = #str
                        for i = 0, #str - 1 do
                            charArray[i] = asChar(str:sub(i + 1, i + 1):byte())
                        end
                        local ref = asObjRef(obj, "Ljava/lang/String;")
                        findMethod(obj, "<init>([C)V")[1](ref, asObjRef(charArray, "[C"))
                        push(ref)
                    end
                end, function() -- 13
                    --ldc_w
                    --push constant
                    local s = cp[u2()]
                    if s.bytes then
                        push({s.cl:lower(), s.bytes})
                    else
                        local str = cp[s.string_index].bytes
                        local obj = newInstance(classByName("java.lang.String"))
                        local charArray = { }
                        charArray.length = #str
                        for i = 0, #str - 1 do
                            charArray[i] = asChar(str:sub(i + 1, i + 1):byte())
                        end
                        local ref = asObjRef(obj, "Ljava/lang/String;")
                        findMethod(obj, "<init>([C)V")[1](ref, asObjRef(charArray, "[C"))
                        push(ref)
                    end
                end, function() -- 14
                    --ldc2_w
                    --push constant
                    local s = cp[u2()]
                    push({s.cl:lower(), s.bytes})
                end, function() -- 15
                    --loads
                    push(lvars[u1()])
                end, function() -- 16
                    --loads
                    push(lvars[u1()])
                end, function() -- 17
                    --loads
                    push(lvars[u1()])
                end, function() -- 18
                    --loads
                    push(lvars[u1()])
                end, function() -- 19
                    --loads
                    push(lvars[u1()])
                end, function() -- 1A
                    --load_0
                    push(lvars[0])
                end, function() -- 1B
                    --load_1
                    push(lvars[1])
                end, function() -- 1C
                    --load_2
                    push(lvars[2])
                end, function() -- 1D
                    --load_3
                    push(lvars[3])
                end, function() -- 1E
                    --load_0
                    push(lvars[0])
                end, function() -- 1F
                    --load_1
                    push(lvars[1])
                end, function() -- 20
                    --load_2
                    push(lvars[2])
                end, function() -- 21
                    --load_3
                    push(lvars[3])
                end, function() -- 22
                    --load_0
                    push(lvars[0])
                end, function() -- 23
                    --load_1
                    push(lvars[1])
                end, function() -- 24
                    --load_2
                    push(lvars[2])
                end, function() -- 25
                    --load_3
                    push(lvars[3])
                end, function() -- 26
                    --load_0
                    push(lvars[0])
                end, function() -- 27
                    --load_1
                    push(lvars[1])
                end, function() -- 28
                    --load_2
                    push(lvars[2])
                end, function() -- 29
                    --load_3
                    push(lvars[3])
                end, function() -- 2A
                    --load_0
                    push(lvars[0])
                end, function() -- 2B
                    --load_1
                    push(lvars[1])
                end, function() -- 2C
                    --load_2
                    push(lvars[2])
                end, function() -- 2D
                    --load_3
                    push(lvars[3])
                end, function() -- 2E
                    --aaload
                    local i, arr = pop(), pop()
                    if i[2] >= arr[2].length then
                        error("Index out of bounds", 0)
                    end
                    local value = arr[2][i[2]]
                    push(value)
                end, function() -- 2F
                    --aaload
                    local i, arr = pop(), pop()
                    if i[2] >= arr[2].length then
                        error("Index out of bounds", 0)
                    end
                    local value = arr[2][i[2]]
                    push(value)
                end, function() -- 30
                    --aaload
                    local i, arr = pop(), pop()
                    if i[2] >= arr[2].length then
                        error("Index out of bounds", 0)
                    end
                    local value = arr[2][i[2]]
                    push(value)
                end, function() -- 31
                    --aaload
                    local i, arr = pop(), pop()
                    if i[2] >= arr[2].length then
                        error("Index out of bounds", 0)
                    end
                    local value = arr[2][i[2]]
                    push(value)
                end, function() -- 32
                    --aaload
                    local i, arr = pop(), pop()
                    if i[2] >= arr[2].length then
                        error("Index out of bounds", 0)
                    end
                    local value = arr[2][i[2]]
                    push(value)
                end, function() -- 33
                    --aaload
                    local i, arr = pop(), pop()
                    if i[2] >= arr[2].length then
                        error("Index out of bounds", 0)
                    end
                    local value = arr[2][i[2]]
                    push(value)
                end, function() -- 34
                    --aaload
                    local i, arr = pop(), pop()
                    if i[2] >= arr[2].length then
                        error("Index out of bounds", 0)
                    end
                    local value = arr[2][i[2]]
                    push(value)
                end, function() -- 35
                    --aaload
                    local i, arr = pop(), pop()
                    if i[2] >= arr[2].length then
                        error("Index out of bounds", 0)
                    end
                    local value = arr[2][i[2]]
                    push(value)
                end, function() -- 36
                    --stores
                    lvars[u1()] = pop()
                end, function() -- 37
                    --stores
                    lvars[u1()] = pop()
                end, function() -- 38
                    --stores
                    lvars[u1()] = pop()
                end, function() -- 39
                    --stores
                    lvars[u1()] = pop()
                end, function() -- 3A
                    --stores
                    lvars[u1()] = pop()
                end, function() -- 3B
                    lvars[0] = pop()
                end, function() -- 3C
                    lvars[1] = pop()
                end, function() -- 3D
                    lvars[2] = pop()
                end, function() -- 3E
                    lvars[3] = pop()
                end, function() -- 3F
                    lvars[0] = pop()
                end, function() -- 40
                    lvars[1] = pop()
                end, function() -- 41
                    lvars[2] = pop()
                end, function() -- 42
                    lvars[3] = pop()
                end, function() -- 43
                    lvars[0] = pop()
                end, function() -- 44
                    lvars[1] = pop()
                end, function() -- 45
                    lvars[2] = pop()
                end, function() -- 46
                    lvars[3] = pop()
                end, function() -- 47
                    lvars[0] = pop()
                end, function() -- 48
                    lvars[1] = pop()
                end, function() -- 49
                    lvars[2] = pop()
                end, function() -- 4A
                    lvars[3] = pop()
                end, function() -- 4B
                    lvars[0] = pop()
                end, function() -- 4C
                    lvars[1] = pop()
                end, function() -- 4D
                    lvars[2] = pop()
                end, function() -- 4E
                    lvars[3] = pop()
                end, function() -- 4F
                    --aastore
                    local v,i,t = pop(),pop(),pop()
                    if not isIndirectEqual(v[1], t[1]:sub(2)) then
                        error("Type mismatch in array assignment: " .. v[1] .. " -> " .. t[1], 0)
                    end
                    if i[2] >= t[2].length then
                        error("Index out of bounds", 0)
                    end
                    t[2][i[2]] = v
                end, function() -- 50
                    --aastore
                    local v,i,t = pop(),pop(),pop()
                    if not isIndirectEqual(v[1], t[1]:sub(2)) then
                        error("Type mismatch in array assignment: " .. v[1] .. " -> " .. t[1], 0)
                    end
                    if i[2] >= t[2].length then
                        error("Index out of bounds", 0)
                    end
                    t[2][i[2]] = v
                end, function() -- 51
                    --aastore
                    local v,i,t = pop(),pop(),pop()
                    if not isIndirectEqual(v[1], t[1]:sub(2)) then
                        error("Type mismatch in array assignment: " .. v[1] .. " -> " .. t[1], 0)
                    end
                    if i[2] >= t[2].length then
                        error("Index out of bounds", 0)
                    end
                    t[2][i[2]] = v
                end, function() -- 52
                    --aastore
                    local v,i,t = pop(),pop(),pop()
                    if not isIndirectEqual(v[1], t[1]:sub(2)) then
                        error("Type mismatch in array assignment: " .. v[1] .. " -> " .. t[1], 0)
                    end
                    if i[2] >= t[2].length then
                        error("Index out of bounds", 0)
                    end
                    t[2][i[2]] = v
                end, function() -- 53
                    --aastore
                    local v,i,t = pop(),pop(),pop()
                    if not isIndirectEqual(v[1], t[1]:sub(2)) then
                        error("Type mismatch in array assignment: " .. v[1] .. " -> " .. t[1], 0)
                    end
                    if i[2] >= t[2].length then
                        error("Index out of bounds", 0)
                    end
                    t[2][i[2]] = v
                end, function() -- 54
                    --aastore
                    local v,i,t = pop(),pop(),pop()
                    if not isIndirectEqual(v[1], t[1]:sub(2)) then
                        error("Type mismatch in array assignment: " .. v[1] .. " -> " .. t[1], 0)
                    end
                    if i[2] >= t[2].length then
                        error("Index out of bounds", 0)
                    end
                    t[2][i[2]] = v
                end, function() -- 55
                    --aastore
                    local v,i,t = pop(),pop(),pop()
                    if not isIndirectEqual(v[1], t[1]:sub(2)) then
                        error("Type mismatch in array assignment: " .. v[1] .. " -> " .. t[1], 0)
                    end
                    if i[2] >= t[2].length then
                        error("Index out of bounds", 0)
                    end
                    t[2][i[2]] = v
                end, function() -- 56
                    --aastore
                    local v,i,t = pop(),pop(),pop()
                    if not isIndirectEqual(v[1], t[1]:sub(2)) then
                        error("Type mismatch in array assignment: " .. v[1] .. " -> " .. t[1], 0)
                    end
                    if i[2] >= t[2].length then
                        error("Index out of bounds", 0)
                    end
                    t[2][i[2]] = v
                end, function() -- 57
                    pop()
                end, function() -- 58
                    local pv = pop()
                    if pv[1] ~= "D" and pv[1] ~= "J" then
                        pop()
                    end
                end, function() -- 59
                    local v = pop()
                    push(v)
                    push({v[1], v[2]})
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
                    local b, a = pop(), pop()
                    push({a[1], a[2]+b[2]})
                end, function() -- 61
                    --add
                    local b, a = pop(), pop()
                    push({a[1], a[2]+b[2]})
                end, function() -- 62
                    --add
                    local b, a = pop(), pop()
                    push({a[1], a[2]+b[2]})
                end, function() -- 63
                    --add
                    local b, a = pop(), pop()
                    push({a[1], a[2]+b[2]})
                end, function() -- 64
                    --sub
                    local b, a = pop(), pop()
                    push({a[1], a[2]-b[2]})
                end, function() -- 65
                    --sub
                    local b, a = pop(), pop()
                    push({a[1], a[2]-b[2]})
                end, function() -- 66
                    --sub
                    local b, a = pop(), pop()
                    push({a[1], a[2]-b[2]})
                end, function() -- 67
                    --sub
                    local b, a = pop(), pop()
                    push({a[1], a[2]-b[2]})
                end, function() -- 68
                    --mul
                    local b, a = pop(), pop()
                    push({a[1], a[2]*b[2]})
                end, function() -- 69
                    --mul
                    local b, a = pop(), pop()
                    push({a[1], a[2]*b[2]})
                end, function() -- 6A
                    --mul
                    local b, a = pop(), pop()
                    push({a[1], a[2]*b[2]})
                end, function() -- 6B
                    --mul
                    local b, a = pop(), pop()
                    push({a[1], a[2]*b[2]})
                end, function() -- 6C
                    --div
                    local b, a = pop(), pop()
                    push({a[1], a[2]/b[2]})
                end, function() -- 6D
                    --div
                    local b, a = pop(), pop()
                    push({a[1], a[2]/b[2]})
                end, function() -- 6E
                    --div
                    local b, a = pop(), pop()
                    push({a[1], a[2]/b[2]})
                end, function() -- 6F
                    --div
                    local b, a = pop(), pop()
                    push({a[1], a[2]/b[2]})
                end, function() -- 70
                    --rem
                    local b, a = pop(), pop()
                    push({a[1], a[2]%b[2]})
                end, function() -- 71
                    --rem
                    local b, a = pop(), pop()
                    push({a[1], a[2]%b[2]})
                end, function() -- 72
                    --rem
                    local b, a = pop(), pop()
                    push({a[1], a[2]%b[2]})
                end, function() -- 73
                    --rem
                    local b, a = pop(), pop()
                    push({a[1], a[2]%b[2]})
                end, function() -- 74
                    --neg
                    local a = pop(), pop()
                    push({a[1], -a[2]})
                end, function() -- 75
                    --neg
                    local a = pop(), pop()
                    push({a[1], -a[2]})
                end, function() -- 76
                    --neg
                    local a = pop(), pop()
                    push({a[1], -a[2]})
                end, function() -- 77
                    --neg
                    local a = pop(), pop()
                    push({a[1], -a[2]})
                end, function() -- 78
                    --shl
                    local b, a = pop(), pop()
                    push({b[1], bit.blshift(b[2],a[2])})
                end, function() -- 79
                    --shl
                    local b, a = pop(), pop()
                    push({b[1], bit.blshift(b[2],a[2])})
                end, function() -- 7A
                    --shr
                    local b, a = pop(), pop()
                    push({b[1], bit.brshift(b[2],a[2])})
                end, function() -- 7B
                    --shr
                    local b, a = pop(), pop()
                    push({b[1], bit.brshift(b[2],a[2])})
                end, function() -- 7C
                    --shlr
                    local b, a = pop(), pop()
                    push({b[1], bit.blogic_rshift(b[2],a[2])})
                end, function() -- 7D
                    --shlr
                    local b, a = pop(), pop()
                    push({b[1], bit.blogic_rshift(b[2],a[2])})
                end, function() -- 7E
                    --and
                    local b, a = pop(), pop()
                    push({a[1], bit.band(a[2],b[2])})
                end, function() -- 7F
                    --and
                    local b, a = pop(), pop()
                    push({a[1], bit.band(a[2],b[2])})
                end, function() -- 80
                    --or
                    local b, a = pop(), pop()
                    push({a[1], bit.bor(a[2],b[2])})
                end, function() -- 81
                    --or
                    local b, a = pop(), pop()
                    push({a[1], bit.bor(a[2],b[2])})
                end, function() -- 82
                    --xor
                    local b, a = pop(), pop()
                    push({a[1], bit.bxor(a[2],b[2])})
                end, function() -- 83
                    --xor
                    local b, a = pop(), pop()
                    push({a[1], bit.bxor(a[2],b[2])})
                end, function() -- 84
                    --iinc
                    local idx = u1()
                    local c = u1ToSignedByte(u1())
                    lvars[idx][2] = lvars[idx][2]+c
                end, function() -- 85
                    --i2l
                    push(asLong(bigInt.toBigInt(pop()[2])))
                end, function() -- 86
                    --i2f
                    push(asFloat(pop()[2]))
                end, function() -- 87
                    --i2d
                    push(asDouble(pop()[2]))
                end, function() -- 88
                    --l2i
                    push(asInt(bigInt.fromBigInt(pop()[2])))
                end, function() -- 89
                    --l2f
                    push(asFloat(bigInt.fromBigInt(pop()[2])))
                end, function() -- 8A
                    --l2d
                    push(asDouble(bigInt.fromBigInt(pop()[2])))
                end, function() -- 8B
                    --f2i
                    push(asInt(math.floor(pop()[2])))
                end, function() -- 8C
                    --f2l
                    push(asLong(bigInt.toBigInt(math.floor(pop()[2]))))
                end, function() -- 8D
                    --f2d
                    push(asDouble(pop()[2]))
                end, function() -- 8E
                    --d2i
                    push(asInt(math.floor(pop()[2])))
                end, function() -- 8F
                    --d2l
                    push(asLong(bigInt.toBigInt(math.floor(pop()[2]))))
                end, function() -- 90
                    --d2f
                    push(asFloat(pop()[2]))
                end, function() -- 91
                    --i2b
                    push(asByte(pop()[2]))
                end, function() -- 92
                    --i2c
                    push(asChar(string.char(pop()[2])))
                end, function() -- 93
                    --i2s
                    push(asShort(pop()[2]))
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
                    local offset = u2ToSignedShort(u2())
                    if pop()[2] == 0 then
                        pc(pc() + offset - 2) -- minus 2 becuase u2()
                    end
                end, function() -- 9A
                    --ifne
                    local offset = u2ToSignedShort(u2())
                    if pop()[2] ~= 0 then
                        pc(pc() + offset - 2)
                    end
                end, function() -- 9B
                    --iflt
                    local offset = u2ToSignedShort(u2())
                    if pop()[2] < 0 then
                        pc(pc() + offset - 2)
                    end
                end, function() -- 9C
                    --ifge
                    local offset = u2ToSignedShort(u2())
                    if pop()[2] >= 0 then
                        pc(pc() + offset - 2)
                    end
                end, function() -- 9D
                    --ifgt
                    local offset = u2ToSignedShort(u2())
                    if pop()[2] > 0 then
                        pc(pc() + offset - 2)
                    end
                end, function() -- 9E
                    --ifle
                    local offset = u2ToSignedShort(u2())
                    if pop()[2] <= 0 then
                        pc(pc() + offset - 2)
                    end
                end, function() -- 9F
                    --if_icmpeq
                    local offset = u2ToSignedShort(u2())
                    if pop()[2] == pop()[2] then
                        pc(pc() + offset - 2)
                    end
                end, function() -- A0
                    --if_icmpne
                    local offset = u2ToSignedShort(u2())
                    if pop()[2] ~= pop()[2] then
                        pc(pc() + offset - 2)
                    end
                end, function() -- A1
                    --if_icmplt
                    local offset = u2ToSignedShort(u2())
                    if pop()[2] > pop()[2] then
                        pc(pc() + offset - 2)
                    end
                end, function() -- A2
                    --if_icmpge
                    local offset = u2ToSignedShort(u2())
                    if pop()[2] <= pop()[2] then
                        pc(pc() + offset - 2)
                    end
                end, function() -- A3
                    --if_icmpgt
                    local offset = u2ToSignedShort(u2())
                    if pop()[2] < pop()[2] then
                        pc(pc() + offset - 2)
                    end
                end, function() -- A4
                    --if_icmple
                    local offset = u2ToSignedShort(u2())
                    if pop()[2] >= pop()[2] then
                        pc(pc() + offset - 2)
                    end
                end, function() -- A5
                    --ifle
                    local offset = u2ToSignedShort(u2())
                    if pop()[2] <= 0 then
                        pc(pc() + offset - 2)
                    end
                end, function() -- A6
                    --if_icmpeq
                    local offset = u2ToSignedShort(u2())
                    if pop()[2] == pop()[2] then
                        pc(pc() + offset - 2)
                    end
                end, function() -- A7
                    --goto
                    local offset = u2ToSignedShort(u2())
                    pc(pc() + offset - 2)
                end, function() -- A8
                    --jsr
                    local addr = pc() + 3
                    local offset = u2ToSignedShort(u2())
                    push({"address", addr})
                    pc(pc() + offset - 2)
                end, function() -- A9
                    --ret
                    local index = u1()
                    local addr = lvars[index]
                    if addr[1] ~= "address" then
                        error("Not an address", 0)
                    end
                    pc(addr[2])
                end, function() -- AA
                end, function() -- AB
                end, function() -- AC
                    mustRet = true
                    popStackTrace()
                    return pop()
                end, function() -- AD
                    mustRet = true
                    popStackTrace()
                    return pop()
                end, function() -- AE
                    mustRet = true
                    popStackTrace()
                    return pop()
                end, function() -- AF
                    mustRet = true
                    popStackTrace()
                    return pop()
                end, function() -- B0
                    mustRet = true
                    popStackTrace()
                    return pop()
                end, function() -- B1
                    mustRet = true
                    popStackTrace()
                    return pop()
                end, function() -- B2
                    --getstatic
                    local fr = cp[u2()]
                    local cl = resolveClass(cp[fr.class_index])
                    local name = cp[cp[fr.name_and_type_index].name_index].bytes
                    local descriptor = cp[cp[fr.name_and_type_index].descriptor_index].bytes
                    --print(descriptor)
                    push(asObjRef(cl.fields[name].value, descriptor))
                end, function() -- B3
                    --putstatic
                    local fr = cp[u2()]
                    local cl = resolveClass(cp[fr.class_index])
                    local name = cp[cp[fr.name_and_type_index].name_index].bytes
                    cl.fields[name].value = pop()[2]
                end, function() -- B4
                    --getfield
                    local fr = cp[u2()]
                    local name = cp[cp[fr.name_and_type_index].name_index].bytes
                    local descriptor = cp[cp[fr.name_and_type_index].descriptor_index].bytes
                    local obj = pop()[2]
                    push(asObjRef(obj.fields[name].value, descriptor))
                end, function() -- B5
                    --putfield
                    local fr = cp[u2()]
                    local value = pop()[2]
                    local obj = pop()[2]
                    local name = cp[cp[fr.name_and_type_index].name_index].bytes
                    obj.fields[name].value = value
                end, function() -- B6
                    --invokevirtual
                    local mr = cp[u2()]
                    local cl = resolveClass(cp[mr.class_index])
                    local name = cp[cp[mr.name_and_type_index].name_index].bytes..cp[cp[mr.name_and_type_index].descriptor_index].bytes
                    local mt = findMethod(cl,name)
                    local args = {}
                    for i=#mt.desc-1,1,-1 do
                        args[i+1] = pop()
                    end
                    args[1] = pop()
                    local obj = args[1][2]
                    if type(obj) == "table" and obj.methods then -- if the object holds its own methods, use those so A a = new B(); a.c() calls B.c(), not A.c()
                        mt = findMethod(obj, name)
                    end
                    --[[if bit.band(mt.acc,METHOD_ACC.NATIVE) == METHOD_ACC.NATIVE then
                        for i=1, #args do
                            args[i] = args[i][2]
                        end
                    end]]
                    local ret = mt[1](unpack(args))
                    if mt.desc[#mt.desc][1] ~= "V" then
                        push(ret)
                    end
                end, function() -- B7
                    --invokespecial
                    local mr = cp[u2()]
                    local cl = resolveClass(cp[mr.class_index])
                    local name = cp[cp[mr.name_and_type_index].name_index].bytes..cp[cp[mr.name_and_type_index].descriptor_index].bytes
                    local mt = findMethod(cl,name)
                    local args = {}
                    for i=#mt.desc-1,1,-1 do
                        args[i+1] = pop()
                    end
                    args[1] = pop()
                    local obj = args[1][2]
                    --[[if bit.band(mt.acc,METHOD_ACC.NATIVE) == METHOD_ACC.NATIVE then
                        for i=1, #args do
                            args[i] = args[i][2]
                        end
                    end]]
                    local ret = mt[1](unpack(args))
                    if mt.desc[#mt.desc][1] ~= "V" then
                        push(ret)
                    end
                end, function() -- B8
                    --invokestatic
                    local mr = cp[u2()]
                    local cl = resolveClass(cp[mr.class_index])
                    local name = cp[cp[mr.name_and_type_index].name_index].bytes..cp[cp[mr.name_and_type_index].descriptor_index].bytes
                    local mt = findMethod(cl,name)
                    local args = {}
                    for i=#mt.desc-1,1,-1 do
                        args[i] = pop()
                    end
                    --[[if bit.band(mt.acc,METHOD_ACC.NATIVE) == METHOD_ACC.NATIVE then
                        for i=1, #args do
                            args[i] = args[i][2]
                        end
                    end]]
                    local ret = mt[1](unpack(args))
                    if mt.desc[#mt.desc][1] ~= "V" then
                        push(ret)
                    end
                end, function() -- B9
                end, function() -- BA
                end, function() -- BB
                    --new
                    local cr = cp[u2()]
                    local c = resolveClass(cr)
                    local obj = newInstance(c)
                    local type = "L"..c.name:gsub("%.", "/")..";"
                    push(asObjRef(obj, type))
                end, function() -- BC
                    --newarray
                    local type = "[" .. ARRAY_TYPES[u1()]
                    local length = pop()[2]
                    push(asObjRef({length=length}, type))
                end, function() -- BD
                    --anewarray
                    local cr = cp[u2()]
                    local c = resolveClass(cr)
                    local type = "[L" .. c.name:gsub("%.", "/")..";"
                    local length = pop()[2]
                    push(asObjRef({length=length}, type))
                end, function() -- BE
                    --arraylength
                    local arr = pop()
                    push(asInt(arr[2].length))
                end, function() -- BF
                end, function() -- C0
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
            
            while true do
                inst = u1()
                local ret = oplookup[inst]()
                if mustRet then
                    return ret
                end
            end
            popStackTrace()
        end
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
        for i=0, method.attributes_count-1 do
            method.attributes[i] = attribute()
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
        
        --start processing the data
        Class.name = cn
        Class.acc = access_flags

        local interfaces_count = u2()
        Class.interfaces = {}
        for i=0, interfaces_count-1 do
            interfaces[i] = u2()
        end
        local fields_count = u2()
        for i=0, fields_count-1 do
            Class.fields[i] = field_info()
            Class.fields[Class.fields[i].name] = Class.fields[i]
        end
        local methods_count = u2()
        local initialCount = #Class.methods
        local subtractor = 0
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
                if v.code then ca = v break end
            end

            local mt_name = Class.name.."."..m.name

            if ca then
                m[1] = createCodeFunction(ca.code, mt_name)
            elseif bit.band(m.acc,METHOD_ACC.NATIVE) == METHOD_ACC.NATIVE then
                if not natives[cn] then natives[cn] = {} end
                m[1] = function(...)
                    pushStackTrace(mt_name)
                    if not natives[cn][m.name] then
                        error("Native not implemented: " .. m.name, 0)
                    end
                    local ret = natives[cn][m.name](...)
                    popStackTrace()
                    return ret
                end
            else
                print(m.name," doesn't have code")
            end
        end
        local attrib_count = u2()
        Class.attributes = {}
        for i=0, attrib_count-1 do
            Class.attributes[i] = attribute()
        end

        -- invoke static{}
        local staticmr = findMethod(Class, "<clinit>()V")
        if staticmr then
            staticmr[1]()
        end
    end)

    fh.close()
    if not s then error(e,0) end
    return cn
end
