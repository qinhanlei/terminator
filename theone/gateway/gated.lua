local skynet = require "skynet"
local socket = require "skynet.socket"

local thread = tonumber(skynet.getenv("thread"))
local CMD = {}


function CMD.start(ip, port, protocol)
	local agent = {}
	local balance = 1
	for i = 1, thread do
		agent[i] = skynet.newservice("gateway/agent")
	end
	local listenid = socket.listen(ip, port)
	socket.start(listenid, function(id, addr)
		skynet.send(agent[balance], "lua", "start", id, addr, protocol or "ws")
		balance = (balance % #agent) + 1
	end)
end


skynet.start(function()
	skynet.dispatch("lua", function(_, _, cmd, ...)
		local f = assert(CMD[cmd], cmd .. " not found")
		skynet.retpack(f(...))
	end)
end)
