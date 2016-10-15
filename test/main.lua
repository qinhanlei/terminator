local skynet = require "skynet"

skynet.start(function()
    tlog.info("welcome to test.")
    
    -- let start test service from console
    skynet.newservice("console")
    
    skynet.exit()
end)
