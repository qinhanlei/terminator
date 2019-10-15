local skynet = require "skynet"
local log = require "log"


skynet.start(function()
	log.debug("Test of Reentry.")

	skynet.newservice("testpool")

	skynet.timeout(100, function()
		log.debug("busy call")
		skynet.call(".testpool", "lua", "busy")
		log.debug("busy call done")
	end)

	skynet.timeout(200, function()
		for i = 1, 10 do
			log.debug("normal call:%d", i)
			skynet.call(".testpool", "lua", "normal", i)
		end
		log.debug("normal call done")
	end)

	-- skynet.exit()
end)
