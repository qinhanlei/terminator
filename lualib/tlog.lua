local skynet = require "skynet"


local function send_log(level, fmt, ...)
	local ok, str = pcall(string.format, fmt, ...)
	if not ok then
		print("format error: %s", str)
		return
	end
	local info = debug.getinfo(3)
	if info then
		local filename = string.match(info.short_src, "[^/.]+.lua")
		str = string.format("[%s:%d] %s", filename, info.currentline, str)
	end
	skynet.send(".logger", "lua", "logging", level, str)
end


return {
	debug = function(fmt, ...) send_log(1, fmt, ...) end,
	info = function(fmt, ...) send_log(2, fmt, ...) end,
	warn = function(fmt, ...) send_log(3, fmt, ...) end,
	error = function(fmt, ...) send_log(4, fmt, ...) end,
	fatal = function(fmt, ...) send_log(5, fmt, ...) end,
}
