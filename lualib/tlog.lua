local skynet = require "skynet"
local queue = require "skynet.queue"
local cs = queue()
local nodename = skynet.getenv("nodename")

local logkv = {
    debug = 1,
    info = 2,
    warn = 3,
    error = 4,
    fatal = 5,
}

tlog = {}
LOG_LEVEL = logkv.debug


local function send_log(typ, level, fmt, ...)
    if level < LOG_LEVEL then 
        return 
    end
    
    local log = string.format(fmt, ...)
	local info = debug.getinfo(3)
	if info then
        -- local filename = info.short_src
        local filename = string.match(info.short_src, "[^/.]+.lua")
		log = string.format("[%s:%d] %s", filename, info.currentline, log)
	end
    
    skynet.send(".logger", "lua", "logging", typ, log)
end


for k, v in pairs(logkv) do
    local typ = string.upper(k)
    tlog[k] = function(fmt, ...)
        send_log(typ, v, fmt, ...)
    end
end

