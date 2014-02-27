--Object is the baseclass of everything!--
local Object = {}
FROM = nil

local function fieldManager(fields) --this creates a manager for the fields of created objects
	return setmetatable({},{__index=function(_,i)
		--check if field is protected or private
	end,__newindex=function(_,i,v)
		--check if field is protected, private, or final
		--also check type of value
	end})
end

local function methodManager(methods) --this creates a manager for the methods of created objects
	return setmetatable({},{__index=function(_,i)
		local m = methods[i]
		if FROM then
			if bit.band(m.acc,METHOD_ACC.PROTECTED) == 1 and not true then --todo: firgure out if from is subclass of current
				error("Cannot access a protected method from a non subclass")
			end
			if bit.band(m.acc,METHOD_ACC.PRIVATE) == 1 and not true then --todo: firgure out if from is me
				error("Cannot access a private method from outside of class")
			end
		end
		return m
	end})
end

function Object:new(cf)
	local obj = {fields={},methods={},name=self.name,class=self}
	local hc = tonumber(tostring(obj):sub(8),16)
	obj.hashCode = hc
	for i, v in pairs(self.fields) do
		obj.fields[i] = {type=v.type,attrib=v.attrib,value=nil}
	end
	for i, v in pairs(self.methods) do
		obj.methods[i] = v
	end
	obj.fields = fieldManager(obj.fields)
	obj.methods = methodManager(obj.methods)
	if self.methods["<init>"] and bit.band(self.methods["<init>"].acc,METHOD_ACC.PUBLIC) == 1 then
		self.methods["<init>"][1](obj)
	end
	return obj
end

function Object:extend()
	if bit.band(self.access,CLASS_ACC.FINAL) == 1 then error("Cannot extend final class") end
	local obj = {fields={},methods={},name="?",access=self.access,init=self.init,new=self.new,extend=self.extend,super=self.name,addMethods=self.addMethods}
	for i, v in pairs(self.fields) do
		obj.fields[i] = v
	end
	for i, v in pairs(self.methods) do
		obj.methods[i] = v
	end
	return obj
end

local function descToDescriptor(desc)
	local d = "("
	for i=1, #desc-1 do
		local v = desc[i].type
		if v == "int" then
			d = d.."I"
		elseif v == "double" then
			d = d.."D"
		elseif v == "void" then
			d = d.."V"
		elseif v == "boolean" then
			d = d.."Z"
		else
			d = d.."L"..v:gsub("%.","/")..";"
		end
	end
	d = d..")"
	local v = desc[#desc].type
	if v == "int" then
		d = d.."I"
	elseif v == "double" then
		d = d.."D"
	elseif v == "void" then
		d = d.."V"
	elseif v == "boolean" then
		d = d.."Z"
	else
		d = d.."L"..v:gsub("%.","/")..";"
	end
	return d
end

function Object:addMethods(m)
	m.name = m.name..descToDescriptor(m.desc)
	self.methods[#self.methods+1] = m
end

--Java stuff--
Object.fields = {}
Object.methods = {}
Object.name = "java.lang.Object"
Object.access = CLASS_ACC.PUBLIC

Object.methods.clone = {acc=METHOD_ACC.PROTECTED+METHOD_ACC.NATIVE,function (this)
	--TODO: Throw
end}

Object.methods.hashCode = {acc=METHOD_ACC.PUBLIC+METHOD_ACC.NATIVE,function (this)
	return this.hashCode
end}



Object:addMethods({
	acc=METHOD_ACC.PUBLIC+METHOD_ACC.NATIVE,
	function(this)
	end,
	desc={
		{type="void"}
	},
	name = "<init>"
})

return Object
