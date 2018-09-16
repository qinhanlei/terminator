local skynet = require "skynet"

skynet.start(function()
	assert(skynet.newservice("slave-service"))
	skynet.exit()
end)
