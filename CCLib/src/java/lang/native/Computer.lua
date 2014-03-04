natives["cc.Computer"] = natives["cc.Computer"] or {}
natives["cc.Computer"]["shutdown()V"] = function()
    os.shutdown()
end

natives["cc.Computer"]["restart()V"] = function()
    os.restart()
end

natives["cc.Computer"]["sleep(D)V"] = function()end

natives["cc.Computer"]["isTurtle()Z"] = function()
    return asBoolean(turtle ~= nil)
end

natives["cc.Computer"]["getTime()I"] = function()
    return asInt(os.time())
end

natives["cc.Computer"]["getClock()F"] = function()
    return asFloat(os.clock())
end

natives["cc.Computer"]["pullEvent(Ljava/lang/String;)Lcc/Event;"] = function(filter)
    local typ, args
    (function(t, arg0, ...)
        typ = toJString(t)
        args = { ... }
        args.length = #args
        args[0] = arg0
    end)(os.pullEvent(toLString(filter)))

    if args[0] then
        local v = args[0]
        if type(v) == "string" then
            args[0] = toJString(v)
        elseif type(v) == "number" then
            -- TODO: Decide proper sized primitive type
            args[0] = asDouble(v)
        end
        args.length = args.length + 1
    end

    for i = 0, args.length - 1 do
        local v = args[i]
        if type(v) == "string" then
            args[i] = toJString(v)
        elseif type(v) == "number" then
            -- TODO: Decide proper sized primitive type
            args[i] = asDouble(v)
        end
    end

    local event = newInstance(classByName("cc.Event"))
    local ref = asObjRef(event, "Lcc/Event")
    findMethod(event, "<init>(Ljava/lang/String;[Ljava/lang/Object;)V")[1](ref, typ, asObjRef(args, "[Ljava/lang/Object;"))
    return ref
end