local skynet = require "skynet"
local codecache = require "skynet.codecache"

local logger = require "simple-logger"


skynet.start(function()
    codecache.clear()
    tlog.info("clear codecache ...")
    skynet.exit()
end)
