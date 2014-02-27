natives["java.io.PrintStream"] = natives["java.io.PrintStream"] or {}
natives["java.io.PrintStream"]["println(Ljava/lang/String;)V"] = function(this, str)
	print(str)
end

natives["java.io.PrintStream"]["println(Z)V"] = function(this, str)
	print(str)
end

natives["java.io.PrintStream"]["println(I)V"] = function(this, str)
	print(str)
end