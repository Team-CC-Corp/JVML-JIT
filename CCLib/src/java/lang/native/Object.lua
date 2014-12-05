natives["java.lang.Object"] = natives["java.lang.Object"] or {}
natives["java.lang.Object"]["toString()Ljava/lang/String;"] = function(this)
    return toJString(tostring(this):sub(8))
end

natives["java.lang.Object"]["getClass()Ljava/lang/Class;"] = function(this)
    return getJClass(this[1].name)
end

natives["java.lang.Object"]["hashCode()I"] = function(this)
	num = tonumber(tostring(this):sub(8), 16)
    return num
end
