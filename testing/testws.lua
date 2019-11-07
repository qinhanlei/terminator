local skynet = require "skynet"
local socket = require "skynet.socket"
local websocket = require "http.websocket"
local log = require "log"

local handle = {}
local MODE = ...
local SERVICE_NAME = _G.SERVICE_NAME

if MODE == "agent" then
    local idx = 0

    function handle.connect(id)
        log.info("ws connect from: " .. tostring(id))
    end

    function handle.handshake(id, header, url)
        local addr = websocket.addrinfo(id)
        log.debug("ws handshake from: " .. tostring(id), "url", url, "addr:", addr)
        log.debug("----header-----")
        for k,v in pairs(header) do
            log.debug(k,v)
        end
        log.debug("--------------")
    end

    function handle.message(id, msg)
        idx = idx + 1
        websocket.write(id, msg.." idx:"..idx)
    end

    function handle.ping(id)
        log.debug("ws ping from: " .. tostring(id) .. "\n")
    end

    function handle.pong(id)
        log.debug("ws pong from: " .. tostring(id))
    end

    function handle.close(id, code, reason)
        log.debug("ws close from: " .. tostring(id), code, reason)
    end

    function handle.error(id)
        log.error("ws error from: " .. tostring(id))
    end

    skynet.start(function ()
        skynet.dispatch("lua", function (_,_, id, protocol, addr)
            websocket.accept(id, handle, protocol, addr)
        end)
    end)

elseif MODE == "client" then

    local _, clientid, protocol = ...

    skynet.start(function()
        skynet.fork(function()
            local url = string.format("%s://127.0.0.1:9948/test_websocket", protocol)
            local ws_id = websocket.connect(url)
            local count = 1
            log.debug("this is echo client:"..clientid)
            while true do
                local msg = "hello world! " .. count
                count = count + 1
                websocket.write(ws_id, msg)
                log.debug(clientid.." >>>: " .. msg)
                local resp, close_reason = websocket.read(ws_id)
                log.debug(clientid.." <<<: " .. (resp and resp or "[Close] " .. close_reason))
                if not resp then
                    log.debug(clientid .. "echo server close.")
                    break
                end
                websocket.ping(ws_id)
                skynet.sleep(100)
            end
        end)
    end)

else

    skynet.start(function ()
        local agent = {}
        for i= 1, 1 do
            agent[i] = skynet.newservice(SERVICE_NAME, "agent")
        end
        local balance = 1
        local protocol = "ws"

        local lfd = socket.listen("0.0.0.0", 9948)
        skynet.error(string.format("Listen websocket port 9948 protocol:%s", protocol))
        socket.start(lfd, function(id, addr)
            log.debug(string.format("accept client socket_id: %s addr:%s", id, addr))
            skynet.send(agent[balance], "lua", id, protocol, addr)
            balance = balance + 1
            if balance > #agent then
                balance = 1
            end
        end)

        -- test echo client
        for i = 1, 3 do
            skynet.newservice(SERVICE_NAME, "client", i, protocol)
        end
    end)
end