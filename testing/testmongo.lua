local skynet = require "skynet"

local log = require "tm.log"
local mgoaux = require "tm.mgoaux"
local mgoutil = require "tm.mgoutil"
local mgologic = require "mgologic"

local conf = require("config_db").mongo
local test_mode = ...  -- mgoaux / mgoutil

local CMD = {}


function CMD.mgoaux()
	log.info("test mgoaux ...")
	mgoaux.init(conf, "mgologic")
	mgoaux.call("hello", "this is test!")
	mgoaux.call("test_insert")
	mgoaux.call("test_query")
	mgoaux.call("test_update")
	mgoaux.call("test_delete")
end


function CMD.mgoutil()
	log.info("test mgoutil ...")
	mgoutil.init(conf)
	mgologic.test_insert()
	mgologic.test_query()
	mgologic.test_update()
	mgologic.test_delete()
end


skynet.start(function()
	log.debug("Test of MongoDB")

	test_mode = test_mode or "mgoaux"
	log.debug("testmode:", test_mode)
	local f = assert(CMD[test_mode])
	f()

	log.debug("Test of MongoDB done")
end)
