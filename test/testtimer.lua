local skynet = require "skynet"
local util = require "util"

local timer = util.newtimer()


skynet.start(function()
    tlog.debug("Test of Timer.")
    
    timer.timeout(100, function()
        tlog.info("Hi there!")
    end)
    
    timer.timeout(TM_TIMEOUT_LIMIT + 1, function()
        tlog.info("Still there?")
    end)
    
    -- skynet.exit()
end)
