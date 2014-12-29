natives["java.lang.System"] = natives["java.lang.System"] or {}

natives["java.lang.System"]["load(Ljava/lang/String;)V"] = function(jString)
    local str = toLString(jString)
    classpath.dofile(str)
end

-- TODO: Reimplement this less naively
natives["java.lang.System"]["arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V"] = function(
    src, srcPos, dest, destPos, length)
    for i=1,length do
        dest[5][i + destPos] = src[5][i + srcPos]
    end
end

natives["java.lang.System"]["initProperties()V"] = function()
    local defaultProps = {
        ["file.separator"]  = "/"
        ["line.separator"]  = "\n"
        ["path.separator"]  = ":"
        ["user.dir"      ]  = shell.dir()
    }

    local System = classByName("java.lang.System")
    local propsMap = System.fields[System.fieldIndexByName["props"]]
    local put = findMethod(propsMap[1], "put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;")[1]

    for k,v in pairs(defaultProps) do
        put(propsMap, toJString(tostring(k)), toJString(tostring(v)))
    end
end