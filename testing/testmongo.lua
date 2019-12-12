local skynet = require "skynet"

local log = require "tm.log"
local mongoaux = require "tm.db.mongoaux"
local mongoutil = require "tm.db.mongoutil"
local mongotester = require "mongotester"

local conf = require("config_db").mongo
local test_mode = ...

local CMD = {}


function CMD.aux()
	log.info("test mongoaux ...")
	mongoaux.init(conf, "mongotester")
	mongoaux.call("hello", "this is test!")
	mongoaux.call("test_insert")
	mongoaux.call("test_query")
	mongoaux.call("test_update")
	mongoaux.call("test_delete")
end


function CMD.util()
	log.info("test mongoutil ...")
	mongoutil.init(conf)
	mongotester.test_insert()
	mongotester.test_query()
	mongotester.test_update()
	mongotester.test_delete()
end


skynet.start(function()
	log.debug("Test of MongoDB")

	test_mode = test_mode or "aux"
	log.debug("testmode:", test_mode)
	local f = assert(CMD[test_mode])
	f()

	log.debug("Test of MongoDB done")
end)
