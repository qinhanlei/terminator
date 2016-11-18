local skynet = require "skynet"
require "skynet.manager"

local queue = require "skynet.queue"
local cs = queue()

local nodename = skynet.getenv("nodename")
local logpath = skynet.getenv("logpath")

local MB = 1024 * 1024
local FILE_LIMIT = 32 * MB

local CMD = {}

local _log_file = nil
local _log_name = ""
local _log_size = 0
local _log_idx = 0


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
		
		if not _log_file then
			_log_name = string.format("%s/%s_%04d%02d%02d_%02d%02d%02d_%02d.log", 
				logpath, nodename, t.year, t.month, t.day, t.hour, t.min, t.sec, _log_idx)
			local f, e = io.open(_log_name, "a+")
			if not f then
				print("logger error:", tostring(e))
				-- skynet.abort()
				return
			end
			_log_file = f
		end
		_log_file:write(log .. "\n")
	    _log_file:flush()
		
		_log_size = _log_size + string.len(log) + 1
		if _log_size >= FILE_LIMIT then
			_log_file:close()
			_log_file = nil
			_log_size = 0
			_log_idx = _log_idx + 1
		end
	end)
end


function CMD.logging(source, typ, log)
    logging(source, typ, log)
end


function CMD.logging_ret(source, typ, log)
	logging(source, typ, log)
	skynet.retpack()
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
	logging(skynet.self(), "INFO", "terminator logger is ready.")
end)
