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
	for i,v in ipairs(class.staticMethods) do
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
	setObjectField(methodObj, "declaringClass", getJClass(class.name))
	return methodObj
end

local function getMethodNames(class, t)
	if class.super then
		getMethodNames(class.super, t)
	end
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
		setObjectField(m, "declaringClass", getJClass(class.name))
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

natives["java.lang.Class"]["getInterfaces()[Ljava/lang/Class;"] = function(this)
    local class = classByName(toLString(getObjectField(this, "name")))

    local len = 0
    if class.interfaces then len = #class.interfaces end
    local array = newArray(getArrayClass("Ljava/lang/Class;"), len)
    array[5] = { }
    for i = 1, len do
        array[5][#array[5] + 1] = getJClass(class.interfaces[i].name)
    end
    return array
end

natives["java.lang.Class"]["isInterface()Z"] = function(this)
    local class = classByName(toLString(getObjectField(this, "name")))
    return bit.band(class.acc, CLASS_ACC.INTERFACE) > 0 and 1 or 0
end

natives["java.lang.Class"]["isAssignableFrom(Ljava/lang/Class;)Z"] = function(this, cls)
    local thisClass = classByName(toLString(getObjectField(this, "name")))
    local otherClass = classByName(toLString(getObjectField(cls, "name")))
    return isClassAssignableFromClass(thisClass, otherClass) and 1 or 0
end

natives["java.lang.Class"]["isInstance(Ljava/lang/Object;)Z"] = function(this, obj)
    local class = getJClass(obj[1].name)
    local cls = classByName(toLString(getObjectField(this, "name")))
    local tmp = class
    while tmp do
        if cls.name == toLString(getObjectField(tmp, "name")) then
            break
        end
        if tmp == getJClass("java.lang.Object") then tmp = nil break end
        if tmp then break end
        if not tmp.super then break end
        tmp = getJClass(tmp.super.name)
    end
    if not tmp then return 0 else
        return cls.name == toLString(getObjectField(tmp, "name")) and 1 or 0
    end
end

natives["java.lang.Class"]["newInstance()Ljava/lang/Object;"] = function(this)
    local class = classByName(toLString(getObjectField(this, "name")))
    local obj = newInstance(class)
    findMethod(class, "<init>()V")[1](obj)
    return obj
end

natives["java.lang.Class"]["getAnnotation(Ljava/lang/Class;)Ljava/lang/annotation/Annotation;"] = function(this, annot)
	local thisClass = classByName(toLString(getObjectField(this, "name")))
	local annotClass = classByName(toLString(getObjectField(annot, "name")))
	return findClassAnnotation(thisClass, annotClass)
end