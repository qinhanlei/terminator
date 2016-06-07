local skynet = require "skynet"
local logger = require "simple-logger"

local mc = require "multicast"
local dc = require "datacenter"

require "constants"

local master_service = {}
master_service.handler = function(session, source, cmd, id, ...)
    logger("["..skynet.address(source).."]", cmd, id)

    -- single response
    skynet.send(source, "lua", "hi, slave"..id)
    -- multicast welcome
    master_service.mc:publish("hi, slave"..id)
end


skynet.start(function()
    logger("master service starting...")
    skynet.dispatch("lua", master_service.handler)
    logger("master service dispatching...")

    master_service.mc = mc.new()
    dc.set("master-slave", "multicast-channel", master_service.mc.channel)
    logger("MASTER channel:"..master_service.mc.channel, "established.")
end)
