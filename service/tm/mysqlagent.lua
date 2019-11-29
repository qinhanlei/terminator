local skynet = require "skynet"
require "skynet.manager"
local mysql = require "skynet.db.mysql"
local log = require "tm.log"

local TM_DB_PING_INTERVAL = 60*100

local CMD = {}

local conn
local index
local database


local function keep_alive()
	local ok, err
	while true do
		skynet.sleep(TM_DB_PING_INTERVAL)
		if conn then
			log.debug("keep alive %s:%d", database, index)
			ok, err = pcall(conn.query, conn, "set charset utf8mb4")
			if not ok then
				log.warn("ping %s:%d failed:%s", database, index, err)
			end
		end
	end
end


function CMD.start(id, db, conf, mconf)
	if conn then
		conn:disconnect()
	end

	db = conf.database or db
	local c = mysql.connect({
		host = conf.host or mconf.host,
		port = conf.port or mconf.port,
		database = db,
		user = conf.user or mconf.user,
		password = conf.pass or mconf.pass,
		max_packet_size = 1024 * 1024,
		on_connect = function(c)
			local ok, t = pcall(c.query, c, "set charset utf8mb4")
			if ok and not t.badresult then
				log.info("connect %s:%d succeed!", db, id)
			end
		end
	})

	conn = c
	index = id
	database = db
end


function CMD.query(sql)
	log.debug("DB:[%s] run SQL: %s", database, sql)
	if not conn then
		log.error("no connect with db:%s !", database)
		return
	end

	local ok, t = pcall(conn.query, conn, sql)
	if not ok then  -- will reconnect by socketchannel
		ok, t = pcall(conn.query, conn, sql)  -- try again
		if not ok then
			log.error("call query %s:%d failed:%s", database, index, t)
			return
		end
	end
	return t
end


skynet.start(function()
	skynet.dispatch("lua", function(_, _, cmd, ...)
		local f = assert(CMD[cmd], cmd .. " not found")
		skynet.retpack(f(...))
	end)
	skynet.fork(keep_alive)
end)
