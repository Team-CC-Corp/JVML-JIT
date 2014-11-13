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
    return (turtle ~= nil) and 1 or 0
end

natives["cc.Computer"]["getTime()I"] = function()
    return os.time()
end

natives["cc.Computer"]["getClock()F"] = function()
    return os.clock()
end

local function createEvent(type, ... )
    local jType = toJString(type)

    local lArgs = { ... }
    local jArgs = newArray(getArrayClass("[java.lang.Object;"), #lArgs)
    for i,v in ipairs(lArgs) do
        jArgs[5][i] = l2jType(v)
    end

    local event = newInstance(classByName("cc.event.Event"))
    findMethod(event[1], "<init>(Ljava/lang/String;[Ljava/lang/Object;)V")[1](event, jType, jArgs)
    return event
end

natives["cc.Computer"]["pullEvent()Lcc/event/Event;"] = function()
    return createEvent(os.pullEvent())
end

natives["cc.Computer"]["pullEvent(Ljava/lang/String;)Lcc/event/Event;"] = function(filter)
    local lFilter = toLString(filter)
    return createEvent(os.pullEvent(lFilter))
end

natives["cc.Computer"]["pullEventRaw()Lcc/event/Event;"] = function()
    return createEvent(os.pullEventRaw())
end

natives["cc.Computer"]["pullEventRaw(Ljava/lang/String;)Lcc/event/Event;"] = function(filter)
    local lFilter = toLString(filter)
    return createEvent(os.pullEventRaw(lFilter))
end

natives["cc.Computer"]["queueEvent(Lcc/event/Event;)V"] = function(e)
    local lArgs = {}
    for i,v in ipairs(getObjectField(e, "args")[5]) do
        lArgs[i] = j2lType(v)
    end
    local lType = toLString(getObjectField(e, "type"))

    os.queueEvent(lType, unpack(lArgs))
end

natives["cc.Computer"]["startTimer(D)I"] = function(t)
    return os.startTimer(t)
end

natives["cc.Computer"]["setAlarm(D)I"] = function(t)
    return os.setAlarm(t)
end

natives["cc.Computer"]["getVersion()Ljava/lang/String;"] = function()
    return toJString(os.version())
end

natives["cc.Computer"]["getComputerID()I"] = function()
    return os.getComputerID()
end

natives["cc.Computer"]["getComputerLabel()Ljava/lang/String;"] = function()
    local l = os.getComputerLabel()
    if l then
        return toJString(l)
    else
        return nil
    end
end

natives["cc.Computer"]["setComputerLabel(Ljava/lang/String;)V"] = function(s)
    os.setComputerLabel(toLString(s))
end

natives["cc.Computer"]["read()Ljava/lang/String;"] = function()
    return toJString(read())
end

natives["cc.Computer"]["read(Ljava/lang/String;)Ljava/lang/String;"] = function(s)
    return toJString(read(toLString(s)))
end