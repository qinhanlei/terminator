local log = require "tm.log"
local mongoutil = require "tm.mongoutil"
-- local xdump = require "tm.xtable".dump


local mongotester = {}


function mongotester.start()
	log.info("mongotester start!")
end


function mongotester.hello(str)
	log.info("mongotester hello back:[ %s ]", str)
end


function mongotester.test_insert()
	log.info("test insert ...")

	local ok, err, ret
	local db = mongoutil.use("testdb")

	log.info("test insert without index")
	db.testcoll:dropIndex("*")
	db.testcoll:drop()

	ok, err, ret = db.testcoll:safe_insert({test_key = 1});
	assert(ok and ret and ret.n == 1, err)

	ok, err, ret = db.testcoll:safe_insert({test_key = 2, test_key2 = 2});
	assert(ok and ret and ret.n == 1, err)

	db.testcoll:delete({test_key = 2}, true)

	log.info("test insert with index")
	db.testcoll:ensureIndex({test_key = 1}, {unique = true, name = "test_key_index"})

	ok, err, ret = db.testcoll:safe_insert({test_key = 2})
	assert(ok and ret and ret.n == 1, err)

	ok, err, ret = db.testcoll:safe_insert({test_key = 1})
	assert(ok == false and string.find(err, "duplicate key error"))

	return true
end


function mongotester.test_query()
	log.info("test query ...")

	local ok, err, ret
	local db = mongoutil.use("testdb")
	db.testcoll:dropIndex("*")
	db.testcoll:drop()

	db.testcoll:ensureIndex({test_key = 1}, {test_key2 = -1}, {unique = true, name = "test_index"})

	ok, err, ret = db.testcoll:safe_insert({test_key = 1, test_key2 = 1})
	assert(ok and ret and ret.n == 1, err)

	ok, err, ret = db.testcoll:safe_insert({test_key = 1, test_key2 = 2})
	assert(ok and ret and ret.n == 1, err)

	ok, err, ret = db.testcoll:safe_insert({test_key = 2, test_key2 = 3})
	assert(ok and ret and ret.n == 1, err)

	ret = db.testcoll:findOne({test_key2 = 1})
	assert(ret and ret.test_key2 == 1, err)
	-- log.debug("findOne: ", xdump(ret))

	ret = db.testcoll:find({test_key2 = {['$gt'] = 0}}):sort({test_key = 1}, {test_key2 = -1}):skip(1):limit(1)
	assert(ret:count() == 3)
	assert(ret:count(true) == 1)
	-- log.debug("find: %s", xdump(ret))
	if ret:hasNext() then
		ret = ret:next()
		-- log.debug("find next: %s", xdump(ret))
	end
	assert(ret and ret.test_key2 == 1)

	return true
end


function mongotester.test_update()
	log.info("test update ...")

	local ok, err, ret
	local db = mongoutil.use("testdb")
	db.testcoll:dropIndex("*")
	db.testcoll:drop()

	ok, err, ret = db.testcoll:safe_insert({test_key = 1});
	assert(ok and ret and ret.n == 1, err)

	ok, err, ret = db.testcoll:safe_insert({test_key = 2, value = 42});
	assert(ok and ret and ret.n == 1, err)

	ok, err, ret = db.testcoll:safe_update({test_key = 2}, {['$set'] = { value = 73}})
	assert(ok and ret and ret.n == 1, err)

	return true
end


function mongotester.test_delete()
	log.info("test delete ...")

	local db = mongoutil.use("testdb")

	db.testcoll:delete({test_key = 1})
	db.testcoll:delete({test_key = 2})

	local ret = db.testcoll:findOne({test_key = 1})
	assert(ret == nil)

	return true
end


return mongotester
