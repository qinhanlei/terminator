local skynet = require "skynet"

skynet.start(function()
	tlog.info("welcome to test.")
	
	-- let start test service from console
	skynet.newservice("console")
	skynet.newservice("debug_console", 9600)
	
	skynet.exit()
end)
