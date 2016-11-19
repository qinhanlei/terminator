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


return util