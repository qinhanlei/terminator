local skynet = require "skynet"
require "skynet.manager"
local log = require "tm.log"
local xtable = require "tm.xtable"

local CMD = {}

local clients = {}
local balance = 0


function CMD.client()
	if not clients then
		log.error("MongoDB clients not exist!")
		return nil
	end
	balance = (balance % #clients) + 1
	return clients[balance]
end


function CMD.start(conf, logiclua)
	assert(#clients == 0, "already started!")
	if not conf then
		log.error("no MongoDB config!")
		return
	end
	log.info("MongoDB config: %s", xtable.dump(conf))
	for i = 1, conf.connects or 2 do
		local cli = skynet.newservice("tm/mongoc")
		skynet.call(cli, "lua", "start", i, conf, logiclua)
	end
end


skynet.start(function()
	skynet.dispatch("lua", function(_, _, cmd, ...)
		local f = assert(CMD[cmd], cmd .. " not found")
		skynet.retpack(f(...))
	end)
	skynet.register(".mongod")
end)
