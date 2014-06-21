natives["java.lang.Math"] = natives["java.lang.Math"] or {}

natives["java.lang.Math"]["pow(DD)D"] = function(a, b)
	return a^b
end