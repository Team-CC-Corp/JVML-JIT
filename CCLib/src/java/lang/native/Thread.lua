natives["java.lang.Thread"] = natives["java.lang.Thread"] or {}

natives["java.lang.Thread"]["yield()V"] = function()
    coroutine.yield()
end

natives["java.lang.Thread"]["start0()V"] = function(this)
    createThread(this)
end

natives["java.lang.Thread"]["currentThread()Ljava/lang/Thread;"] = function()
    return getCurrentThread()
end

natives["java.lang.Thread"]["sleep(J)V"] = function(ms)
    sleep(bigintToDouble(ms))
end