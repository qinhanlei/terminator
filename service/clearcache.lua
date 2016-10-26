local skynet = require "skynet"
local codecache = require "skynet.codecache"

skynet.start(function()
    tlog.info("clear codecache ...")
    
    codecache.clear()
    
    skynet.exit()
end)
