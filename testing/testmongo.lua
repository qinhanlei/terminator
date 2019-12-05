local skynet = require "skynet"

local log = require "tm.log"
local mgoaux = require "tm.mgoaux"

local conf = require("config_db").mongo


local function test_insert()
	log.info("test insert ...")
	--TODO: ...
end


local function test_query()
	log.info("test query ...")
	--TODO: ...
end


local function test_update()
	log.info("test update ...")
	--TODO: ...
end


local function test_delete()
	log.info("test delete ...")
	--TODO: ...
end


skynet.start(function()
	log.debug("Test of MongoDB")

	mgoaux.init(conf)

	test_insert()
	test_query()
	test_update()
	test_delete()

	log.debug("Test of MongoDB done")
end)
