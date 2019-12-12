local skynet = require "skynet"

local log = require "tm.log"
local xmongo = require "tm.db.xmongo"
local mongotester = require "mongotester"

local conf = require("config_db").mongo
local test_mode = ...

local CMD = {}


function CMD.simple()
	log.info("test xmongo in simple mode ...")
	xmongo.init(conf)
	mongotester.test_insert()
	mongotester.test_query()
	mongotester.test_update()
	mongotester.test_delete()
end


function CMD.multi()
	log.info("test xmongo in multi mode ...")
	xmongo.init(conf, "mongotester")
	xmongo.call("hello", "this is test!")
	xmongo.call("test_insert")
	xmongo.call("test_query")
	xmongo.call("test_update")
	xmongo.call("test_delete")
end


skynet.start(function()
	log.debug("Test of MongoDB")

	test_mode = test_mode or "simple"
	log.debug("testmode:", test_mode)
	local f = assert(CMD[test_mode])
	f()

	log.debug("Test of MongoDB done")
end)
