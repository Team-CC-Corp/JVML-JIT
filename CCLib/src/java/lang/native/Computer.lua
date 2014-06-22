natives["cc.Computer"] = natives["cc.Computer"] or {}
natives["cc.Computer"]["shutdown()V"] = function()
    os.shutdown()
end

natives["cc.Computer"]["restart()V"] = function()
    os.restart()
end

natives["cc.Computer"]["sleep(D)V"] = function(s)
    sleep(s)
end

natives["cc.Computer"]["isTurtle()Z"] = function()
    return turtle ~= nil
end

natives["cc.Computer"]["getTime()I"] = function()
    return os.time()
end

natives["cc.Computer"]["getClock()F"] = function()
    return os.clock()
end

natives["cc.Computer"]["pullEvent()Lcc/Event;"] = function()
    local typ, args
    (function(t, arg0, ...)
        typ = toJString(t)
        args = { ... }
        args.length = #args
        args[1] = arg0
    end)(os.pullEvent())

    if args[1] then
        local v = args[1]
        if type(v) == "string" then
            args[1] = toJString(v)
        elseif type(v) == "number" then
            args[1] = wrapPrimitive(v, "D")
        end
        args.length = args.length + 1
    end

    for i = 2, args.length do
        local v = args[i]
        if type(v) == "string" then
            args[i] = toJString(v)
        elseif type(v) == "number" then
            args[i] = wrapPrimitive(v, "D")
        end
    end

    local eventClass = classByName("cc.Event")
    local event = newInstance(eventClass)
    local argsRef = newArray(getArrayClass("[java.lang.Object;"), #args)
    argsRef[5] = args
    findMethod(eventClass, "<init>(Ljava/lang/String;[Ljava/lang/Object;)V")[1](event, typ, argsRef)
    return event
end

natives["cc.Computer"]["pullEvent(Ljava/lang/String;)Lcc/Event;"] = function(filter)
    local typ, args
    (function(t, arg0, ...)
        typ = toJString(t)
        args = { ... }
        args.length = #args
        args[1] = arg0
    end)(os.pullEvent(toLString(filter)))

    if args[1] then
        local v = args[1]
        if type(v) == "string" then
            args[1] = toJString(v)
        elseif type(v) == "number" then
            args[1] = wrapPrimitive(v, "D")
        end
        args.length = args.length + 1
    end

    for i = 2, args.length do
        local v = args[i]
        if type(v) == "string" then
            args[i] = toJString(v)
        elseif type(v) == "number" then
            args[i] = wrapPrimitive(v, "D")
        end
    end

    local eventClass = classByName("cc.Event")
    local event = newInstance(eventClass)
    local argsRef = { #args, classByName("java.lang.Object"), args }
    findMethod(eventClass, "<init>(Ljava/lang/String;[Ljava/lang/Object;)V")[1](event, typ, argsRef)
    return event
end