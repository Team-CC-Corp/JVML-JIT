natives["java.lang.System"] = natives["java.lang.System"] or {}

natives["java.lang.System"]["load(Ljava/lang/String;)V"] = function(jString)
	local str = toLString(jString)
	local path = resolvePath(str)
	dofile(path)
end