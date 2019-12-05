--[[
MongoDB auxiliary

create mongo logic service, then:
	mgoaux.init(conf)
	db = mgoaux.use("testdb")
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

local mgoaux = {}

local clients = {}
local balance = 0


local function keep_alive()
	while true do
		skynet.sleep(PING_INTERVAL)
		for i, c in ipairs(clients) do
			log.info("ping MongDB[%d]: %s", i, xdump(c:runCommand("ping")))
		end
	end
end


function mgoaux.init(conf)
	if #clients > 0 then
		log.error("mgoaux already initialized!")
		return
	end
	log.warn("mgoaux init by conf: %s", xdump(conf))
	for i = 1, conf.connects or 4 do
		local cli = mongo.client({
			host = conf.host,
			port = conf.port,
			username = conf.user,
			password = conf.password,
			authdb = conf.authdb,
		})
		log.info("connect MongoDB %s:%d %d succeed!", conf.host, conf.port, i)
		table.insert(clients, cli)
	end
	skynet.fork(keep_alive)
end


function mgoaux.use(dbname)
	balance = (balance % #clients) + 1
	return clients[balance][dbname]
end


return mgoaux
