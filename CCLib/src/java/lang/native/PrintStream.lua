natives["java.io.PrintStream"] = natives["java.io.PrintStream"] or {}

natives["java.io.PrintStream"]["println(Ljava/lang/String;)V"] = function(this, str)
	if not str then
		print("(null)")
	else
	    print(toLString(str))
	end
end

natives["java.io.PrintStream"]["print(Ljava/lang/String;)V"] = function(this, str)
    if not str then
        io.write("(null)")
    else
        io.write(toLString(str))
    end
end