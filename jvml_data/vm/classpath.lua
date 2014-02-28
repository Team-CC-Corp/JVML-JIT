local class = {}

function findMethod(c,name)
	if not c then error("class expected, got nil",2) end
	for i=1, #c.methods do
		if c.methods[i].name == name then
			return c.methods[i]
		end
	end
end

function newInstance(class)
	local obj = {fields={},methods={},name=class.name,class=class}
	for i, v in pairs(class.fields) do
		obj.fields[i] = {type=v.type,attrib=v.attrib,value=nil}
	end
	for i, v in pairs(class.methods) do
		obj.methods[i] = v
	end
	
	return obj
end

function classByName(cn)
	local c = class[cn]
	if not c then
		local cd = cn:gsub("%.","/")
		local _ =
		loadJavaClass(fs.combine(jcd, cd..".class"))
		or
		loadJavaClass(fs.combine(fs.combine(jcd, "CCLib"), cd..".class"))
		if not _ then
			error("Cannot find class "..cn,0)
		else
			c = class[cn]
		end
	end
	return c
end

function createClass(super_name, cn)
	local cls = {}
	class[cn] = cls
	cls.fields = {}
	cls.methods = {}
	if super_name then -- we have a custom Object class file which won't have a super
		local super = classByName(super_name)
		for i,v in pairs(super.fields) do
			cls.fields[i] = v
		end
		for i,v in pairs(super.methods) do
			cls.methods[i] = v
		end
	end
	return cls
end