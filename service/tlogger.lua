local skynet = require "skynet"
require "skynet.manager"

local nodename = skynet.getenv("nodename")
local logpath = skynet.getenv("logpath")

local MB = 1024 * 1024
local FILE_LIMIT = 32 * MB

-- Also works on 'print' of C and Python, 'echo' of Unix like Shell, etc.
local DEFAULT_COLOR = "\x1b[m"
local LOG_COLOR_MAP = {
	DEBUG = DEFAULT_COLOR,
	INFO = "\x1b[32m",
	WARN = "\x1b[33m",
	ERROR = "\x1b[31m",
	FATAL = "\x1b[35m",
	SKY = "\x1b[34m",
}

local CMD = {}
local log = {file=nil, name="", size=0, idx=0}


local function str_datetime(t, p)
	t = t or os.date("*t")
	p = p or math.floor(skynet.time()*100%100)
	return string.format("%04d-%02d-%02d %02d:%02d:%02d.%02d",
		t.year, t.month, t.day, t.hour, t.min, t.sec, p)
end


local function logging(source, typ, str)
	local t = os.date("*t")
	local p = math.floor(skynet.time()*100%100)
	local tm = str_datetime(t,p)
	local str = string.format("[%s] [%s] [%s:%x] %s", tm, typ, nodename, source, str)
	print(LOG_COLOR_MAP[typ]..str..DEFAULT_COLOR)
	
	if not log.file then
		log.name = string.format("%s/%s_%04d%02d%02d_%02d%02d%02d_%02d.log",
			logpath, nodename, t.year, t.month, t.day, t.hour, t.min, t.sec, log.idx)
		local f, e = io.open(log.name, "a+")
		if not f then
			print("logger error:", tostring(e))
			return
		end
		log.file = f
	end
	log.file:write(str .. "\n")
	log.file:flush()
	
	log.size = log.size + string.len(str) + 1
	if log.size >= FILE_LIMIT then
		log.file:close()
		log.file = nil
		log.size = 0
		log.idx = log.idx + 1
	end
end


function CMD.logging(source, typ, str)
	logging(source, typ, str)
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
		local f = assert(CMD[cmd], cmd .. " not found")
		f(source, ...)
	end)
	skynet.register(".logger")
	tlog.info("terminator logger is ready.")
end)
