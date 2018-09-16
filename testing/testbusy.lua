local skynet = require "skynet"
local tlog = require "tlog"


skynet.start(function()
	tlog.debug("Test of Reentry.")

	skynet.newservice("testpool")

	skynet.timeout(100, function()
		tlog.debug("busy call")
		skynet.call(".testpool", "lua", "busy")
		tlog.debug("busy call done")
	end)

	skynet.timeout(200, function()
		for i = 1, 10 do
			tlog.debug("normal call:%d", i)
			skynet.call(".testpool", "lua", "normal", i)
		end
		tlog.debug("normal call done")
	end)

	-- skynet.exit()
end)
