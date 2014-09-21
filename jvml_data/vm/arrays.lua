local arrayClasses = {}

function getArrayClass(name)
	if not arrayClasses[name] then
		local Class = createClass(name, "java.lang.Object")
		Class.name = name
        Class.acc = 0 -- TODO: Figure out exactly what to assign to this

        arrayClasses[name] = Class
	end

	return arrayClasses[name]
end

function newArray(class, length)
	local arr = newInstance(class)
	-- two new entries for length and data
	arr[4] = length
	arr[5] = {}
	return arr
end