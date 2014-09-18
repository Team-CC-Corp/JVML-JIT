natives["java.lang.Enum"] = natives["java.lang.Enum"] or {}

natives["java.lang.Enum"]["_valueOf(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/Enum;"] = function(cls, str)
	local class = classByName(toLString(getObjectField(cls, "name")))
	local name = toLString(str)
	local key = class.fieldIndexByName[name]
	if not key then
		return nil
	end
	return class.fields[key]
end