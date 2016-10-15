local skynet = require "skynet"
local logger = require "simple-logger"


skynet.start(function()
    tlog.debug("this is test of logger.")
    
    local n = 100000
    local begin_time = skynet.now()
    for i = 1, n do
        tlog.debug("here is logging the log:" .. i)
    end
    local end_time = skynet.now()
    tlog.debug("logging %d logs, cost time:%fs", n, (end_time - begin_time)/100.0)
    
end)
