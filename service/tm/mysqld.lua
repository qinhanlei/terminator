local skynet = require "skynet"
require "skynet.manager"
local log = require "tm.log"
local xtable = require "tm.xtable"

local CMD = {}

local db2clients = {}  -- { db => clients:array }
local db2balance = {}  -- { db => balance:int }


function CMD.client(db)
	local clients = db2clients[db]
	if not clients then
		log.error("db:%s clients not exist!", db)
		return nil
	end
	db2balance[db] = (db2balance[db] % #clients) + 1
	return clients[db2balance[db]]
end


function CMD.start(conf)
	assert(#db2clients == 0, "already started!")
	if not conf then
		log.error("no mysql config!")
		return
	end
	log.info("databse config: %s", xtable.dump(conf))
	local dbhash = {}
	for k, v in pairs(conf) do
		if k == "database" then v = { database = v } end
		if type(v) == "table" then
			k = v.database
			assert(not dbhash[k], "Duplicated config of database: "..k)
			dbhash[k] = true
			db2clients[k] = {}
			db2balance[k] = 0
			v.host = v.host or conf.host
			v.port = v.port or conf.port
			v.user = v.user or conf.user
			v.password = v.password or conf.password
			assert(v.database and type(v.database) == "string")
			for i = 1, v.connects or conf.connects or 2 do
				local cli = skynet.newservice("tm/mysqlc")
				skynet.call(cli, "lua", "start", i, v)
				table.insert(db2clients[k], cli)
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
