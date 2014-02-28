natives["java.lang.Object"] = natives["java.lang.Object"] or {}
natives["java.lang.Object"]["toString()Ljava/lang/String;"] = function(this)
	return asObjRef(tostring(this):sub(8), "Ljava/lang/String;")
end