-- use build.xml to import the zip and json libraries directly

local zip = setmetatable({}, {__index=getfenv()})
local json = setmetatable({}, {__index=getfenv()})
local base64 = setmetatable({}, {__index=getfenv()})

do
	local function zip_api_make()
		@ZIP@
	end
	setfenv(zip_api_make, zip)
	zip_api_make()

	local function json_api_make()
		@JSON@
	end
	setfenv(json_api_make, json)
	json_api_make()

	local function base64_api_make()
		@BASE64@
	end
	setfenv(base64_api_make, base64)
	base64_api_make()
end

local oldTime = os.time()
local function sleepCheckin()
	local newTime = os.time()
	if newTime - oldTime >= (0.020 * 2) then
		oldTime = newTime
		sleep(0)
	end
end

local function combine(path, ...)
	if not path then
		return ""
	end
	return fs.combine(path, combine(...))
end

-- Begin installation

local githubApiResponse = assert(http.get("https://api.github.com/repos/Yevano/JVML-JIT/releases"))
assert(githubApiResponse.getResponseCode() == 200, "Failed github response")
print("Got github response")
local githubApiJSON = json.decode(githubApiResponse.readAll())
assert(githubApiJSON and
	githubApiJSON[1] and
	githubApiJSON[1].assets and
	githubApiJSON[1].assets[1] and
	githubApiJSON[1].assets[1].url,
	"Malformed response")
print("Got JSON")
local zipResponse = assert(http.get(githubApiJSON[1].assets[1].url, {["Accept"]="application/octet-stream"}))
assert(zipResponse.getResponseCode() == 200 or zipResponse.getResponseCode() == 302, "Failed zip response")
local base64Str = zipResponse.readAll()
print("Decoding base64")
sleep(0)
local zipTbl = assert(base64.decode(base64Str), "Failed to decode base 64")
print("Zip scanned. Unarchiving...")
sleep(0)

local i = 0
local zfs = zip.open({read=function()
	sleepCheckin()
	i = i + 1
	return zipTbl[i]
end})

local function copyFilesFromDir(dir)
	for i,v in ipairs(zfs.list(dir)) do
		sleepCheckin()
		local fullPath = fs.combine(dir, v)
		if zfs.isDir(fullPath) then
			copyFilesFromDir(fullPath)
		else
			print("Copying file: " .. fullPath)
			local fh = fs.open(combine(shell.dir(), "jvml", fullPath), "wb")
			local zfh = zfs.open(fullPath, "rb")
			for b in zfh.read do
				sleepCheckin()
				fh.write(b)
			end
			fh.close()
			zfh.close()
		end
	end
end

copyFilesFromDir("")
print("Installation complete. It is recommended that you add jvml/bin to your shell's path at startup")