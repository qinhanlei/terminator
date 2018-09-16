local skynet = require "skynet"
local tlog = require "tlog"

local CMD = {}


function CMD.hi()
	tlog.info("Hello! this is Terminator :)")
end


skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		skynet.retpack(f(...))
	end)
end)
