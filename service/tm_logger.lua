local skynet = require "skynet"
require "skynet.manager"
local nodename = skynet.getenv("nodename")

local CMD = {}


local function str_now()
	local t = os.date("*t")
	return string.format("%04d-%02d-%02d %02d:%02d:%02d", 
        t.year, t.month, t.day, t.hour, t.min, t.sec)
end


function CMD.logging(source, typ, log)
    local log = string.format("[%s] [%s] [%s:%x] %s", str_now(), typ, nodename, source, log)
    print(log)
    --TODO: write to file.
end


skynet.register_protocol {
	name = "text",
	id = skynet.PTYPE_TEXT,
	unpack = skynet.tostring,
	dispatch = function(_, address, msg)
        CMD.logging(address, "SKY", msg)
	end
}


skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		f(source, ...)
	end)

	skynet.register(".logger")
end)
