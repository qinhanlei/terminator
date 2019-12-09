--[[
MongoDB eXecute

create mongo logic service, then:
	mongox.init(conf)
	db = mongox.use("testdb")
	db:findOne({test_key2 = 1})
	...
	do other CRUDs like above

NOTE:
	only one MongoDB instance connected per service!
]]--

local skynet = require "skynet"
local mongo = require "skynet.db.mongo"
local log = require "tm.log"
local xdump = require "tm.xtable".dump

local PING_INTERVAL = 60*100

local mongox = {}

local cli


local function keep_alive()
	while true do
		skynet.sleep(PING_INTERVAL)
		log.info("ping MongDB:%s %s", cli, xdump(cli:runCommand("ping")))
	end
end


function mongox.init(conf)
	if cli then
		log.error("mongox already initialized!")
		return
	end
	log.warn("mongox init by conf: %s", xdump(conf))
	cli = mongo.client({
		host = conf.host,
		port = conf.port,
		username = conf.user,
		password = conf.password,
		authdb = conf.authdb,
	})
	log.info("connect MongoDB %s:%d succeed!", conf.host, conf.port)
	skynet.fork(keep_alive)
end


function mongox.client()
	return cli
end


function mongox.use(dbname)
	return cli[dbname]
end


return mongox
