-- MongoDB auxiliary
--   Use logiclua(lua file) wrap up logic to access MongoDB parallel.
-- NOTE: A complex way like sqlaux, mgoutil is simple one.
local skynet = require "skynet"
local log = require "tm.log"

local mgoaux = {}
local SERVICE_PATH = "tm/mongod"


function mgoaux.init(conf, logiclua)
	local tmysql, e = skynet.uniqueservice(SERVICE_PATH)
	if not tmysql then
		log.error("create uniqueservice:%s failed:%s", SERVICE_PATH, e)
		return
	end
	skynet.call(tmysql, "lua", "start", conf, logiclua)
end


function mgoaux.call(method, ...)
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


return mgoaux
