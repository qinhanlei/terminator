--[[
eXecute Redis immediately utility

	As simple wrapper of `skynet.db.redis`:  --NOTE: may deprecated ?
		```
		xredis.init(conf)
		local db = xredis.client()
		db.set("hello", "world")
		... do other CRUD operators like above ...
		```
		NOTE: one service one connection to one Redis instance

	More connections with one Redis instance for conccurrency ?
		let uniquesvr(unique skynet service) true
		xredis.init(conf, true)
		local db = xredis.client()
		...
]]--
local skynet = require "skynet"
local redis = require "skynet.db.redis"
local log = require "tm.log"
local xdump = require "tm.xtable".dump

local PING_INTERVAL = 10*60*100
local SERVICE_PATH = "tm/db/redisd"

local xredis = {}

-- simple mode only
local cli
local cfg
local firsttime = true


local function watcher()
	local ok, ret
	while true do
		skynet.sleep(PING_INTERVAL)
		if cli then
			log.info("keep alive redis[%s:%s] ...", cfg.host, cfg.port)
			ok, ret = pcall(cli.ping, cli)
			if not ok then
				log.error("ping %s:%s failed:%s", cfg.host, cfg.port, ret)
			end
		end
	end
end


function xredis.init(conf, uniquesvr)
	-- multi redisc services mode
	if uniquesvr then
		local service = skynet.uniqueservice(SERVICE_PATH)
		skynet.call(service, "lua", "start", conf)
		return
	end

	-- simple xredis utility mode
	if cli then
		log.warn("xredis already initialized!")
		return
	end

	if type(conf.auth) == "string" and #conf.auth == 0 then
		conf.auth = nil
	end
	log.debug("xredis init by conf: %s", xdump(conf))
	cli = redis.connect(conf)
	cfg = conf

	if firsttime then
		firsttime = false
		skynet.fork(watcher)
	end
end


function xredis.clear()
	if cli then
		cli:disconnect()
		cli = nil
		cfg = nil
	else
		local service = skynet.localname(".redisd")
		if service then
			skynet.send(service, "lua", "stop")
		end
	end
end


local simpleclient = setmetatable({}, {
	__index = function(_, key)
		return function(...)
			return cli[key](cli, ...)
		end
	end
})

local multimodeclient = setmetatable({}, {
	__index = function(_, key)
		return function(...)
			local c = skynet.call(".redisd", "lua", "client")
			if not c then
				log.error("have no redis client!")
				return nil, "connection not exist"
			end
			local ok, t = pcall(skynet.call, c, "lua", "exec", key, ...)
			if not ok then
				log.error("call failed: %s", t)
				return nil, tostring(t)
			end
			return t
		end
	end
})

function xredis.client()
	if cli then
		return simpleclient
	else
		return multimodeclient
	end
end


return xredis
