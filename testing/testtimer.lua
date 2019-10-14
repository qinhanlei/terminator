local skynet = require "skynet"
local util = require "util"
local tlog = require "tlog"

local timer = util.newtimer(1)


skynet.start(function()
	tlog.debug("Test of Timer.")

	timer.timeout(5, function()
		tlog.info("Hi there!")
		timer.clear()
		timer.watch(2)
	end)

	timer.timeout(60, function()
		tlog.info("Still there?")
	end)

	timer.timeout(1, no_func)

	-- skynet.exit()
end)
