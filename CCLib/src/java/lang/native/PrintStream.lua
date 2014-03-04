natives["java.io.PrintStream"] = natives["java.io.PrintStream"] or {}

natives["java.io.PrintStream"]["println(Ljava/lang/Object;)V"] = function(this, obj)
    if isPrimitive(obj) then
        obj = wrapPrimitive(obj)
    end
    local str = findMethod(obj.data, "toString()Ljava/lang/String;")[1](obj)
    print(toLString(str))
end