local skynet = require "skynet"
local snax = require "snax"

local logger = require "simple-logger"

local handler = handler or {}
handler.name = nil

function accept.log(...)
    logger("my-snax accept.log <"..handler.name..">", ...)
end

function accept.exit()
    logger("my-snax accept.exit ...")
    snax.exit()
end

function response.echo(...)
    logger("my-snax echo ...")
    return ...
end

function init(name, ...)
    logger("my-snax init ...")
    handler.name = name or "unnamed"
end

function exit()
    logger("my-snax exiting ...")
end
