local skynet = require "skynet"
local skynet_manager = require "skynet.manager"

local socket = require "socket"
local socketchannel = require "socketchannel"

local logger = require "simple-logger"
require "constants"


local name = ... or ""

local function _do_socket()
    local function _read(id)
        while true do
            local str = socket.read(id)
            if str then
                logger(id, "server:", str)
                socket.close(id)
                skynet.exit()
            else
                socket.close(id)
                logger("disconnected.")
                skynet.exit()
            end
        end
    end
    local addr = skynet.getenv"echo_server"

    local id = socket.open(addr)
    if not id then
        logger("can't connect to ", addr)
        skynet.exit()
    end

    logger("connected!")
    skynet.fork(_read, id)
    socket.write(id, "hello, "..name)
end


local function _do_socket_channel()
    -- TODO: ...
end


skynet.start(function()
    logger("my name is", name)
    --skynet_manager.name(".dbgconsole", skynet.newservice("debug_console", DEBUG_CONSOLE_PORT+1))

    _do_socket()
    --_do_socket_channel()
end)
