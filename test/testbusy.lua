local skynet = require "skynet"
local util = require "util"

local _cmd = table.pack(...)


skynet.start(function()
    tlog.debug("Test of Reentry.")
    
    skynet.newservice("testpool")
    
    skynet.timeout(100, function()
        tlog.debug("busy call")
        skynet.call(".testpool", "lua", "busy")
    end)
    
    skynet.timeout(200, function()
        for i = 1, 10 do
            tlog.debug("normal call:%d", i)
            skynet.call(".testpool", "lua", "normal", i) --TODO: will dead forever?
            -- skynet.fork(function()
            --     skynet.call(".testpool", "lua", "normal", i)
            -- end)
        end
        tlog.debug("normal call done")
    end)
    
    skynet.timeout(700, function()
        skynet.call(".testpool", "lua", "normal", 99)
    end)
    
    -- skynet.exit()
end)
