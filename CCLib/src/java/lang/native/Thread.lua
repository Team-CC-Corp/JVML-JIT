natives["java.lang.Thread"] = natives["java.lang.Thread"] or {}

natives["java.lang.Thread"]["start0()V"] = function(this)
    createThread(this)
end