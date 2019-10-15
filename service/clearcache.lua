local skynet = require "skynet"
local codecache = require "skynet.codecache"
local log = require "log"

skynet.start(function()
	log.info("clear codecache ...")
	codecache.clear()
	skynet.exit()
end)
