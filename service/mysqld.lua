local skynet = require "skynet"
require "skynet.manager"
local log = require "log"

local CMD = {}

local db2agents = {}  -- { db => agents:array }
local db2balance = {}


local function stopall()
	if table.size(db2agents) == 0 then
		return
	end
	for _, v in ipairs(db2agents) do
		local ok, e = pcall(skynet.call, v, "lua", "stop")
		if not ok then
			log.error("call stop agent failed: %s", e)
		end
	end
	db2agents = {}
end


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


function CMD.start(mconf)
	if not mconf then
		log.error("no mysql config!")
		return
	end
	stopall()
	for k, v in pairs(mconf) do
		if type(v) == "table" then
			db2agents[k] = {}
			db2balance[k] = 0
			local n = v.connects or mconf.connects or 1
			local database = v.database or k
			for i = 1, n do
				local agent = skynet.newservice("mysqlagent")
				skynet.call(agent, "lua", "start", i, database, v, mconf)
				table.insert(db2agents[k], agent)
			end
		end
	end
end


function CMD.stop()
	stopall()
end


skynet.start(function()
	skynet.dispatch("lua", function(_, _, cmd, ...)
		local f = assert(CMD[cmd], cmd .. " not found")
		skynet.retpack(f(...))
	end)
	skynet.register(".mysqld")
end)
