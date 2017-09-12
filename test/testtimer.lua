local skynet = require "skynet"
local util = require "util"

local timer = util.newtimer()


skynet.start(function()
    tlog.debug("Test of Timer.")
    
    timer.timeout(5, function()
        tlog.info("Hi there!")
    end)
    
    timer.timeout(TM_TIMEOUT_LIMIT, function()
        tlog.info("Still there?")
    end)
    
    timer.timeout(1, no_func)
    
    -- skynet.exit()
end)
