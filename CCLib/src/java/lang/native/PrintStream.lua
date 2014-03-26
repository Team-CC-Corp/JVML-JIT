natives["java.io.PrintStream"] = natives["java.io.PrintStream"] or {}

natives["java.io.PrintStream"]["println(Ljava/lang/Object;)V"] = function(this, obj)
    local str = findMethod(obj[1], "toString()Ljava/lang/String;")[1](obj)
    realPrint(toLString(str))
end