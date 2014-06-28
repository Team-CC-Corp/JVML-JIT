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
	mt = assert(findMethod(class, methodName), "Couldn't find method: " .. methodName)

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