local skynet = require "skynet"
local log = require "log"

skynet.start(function()
	-- let start test service from console
	skynet.newservice("console")
	skynet.newservice("debug_console", 9600)

	log.info("==== Welcome to test ====")
	log.info("type lua service filename to run it!")

	skynet.exit()
end)
