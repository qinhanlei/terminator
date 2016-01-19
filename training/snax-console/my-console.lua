local skynet = require "skynet"
local skynet_manager = require "skynet.manager"

local logger = require "simple-logger"


skynet.start(function()
    skynet.dispatch("lua", function(session, source, cmd, ...)
        logger("["..source.."]", cmd, ...)
    end)

    --math.randomseed(os.time())
    local debug_console_port = 7342 -- 7000 + math.random(800)
    skynet_manager.name(".dbgconsole", skynet.newservice("debug_console", debug_console_port))

end)
