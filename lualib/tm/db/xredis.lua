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
			log.info("keep alive [%s:%s] ...", cfg.host, cfg.port)
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
		local service = skynet.uniqueservice("tm/db/redisd")
		return skynet.call(service, "lua", "start", conf)
	end

	-- simple xredis utility mode
	if cli then
		log.warn("already initialized!")
		return true
	end

	if type(conf.auth) == "string" and #conf.auth == 0 then
		conf.auth = nil
	end

	log.debug("init by conf: %s", xdump(conf))
	local ok, c = pcall(redis.connect, conf)
	if not ok then
		log.error("connect failed! %s", c)
		return false, c
	end
	cli = c
	cfg = conf
	log.info("connect %s:%d succeed!", conf.host, conf.port)

	if firsttime then
		firsttime = false
		skynet.fork(watcher)
	end
	return true
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
				log.error("have no client!")
				return nil, "have no client"
			end
			local ok, t = pcall(skynet.call, c, "lua", "exec", key, ...)
			if not ok then
				log.error("call failed: %s", t)
				return nil, t
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
