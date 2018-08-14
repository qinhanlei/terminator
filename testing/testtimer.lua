local skynet = require "skynet"
local util = require "util"

local timer = util.newtimer(1)


skynet.start(function()
	tlog.debug("Test of Timer.")
	
	timer.timeout(5, function()
		tlog.info("Hi there!")
		timer.clear()
		timer.watch(2)
	end)
	
	timer.timeout(TM_TIMEOUT_LIMIT, function()
		tlog.info("Still there?")
	end)
	
	timer.timeout(1, no_func)
	
	-- skynet.exit()
end)
