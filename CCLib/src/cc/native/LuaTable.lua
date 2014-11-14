natives["cc.LuaTable"] = natives["cc.LuaTable"] or {}

natives["cc.LuaTable"]["getValue(Ljava/lang/Object;)Ljava/lang/Object;"] = function (this, key)
    local a=this.native_data[j2lType(key)]
    if a==nil then return nil end
    return l2jType(a)
end

natives["cc.LuaTable"]["setValue(Ljava/lang/Object;Ljava/lang/Object;)V"] = function (this, key, val)
    this.native_data[j2lType(key)]=j2lType(val)
end

natives["cc.LuaTable"]["entries()[Ljava/lang/Object;"] = function (this)
    local i=1
    local size=0
    for k,v in pairs(this.native_data) do
        size=size+2
    end
    local jRet = newArray(getArrayClass("[Ljava.lang.Object;"), size)
    for k,v in pairs(this.native_data) do
        jRet[5][i]=l2jType(k)
        i=i+1
        jRet[5][i]=l2jType(v)
        i=i+1
    end
    return jRet
end

natives["cc.LuaTable"]["newTable()V"] = function (this)
    this.native_data={}
end
