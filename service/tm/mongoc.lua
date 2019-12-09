local skynet = require "skynet"
require "skynet.manager"
local mgoutil = require "tm.mgoutil"
local log = require "tm.log"

local CMD = {}

local logic


function CMD.start(id, conf, logiclua)
	log.info("mongoc:%d start", id)
	mgoutil.init(conf)
	logic = assert(require(logiclua))
	assert(type(logic.start) == "function", "have no start function")
	skynet.fork(logic.start)
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
