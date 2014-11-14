natives["cc.NativeObject"] = natives["cc.NativeObject"] or {}

natives["cc.NativeObject"]["hashCode()I"] = function (this)
    local stringClass = classByName("java.lang.String")
    return findMethod(stringClass, "hashCode()I")[1](toJString(tostring(this.native_data)))
end

natives["cc.NativeObject"]["toString()Ljava/lang/String;"] = function (this)
    return toJString(tostring(this.native_data))
end

natives["cc.NativeObject"]["equalsInner(Lcc/NativeObject;)Z"] = function (this,other)
    if other.native_data==this.native_data then
        return 1
    end
    return 0
end

