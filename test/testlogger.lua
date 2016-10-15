local skynet = require "skynet"
local logger = require "simple-logger"


skynet.start(function()
    logger("this is test of logger.")
    
end)
