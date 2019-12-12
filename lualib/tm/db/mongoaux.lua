-- MongoDB auxiliary
--   Use logicfile(lua file) wrap up logic to access MongoDB parallel.
-- NOTE: A complex way like sqlaux, mongoutil is simple one.
local skynet = require "skynet"
local log = require "tm.log"

local mongoaux = {}
local SERVICE_PATH = "tm/db/mongod"


function mongoaux.init(conf, logicfile)
	local service = skynet.uniqueservice(SERVICE_PATH)
	skynet.call(service, "lua", "start", conf, logicfile)
end


function mongoaux.clear()
	local service = skynet.uniqueservice(SERVICE_PATH)
	skynet.call(service, "lua", "stop")
end


function mongoaux.call(method, ...)
	local cli = skynet.call(".mongod", "lua", "client")
	if not cli then
		log.error("have no MongoDB connection!")
		return nil, "connection not exist"
	end

	local ok, t = pcall(skynet.call, cli, "lua", "logic", method, ...)
	if not ok then
		log.error("call failed: %s", t)
		return nil, tostring(t)
	end

	return t
end


return mongoaux
