local skynet = require "skynet"

local util = {}


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


function util.nowstr()
	local t = os.date("*t")
	return string.format("%04d-%02d-%02d %02d:%02d:%02d",
			t.year, t.month, t.day, t.hour, t.min, t.sec)
end


function util.newtimer()
    local timer = {}
    local handles = {} --setmetatable({}, {__mode = "kv"})
    
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
    
    return timer
end


return util
