local skynet = require "skynet"
require "skynet.manager"
local log = require "tm.log"
local xdump = require "tm.xtable".dump

local CMD = {}

local config
local logicf

local clients
local balance


function CMD.start(conf, logicfile)
	if clients then
		log.warn("already started by: %s - %s", logicf, xdump(config))
		return false
	end
	if not conf then
		log.error("have no config!")
		return false
	end
	clients = {}
	balance = 0
	-- log.info("MongoDB config: %s", xtable.dump(conf))
	for i = 1, conf.connects or 2 do
		local cli = skynet.newservice("tm/db/mongoc")
		skynet.call(cli, "lua", "start", i, conf, logicfile)
		table.insert(clients, cli)
	end
	config, logicf = conf, logicfile
	return true
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
		log.error("clients not exist!")
		return nil
	end
	balance = (balance % #clients) + 1
	return clients[balance]
end


skynet.start(function()
	skynet.dispatch("lua", function(_, _, cmd, ...)
		local f = assert(CMD[cmd], cmd .. " not found")
		skynet.retpack(f(...))
	end)
	skynet.register(".mongod")
end)
