local skynet = require "skynet"

local log = require "tm.log"
local mgoaux = require "tm.mgoaux"
local mgoutil = require "tm.mgoutil"
-- local xdump = require "tm.xtable".dump

local conf = require("config_db").mongo
local test_mode = ...  -- mgoaux / mgoutil


local function test_insert()
	log.info("test insert ...")

	local ok, err, ret
	local db = mgoutil.use("testDB")

	log.info("test insert without index")
	db.testColl:dropIndex("*")
	db.testColl:drop()

	ok, err, ret = db.testColl:safe_insert({test_key = 1});
	assert(ok and ret and ret.n == 1, err)

	ok, err, ret = db.testColl:safe_insert({test_key = 2, test_key2 = 2});
	assert(ok and ret and ret.n == 1, err)

	db.testColl:delete({test_key = 2}, true)

	log.info("test insert with index")
	db.testColl:ensureIndex({test_key = 1}, {unique = true, name = "test_key_index"})

	ok, err, ret = db.testColl:safe_insert({test_key = 2})
	assert(ok and ret and ret.n == 1, err)

	ok, err, ret = db.testColl:safe_insert({test_key = 1})
	assert(ok == false and string.find(err, "duplicate key error"))
end


local function test_query()
	log.info("test query ...")

	local ok, err, ret
	local db = mgoutil.use("testDB")
	db.testColl:dropIndex("*")
	db.testColl:drop()

	db.testColl:ensureIndex({test_key = 1}, {test_key2 = -1}, {unique = true, name = "test_index"})

	ok, err, ret = db.testColl:safe_insert({test_key = 1, test_key2 = 1})
	assert(ok and ret and ret.n == 1, err)

	ok, err, ret = db.testColl:safe_insert({test_key = 1, test_key2 = 2})
	assert(ok and ret and ret.n == 1, err)

	ok, err, ret = db.testColl:safe_insert({test_key = 2, test_key2 = 3})
	assert(ok and ret and ret.n == 1, err)

	ret = db.testColl:findOne({test_key2 = 1})
	assert(ret and ret.test_key2 == 1, err)
	-- log.debug("findOne: ", xdump(ret))

	ret = db.testColl:find({test_key2 = {['$gt'] = 0}}):sort({test_key = 1}, {test_key2 = -1}):skip(1):limit(1)
	assert(ret:count() == 3)
	assert(ret:count(true) == 1)
	-- log.debug("find: %s", xdump(ret))
	if ret:hasNext() then
		ret = ret:next()
		-- log.debug("find next: %s", xdump(ret))
	end
	assert(ret and ret.test_key2 == 1)
end


local function test_update()
	log.info("test update ...")

	local ok, err, ret
	local db = mgoutil.use("testDB")
	db.testColl:dropIndex("*")
	db.testColl:drop()

	ok, err, ret = db.testColl:safe_insert({test_key = 1});
	assert(ok and ret and ret.n == 1, err)

	ok, err, ret = db.testColl:safe_insert({test_key = 2, value = 42});
	assert(ok and ret and ret.n == 1, err)

	ok, err, ret = db.testColl:safe_update({test_key = 2}, {['$set'] = { value = 73}})
	assert(ok and ret and ret.n == 1, err)
end


local function test_delete()
	log.info("test delete ...")

	local db = mgoutil.use("testDB")

	db.testColl:delete({test_key = 1})
	db.testColl:delete({test_key = 2})

	local ret = db.testColl:findOne({test_key = 1})
	assert(ret == nil)
end


local CMD = {}

function CMD.mgoaux()
	log.info("test mgoaux ...")
	mgoaux.init(conf)
end

function CMD.mgoutil()
	log.info("test mgoutil ...")
	mgoutil.init(conf)
	test_insert()
	test_query()
	test_update()
	test_delete()
end


skynet.start(function()
	log.debug("Test of MongoDB")

	test_mode = test_mode or "mgoaux"
	log.debug("testmode:", test_mode)
	local f = assert(CMD[test_mode])
	f()

	log.debug("Test of MongoDB done")
end)
