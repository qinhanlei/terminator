local skynet = require "skynet"
local codecache = require "skynet.codecache"

local logger = require "simple-logger"


skynet.start(function()
    codecache.clear()
    logger("clear codecache ...")
    skynet.exit()
end)
