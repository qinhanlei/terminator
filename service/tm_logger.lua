local skynet = require "skynet"
require "skynet.manager"
local queue = require "skynet.queue"
local cs = queue()

local nodename = skynet.getenv("nodename")

local MB = 1024 * 1024
local GB = 1024 * MB
local FILE_LIMIT = 2 * MB

local CMD = {}
local logfile = nil
local filesize = 0
local fileidx = 0


local function str_datetime(t, p)
	t = t or os.date("*t")
	p = p or math.floor(skynet.time()*100%100)
	return string.format("%04d-%02d-%02d %02d:%02d:%02d.%02d", 
        t.year, t.month, t.day, t.hour, t.min, t.sec, p)
end


local function logging(source, typ, log)
	cs(function()
		local t = os.date("*t")
		local p = math.floor(skynet.time()*100%100)
		local tm = str_datetime(t,p)
		local log = string.format("[%s] [%s] [%s:%x] %s", tm, typ, nodename, source, log)
		print(log)
		
		if not logfile then
			local logpath = string.format("./logs/%s_%04d%02d%02d_%02d%02d%02d_%02d.log",
					nodename, t.year, t.month, t.day, t.hour, t.min, t.sec, fileidx)
			logfile = io.open(logpath, "a+")
		end
		logfile:write(log .. "\n")
	    logfile:flush()
		filesize = filesize + string.len(log) + 1
		if logfile and filesize >= FILE_LIMIT then
			logfile:close()
			logfile = nil
			filesize = 0
			fileidx = fileidx + 1
		end
	end)
end


function CMD.logging(source, typ, log)
    logging(source, typ, log)
end


skynet.register_protocol {
	name = "text",
	id = skynet.PTYPE_TEXT,
	unpack = skynet.tostring,
	dispatch = function(_, address, msg)
        logging(address, "SKY", msg)
	end
}


skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		f(source, ...)
	end)

	skynet.register(".logger")
	logging(skynet.self(), "INFO", "terminator-logger ready.")
end)
