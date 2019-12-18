local skynet = require "skynet"
require "skynet.manager"
local xmongo = require "tm.db.xmongo"
local log = require "tm.log"

local CMD = {}

local logic


function CMD.start(id, conf, logicfile)
	assert(not logic, "already started!")
	log.info("mongoc:%d start", id)
	local ok = xmongo.init(conf)
	if not ok then
		return false
	end
	logic = assert(require(logicfile))
	return true
end


function CMD.stop()
	xmongo.clear()
	logic = nil
	skynet.exit()
end


function CMD.logic(method, ...)
	local f = assert(logic[method])
	return f(...)
end


skynet.start(function()
	skynet.dispatch("lua", function(_, _, cmd, ...)
		local f = assert(CMD[cmd], cmd .. " not found")
		skynet.retpack(f(...))
	end)
end)
