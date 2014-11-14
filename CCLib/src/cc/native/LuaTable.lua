natives["cc.LuaTable"] = natives["cc.LuaTable"] or {}

natives["cc.LuaTable"]["getValue(Ljava/lang/Object;)Ljava/lang/Object;"] = function (this, key)
    local a=getObjectField(this,"NATIVE_handle")[j2lType(key)]
    if a==nil then return nil end
    return l2jType(a)
end

