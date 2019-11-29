local skynet = require "skynet"
require "skynet.manager"

local nodename = skynet.getenv("nodename")
local logpath = skynet.getenv("logpath")

local LOG_LEVEL = 1  -- see LOG_LEVEL_TYPE
local LOG_CONSOLE = true  -- also print logs to screen console
local LOG_FILE_LIMIT = 32 * 1024*1024

local LOG_TYPE_LEVEL = {DEBUG=1, INFO=2, WARN=3, ERROR=4, FATAL=5, SKY=6}
local LOG_LEVEL_TYPE = {"DEBUG", "INFO", "WARN", "ERROR", "FATAL", "SKY"}
-- Also works on 'print' of C and Python, 'echo' of Unix like Shell, etc.
local LOG_COLOR_MAP = {
	DEBUG = "\x1b[0m",  -- default black
	INFO  = "\x1b[32m", -- green
	WARN  = "\x1b[33m", -- yellow
	ERROR = "\x1b[31m", -- red
	FATAL = "\x1b[35m", -- violet
	SKY   = "\x1b[34m", -- blue
}

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

local function logging(source, level, str)
	if level < LOG_LEVEL then
		return
	end
	local typ = LOG_LEVEL_TYPE[level]
	local t = os.date("*t")
	str = string.format("%s %s [%s:%x] %s", timetag(t), typ, nodename, source, str)
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
	if lgsize >= LOG_FILE_LIMIT then
		lgsize = 0
		lgidx = lgidx + 1
		lgfile:close()
		lgfile = nil
	end
end


skynet.register_protocol {
	name = "text",
	id = skynet.PTYPE_TEXT,
	unpack = skynet.tostring,
	dispatch = function(_, address, msg)
		local s = string.find(msg, "stack traceback:")
		if s then logging(address, LOG_TYPE_LEVEL.ERROR, ">>>>>>>>") end
		logging(address, LOG_TYPE_LEVEL.SKY, msg)
		if s then logging(address, LOG_TYPE_LEVEL.ERROR, "<<<<<<<<") end
	end
}

local CMD = {logging = logging}

skynet.start(function()
	skynet.dispatch("lua", function(_, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. " not found")
		f(source, ...)
	end)
	skynet.register(".logger")
	logging(skynet.self(), LOG_TYPE_LEVEL.SKY, "logger is ready")
end)
