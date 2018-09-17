local skynet = require "skynet"
require "skynet.manager"
local tlog = require "tlog"
local mysql = require "mysql"
local config = require "config_db"

local mconf = config.mysql

local TM_DB_PING_INTERVAL = TM_DB_PING_INTERVAL or 60*100

local CMD = {}
local db2opts, db2conns


local function connect(db, conf)
	if not db then return end

	db2opts[db] = {
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
	db2conns[db] = {}

	local n = conf.connects or mconf.connects or 4
	for i = 1, n do
		local c = mysql.connect(db2opts[db])
		if c then
			tlog.info("connect %s:%d succeed.", db, i)
			table.insert(db2conns[db], c)
		else
			tlog.error("connect %s:%d failed!", db, i)
		end
	end
end


local function clear()
	for _, conns in pairs(db2conns) do
		for _, c in pairs(conns) do
			c:disconnect()
		end
	end
	db2conns = nil
end


local function init()
	if db2conns then
		clear()
	end

	if not mconf then
		tlog.error("no mysql config!")
		return
	end

	db2opts = {}
	db2conns = {}
	for k, v in pairs(mconf) do
		if type(v) == "table" then
			connect(k, v)
		end
	end
	tlog.debug("init done.")
end


local function check_conn(db, conns)
	for i, c in pairs(conns) do
		local ok, err = pcall(c.query, c, "set charset utf8mb4")
		if not ok then
			tlog.warn("ping %s:%d failed:%s", db, i, err)
			local new_c = mysql.connect(db2opts[db])
			if new_c then
				tlog.info("reconnect %s:%d succeed.", db, i)
				conns[i] = new_c
			else
				tlog.error("reconnect %s:%d failed!", db, i)
			end
		end
	end
end


local function keep_alive()
	while true do
		skynet.sleep(TM_DB_PING_INTERVAL)
		if db2conns then
			for db, conns in pairs(db2conns) do
				tlog.debug("keep alive %s #conns:%d", db, #conns)
				check_conn(db, conns)
			end
		end
	end
end


function CMD.start()
	init()
end


function CMD.stop()
	clear()
end


function CMD.query(db, sql)
	tlog.debug("db:%s, sql:%s", db, sql)
	if not db2conns then
		tlog.error("not init yet!")
		return
	end

	local conns = db2conns[db]
	if not conns or #conns == 0 then
		tlog.error("no connect with db:%s !", tostring(db))
		return
	end

	local idx = math.random(1, #conns)
	local c = conns[idx]
	local ok, ret = pcall(c.query, c, sql)
	if not ok then
		tlog.warn("call query %s:%d failed:%s", db, idx, ret)
		local new_c = mysql.connect(db2opts[db])
		if not new_c then
			tlog.error("reconnect %s:%d failed!", db, idx)
			return
		end
		tlog.info("reconnect %s:%d succeed.", db, idx)
		conns[idx] = new_c
		return new_c:query(sql)
	end

	return ret
end


skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. " not found")
		skynet.retpack(f(...))
	end)
	init()
	skynet.register(".tmysql")
	skynet.fork(keep_alive)
end)
