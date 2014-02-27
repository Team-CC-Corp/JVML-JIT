natives["cc.Computer"] = natives["cc.Computer"] or {}
natives["cc.Computer"]["shutdown()V"] = function()
	os.shutdown()
end

natives["cc.Computer"]["restart()V"] = function()
	os.restart()
end

natives["cc.Computer"]["sleep(D)V"] = function()end

natives["cc.Computer"]["isTurtle()Z"] = function()
	return asBoolean(turtle ~= nil)
end

natives["cc.Computer"]["getTime()int"] = function()
	return asInt(os.time())
end