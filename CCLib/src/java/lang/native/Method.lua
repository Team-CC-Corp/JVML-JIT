natives["java.lang.reflect.Method"] = natives["java.lang.reflect.Method"] or {}

natives["java.lang.reflect.Method"]["invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;"] = function(this, target, args)
	local methodName = toLString(getObjectField(this, "name"))

	local class
	if target then
		class = target[1]
	else
		local declaringClass = getObjectField(this, "declaringClass")
		local className = toLString(getObjectField(declaringClass, "name"))
		class = classByName(className)
	end
	local mt = assert(findMethod(class, methodName), "Couldn't find method: " .. methodName .. " in class: " .. class.name)

	-- Check static
	assert((target == nil) == (bit.band(mt.acc, METHOD_ACC.STATIC) > 0), "Mismatch in target or static invocation")

	local newArgs = {target} -- if target is nil, this array is empty so no work needed there

	for i=1, #mt.desc-1 do -- last is return value
		local newArg
		local v = mt.desc[i]
		if v.array_depth == 0 and not v.type:find("^L") then
			-- primitive. Time to unbox!
			newArg = getObjectField(args[5][i], "value") -- sidestep the need to check each type for the typeValue() call
		else
			newArg = args[5][i]
		end
		table.insert(newArgs, newArg)
	end

	local ret = mt[1](unpack(newArgs))
	local retType = mt.desc[#mt.desc]
	if retType.array_depth == 0 and not retType.type:find("^L") and retType.type ~= "V" then
		-- return type is primitive. Need to box the primitive to return Object
		ret = wrapPrimitive(ret, retType.type)
	end
	return ret
end

natives["java.lang.reflect.Method"]["getAnnotation(Ljava/lang/Class;)Ljava/lang/annotation/Annotation;"] = function(this, annot)
	local declaringClass = getObjectField(this, "declaringClass")
	local thisClassName = toLString(getObjectField(declaringClass, "name"))
	local thisClass = classByName(thisClassName)
	local methodName = toLString(getObjectField(this, "name"))
	local mt = assert(findMethod(thisClass, methodName), "Couldn't find method: " .. methodName)

	local annotClassName = toLString(getObjectField(annot, "name"))
	return findMethodAnnotation(mt, classByName(annotClassName))
end

natives["java.lang.reflect.Method"]["getParameterTypes()[Ljava/lang/Class;"] = function(this)
	local methodName = toLString(getObjectField(this, "name"))
	local declaringClass = getObjectField(this, "declaringClass")
	local className = toLString(getObjectField(declaringClass, "name"))
	local class = classByName(className)
	local mt = assert(findMethod(class, methodName), "Couldn't find method: " .. methodName)

	local arr = newArray(getArrayClass("[java.lang.Class;"), #mt.desc - 1)
	for i=1, #mt.desc-1 do -- last is return value, first is target
		local class
		local type = mt.desc[i].type
		if type:find("^L") then
			class = getJClass(type:gsub("^L", ""):gsub(";$", ""):gsub("/", "."))
		elseif type:find("^[") then
			class = getJClass(type:gsub("/", "."))
		elseif type:find("^B") then
			class = getJClass("byte")
		elseif type:find("^C") then
			class = getJClass("char")
		elseif type:find("^D") then
			class = getJClass("double")
		elseif type:find("^F") then
			class = getJClass("float")
		elseif type:find("^I") then
			class = getJClass("int")
		elseif type:find("^J") then
			class = getJClass("long")
		elseif type:find("^S") then
			class = getJClass("short")
		elseif type:find("^Z") then
			class = getJClass("boolean")
		end

		arr[5][i] = class
	end
	return arr
end

natives["java.lang.reflect.Method"]["getParameterCount()I"] = function(this)
	local methodName = toLString(getObjectField(this, "name"))
	local declaringClass = getObjectField(this, "declaringClass")
	local className = toLString(getObjectField(declaringClass, "name"))
	local class = classByName(className)
	local mt = assert(findMethod(class, methodName), "Couldn't find method: " .. methodName)

	return #mt.desc - 1
end