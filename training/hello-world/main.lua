local skynet = require "skynet"
local skynet_manager = require "skynet.manager"
local skynet_core = require "skynet.core"

skynet.start(function()

    local logger = skynet.localname(".logger")
    if not logger then
        skynet.error("no logger!")
        skynet_manager.abort()
    end

    skynet_core.send(logger, skynet.PTYPE_TEXT, 0, "---> hello world! <---")
    skynet.timeout(3, function()
        skynet_manager.abort()
    end)

end)
