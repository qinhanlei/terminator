local skynet = require "skynet"
local tlog = require "tlog"

local util = {}


function util.concat(t)
	if #t == 0 then return "nil" end
	local ret = ""
	for _, v in pairs(t) do
		if string.len(ret) == 0 then
			ret = tostring(v)
		else
			ret = ret .. " " .. tostring(v)
		end
	end
	return ret
end


function util.nowstr()
	local t = os.date("*t")
	return string.format("%04d-%02d-%02d %02d:%02d:%02d",
			t.year, t.month, t.day, t.hour, t.min, t.sec)
end


function util.process(CMD, cmd, ...)
	if not cmd then
		return
	end

	local f = CMD[cmd]
	if not f then
		tlog.error("cmd %s not found", tostring(cmd))
		return
	end

	f(...)
end


function util.newtimer(ti, cb)
	local timer = {}
	local handles = {} --setmetatable({}, {__mode = "kv"})
	local watcher = nil

	timer.id = skynet.now()

	function timer.timeout(ti, f)
		if not f then
			tlog.warn("timeout callback is nil %s", debug.traceback())
			return
		end
		if ti > TM_TIMEOUT_LIMIT then
			tlog.warn("long timeout:%d! %s", ti, debug.traceback())
		end
		local function tf()
			if handles[tf] then
				handles[tf] = nil
				f()
			end
		end
		skynet.timeout(ti*100, tf)
		handles[tf] = f
		return tf
	end

	function timer.cancel(tf)
		if tf then
			handles[tf] = nil
		end
	end

	function timer.clear()
		for k, _ in pairs(handles) do
			handles[k] = nil
		end
	end

	local function watching(ti, cb)
		local id = skynet.now()
		tlog.debug("this is timer:%x watcher:%x", timer.id, id)
		while watcher do
			skynet.sleep(ti*100)
			tlog.debug("timer:%x task number:%d", timer.id, table.nums(handles))
			if type(cb) == "function" then
				cb()
			end
		end
		tlog.debug("timer:%x watcher:%x finished.", timer.id, id)
	end

	function timer.watch(ti, cb)
		if watcher then  -- stop previous watcher
			skynet.wakeup(watcher)
			watcher = nil
		end
		if type(ti) == "number" then
			skynet.timeout(42, function()
				watcher = skynet.fork(watching, ti, cb)
			end)
		end
	end

	timer.watch(ti, cb)

	return timer
end


return util
