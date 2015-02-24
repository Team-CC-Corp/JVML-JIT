function assert(condition, errMsg, level)
    if condition then return condition end
    if type(level) ~= "number" then
        level = 2
    elseif level <= 0 then
        level = 0
    else
        level = level + 1
    end
    error(errMsg or "Assertion failed!", level)
end

local jarCache = {}
local function forEach(fsF, jarFsF)
    for sPath in string.gmatch(jcp, "[^:]+") do
        if sPath:find(".jar$") or sPath:find(".zip$") then
            if not jarCache[sPath] then
                local jarHandle = fs.open(sPath, "rb")
                jarCache[sPath] = zip.open(jarHandle)
            end
            jarFsF(jarCache[sPath])
        else
            fsF(sPath)
        end
    end
end

classpath = {}

function classpath.exists(path)
    local ret = false
    forEach(function(sPath)
        ret = ret or fs.exists(fs.combine(sPath, path))
    end, function(jarFs)
        ret = ret or jarFs.exists(path)
    end)
    return ret
end

function classpath.isDir(path)
    local ret = false
    forEach(function(sPath)
        ret = ret or fs.isDir(fs.combine(sPath, path))
    end, function(jarFs)
        ret = ret or jarFs.isDir(path)
    end)
    return ret
end

function classpath.open(path, mode)
    local ret
    forEach(function(sPath)
        ret = ret or fs.open(fs.combine(sPath, path), mode)
    end, function(jarFs)
        ret = ret or jarFs.open(path, mode)
    end)
    return ret
end

function classpath.list(path)
    local list = {}
    forEach(function(sPath)
        local fullPath = fs.combine(sPath, path)
        if not fs.isDir(fullPath) then return end
        local addList = fs.list(fullPath)
        for i,v in ipairs(addList) do
            table.insert(list, v)
        end
    end, function(jarFs)
        local addList = jarFs.list(path)
        for i,v in ipairs(addList) do
            table.insert(list, v)
        end
    end)
    return list
end

function classpath.dofile(path, ...)
    local fh
    forEach(function(sPath)
        fh = fh or assert(fs.open(fs.combine(sPath, path), "r"), "File not found", 2)
    end, function(jarFs)
        fh = fh or assert(jarFs.open(path, "r"), "File not found", 2)
    end)
    local f = assert(loadstring(fh.readAll(), fs.getName(path)))
    setfenv(f, getfenv())
    return f(...)
end