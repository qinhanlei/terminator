local skynet = require "skynet"
local skynet_manager = require "skynet.manager"

local logger = require "simple-logger"


skynet.start(function()

	-- name service as ".console"
	skynet_manager.name(".console", skynet.newservice("console"))

	-- try tpye "debug_console port_xxx" in console

end)
