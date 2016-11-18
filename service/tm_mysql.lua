local skynet = require "skynet"
require "skynet.manager"

local nodename = skynet.getenv("nodename")

local CMD = {}


skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. " not found")
		f(source, ...)
	end)

end)
