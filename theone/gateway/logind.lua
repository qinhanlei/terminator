local skynet = require "skynet"
local log = require "log"

local CMD = {}

function CMD.register()
	--TODO:...
end

function CMD.auth()
	--TODO:...
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = CMD[cmd]
		if f then
			skynet.retpack(f(...))
		else
			log.error("from[%s:%s] cmd:%s not found", session, source, cmd)
		end
	end)
end)
