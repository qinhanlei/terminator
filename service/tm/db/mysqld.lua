local skynet = require "skynet"
require "skynet.manager"
local log = require "tm.log"
local xtable = require "tm.xtable"
local xdump = xtable.dump

local CMD = {}

local config
local db2clients  -- { db => clients:array }
local db2balance  -- { db => balance:int }
local SERVICE_MYSQLC = "tm/db/mysqlc"


function CMD.client(db)
	assert(db2clients and xtable.size(db2clients) > 0)
	local clients = db2clients[db]
	if not clients then
		log.error("db:%s clients not exist!", db)
		return nil
	end
	db2balance = db2balance or {}
	db2balance[db] = ((db2balance[db] or 0) % #clients) + 1
	return clients[db2balance[db]]
end


function CMD.start(conf)
	if db2clients then
		log.warn("already started by: %s", xdump(config))
		return
	end
	if not conf then
		log.error("no MySQL config!")
		return
	end
	log.debug("start by conf: %s", xdump(conf))
	-- log.info("MySQL config: %s", xtable.dump(conf))
	local dbhash = {}
	local mapcli = {}
	for k, v in pairs(conf) do
		if k == "database" then v = { database = v } end
		if type(v) == "table" then
			k = v.database
			assert(not dbhash[k], "Duplicated config of database: "..k)
			dbhash[k] = true
			mapcli[k] = {}
			v.host = v.host or conf.host
			v.port = v.port or conf.port
			v.user = v.user or conf.user
			v.password = v.password or conf.password
			assert(v.database and type(v.database) == "string")
			for i = 1, v.connects or conf.connects or 2 do
				local cli = skynet.newservice(SERVICE_MYSQLC)
				skynet.call(cli, "lua", "start", i, v)
				table.insert(mapcli[k], cli)
			end
		end
	end
	db2clients = mapcli
	config = conf
	log.info("done")
end


function CMD.stop()
	for _, clients in pairs(db2clients) do
		for _, cli in ipairs(clients) do
			skynet.send(cli, "lua", "stop")
		end
	end
	db2clients = {}
	db2balance = {}
	skynet.exit()
end


skynet.start(function()
	skynet.dispatch("lua", function(_, _, cmd, ...)
		local f = assert(CMD[cmd], cmd .. " not found")
		skynet.retpack(f(...))
	end)
	skynet.register(".mysqld")
end)
