-- master multi slaves concurrenctly
local skynet = require "skynet"
require "skynet.manager"
local log = require "tm.log"

local SERVICE_SLAVE = "tm/utils/slave"
local regname = ...

local fpath
local slaves
local balance = 0

local CMD = {}

function CMD.start(filepath, num, ...)
	if slaves then
		log.warn("master of:%s is already started!", filepath)
		return
	end
	num = num or 0
	fpath = filepath
	slaves = slaves or {}
	assert(type(filepath) == "string", "have no handle filepath!")
	for i = 1, num do
		local v = skynet.newservice(SERVICE_SLAVE)
		log.info("start %dth slave:[%x] ...", i, v)
		skynet.call(v, "lua", "start", filepath, ...)
		table.insert(slaves, v)
	end
end

function CMD.stop(...)
	for _, v in ipairs(slaves) do
		skynet.call(v, "lua", "stop", ...)
	end
	skynet.exit()
end

function CMD.newslave(...)
	assert(slaves, "please start first!")
	local v = skynet.newservice(SERVICE_SLAVE)
	log.info("start %dth slave %x ...", #slaves + 1, v)
	skynet.call(v, "lua", "start", fpath, ...)
	table.insert(slaves, v)
end

function CMD.getslave()
	balance = (balance % #slaves) + 1
	return slaves[balance]
end

skynet.start(function()
	skynet.dispatch("lua", function(_, _, cmd, ...)
		local f = assert(CMD[cmd], cmd .. " not found")
		skynet.retpack(f(...))
	end)
	log.info("regname : %s", regname)
	skynet.register(regname)
end)
