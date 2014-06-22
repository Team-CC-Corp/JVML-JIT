local jcd = shell.resolve(fs.combine(fs.getDir(shell.getRunningProgram()), ".."))
local program = fs.combine(jcd, "bin/jvml")
local tests = fs.combine(jcd, "tests/build")

shell.run(program, "-cp", tests, "-g")
local vm = jvml.popVM()

for i,v in ipairs(fs.list(tests)) do
	if v:sub(-6) == ".class" and not v:find("^%.") then
		v = v:sub(1, -7)
		local jArray = vm.newArray(vm.getArrayClass("[Ljava.lang.String;"), 0)
	    local m = vm.findMethod(vm.classByName(v), "main([Ljava/lang/String;)V")
	    if m then
		    local ok, err = pcall(m[1], jArray)
		    if not ok then
		    	printError(err)
		        vm.printStackTrace(true)
		    end
		end
	end
end