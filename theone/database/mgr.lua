local skynet = require "skynet"
local log = require "log"
local mconf = require("database.conf").mysql

local CMD = {}

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = CMD[cmd]
		if f then
			skynet.retpack(f(...))
		else
			log.error("from[%s:%s] cmd:%s not found", session, source, cmd)
		end
	end)
	
	local mysqld, err = skynet.uniqueservice("mysqld")
	if not mysqld then
		log.error("launch mysqld failed:%s", err)
	end
	skynet.send(mysqld, "lua", "start", mconf)
end)
