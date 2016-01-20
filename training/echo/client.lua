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
    local chan = socketchannel.channel {
        host = skynet.getenv"echo_server_ip",
        port = skynet.getenv"echo_server_port",
    }

    while true do
        local msg = chan:request("hello, "..name, function(sock)
            local str = sock:read()
            if not str then
                logger("sock:read() failed !")
                return false
            end
            --logger("sock:read() succeed:", str)
            return true, str
        end)

        if not msg then
            logger("error: server MSG nil.")
            break
        end
        logger("server MSG:", msg)
        skynet.sleep(2*SKYNET_ONE_SECOND)
    end

    chan:close()
    skynet.exit()
end


skynet.start(function()
    logger("my name is", name)
    local dbgc_service = skynet.newservice("debug_console", DEBUG_CONSOLE_PORT+1)
    skynet_manager.name(".dbgconsole", dbgc_service)

    -- _do_socket()

    skynet.fork(_do_socket_channel)
end)
