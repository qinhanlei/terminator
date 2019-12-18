local skynet = require "skynet"
require "skynet.manager"
local xredis = require "tm.db.xredis"
local log = require "tm.log"

local CMD = {}


function CMD.start(id, conf)
	log.info("redisc:%d start", id)
	return xredis.init(conf)
end


function CMD.stop()
	xredis.clear()
	skynet.exit()
end


function CMD.exec(method, ...)
	-- log.debug("redisc exec:", method, ...)
	return xredis.client()[method](...)
end


skynet.start(function()
	skynet.dispatch("lua", function(_, _, cmd, ...)
		local f = assert(CMD[cmd], cmd .. " not found")
		skynet.retpack(f(...))
	end)
end)
