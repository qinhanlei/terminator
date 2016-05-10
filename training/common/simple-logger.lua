local skynet = require "skynet"
local skynet_manager = require "skynet.manager"
local skynet_core = require "skynet.core"

local _logger = nil
local function get_logger()
    if _logger == nil then
        -- print("logger is nil.")
        _logger = skynet.localname(".logger")
        if not _logger then
            skynet.error("no logger!")
            skynet_manager.abort()
        end
    else
        -- print("logger already exist.")
    end
    return _logger
end

local function logging(...)
    local t = {...}
	for i=1,#t do
		t[i] = tostring(t[i])
	end
    local msg = table.concat(t, " ")
    
    local info = debug.getinfo(2)
	if info then
		-- local filename = string.match(info.short_src, "[^/.]+.lua")
        local filename = info.short_src
		msg = string.format("[%s:%d] %s", filename, info.currentline, msg)
	end
    
    local logger = get_logger()
    if logger then
        skynet_core.send(logger, skynet.PTYPE_TEXT, 0, msg)
    else
        print(table.concat(t, " "))
    end
end

return logging
