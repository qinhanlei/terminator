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


return util