local skynet = require "skynet"


skynet.start(function()
    tlog.debug("Test of logger.")
    
    local n = 10000
    local begin_time = skynet.now()
    for i = 1, n do
        tlog.debug("here is log:" .. i)
    end
    local end_time = skynet.now()
    
    --NOTE: incorrect!
    local cost = (end_time - begin_time)/100.0
    tlog.debug("process %d logs, cost time:%fs", n, cost)
    
    -- skynet.exit()
end)
