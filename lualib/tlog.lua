local skynet = require "skynet"

local logkv = {
	debug = 1,
	info = 2,
	warn = 3,
	error = 4,
	fatal = 5,
}

tlog = {}
LOG_LEVEL = logkv.debug


local function concat(t)
	if #t == 0 then return "nil" end
	local ret = ""
	for _, v in pairs(t) do
		if string.len(ret) == 0 then
			ret = tostring(v)
		else
			ret = ret .. " " .. tostring(v)
		end
	end
	return ret
end


local function send_log(typ, level, fmt, ...)
	if level < LOG_LEVEL then
		return
	end
	
	local ok, str = pcall(string.format, fmt, ...)
	if not ok then
		typ = "ERROR"
		-- str = str .. ":\n" .. concat({fmt, "|", ...})
	end
	
	local info = debug.getinfo(3)
	if info then
		local filename = string.match(info.short_src, "[^/.]+.lua")
		str = string.format("[%s:%d] %s", filename, info.currentline, str)
	end
	
	if TEST_LOGGER then
		skynet.call(".logger", "lua", "logging_ret", typ, str)
	else
		skynet.send(".logger", "lua", "logging", typ, str)
	end
end


for k, v in pairs(logkv) do
	local typ = string.upper(k)
	tlog[k] = function(fmt, ...)
		send_log(typ, v, fmt, ...)
	end
end
