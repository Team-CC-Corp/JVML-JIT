natives["java.util.HashMap"] = natives["java.util.HashMap"] or {}

tables = {}

natives["java.util.HashMap"]["putHash(Ljava/lang/Object;ILjava/lang/Object;)Ljava/lang/Object;"] = function(this, key, hash, value)
	tables[this] = tables[this] or {}
	
	local bucket = tables[this][hash]
	local previous = nil
	
	if not bucket then
		bucket = {{key, value}}
	elseif #bucket == 1 then
		local jKeyEquals = findMethod(key[1], "equals(Ljava/lang/Object;)Z")[1]
		local ret, exception = jKeyEquals(key, bucket[1][1])
		if exception then return exception end
		if ret == 1 then
			bucket[1][2] = value
		else
			table.insert(bucket, {key, value})
		end
	else
		local jKeyEquals = findMethod(key[1], "equals(Ljava/lang/Object;)Z")[1]
		local found = false
		for _, j in pairs(bucket) do
			local ret, exception = jKeyEquals(key, j[1])
			if exception then return exception end
			if ret == 1 then
				found = true
				previous = j[2]
				j[2] = value
			end
		end
		if not found then
			table.insert(bucket, {key, value})
		end
	end
	if newBucket then
		tables[this][hash] = newBucket
	else
		tables[this][hash] = bucket
	end
	
	return previous
end

natives["java.util.HashMap"]["getHash(Ljava/lang/Object;I)Ljava/lang/Object;"] = function(this, key, hash)
	if tables[this] == nil then
		return nil
	end
	local bucket = tables[this][hash]
	if not bucket then
		return nil
	elseif #bucket == 1 then
		return bucket[1][2]
	else
		local jKeyEquals = findMethod(key[1], "equals(Ljava/lang/Object;)Z")[1]
		for _, i in pairs(bucket) do
			local ret, exc = jKeyEquals(key, i[1])
			if exc then return exc end
			if ret == 1 then
				return i[2]
			end
		end
	end
end