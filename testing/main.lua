local skynet = require "skynet"
local tlog = require "tlog"

skynet.start(function()
	tlog.info("==== Welcome to test ====")

	-- let start test service from console
	skynet.newservice("console")
	skynet.newservice("debug_console", 9600)

	tlog.info("Just type lua service filename to run it!")

	skynet.exit()
end)
