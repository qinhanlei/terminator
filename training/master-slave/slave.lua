local skynet = require "skynet"
local logger = require "simple-logger"

skynet.start(function()
	local slave_service = assert(skynet.newservice("slave-service"))

	skynet.exit()
end)
