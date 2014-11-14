natives["cc.LuaFunction"] = natives["cc.LuaFunction"] or {}

natives["cc.LuaFunction"]["call([Ljava/lang/Object;)[Ljava/lang/Object;"] = function (this, args)
    local t={}
    for k,v in ipairs(args[5]) do
        t[k]=j2lType(v)
    end
    local ret={this.native_data(unpack(t))}

    local jRet = newArray(getArrayClass("[Ljava.lang.Object;"), #ret)
    for i,v in ipairs(ret) do
        jRet[5][i] = l2jType(v)
    end
    return jRet
end

natives["cc.LuaFunction"]["hashCode()I"] = function (this)
    local stringClass = classByName("java.lang.String")
    return findMethod(stringClass, "hashCode()I")[1](toJString(tostring(this.native_data)))
end

natives["cc.LuaFunction"]["equals(Ljava/lang/Object;)Z"] = function (this,other)
    if (jInstanceOf(other,classByName("cc.LuaFunction"))~=0) then
        if other.native_data==this.native_data then
            return 1
        end
    end
    return 0
end

