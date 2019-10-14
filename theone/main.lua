local skynet = require "skynet"
local tlog = require "tlog"

local CMD = {}


function CMD.hi()
	tlog.info("Hello! this is Terminator :)")
end


skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = CMD[cmd]
		if f then
			skynet.retpack(f(...))
		else
			tlog.error("from[%s:%s] cmd:%s not found", session, source, cmd)
			assert(false, "dispatch failed!")
		end
	end)
end)
