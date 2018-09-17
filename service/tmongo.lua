local skynet = require "skynet"
require "skynet.manager"
local mongo = require "skynet.db.mongo"

local tlog = require "tlog"
local mconf = require("config_db").mongo

local CMD = {}


--TODO: ...


skynet.start(function()
	skynet.dispatch("lua", function(_, _, cmd, ...)
		local f = assert(CMD[cmd], cmd .. " not found")
		skynet.retpack(f(...))
	end)
	tlog.Info("mongo service start")
	skynet.register(".tmongo")
end)
