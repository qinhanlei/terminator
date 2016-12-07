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
    local handles = {}
    
    function timer.timeout(ti, f)
    	local function tf()
    		local f = handles[tf]
    		if f then
    			f()
    		end
    	end
    	skynet.timeout(ti, tf)
        handles[tf] = f
    	return tf
    end
    
    function timer.cancel(tf)
    	handles[tf] = nil
    end
    
    function timer.clear()
    	for k, _ in pairs(handles) do
    		handles[k] = nil
    	end
    end
    
    return timer
end


return util
