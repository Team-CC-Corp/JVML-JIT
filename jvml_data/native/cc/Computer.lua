Computer = class["java.lang.Object"]:extend()
Computer.access = CLASS_ACC.PUBLIC+CLASS_ACC.FINAL

Computer:addMethods({
	acc=METHOD_ACC.PUBLIC+METHOD_ACC.NATIVE+METHOD_ACC.STATIC,
	function(a)
		os.shutdown()
	end,
	desc={
		{type="void"}
	},
	name = "shutdown"
})

Computer:addMethods({
	acc=METHOD_ACC.PUBLIC+METHOD_ACC.NATIVE+METHOD_ACC.STATIC,
	function(a)
		os.restart()
	end,
	desc={
		{type="void"}
	},
	name = "restart"
})

Computer:addMethods({
	acc=METHOD_ACC.PUBLIC+METHOD_ACC.NATIVE+METHOD_ACC.STATIC,
	function(a)
		--sleep(a)
	end,
	desc={
		{type="double"},
		{type="void"}
	},
	name = "sleep"
})

Computer:addMethods({
	acc=METHOD_ACC.PUBLIC+METHOD_ACC.NATIVE+METHOD_ACC.STATIC,
	function(a)
		return asBoolean(turtle ~= nil)
	end,
	desc={
		{type="boolean"}
	},
	name = "isTurtle"
})

Computer:addMethods({
	acc=METHOD_ACC.PUBLIC+METHOD_ACC.NATIVE+METHOD_ACC.STATIC,
	function(a)
		return asInt(os.time())
	end,
	desc={
		{type="int"}
	},
	name = "getTime"
})

return Computer
