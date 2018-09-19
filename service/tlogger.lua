local skynet = require "skynet"
require "skynet.manager"

local nodename = skynet.getenv("nodename")
local logpath = skynet.getenv("logpath")

local FILE_LIMIT = LOG_FILE_LIMIT or 32*1024*1024

-- Also works on 'print' of C and Python, 'echo' of Unix like Shell, etc.
local LOG_COLOR_MAP = {
	DEBUG = "\x1b[0m",  -- default black
	INFO  = "\x1b[32m", -- green
	WARN  = "\x1b[33m", -- yellow
	ERROR = "\x1b[31m", -- red
	FATAL = "\x1b[35m", -- violet
	SKY   = "\x1b[34m", -- blue
}

local CMD = {}
local lgidx, lgfile, lgsize = 0, nil, 0

local function timetag(t)
	t = t or os.date("*t")
	return string.format("%04d-%02d-%02d %02d:%02d:%02d.%02d",
		t.year, t.month, t.day, t.hour, t.min, t.sec, math.floor(skynet.time()*100%100))
end

local function fullpath(t)
	t = t or os.date("*t")
	return string.format("%s/%s_%04d%02d%02d_%02d%02d%02d_%d.log",
		logpath, nodename, t.year, t.month, t.day, t.hour, t.min, t.sec, lgidx)
end

local function dolog(source, typ, str)
	local t = os.date("*t")
	local str = string.format("%s %s [%s:%x] %s", timetag(t), typ, nodename, source, str)
	if LOG_CONSOLE then
		print(LOG_COLOR_MAP[typ]..str..LOG_COLOR_MAP.DEBUG)
	end
	if not lgfile then
		local f, e = io.open(fullpath(t), "a+")
		if not f then
			print("logger error:", tostring(e))
			return
		end
		lgfile = f
	end
	lgfile:write(str..'\n')
	lgfile:flush()
	lgsize = lgsize + string.len(str) + 1
	if lgsize >= FILE_LIMIT then
		lgsize = 0
		lgidx = lgidx + 1
		lgfile:close()
		lgfile = nil
	end
end


function CMD.logging(source, typ, str)
	dolog(source, typ, str)
end

function CMD.logtest(source, typ, str)
	dolog(source, typ, str)
	skynet.retpack()
end


skynet.register_protocol {
	name = "text",
	id = skynet.PTYPE_TEXT,
	unpack = skynet.tostring,
	dispatch = function(_, address, msg)
		local s = string.find(msg, "stack traceback:")
		if s then dolog(address, "ERROR", ">>>>>>>>") end
		dolog(address, "SKY", msg)
		if s then dolog(address, "DEBUG", "<<<<<<<<") end
	end
}

skynet.start(function()
	skynet.dispatch("lua", function(_, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. " not found")
		f(source, ...)
	end)
	skynet.register(".logger")
	dolog(skynet.self(), "SKY", "logger is ready")
end)
