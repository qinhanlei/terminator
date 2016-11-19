local skynet = require "skynet"
local util = require "util"

local _cmd = table.pack(...)

local CMD = {}

TEST_LOGGER = true


function CMD.number(n)
    local begin_time = skynet.now()
    
    for i = 1, n do
        tlog.debug("here is log:%d", i)
    end
    
    local end_time = skynet.now()
    local cost = (end_time - begin_time)/100.0
    tlog.debug("writed %d logs, cost time:%fs", n, cost)
end


function CMD.time(sec)
    local cnt = 0
    local is_time_up = false
    local begin_time = skynet.now()
    
    skynet.fork(function()
        while not is_time_up do
            cnt = cnt + 1
            tlog.debug("here is log:%d", cnt)
        end
        local end_time = skynet.now()
        local cost = (end_time - begin_time)/100.0
        tlog.debug("writed %d logs, cost time:%fs", cnt, cost)
    end)
    
    skynet.timeout(sec*100, function()
        is_time_up = true
    end)
end


skynet.start(function()
    tlog.debug("Test of logger.")
    
    util.process(CMD, table.unpack(_cmd))
    
    -- skynet.exit()
end)
