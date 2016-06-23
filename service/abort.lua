-- from skynet/examples/abort.lua
local skynet = require "skynet"
require "skynet.manager"	-- import skynet.abort

local logger = require "simple-logger"


skynet.init(function()
    logger("aborting...", os.time(), skynet.now(), 100/40)
end)

skynet.start(function()
    local one_second = 100
    local count_down = 2*one_second

    -- remove cast(math.floor), run abort in console. # got error
    -- then recover, run abort in console again. # still got error, cause codecached.
    -- run clearcache then ruan abort in console. # works !
    local done_sleep = count_down - math.floor(one_second/40)

    skynet.timeout(count_down - done_sleep, function()
        logger("abort done.", os.time(), skynet.now())
    end)
    skynet.sleep(count_down)
    skynet.abort()
end)
