-- from skynet/examples/abort.lua
local skynet = require "skynet"
require "skynet.manager"	-- import skynet.abort
local log = require "log"


skynet.init(function()
	log.info("aborting...")
end)


skynet.start(function()
	local count_down = 100 * 1

	skynet.timeout(count_down-3, function()
		log.info("abort done.")
	end)
	skynet.sleep(count_down)

	skynet.abort()
end)
