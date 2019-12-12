-- Redis utility
local skynet = require "skynet"
local redis = require "skynet.db.redis"
local log = require "tm.log"
local xdump = require "tm.xtable".dump

local PING_INTERVAL = 10*60*100

local redisutil = {}
local firsttime = true

local cli
local cfg


local function keep_alive()
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


function redisutil.init(conf)
	if cli then
		log.error("redisutil already initialized!")
		return
	end

	if type(conf.auth) == "string" and #conf.auth == 0 then
		conf.auth = nil
	end
	log.debug("redisutil init by conf: %s", xdump(conf))
	cli = redis.connect(conf)
	cfg = conf

	if firsttime then
		firsttime = false
		skynet.fork(keep_alive)
	end
end


function redisutil.clear()
	cli:disconnect()
	cli = nil
	cfg = nil
end


function redisutil.client()
	return setmetatable({}, {
		__index = function(_, key)
			return function(...)
				return cli[key](cli, ...)
			end
		end
	})
end


return redisutil
