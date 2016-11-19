local skynet = require "skynet"
local util = require "util"

local _cmd = table.pack(...)

local CMD = {}


skynet.start(function()
    tlog.debug("Test of MySQL.")
    
    skynet.newservice("tm_mysql")
    
    util.process(CMD, table.unpack(_cmd))

end)
