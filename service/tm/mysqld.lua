local skynet = require "skynet"
require "skynet.manager"
local log = require "tm.log"

local CMD = {}

local db2agents = {}  -- { db => agents:array }
local db2balance = {}


function CMD.agent(db)
	local agents = db2agents[db]
	if not agents then
		log.error("db:%s not exist!", db)
		return nil
	end
	local balance = db2balance[db]
	balance = (balance % #agents) + 1
	return agents[balance]
end


function CMD.start(conf)
	if not conf then
		log.error("no mysql config!")
		return
	end
	for k, v in pairs(conf) do
		if k == "database" then v = { database = v } end
		if type(v) == "table" then
			db2agents[k] = {}
			db2balance[k] = 0
			v.host = v.host or conf.host
			v.port = v.port or conf.port
			v.user = v.user or conf.user
			v.password = v.password or conf.password
			v.database = v.database or k
			for i = 1, v.connects or conf.connects or 2 do
				local agent = skynet.newservice("tm/mysqlagent")
				skynet.call(agent, "lua", "start", i, v)
				table.insert(db2agents[k], agent)
			end
		end
	end
end


skynet.start(function()
	skynet.dispatch("lua", function(_, _, cmd, ...)
		local f = assert(CMD[cmd], cmd .. " not found")
		skynet.retpack(f(...))
	end)
	skynet.register(".mysqld")
end)
