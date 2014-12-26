natives["java.util.HashMap"] = natives["java.util.HashMap"] or {}

local tables = setmetatable({}, {__mode = "k"})

natives["java.util.HashMap"]["clear()V"] = function(this)
    tables[this] = {}
end

natives["java.util.HashMap"]["size()I"] = function(this)
    count = 0
    for _ in pairs(tables[this]) do
       count = count + 1 
    end
    return count
end

natives["java.util.HashMap"]["entryArray()[Ljava/util/Map$Entry;"] = function(this)
    if not tables[this] then
        return nil
    end
    
    local ret = {}
    for _, bucket in pairs(tables[this]) do
        for _, pair in pairs(bucket) do
        	local entryClass = classByName("java.util.HashMap$Entry")
            local entry = newInstance(entryClass)
            findMethod(entryClass, "<init>()V")[1](entry)
            setObjectField(entry, "key", pair[1])
            setObjectField(entry, "value", pair[2])
            table.insert(ret, entry)
        end
    end


    local jRet = newArray(getArrayClass("[Ljava/util/HashMap$Entry;"), #ret)
    for i,v in ipairs(ret) do
        jRet[5][i] = ret[i]
    end
    return jRet
end

natives["java.util.HashMap"]["putHash(Ljava/lang/Object;ILjava/lang/Object;)Ljava/lang/Object;"] = function(this, key, hash, value)
    tables[this] = tables[this] or {}
    
    local bucket = tables[this][hash]
    local previous = nil
    
    if not bucket then
        bucket = {{key, value}}
    elseif #bucket == 1 then
        local jKeyEquals = findMethod(key[1], "equals(Ljava/lang/Object;)Z")[1]
        local ret, exception = jKeyEquals(key, bucket[1][1])
        if exception then return nil, exception end
        if ret == 1 then
            bucket[1][2] = value
        else
            table.insert(bucket, {key, value})
        end
    else
        local jKeyEquals = findMethod(key[1], "equals(Ljava/lang/Object;)Z")[1]
        local found = false
        for _, j in pairs(bucket) do
            local ret, exception = jKeyEquals(key, j[1])
            if exception then return nil, exception end
            if ret == 1 then
                found = true
                previous = j[2]
                j[2] = value
            end
        end
        if not found then
            table.insert(bucket, {key, value})
        end
    end
    tables[this][hash] = bucket
end

natives["java.util.HashMap"]["getHash(Ljava/lang/Object;I)Ljava/lang/Object;"] = function(this, key, hash)
    if tables[this] == nil then
        return nil
    end
    local bucket = tables[this][hash]
    if not bucket then
        return nil
    elseif #bucket == 1 then
        return bucket[1][2]
    else
        local jKeyEquals = findMethod(key[1], "equals(Ljava/lang/Object;)Z")[1]
        for _, i in pairs(bucket) do
            local ret, exc = jKeyEquals(key, i[1])
            if exc then return nil, exc end
            if ret == 1 then
                return i[2]
            end
        end
    end
end

function toJMap(map)
    local class = classByName("java.util.HashMap")
    local jMap = newInstance(class)
    findMethod(class, "<init>()V")[1](jMap)
    local jPut = findMethod(class, "put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;")[1]
    for key, val in pairs(map) do
        key = l2jType(key)
        val = l2jType(val)
        local _, exc = jPut(jMap, key, val)
        if exc then return nil, exc end
    end
    return jMap
end

function toLMap(map)
    local lMap = {}
    for _, bucket in pairs(tables[map]) do
        for _, pair in pairs(bucket) do
            local key = j2lType(pair[1])
            local val = j2lType(pair[2])
            lMap[key] = val
        end
    end
    return lMap;
end
