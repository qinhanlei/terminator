local skynet = require "skynet"
local log = require "log"
local timer = require "timerfactory".new()


skynet.start(function()
	log.debug("Test of Timer.")

	timer.watch(0.5*100)
	timer.timeout(5*100, function()
		log.info("Hi there!")
		-- timer.clear()
		timer.watch(2*100)
	end)

	timer.timeout(60*100, function()
		log.info("Still there?")
	end)

	timer.timeout(1, nil)

	-- skynet.exit()
end)
