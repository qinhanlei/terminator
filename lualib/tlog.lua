local skynet = require "skynet"


tlog = {} -- global util

local logkv = {debug=1, info=2, warn=3, error=4, fatal=5}
local LOG_LEVEL = LOG_LEVEL or logkv.debug


local function send_log(typ, level, fmt, ...)
	if level < LOG_LEVEL then
		return
	end
	
	local ok, str = pcall(string.format, fmt, ...)
	if not ok then
		typ = "ERROR"
		-- str = str .. ":\n" .. util.concat({fmt, "|", ...})
	end
	
	local info = debug.getinfo(3)
	if info then
		local filename = string.match(info.short_src, "[^/.]+.lua")
		str = string.format("[%s:%d] %s", filename, info.currentline, str)
	end
	
	if TM_DEBUG then
		skynet.call(".logger", "lua", "logtest", typ, str)
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
