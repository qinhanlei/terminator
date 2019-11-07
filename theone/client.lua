local skynet = require "skynet"
local websocket = require "http.websocket"
local log = require "log"

local parser = require "parser"
parser.register("msg.proto", "./theone")


local clientid = ...

local function start()
	local ws_id = websocket.connect("ws://127.0.0.1:10086")
	local count = 1
	clientid = clientid or 0
	log.debug("this is echo client%d", clientid)
	while true do
		local msg = "hello world! " .. count
		count = count + 1
		websocket.write(ws_id, msg)
		log.debug("client%d >>> %s", clientid, msg)
		local resp, close_reason = websocket.read(ws_id)
		log.debug("client%d <<< %s", clientid, (resp and resp or "[Close] " .. close_reason))
		if not resp then
			log.debug("client%d echo server close", clientid)
			break
		end
		websocket.ping(ws_id)
		skynet.sleep(100)
	end
end

skynet.start(function()
	skynet.fork(start)
end)
