local skynet = require "skynet"
local skynet_manager = require "skynet.manager"

local logger = require "simple-logger"

require "constants"

skynet.start(function()
    local master_service = assert(skynet.uniqueservice(true, "master-service"))
    logger("launch uniqueservice MASTER done.")

    -- give an alias, send message will more convenience
    skynet_manager.name("the_master_node", master_service)

    -- start finish
    skynet.exit()
end)
