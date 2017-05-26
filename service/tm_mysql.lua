local skynet = require "skynet"
require "skynet.manager"

local mysql = require "mysql"
local config = require "config_db"

local nodename = skynet.getenv("nodename")

local CMD = {}

local _mconf = nil
local _conn = nil


local function connect(dbname, t)
	if not dbname then
		return
	end
	
	_conn[dbname] = {}
	local n = t.connects or _mconf.connects or 1
	for i = 1, n do
		local c = mysql.connect({
			host = t.host or _mconf.host,
			port = t.port or _mconf.port,
			database = dbname,
			user = t.user or _mconf.user,
			password = t.pass or _mconf.pass,
			max_packet_size = 1024 * 1024,
			on_connect = function(c)
				c:query("set charset utf8mb4")
			end
		})
		if c then
			tlog.info("connect to %s success.", dbname)
			table.insert(_conn[dbname], c)
		else
			tlog.error("connect %s failed!", tostring(dbname))
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
	for k, v in pairs(_mconf) do
		if type(v) == "table" then
			connect(k, v)
		end
	end
	tlog.debug("init done.")
end


local function keep_alive()
	while true do
		skynet.sleep(1.5*100)
		if _conn then
			for db, t in pairs(_conn) do
				for i, c in pairs(t) do
					tlog.debug("keep alive %s:%d connection...", db, i)
					c:query("set charset utf8mb4")  --TODO: verify this
					skynet.sleep(0.5*100)
				end
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
	
	local c = table.remove(t)
	table.insert(t, 1, c)
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
