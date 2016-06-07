local skynet = require "skynet"
local logger = require "simple-logger"

local mc = require "multicast"
local dc = require "datacenter"

require "constants"

local slave_service = {}
slave_service.handler = function(session, source, ...)
    logger("["..skynet.address(source).."] MSG:", ...)
end

skynet.init(function()
    -- get handle
    slave_service.master = assert(skynet.queryservice(true, "master-service"))
    logger("get master handle:", slave_service.master)
end)

skynet.start(function()
    skynet.dispatch("lua", slave_service.handler)

    slave_service.mc = mc.new{
        channel = dc.get("master-slave", "multicast-channel"),
        dispatch = function (channel, source, ...)
            local id = channel.channel
            logger("["..skynet.address(source).."] channel"..id, "MSG:", ...)
        end,
    }
    slave_service.mc:subscribe()

    -- test
    --skynet.send("master-service", "lua", "SLAVE", skynet.getenv"harbor")

    -- send by handle
    skynet.send(slave_service.master, "lua", "SLAVE", skynet.getenv"harbor")

    -- send by alias
    --skynet.send("the_master_node", "lua", "SLAVE", skynet.getenv"harbor")
end)
