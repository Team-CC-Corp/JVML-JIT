local stack_trace = {}

function findMethod(c,name)
    if not c then error("class expected, got nil",2) end
    if c.methodLookup[name] then
        return unpack(c.methodLookup[name])
    end
    for i=1, #c.methods do
        if c.methods[i].name == name then
            c.methodLookup[name] = {c.methods[i],i} -- when it's virtual, the index is needed
            return c.methods[i], i
        end
    end
    -- everything after this point is entirely in case of interfaces with default methods
    if c.super then
        local mt = findMethod(c.super, name)
        if mt and bit.band(mt.acc,METHOD_ACC.STATIC) == METHOD_ACC.STATIC then
            c.methodLookup[name] = {}
            return nil
        end
        if mt then
            c.methodLookup[name] = {mt}
            return mt
        end
    end
    for i=1, c.interfaces_count do
        local mt = findMethod(c.interfaces[i], name)
        if mt and bit.band(mt.acc,METHOD_ACC.STATIC) == METHOD_ACC.STATIC then
            c.methodLookup[name] = {}
            return nil
        end
        if mt then
            c.methodLookup[name] = {mt}
            return mt
        end
    end
end

function getObjectField(obj, name)
    return obj[2][obj[1].fieldIndexByName[name]]
end

function setObjectField(obj, name, val)
    obj[2][obj[1].fieldIndexByName[name]] = val
end

function newInstance(class)
    return { class, { }, class.methods }
end

local function implementsInterface(class, interface)
    if class.super and (class.super == interface or implementsInterface(class.super, interface)) then
        return 1
    end
    for i=1, class.interfaces_count do
        local v = class.interfaces[i]
        if v == interface or implementsInterface(v, interface) then
            return 1
        end
    end
    return 0
end

local function _jInstanceof(obj, class)
    if bit.band(class.acc, CLASS_ACC.INTERFACE) == CLASS_ACC.INTERFACE then
        return implementsInterface(obj[1], class)
    else
        local oClass = obj[1]
        while oClass do
            if oClass == class then
                return 1
            end
            oClass = oClass.super
        end
    end
    return 0
end
function jInstanceof(obj, class)
    if not obj then
        return false
    end
    if not obj[1].instanceofCache[class] then
        obj[1].instanceofCache[class] = _jInstanceof(obj, class)
    end
    return obj[1].instanceofCache[class]
end

function resolvePath(name)
    for sPath in string.gmatch(jcp, "[^:]+") do
        local fullPath = fs.combine(sPath, name)
        if fs.exists(fullPath) then
            return fullPath
        end
    end
end

local jClasses = {}
function getJClass(name)
    if not jClasses[name] then
        jClasses[name] = newInstance(classByName("java.lang.Class"))
        setObjectField(jClasses[name], "name", toJString(name))
    end
    return jClasses[name]
end

local class = {}
function classByName(cn)
    local c = class[cn]
    if c then
        return c
    end
    local cd = cn:gsub("%.","/")

    local fullPath = resolvePath(cd..".class")
    if not fullPath then
        error("Cannot find class ".. cn, 0)
    end

    local fh = assert(fs.open(fullPath,"rb"), "File not found: " .. fullPath)
    if not loadJavaClass(fh) then
        error("Cannot load class " .. cn, 0)
    else
        c = class[cn]
        return c
    end
end

-- TODO: Index numerically only
-- cls = { name, fields, methods, super }
function createClass(super_name, cn)
    local cls = {}
    class[cn] = cls
    cls.name = cn
    cls[1] = cn
    cls.fields = {}
    cls[2] = cls.fields
    cls.field_info = {}
    cls.fieldIndexByName = {}
    cls.methods = {}
    cls[3] = cls.methods
    cls.methodLookup = {}
    cls.instanceofCache = {}
    if super_name then -- we have a custom Object class file which won't have a super
        local super = classByName(super_name)
        cls.super = super
        cls[4] = super
        for k,v in pairs(super.field_info) do
            cls.field_info[k] = v
        end
        for k,v in pairs(super.fieldIndexByName) do
            cls.fieldIndexByName[k] = v
        end

        for i,v in pairs(super.methods) do
            cls.methods[i] = v
            cls[3][i] = v
        end
    end
    return cls
end

function pushStackTrace(className, methodName, fileName, lineNumber)
    table.insert(stack_trace, {className=className, methodName=methodName, fileName=fileName, lineNumber=lineNumber})
end

function popStackTrace()
    table.remove(stack_trace)
end

function getStackTrace()
    local newTrace = {}
    for i,v in ipairs(stack_trace) do
        newTrace[i] = {className=v.className, methodName=v.methodName, fileName=v.fileName, lineNumber=v.lineNumber}
    end
    return newTrace
end

function printStackTrace(printer)
    local reversedtable = {}
    for i,v in ipairs(stack_trace) do
        reversedtable[#stack_trace - i + 1] = v.className .. "." .. v.methodName .. ":" .. (v.lineNumber or -1)
    end
    (printer or print)(table.concat(reversedtable,"\n"))
end