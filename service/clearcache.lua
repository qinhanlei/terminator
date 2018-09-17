local skynet = require "skynet"
local codecache = require "skynet.codecache"
local tlog = require "tlog"

skynet.start(function()
	tlog.info("clear codecache ...")
	codecache.clear()
	skynet.exit()
end)
