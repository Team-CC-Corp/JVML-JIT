natives["cc.peripheral.Peripheral"] = natives["cc.peripheral.Peripheral"] or {}

local function j2lType(obj)
	local n = obj[1].name
	if n == "java.lang.Boolean" then
		return getObjectField(obj, "value") ~= 0
	elseif n == "java.lang.Byte" then
		return getObjectField(obj, "value")
	elseif n == "java.lang.Character" then
		return string.char(getObjectField(obj, "value"))
	elseif n == "java.lang.Double" then
		return getObjectField(obj, "value")
	elseif n == "java.lang.Float" then
		return getObjectField(obj, "value")
	elseif n == "java.lang.Integer" then
		return getObjectField(obj, "value")
	elseif n == "java.lang.Short" then
		return getObjectField(obj, "value")
	elseif n == "java.lang.String" then
		return toLString(obj)
	else
		error("Unsupported argument to Peripheral.call: "..n)
	end
end
local function l2jType(v)
	local t = type(v)
	if t == "number" then
		if v == math.floor(v) then
			return wrapPrimitive(v, "I")
		else
			return wrapPrimitive(v, "D")
		end
	elseif t == "boolean" then
		return wrapPrimitive(v and 1 or 0, "Z")
	elseif t == "string" then
		return toJString(v)
	end
end
natives["cc.peripheral.Peripheral"]["call(Ljava/lang/String;[Ljava/lang/Object;)[Ljava/lang/Object;"] = function (this, method, args)
	local t = {}
	for i,v in ipairs(args[5]) do
		t[i] = j2lType(v)
	end

	local side = toLString(getObjectField(this, "id"))
	local ret = {peripheral.call(side, toLString(method), unpack(t))}

	local jRet = newArray(getArrayClass("[Ljava.lang.Object;"), #ret)
	for i,v in ipairs(ret) do
		jRet[5][i] = l2jType(v)
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