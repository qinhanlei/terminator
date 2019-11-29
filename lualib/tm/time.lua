local skynet = require "skynet"
local log = require "tm.log"
local xtable = require "tm.xtable"

local M = {}
local _timeridx = 0


function M.newtimer()
	local handles = {}
	local watcher = nil
	local timer = setmetatable({id = _timeridx}, {
		__tostring = function(obj)
			return string.format("timer[%x-%x]", skynet.self(), obj.id)
		end,
	})
	_timeridx = _timeridx + 1

	function timer.timeout(ti, f)
		if not f then
			log.warn("timeout callback is nil %s", debug.traceback())
			return
		end
		if ti > 60 * 100 then
			log.warn("long timeout:%d! %s", ti, debug.traceback())
		end
		local function tf()
			if handles[tf] then
				handles[tf] = nil
				f()
			end
		end
		skynet.timeout(ti, tf)
		handles[tf] = f
		return tf
	end

	function timer.cancel(tf)
		if tf then
			handles[tf] = nil
		end
	end

	function timer.clear()
		handles = {}
	end

	function timer.watch(ti, cb)
		ti = tonumber(ti) or 100
		if watcher then -- stop previous watcher
			skynet.wakeup(watcher)
			watcher = nil
		end
		log.debug("%s watch start, interval:%s", timer, ti)
		skynet.timeout(42, function()
			watcher = skynet.fork(function()
				while watcher do
					log.debug("%s task number:%d", timer, xtable.size(handles))
					if cb then cb() end
					skynet.sleep(ti)
				end
				log.debug("%s watch done", timer)
			end)
		end)
	end

	return timer
end


function M.nowstr()
	local t = os.date("*t")
	return string.format("%04d-%02d-%02d %02d:%02d:%02d", t.year, t.month, t.day, t.hour, t.min, t.sec)
end


return M
