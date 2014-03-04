natives["java.lang.Object"] = natives["java.lang.Object"] or {}
natives["java.lang.Object"]["toString()Ljava/lang/String;"] = function(this)
	return toJString(tostring(this.data):sub(8))
end