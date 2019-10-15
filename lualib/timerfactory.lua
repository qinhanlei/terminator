local skynet = require "skynet"
local log = require "log"

local TM_TIMEOUT_LIMIT = 60 * 100

local mt = {
	__tostring = function(obj)
		return string.format("timer[%x-%x]", skynet.self(), obj.id)
	end,
}
local M = {}
local idx = 0


function M.new()
	local handles = {}
	local watcher = nil
	local timer = setmetatable({id = idx}, mt)
	idx = idx + 1

	function timer.timeout(ti, f)
		if not f then
			log.warn("timeout callback is nil %s", debug.traceback())
			return
		end
		if ti > TM_TIMEOUT_LIMIT then
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
					log.debug("%s task number:%d", timer, table.size(handles))
					if cb then cb() end
					skynet.sleep(ti)
				end
				log.debug("%s watch done", timer)
			end)
		end)
	end

	return timer
end


return M
