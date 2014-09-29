natives["java.lang.Throwable"] = natives["java.lang.Throwable"] or {}

natives["java.lang.Throwable"]["fillInStackTrace()Ljava/lang/Throwable;"] = function(this)
	local stackTrace = newArray(getArrayClass("[Ljava.lang.StackTraceElement;"), 0)
	local lStackTrace = getStackTrace()
	stackTrace[4] = #lStackTrace - 1
	local StackTraceElement = classByName("java.lang.StackTraceElement")
	for i=1,#lStackTrace-1 do
		local v = lStackTrace[i]
		stackTrace[5][i] = newInstance(StackTraceElement)
		local m = findMethod(StackTraceElement, "<init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V")
		
		local lineNumber = v.lineNumber
		if bit.band(m.acc,METHOD_ACC.NATIVE) == METHOD_ACC.NATIVE then
			lineNumber = -2
		end
		m[1](stackTrace[5][i], toJString(v.className), toJString(v.methodName), toJString(v.fileName or ""), lineNumber or -1)
	end
	setObjectField(this, "stackTrace", stackTrace)
	return this
end