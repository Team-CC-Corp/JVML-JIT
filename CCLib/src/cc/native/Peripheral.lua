natives["cc.peripheral.Peripheral"] = natives["cc.peripheral.Peripheral"] or {}

natives["cc.peripheral.Peripheral"]["call(Ljava/lang/String;[Ljava/lang/Object;)[Ljava/lang/Object;"] = function (this, method, args)
    local t = {}
    for i,v in ipairs(args[5]) do
        t[i] = j2lType(v)
    end

    local side = toLString(getObjectField(this, "id"))
    local ret = {peripheral.call(side, toLString(method), unpack(t))}

    local jRet = newArray(getArrayClass("[Ljava.lang.Object;"), #ret)
    for i,v in ipairs(ret) do
        if type(v) == "table" then
            jRet[5][i] = toJMap(v)
        else
            jRet[5][i] = l2jType(v)
        end
    end
    return jRet
end

natives["cc.peripheral.Peripheral"]["isPresent()Z"] = function(this)
    local side = toLString(getObjectField(this, "id"))
    return peripheral.isPresent(side) and 1 or 0
end

natives["cc.peripheral.Peripheral"]["getType()Ljava/lang/String;"] = function(this)
    local side = toLString(getObjectField(this, "id"))
    local type = peripheral.getType(side)
    if type then
        type = toJString(type)
    else
        type = nil
    end
    return type
end