--[[
eXecute MongoDB immediately utility

	As simple wrapper of `skynet.db.mongo`:
		```
		xmongo.init(conf)
		local db = xmongo.use("testdb")
		db.testcoll:findOne({test_key2 = 1})
		... do other CRUD operators like above ...
		```
		NOTE: one service one connection to one MongoDB instance

	More connections with one MongoDB instance for concurrency :
		Use logicfile(lua file) wrap up logic to access MongoDB parallel.
		`xmongo.init(conf, logicfile)`
		use as simple way by some methods in logicfile:
			`local db = xmongo.use("testdb")`
			...
		`xmongo.call(method, ...)`
]]--

local skynet = require "skynet"
local mongo = require "skynet.db.mongo"
local log = require "tm.log"
local xdump = require "tm.xtable".dump

local PING_INTERVAL = 10*60*100

local xmongo = {}

-- simple mode only
local cli
local firsttime = true


local function watcher()
	local ok, ret
	while true do
		skynet.sleep(PING_INTERVAL)
		if cli then
			log.info("keep alive %s ...", cli)
			ok, ret = pcall(cli.runCommand, cli, "ping")
			if not ok then
				log.error("ping %s failed:%s", cli, ret)
			end
		end
	end
end


function xmongo.init(conf, logicfile)
	-- multi mongoc services mode
	if logicfile then
		local service = skynet.uniqueservice("tm/db/mongod")
		return skynet.call(service, "lua", "start", conf, logicfile)
	end

	-- simple xmongo utility mode
	if cli then
		log.warn("already initialized!")
		return false
	end

	log.debug("init by conf: %s", xdump(conf))
	cli = mongo.client({
		host = conf.host,
		port = conf.port,
		username = conf.user,
		password = conf.password,
		authdb = conf.authdb,
	})
	log.info("connect %s:%d succeed!", conf.host, conf.port)

	if firsttime then
		firsttime = false
		skynet.fork(watcher)
	end
	return true
end


function xmongo.clear()
	if cli then
		cli:disconnect()
		cli = nil
	else
		local service = skynet.localname(".mongod")
		if service then
			skynet.send(service, "lua", "stop")
		end
	end
end


function xmongo.client()
	assert(cli, "have no simple mode client!")
	return cli
end


function xmongo.use(dbname)
	assert(cli, "have no simple mode client!")
	return cli[dbname]
end


function xmongo.call(method, ...)
	local c = skynet.call(".mongod", "lua", "client")
	if not c then
		log.error("have no client")
		return nil, "have no client"
	end
	local ok, t = pcall(skynet.call, c, "lua", "logic", method, ...)
	if not ok then
		log.error("call failed: %s", t)
		return nil, t
	end
	return t
end


return xmongo
