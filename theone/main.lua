local skynet = require "skynet"
local log = require "log"

skynet.start(function()
	log.info("Hello! this is Terminator :)")

	skynet.uniqueservice("database/mgr")
	skynet.uniqueservice("dungeon/mgr")
	skynet.uniqueservice("gateway/mgr")
	skynet.uniqueservice("logic/mgr")
	skynet.uniqueservice("user/mgr")

	skynet.newservice("console")
	skynet.newservice("debug_console", 9600)
	skynet.exit()
end)
