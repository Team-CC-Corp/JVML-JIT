------------------------------------------------------------------
-- Parameter
------------------------------------------------------------------

local Parameter = {}
function Parameter:matches(arg, options, tArgs)
	if arg:sub(1,1) ~= "-" then
		return false
	end
	arg = arg:sub(2)
	
	if not (arg:find("^"..self.name.."$") or arg:find("^"..self.sShortcut.."$")) then
		return false
	end

	local val = table.remove(tArgs, 1)

	if self.isMulti then
		options[self.name] = options[self.name] or {}
		table.insert(options[self.name], val)
	else
		options[self.name] = val
	end

	return true
end

function Parameter:shortcut(shortcut)
	self.sShortcut = shortcut
	return self
end

function Parameter:multi()
	self.isMulti = true
	return self
end

------------------------------------------------------------------
-- Switch
------------------------------------------------------------------

local Switch = {}
function Switch:matches(arg, options, tArgs)
	if arg:sub(1,1) ~= "-" then
		return false
	end
	arg = arg:sub(2)
	
	if not (arg:find("^"..self.name.."$") or arg:find("^"..self.sShortcut.."$")) then
		return false
	end

	options[self.name] = true
	return true
end

function Switch:shortcut(shortcut)
	self.sShortcut = shortcut
	return self
end

------------------------------------------------------------------
-- Argument
------------------------------------------------------------------

local Argument = {}
function Argument:matches(arg, options, tArgs)
	if self.matched then
		return false
	end

	if self.nCount == 1 then
		options[self.name] = arg
	else
		local count = self.nCount
		if count == "*" then
			count = #tArgs
		else
			count = count - 1
		end
		local args = {arg}
		for i=1, count do
			table.insert(args, table.remove(tArgs, 1))
		end
		options[self.name] = args
	end

	self.matched = true
	return true
end

function Argument:count(count)
	assert(type(count) == "number" or count == "*", "Bad argument to Argument:count. Expected number, got " .. count)
	self.nCount = count
	return self
end

------------------------------------------------------------------
-- Parser
------------------------------------------------------------------

local Parser = {}
function Parser:parameter(name)
	local param = setmetatable({name=name,sShortcut=name}, {__index=Parameter})
	table.insert(self.parameters, param)
	return param
end

function Parser:switch(name)
	local switch = setmetatable({name=name,sShortcut=name}, {__index=Switch})
	table.insert(self.switches, switch)
	return switch
end

function Parser:argument(name)
	local arg = setmetatable({name=name,nCount=1}, {__index=Argument})
	table.insert(self.arguments, arg)
	return arg
end

function Parser:usage(str)
	self.sUsage = str
end

function Parser:printUsage()
	print(self.sUsage)
end

function Parser:parseArg(arg, options, tArgs)
	for i,v in ipairs(self.parameters) do
		if v:matches(arg, options, tArgs) then
			return true
		end
	end
	for i,v in ipairs(self.switches) do
		if v:matches(arg, options, tArgs) then
			return true
		end
	end
	for i,v in ipairs(self.arguments) do
		if v:matches(arg, options, tArgs) then
			return true
		end
	end
	return false
end

function Parser:parse(options, ...)
	local tArgs = {...}
	for arg in function() return table.remove(tArgs, 1) end do
		if not self:parseArg(arg, options, tArgs) then
			print(tArgs.error or ("Unknown argument: "..arg))
			self:printUsage()
			return false
		end
	end
	return options
end

function new()
	local parser = setmetatable({parameters={},switches={},arguments={}}, {__index=Parser})
	return parser
end