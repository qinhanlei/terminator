local skynet = require "skynet"

local _cmd = table.pack(...)

local CMD = {}

TEST_LOGGER = true


function CMD.by_num(n)
    local begin_time = skynet.now()
    
    for i = 1, n do
        tlog.debug("here is log:%d", i)
    end
    
    local end_time = skynet.now()
    local cost = (end_time - begin_time)/100.0
    tlog.debug("writed %d logs, cost time:%fs", n, cost)
end


function CMD.by_time(sec)
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


local function process(cmd, ...)
    local f = assert(CMD[cmd], cmd .. " not found")
    f(...)
end


skynet.start(function()
    tlog.debug("Test of logger.")
    
    -- by_num(50000)
    -- by_time(1*100)
    process(table.unpack(_cmd))
    
    -- skynet.exit()
end)
