-- logic for every redis slave
local xredis = require "tm/db/xredis"

local redislave = {}

function redislave.onstart(conf)
	xredis.init(conf)
end

function redislave.onstop()
	xredis.clear()
end

function redislave.onexec(method, ...)
	local cli = xredis.client()
	return cli[method](...)
end

return redislave
