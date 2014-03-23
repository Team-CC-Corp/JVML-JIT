natives["java.lang.Number"] = natives["java.lang.Number"] or { }
natives["java.lang.Number"]["toString(D)Ljava/lang/String;"] = function(value)
    return toJString(tostring(value))
end

natives["java.lang.Number"]["toString(J)Ljava/lang/String;"] = function(value)
    local x = value[1] * 2^32 + value[2]
    return toJString(tostring(x))
end