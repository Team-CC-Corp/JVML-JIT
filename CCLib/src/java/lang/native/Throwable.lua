natives["java.lang.Throwable"] = natives["java.lang.Throwable"] or {}

natives["java.lang.Throwable"]["fillInStackTrace()Ljava/lang/Throwable;"] = function(this)
	local stackTrace = newArray(getArrayClass("[Ljava.lang.StackTraceElement;"), 0)
	local lStackTrace = getStackTrace()
	stackTrace[4] = #lStackTrace
	local StackTraceElement = classByName("java.lang.StackTraceElement")
	for i,v in ipairs(lStackTrace) do
		stackTrace[5][i] = newInstance(StackTraceElement)
		local m = findMethod(StackTraceElement, "<init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V")
		local lineNumber = 0
		if bit.band(m.acc,METHOD_ACC.NATIVE) == METHOD_ACC.NATIVE then
			lineNumber = -2
		end
		m[1](stackTrace[5][i], toJString(v.className), toJString(v.methodName), toJString("?"), lineNumber)
	end
	setObjectField(this, "stackTrace", stackTrace)
	return this
end