local skynet = require "skynet"
require "skynet.manager"
local mongo = require "skynet.db.mongo"
local log = require "tm.log"
local xdump = require "tm.xtable".dump

local PING_INTERVAL = 60*100

local CMD = {}

local cli
local index
local config

local logic
local mongoc = {}

function mongoc.hello()
	log.debug("hello back!")
end

function mongoc.client()
	return cli
end

function mongoc.config()
	return config
end


local function keep_alive()
	while true do
		skynet.sleep(PING_INTERVAL)
		log.info("ping MongDB:%s %d %s", cli, index, xdump(cli:runCommand("ping")))
	end
end


function CMD.start(id, conf, logiclua)
	if cli then
		log.error("mgoaux already initialized!")
		return
	end
	index = id
	config = conf
	logic = assert(require(logiclua))
	assert(type(logic.init) == "function", "have no start function")

	log.warn("mgoaux init by conf: %s", xdump(conf))
	cli = mongo.client({
		host = conf.host,
		port = conf.port,
		username = conf.user,
		password = conf.password,
		authdb = conf.authdb,
	})
	log.info("connect MongoDB %s:%d index:%d succeed!", conf.host, conf.port, index)
	skynet.fork(keep_alive)

	skynet.fork(logic.init, mongoc)
end


skynet.start(function()
	skynet.dispatch("lua", function(_, _, cmd, ...)
		local f = assert(CMD[cmd], cmd .. " not found")
		skynet.retpack(f(...))
	end)
	skynet.fork(keep_alive)
end)
