natives["cc.LuaTable"] = natives["cc.LuaTable"] or {}

natives["cc.LuaTable"]["getValue(Ljava/lang/Object;)Ljava/lang/Object;"] = function (this, key)
    local a=this.native_data[j2lType(key)]
    if a==nil then return nil end
    return l2jType(a)
end

natives["cc.LuaTable"]["setValue(Ljava/lang/Object;Ljava/lang/Object;)V"] = function (this, key, val)
    this.native_data[j2lType(key)]=j2lType(val)
end

natives["cc.LuaTable"]["hashCode()I"] = function (this)
    local stringClass = classByName("java.lang.String")
    return findMethod(stringClass, "hashCode()I")[1](toJString(tostring(this.native_data)))
end

natives["cc.LuaTable"]["equals(Ljava/lang/Object;)Z"] = function (this,other)
    if (jInstanceOf(other,classByName("cc.LuaTable"))~=0) then
        if other.native_data==this.native_data then
            return 1
        end
    end
    return 0
end

natives["cc.LuaTable"]["entries()[Ljava/lang/Object;"] = function (this)
    local jRet = newArray(getArrayClass("[Ljava.lang.Object;"), (#(this.native_data))*2)
    local i=1
    for k,v in pairs(this.native_data) do
        jRet[5][i]=l2jType(k)
        i=i+1
        jRet[5][i]=l2jType(v)
        i=i+1
    end
    return jRet
end

