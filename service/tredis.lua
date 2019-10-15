local skynet = require "skynet"
require "skynet.manager"
local redis = require "skynet.db.redis"

local log = require "log"
local rconf = require("config_db").redis

local CMD = {}


--TODO: ...


skynet.start(function()
	skynet.dispatch("lua", function(_, _, cmd, ...)
		local f = assert(CMD[cmd], cmd .. " not found")
		skynet.retpack(f(...))
	end)
	log.info("redis service start")
	skynet.register(".tredis")
end)
