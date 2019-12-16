-- use producers/consumer pool to avoid transaction disordered
local skynet = require "skynet"
require "skynet.manager"
local log = require "tm.log"
local xdump = require "tm.xtable".dump

local CMD = {}
local SERVICE_REDISC = "tm/db/redisc"

local config

local clients
local balance


function CMD.start(conf)
	if clients then
		log.warn("already started by: %s", xdump(config))
		return
	end
	if not conf then
		log.error("no Redis config!")
		return
	end
	clients = {}
	balance = 0
	for i = 1, conf.connects or 2 do
		local cli = skynet.newservice(SERVICE_REDISC)
		skynet.call(cli, "lua", "start", i, conf)
		table.insert(clients, cli)
	end
	config = conf
end


function CMD.stop()
	for _, cli in ipairs(clients) do
		skynet.send(cli, "lua", "stop")
	end
	clients = nil
	skynet.exit()
end


function CMD.client()
	if not clients then
		log.error("RedisDB clients not exist!")
		return nil
	end
	balance = (balance % #clients) + 1
	-- log.debug("get balance: %d", balance)
	return clients[balance]
end


skynet.start(function()
	skynet.dispatch("lua", function(_, _, cmd, ...)
		local f = assert(CMD[cmd], cmd .. " not found")
		skynet.retpack(f(...))
	end)
	skynet.register(".redisd")
end)
