--[[
MongoDB utility
Just a simple wrapper of `skynet.db.mongo`
Create mongo logic service, then:
	mongoutil.init(conf)
	db = mongoutil.use("testdb")
	db.testcoll:findOne({test_key2 = 1})
	...
	do other CRUDs like above
NOTE:
	only one MongoDB instance connected per service!
]]--

local skynet = require "skynet"
local mongo = require "skynet.db.mongo"
local log = require "tm.log"
local xdump = require "tm.xtable".dump

local PING_INTERVAL = 10*60*100

local mongoutil = {}
local firsttime = true

local cli


local function keep_alive()
	local ok, ret
	while true do
		skynet.sleep(PING_INTERVAL)
		if cli then
			log.info("keep alive MongDB:%s ...", cli)
			ok, ret = pcall(cli.runCommand, cli, "ping")
			if not ok then
				log.error("ping %s failed:%s", cli, ret)
			end
		end
	end
end


function mongoutil.init(conf)
	if cli then
		log.error("mongoutil already initialized!")
		return
	end

	log.debug("mongoutil init by conf: %s", xdump(conf))
	cli = mongo.client({
		host = conf.host,
		port = conf.port,
		username = conf.user,
		password = conf.password,
		authdb = conf.authdb,
	})
	log.info("connect MongoDB %s:%d succeed!", conf.host, conf.port)

	if firsttime then
		firsttime = false
		skynet.fork(keep_alive)
	end
end


function mongoutil.clear()
	if cli then
		cli:disconnect()
		cli = nil
	end
end


function mongoutil.client()
	return cli
end


function mongoutil.use(dbname)
	return cli[dbname]
end


return mongoutil
