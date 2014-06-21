natives["java.util.ArrayList"] = natives["java.util.ArrayList"] or {}

natives["java.util.ArrayList"]["initArray()V"] = function(this)
	-- array must be initialized natively, as generics can't be used for array construction
	local arr = {0, classByName("java.lang.Object"), {}}
	setObjectField(this, "array", arr)
end

natives["java.util.ArrayList"]["add(Ljava/lang/Object;)Z"] = function(this, e)
	local arr = findObjectField(this, "array")
	arr[3][arr[1] + 1] = e
	arr[1] = arr[1] + 1
	return 1 -- java booleans are 1/0
end

natives["java.util.ArrayList"]["add(ILjava/lang/Object;)Z"] = function(this, i, e)
	local arr = findObjectField(this, "array")
	assert(i < arr[1] and i >= 0, "ArrayList index out of bounds")
	table.insert(arr[3], i + 1, e)
	arr[1] = arr[1] + 1
	return 1
end

natives["java.util.ArrayList"]["clear()V"] = function(this)
	local arr = findObjectField(this, "array")
	arr[3] = {}
	arr[1] = 0
end

natives["java.util.ArrayList"]["remove(Ljava/lang/Object;)Z"] = function(this, e)
	local arr = findObjectField(this, "array")
	for i=1, arr[1] do
		if arr[3][i] == e then
			table.remove(arr[3], i)
			arr[1] = arr[1] - 1
			return 1
		end
	end
	return 0
end

natives["java.util.ArrayList"]["remove(I)Ljava/lang/Object;"] = function(this, i)
	local arr = findObjectField(this, "array")
	assert(i < arr[1] and i >= 0, "ArrayList index out of bounds")
	local e = table.remove(arr[3], i + 1)
	arr[1] = arr[1] - 1
	return e
end