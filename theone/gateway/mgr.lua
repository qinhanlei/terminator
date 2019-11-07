local skynet = require "skynet"
local log = require "log"

local CMD = {}

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = CMD[cmd]
		if f then
			skynet.retpack(f(...))
		else
			log.error("from[%s:%s] cmd:%s not found", session, source, cmd)
		end
	end)

	local gated = skynet.uniqueservice("gateway/gated")
	skynet.send(gated, "lua", "start", "localhost", 10086)

	skynet.uniqueservice("gateway/logind")
end)
