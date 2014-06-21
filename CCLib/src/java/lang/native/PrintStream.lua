natives["java.io.PrintStream"] = natives["java.io.PrintStream"] or {}

natives["java.io.PrintStream"]["println(Ljava/lang/Object;)V"] = function(this, obj)
	if not obj then
		print("(null)")
	else
	    local str = findMethod(obj[1], "toString()Ljava/lang/String;")[1](obj)
	    print(toLString(str))
	end
end