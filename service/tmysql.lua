local skynet = require "skynet"
require "skynet.manager"
local mysql = require "skynet.db.mysql"
local log = require "log"

local TM_DB_PING_INTERVAL = 60*100

local CMD = {}
local db2conns  -- dbname -> connections
local db2index  -- connections balance


local function connect(db, conf, mconf)
	if not db then return end

	local opts = {
		host = conf.host or mconf.host,
		port = conf.port or mconf.port,
		database = db,
		user = conf.user or mconf.user,
		password = conf.pass or mconf.pass,
		max_packet_size = 1024 * 1024,
		on_connect = function(c)
			c:query("set charset utf8mb4")
		end
	}
	local connections = {}

	local n = conf.connects or mconf.connects or 4
	for i = 1, n do
		local c = mysql.connect(opts)
		if not c then
			log.error("connect %s:%d failed!", db, i)
			return nil
		end
		log.info("connect %s:%d succeed.", db, i)
		table.insert(connections, c)
	end
	return connections
end


local function check_conn(db, conns)
	local ok, err
	for i, c in pairs(conns) do
		ok = pcall(c.query, c, "set charset utf8mb4")
		if not ok then
			ok, err = pcall(c.query, c, "set charset utf8mb4")
			if not ok then
				log.warn("ping %s:%d failed:%s", db, i, err)
			end
		end
	end
end


local function keep_alive()
	while true do
		skynet.sleep(TM_DB_PING_INTERVAL)
		if db2conns then
			for db, conns in pairs(db2conns) do
				log.debug("keep alive %s #conns:%d", db, #conns)
				check_conn(db, conns)
			end
		end
	end
end


function CMD.start(mconf)
	if not mconf then
		log.error("no mysql config!")
		return
	end

	if db2conns then
		CMD.stop()
	end

	db2conns = {}
	db2index = {}
	for k, v in pairs(mconf) do
		if type(v) == "table" then
			db2conns[k] = assert(connect(k, v, mconf))
			db2index[k] = 0
		end
	end

	skynet.fork(keep_alive)
end


function CMD.stop()
	for _, conns in pairs(db2conns) do
		for _, c in pairs(conns) do
			c:disconnect()
		end
	end
	db2conns = nil
	db2index = nil
end


function CMD.query(db, sql)
	log.debug("DB:[%s] run SQL: %s", db, sql)
	if not db2conns then
		log.error("not init yet!")
		return
	end

	local conns = db2conns[db]
	if not conns or #conns == 0 then
		log.error("no connect with db:%s !", tostring(db))
		return
	end

	db2index[db] = (db2index[db] % #conns) + 1
	local idx = db2index[db]
	local c = conns[idx]
	local ok, ret = pcall(c.query, c, sql)
	if not ok then
		ok, ret = pcall(c.query, c, sql)
		if not ok then
			log.warn("call query %s:%d failed:%s", db, idx, ret)
			return
		end
	end
	return ret
end


skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. " not found")
		skynet.retpack(f(...))
	end)
	skynet.register(".tmysql")
end)
