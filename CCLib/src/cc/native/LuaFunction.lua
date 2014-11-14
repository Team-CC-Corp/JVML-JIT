natives["cc.LuaFunction"] = natives["cc.LuaFunction"] or {}

natives["cc.LuaFunction"]["compileCode(Ljava/lang/String;)V"] = function (this,code)
    this.native_data=loadstring(code)
end

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
