PrintStream = class["java.lang.Object"]:extend()

PrintStream:addMethods({
	acc=METHOD_ACC.PUBLIC+METHOD_ACC.NATIVE,
	function(this,a)
		print(a)
	end,
	desc={
		{type="java.lang.String"},
		{type="void"}
	},
	name = "println"
})

PrintStream:addMethods({
	acc=METHOD_ACC.PUBLIC+METHOD_ACC.NATIVE,
	function(this,a)
		print(a)
	end,
	desc={
		{type="boolean"},
		{type="void"}
	},
	name = "println"
})

PrintStream:addMethods({
	acc=METHOD_ACC.PUBLIC+METHOD_ACC.NATIVE,
	function(this,a)
		print(a)
	end,
	desc={
		{type="int"},
		{type="void"}
	},
	name = "println"
})

return PrintStream
