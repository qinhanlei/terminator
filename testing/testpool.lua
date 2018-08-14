local skynet = require "skynet"
require "skynet.manager"

local CMD = {}


function CMD.busy(source)
	for k = 1, 100 do
		for i = 1, 10000000 do
			-- do nothing
		end
		-- tlog.debug("this is busy running for %x...", source)
	end
	tlog.debug("busy done.")
end


function CMD.normal(source, idx)
	tlog.debug("this is %dth normal call from :%x", idx, source)
end


skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. " not found")
		skynet.retpack(f(source, ...))
	end)
	
	tlog.debug("Test of event pool.")
	
	skynet.register(".testpool")
	-- skynet.exit()
end)
