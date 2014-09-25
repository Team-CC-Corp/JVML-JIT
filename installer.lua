-- use build.xml to import the zip and json libraries directly

local zip = {}
local json = {}

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
end

-- Begin installation

local githubApiResponse = http.get("https://api.github.com/repos/Yevano/JVML-JIT/releases")
assert(githubApiResponse.getResponseCode() == 200, "Failed github response")
print("Got github response")
local githubApiJSON = json.decode(githubApiResponse.readAll())
assert(githubApiJSON and
	githubApiJSON[1] and
	githubApiJSON[1].assets and
	githubApiJSON[1].assets[1] and
	githubApiJSON[1].assets[1].browser_download_url,
	"Malformed response")
print("Got JSON")
local zipResponse = http.get(githubApiJSON[1].assets[1].browser_download_url)
assert(githubApiResponse.getResponseCode() == 200, "Failed zip response")
local zipStr = zipResponse.readAll()

local i = 0
local zfs = zip.open({read=function()
	i = i + 1
	return zipStr:sub(i,i)
end})

local function copyFilesFromDir(dir)
	for i,v in ipairs(zfs.list(dir)) do
		local fullPath = fs.combine(dir, v)
		if zfs.isDir(fullPath) then
			copyFilesFromDir(fullPath)
		else
			print("Copying file: " .. fullPath)
			local fh = fs.open(fs.combine(shell.dir(), fullPath), "wb")
			local zfh = zfs.open(fullPath, "rb")
			for b in zfh.read do
				fh.write(b)
			end
			fh.close()
			zfh.close()
		end
	end
end

copyFilesFromDir("")
print("Installation complete. It is recommended that you add jvml/bin to your shell's path at startup")