local skynet = require "skynet"
local skynet_manager = require "skynet.manager"

-- local consts = require "constants"

skynet.start(function()

    skynet_manager.name(".console", skynet.newservice("console"))
    --skynet_manager.name(".dbgconsole", skynet.newservice("debug_console", consts.DEBUG_CONSOLE_PORT))

    skynet.exit()
end)
