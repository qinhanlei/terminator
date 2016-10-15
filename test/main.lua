local skynet = require "skynet"
local logger = require "simple-logger"

skynet.start(function()
    logger("welcome to test.")
    
    -- let start test service from console
    skynet.newservice("console")
    
    skynet.exit()
end)
