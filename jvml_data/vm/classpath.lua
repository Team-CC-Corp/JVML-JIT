local class = {}
local stack_trace = {}

function findMethod(c,name)
    if not c then error("class expected, got nil",2) end
    for i=1, #c.methods do
        if c == "java.lang.String" then
            print(c.methods[i].name)
        end
        if c.methods[i].name == name then
            return c.methods[i], i
        end
    end
end

function newInstance(class)
    return { class, { }, class.methods }
end

function resolvePath(name)
    for sPath in string.gmatch(jcp, "[^:]+") do
        local fullPath = fs.combine(shell.resolve(sPath), name)
        if fs.exists(fullPath) then
            return fullPath
        end
    end
end

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
    if not loadJavaClass(fullPath) then
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
    cls.methods = {}
    cls[3] = cls.methods
    if super_name then -- we have a custom Object class file which won't have a super
        local super = classByName(super_name)
        cls.super = super
        cls[4] = super
        for i,v in pairs(super.fields) do
            cls.fields[i] = v
            cls[2][i] = v
        end
        for i,v in pairs(super.methods) do
            cls.methods[i] = v
            cls[3][i] = v
        end
    end
    return cls
end

function pushStackTrace(s)
    table.insert(stack_trace, s)
end

function popStackTrace()
    table.remove(stack_trace)
end

function printStackTrace(isError)
    local reversedtable = {}
    for i,v in ipairs(stack_trace) do
        reversedtable[#stack_trace - i + 1] = v
    end
    ((isError and printError) or print)(table.concat(reversedtable,"\n"))
end