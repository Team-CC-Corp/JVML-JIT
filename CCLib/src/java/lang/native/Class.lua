natives["java.lang.Class"] = natives["java.lang.Class"] or {}
natives["java.lang.Class"]["getSuperclass()Ljava/lang/Class;"] = function(this)
	local class = classByName(toLString(getObjectField(this, "name")))
	if class == classByName("java.lang.Object") or bit.band(class.acc, CLASS_ACC.INTERFACE) > 0 then
		return nil
	end
	return getJClass(class.super.name)
end

local function findMethodName(class, name)
	for i,v in ipairs(class.methods) do
		if v.name:find(name, 1, true) then
			return v.name
		end
	end
	-- default interface methods
	for i,v in ipairs(class.interfaces) do
		local iname = findMethodName(v, name)
		if iname then
			return iname
		end
	end
end
natives["java.lang.Class"]["getMethod(Ljava/lang/String;[Ljava/lang/Class;)Ljava/lang/reflect/Method;"] = function(this, name, params)
	local class = classByName(toLString(getObjectField(this, "name")))
	local paramTypes = {}
	for i,v in ipairs(params[5]) do
		local name = toLString(getObjectField(v, "name"))
		if name:find("^%[") then
			name = name:gsub("%.", "/")
		elseif name == "boolean" then
			name = "Z"
		elseif name == "byte" then
			name = "B"
		elseif name == "char" then
			name = "C"
		elseif name == "double" then
			name = "D"
		elseif name == "float" then
			name = "F"
		elseif name == "int" then
			name = "I"
		elseif name == "long" then
			name = "J"
		elseif name == "short" then
			name = "S"
		else
			name = "L"..name:gsub("%.", "/")..";"
		end

		paramTypes[i] = name
	end

	local noReturnName = toLString(name) .. "(" .. table.concat(paramTypes) .. ")"
	local methodName = findMethodName(class, noReturnName)
	assert(methodName, "Failed to find method: "..noReturnName)
	local methodObj = newInstance(classByName("java.lang.reflect.Method"))
	setObjectField(methodObj, "name", toJString(methodName))
	return methodObj
end

local function getMethodNames(class, t)
	getMethodNames(class.super, t)
	for i,v in ipairs(class.methods) do
		t[v.name] = true
	end
	-- default interface methods
	for i,v in ipairs(class.interfaces) do
		getMethodNames(v, t)
	end
end
natives["java.lang.Class"]["getMethods()[Ljava/lang/reflect/Method;"] = function(this)
	local class = classByName(toLString(getObjectField(this, "name")))
	local t = {}
	getMethodNames(class, t)
	local jmethods = {}
	for k,v in pairs(t) do
		local m = newInstance(classByName("java.lang.reflect.Method"))
		setObjectField(m, "name", toJString(k))
		table.insert(jmethods, m)
	end
	local mArray = newArray(getArrayClass("[Ljava.lang.reflect.Method;"), #jmethods)
	mArray[5] = jmethods
	return mArray
end

natives["java.lang.Class"]["getPrimitiveClass(Ljava/lang/String;)Ljava/lang/Class;"] = function(jstr)
	local str = toLString(jstr)
	local class = getJClass(str)
	return class
end