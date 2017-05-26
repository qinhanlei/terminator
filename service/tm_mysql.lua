local skynet = require "skynet"
require "skynet.manager"

local mysql = require "mysql"
local config = require "config_db"

local nodename = skynet.getenv("nodename")

local CMD = {}

local _mconf = nil
local _conn = nil
local _conn_params = nil


local function connect(dbname, t)
	if not dbname then
		return
	end
	
	local n = t.connects or _mconf.connects or 1
	local params = {
		host = t.host or _mconf.host,
		port = t.port or _mconf.port,
		database = dbname,
		user = t.user or _mconf.user,
		password = t.pass or _mconf.pass,
		max_packet_size = 1024 * 1024,
		on_connect = function(c)
			c:query("set charset utf8mb4")
		end
	}
	
	_conn[dbname] = {}
	_conn_params[dbname] = params
	
	for i = 1, n do
		local c = mysql.connect(params)
		if c then
			tlog.info("connect %s:%d succeed.", dbname, i)
			table.insert(_conn[dbname], c)
		else
			tlog.error("connect %s:%d failed!", tostring(dbname), i)
		end
	end
end


local function clear()
	for _, t in pairs(_conn) do
		for _, c in pairs(t) do
			c:disconnect()
		end
	end
	_conn = nil
end


local function init()
	if _conn then
		clear()
	end
	
	_mconf = config.mysql
	if not _mconf then
		tlog.error("no mysql config!")
		return
	end
	
	_conn = {}
	_conn_params = {}
	for k, v in pairs(_mconf) do
		if type(v) == "table" then
			connect(k, v)
		end
	end
	tlog.debug("init done.")
end


local function check_conn(db, t)
	tlog.debug("keep alive %s, connections %d ...", db, #t)
	for i, c in pairs(t) do
		local ok, err = pcall(query, c, "set charset utf8mb4")
		if not ok then
			tlog.warn("ping %s:%d failed! try reconnect ...", db, i)
			local new_c = mysql.connect(_conn_params[db])
			if new_c then
				tlog.info("reconnect %s:%d succeed.", db, i)
				t[i] = new_c
			else
				tlog.error("reconnect %s:%d failed!", tostring(db), i)
			end
		end
	end
end


local function keep_alive()
	while true do
		skynet.sleep(15*100)
		if _conn then
			for db, t in pairs(_conn) do
				check_conn(db, t)
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
	if not _conn then
		tlog.error("not init yet!")
		return
	end
	
	local t = _conn[db]
	if not t or #t == 0 then
		tlog.error("no connect with db:%s !", tostring(db))
		return
	end
	
	local idx = math.random(1, #t)
	local c = t[idx]
	
	return c:query(sql)
end


skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. " not found")
		skynet.retpack(f(...))
	end)
    
	skynet.register(".tm_mysql")
	init()
	
	skynet.fork(keep_alive)
end)
