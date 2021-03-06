local skynet = require "skynet"
require "skynet.manager"

local log = require "tm.log"

local CMD = {}


function CMD.busy(source)
	for _ = 1, 100 do
		for _ = 1, 10000000 do
			-- do nothing
		end
		-- log.debug("this is busy running for %x...", source)
	end
	log.debug("busy for %x done.", source)
end


function CMD.normal(source, idx)
	log.debug("this is %dth normal call from :%x", idx, source)
end


skynet.start(function()
	skynet.dispatch("lua", function(_, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. " not found")
		skynet.retpack(f(source, ...))
	end)

	log.debug("Test of event pool.")

	skynet.register(".testpool")
	-- skynet.exit()
end)
