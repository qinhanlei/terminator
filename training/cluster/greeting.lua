local skynet = require "skynet"
local cluster = require "cluster"

local logger = require "simple-logger"


local CMD = {}

function CMD.hi(msg)
	logger("receive msg:", msg.content)
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		skynet.retpack(f(...))
	end)
end)
