natives["cc.redstone.SidedRedstone"] = natives["cc.redstone.SidedRedstone"] or {}

natives["cc.redstone.SidedRedstone"]["getInput()Z"] = function(this)
	local side = toLString(getObjectField(this, "side"))
	if rs.getInput(side) then
		return 1
	else
		return 0
	end
end

natives["cc.redstone.SidedRedstone"]["getOutput()Z"] = function(this)
	local side = toLString(getObjectField(this, "side"))
	if rs.getOutput(side) then
		return 1
	else
		return 0
	end
end

natives["cc.redstone.SidedRedstone"]["setOutput(Z)V"] = function(this, on)
	local side = toLString(getObjectField(this, "side"))
	rs.setOutput(side, on ~= 0)
end

natives["cc.redstone.SidedRedstone"]["getAnalogInput()I"] = function(this)
	local side = toLString(getObjectField(this, "side"))
	return rs.getAnalogInput(side)
end

natives["cc.redstone.SidedRedstone"]["getAnalogOutput()I"] = function(this)
	local side = toLString(getObjectField(this, "side"))
	return rs.getAnalogOutput(side)
end

natives["cc.redstone.SidedRedstone"]["setAnalogOutput(I)V"] = function(this, val)
	local side = toLString(getObjectField(this, "side"))
	rs.setAnalogOutput(side, val)
end