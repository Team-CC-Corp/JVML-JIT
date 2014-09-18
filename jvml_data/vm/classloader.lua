--This will load class files and will register them--
natives = {["java.lang.Object"]={
    ["registerNatives()V"] = function()
        local path = resolvePath("java/lang/native")
        for i,v in ipairs(fs.list(path)) do
            if v:sub(1,1) ~= "." then
                dofile(fs.combine(path, v))
            end
        end
    end
}}

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
    local obj = newInstance(stringClass)

    local charArray = getArrayClass("[C")
    local charArrayRef = newArray(charArray, #str)
    local charArray = charArrayRef[5]
    for i = 1, #str do
        charArray[i] = str:sub(i, i):byte()
    end
    findMethod(stringClass, "<init>([C)V")[1](obj, charArrayRef)
    return obj
end

function toLString(str)
    local stringClass = classByName("java.lang.String")
    local strArray = { }
    local charArrayRef = getObjectField(str, "value")
    local len = charArrayRef[4]
    local charArray = charArrayRef[5]

    for i = 1, len do
        strArray[i] = string.char(charArray[i])
    end
    return table.concat(strArray)
end

function u2ToSignedShort(i)
    if i > 2^15 - 1 then
        return -(2^16 - i)
    end
    return i
end
function u1ToSignedByte(i)
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

ARRAY_TYPES_LOOKUP = {
    Z=4,
    C=5,
    F=6,
    D=7,
    B=8,
    S=9,
    I=10,
    J=11
}

ARRAY_TYPES = {}
for k,v in pairs(ARRAY_TYPES_LOOKUP) do
    ARRAY_TYPES[v] = k
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

VERIFICATION_TYPES = {
    Top_variable_info = 0,
    Integer_variable_info = 1,
    Float_variable_info = 2,
    Long_variable_info = 3,
    Double_variable_info = 4,
    Null_variable_info = 5,
    UninitializedThis_variable_info = 6,
    Object_variable_info = 7,
    Uninitialized_variable_info = 8
}

function loadJavaClass(fh)
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
        return high_bytes * 4294967296 + low_bytes
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

    local function verification_type_info(info)
        info.tag = u1()
        if info.tag == VERIFICATION_TYPES.Object_variable_info then
            info.cpool_index = u2()
        elseif info.tag == VERIFICATION_TYPES.Uninitialized_variable_info then
            info.offset = u2()
        end
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
            attrib.local_variable_type_table_length = u2()
            attrib.local_variable_type_table = {}
            for i=0, attrib.local_variable_type_table_length-1 do
                attrib.local_variable_type_table[i] = {
                    start_pc = u2(),
                    length = u2(),
                    name_index = u2(),
                    signature_index = u2(),
                    index = u2()
                }
            end
        elseif an == "Deprecated" then
            --lel, this doesn't have content in it--
        elseif an == "SourceFile" then
            attrib.source_file_index = u2()
        elseif an == "StackMapTable" then
            attrib.number_of_entries = u2()
            attrib.entries = {}
            local entries = attrib.entries

            for i=0,attrib.number_of_entries-1 do
                entries[i] = {}
                local entry = entries[i]
                entry.frame_type = u1()
                local frame_type = entry.frame_type

                if frame_type >= 0 and frame_type <= 63 then
                    --same_frame
                    entry.offset_delta = frame_type
                    entry.stack_items = 0
                elseif frame_type >=64 and frame_type <= 127 then
                    --same_locals_1_stack_item_frame
                    entry.offset_delta = frame_type - 64
                    entry.stack_items = 1

                    verification_type_info({}) -- dump. We don't implement verification
                elseif frame_type == 247 then
                    --same_locals_1_stack_item_frame_extended
                    entry.offset_delta = u2()
                    entry.stack_items = 1

                    verification_type_info({}) -- dump
                elseif frame_type >= 248 and frame_type <= 250 then
                    --chop_frame
                    entry.offset_delta = u2()
                    entry.stack_items = 0
                elseif frame_type == 251 then
                    --same_frame_extended
                    entry.offset_delta = u2()
                    entry.stack_items = 0
                elseif frame_type >= 252 and frame_type <= 254 then
                    --append_frame
                    entry.offset_delta = u2()
                    entry.stack_items = 0
                    for i=1,frame_type - 251 do
                        verification_type_info({}) -- dump
                    end
                elseif frame_type == 255 then
                    --full_frame
                    entry.offset_delta = u2()
                    local number_of_locals = u2()
                    for i=0,number_of_locals-1 do
                        verification_type_info({}) -- dump
                    end
                    entry.stack_items = u2()
                    for i=0,entry.stack_items-1 do
                        verification_type_info({}) -- dump
                    end
                end
            end
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

        --start processing the data
        Class.name = cn
        Class.acc = access_flags

        Class.interfaces_count = u2()
        Class.interfaces = {}
        for i=1, Class.interfaces_count do
            local iname = u2()
            Class.interfaces[i] = classByName(cp[cp[iname].name_index].bytes:gsub("/","."))
        end
        local fields_count = u2()
        for i=1, fields_count do
            local newField = field_info()
            table.insert(Class.field_info, newField)
            Class.fieldIndexByName[newField.name] = #Class.field_info
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

            table.insert(doAfter, function()
                if ca then
                    m[1] = createCodeFunction(Class, m, ca, cp)
                elseif bit.band(m.acc,METHOD_ACC.NATIVE) == METHOD_ACC.NATIVE then
                    if not natives[cn] then natives[cn] = {} end
                    m[1] = function(...)
                        pushStackTrace(Class.name, m.name:gsub("L.-/(%a+);", "%1;"))
                        if not (natives[cn] and natives[cn][m.name]) then
                            error("Native not implemented: " .. Class.name .. "." .. m.name, 0)
                        end
                        local ret, exception = natives[cn][m.name](...)
                        popStackTrace()
                        return ret, exception
                    end
                else
                    --print(m.name," doesn't have code")
                end
            end)
        end

        for i, v in pairs(doAfter) do
            v()
        end

        Class.attributes_count = u2()
        Class.attributes = {}
        for i=0, Class.attributes_count-1 do
            Class.attributes[i] = attribute()
        end

        local staticmr = findMethod(Class, "<clinit>()V")
        if staticmr then
            local ok, err = pcall(staticmr[1])
            if not ok then
                printError(err)
                error("Error in "..Class.name.." <clinit>()V")
            end
        end
    end)

    fh.close()
    if not s then error(e,0) end
    return cn
end