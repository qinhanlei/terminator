local skynet = require "skynet"
local skynet_manager = require "skynet.manager"

-- require "constants"

skynet.start(function()

    skynet_manager.name(".console", skynet.newservice("console"))
    --skynet_manager.name(".dbgconsole", skynet.newservice("debug_console", DEBUG_CONSOLE_PORT))

    skynet.exit()
end)
