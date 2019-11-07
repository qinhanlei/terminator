local skynet = require "skynet"
local websocket = require "http.websocket"
local log = require "log"

local parser = require "parser"
parser.register("msg.proto", "./theone")

local CMD = {}

--NOTE: handler API list by websocket.lua, see simplewebsocket.lua
local handle = {}

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
	websocket.write(id, msg)
end

function handle.ping(id)
	log.debug("ws ping from: " .. tostring(id) .. "\n")
end

function handle.pong(id)
	log.debug("ws pong from: " .. tostring(id))
end

function handle.close(id, code, reason)
	log.info("ws close from: " .. tostring(id), code, reason)
end

function handle.error(id)
	log.error("ws error from: " .. tostring(id))
end


function CMD.start(id, addr, protocol)
	log.info("start fd:%d addr:%s protocol:%s", id, addr, protocol)
	local ok, err = websocket.accept(id, handle, protocol, addr)
	if not ok then
		log.error("accept failed:%s", err)
	end
end


skynet.start(function()
	skynet.dispatch("lua", function(_, _, cmd, ...)
		local f = assert(CMD[cmd], cmd .. " not found")
		skynet.retpack(f(...))
	end)
end)
