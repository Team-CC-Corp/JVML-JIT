natives["java.lang.Class"] = natives["java.lang.Class"] or {}
natives["java.lang.Class"]["getSuperclass()Ljava/lang/Class;"] = function(this)
	local class = classByName(toLString(getObjectField(this, "name")))
	if class == classByName("java.lang.Object") or bit.band(class.acc, CLASS_ACC.INTERFACE) > 0 then
		return nil
	end
	return getJClass(class.super.name)
end
natives["java.lang.Class"]["getPrimitiveClass(Ljava/lang/String;)Ljava/lang/Class;"] = function(jstr)
	local str = toLString(jstr)
	local class = getJClass(str)
	return class
end