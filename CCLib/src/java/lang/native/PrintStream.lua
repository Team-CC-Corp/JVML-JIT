natives["java.io.PrintStream"] = natives["java.io.PrintStream"] or {}

local function lprint(s)
	if s ~= nil then
		print(s)
	else
		print("(null)")
	end
end

natives["java.io.PrintStream"]["println(Ljava/lang/String;)V"] = function(this, str)
	lprint(str)
end

natives["java.io.PrintStream"]["println(Z)V"] = function(this, str)
	lprint(str)
end

natives["java.io.PrintStream"]["println(I)V"] = function(this, str)
	lprint(str)
end