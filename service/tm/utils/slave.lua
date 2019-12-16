-- pick by master, then call slave to exec
local skynet = require "skynet"
local log = require "tm.log"

local handler

local function excute(method, ...)
	local f = handler[method]
	if not f then
		log.error("slave have no method:%d", method)
		return
	end
	return f(...)
end


local CMD = {}

function CMD.start(filepath, ...)
	handler = assert(require(filepath), "require failed!")
	excute("onstart", ...)
end

function CMD.stop(...)
	excute("onstop", ...)
	skynet.exit()
end

function CMD.exec(method, ...)
	return excute("onexec", method, ...)
end

skynet.start(function()
	skynet.dispatch("lua", function(_, _, cmd, ...)
		local f = assert(CMD[cmd], cmd .. " not found")
		skynet.retpack(f(...))
	end)
end)
