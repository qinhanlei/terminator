local skynet = require "skynet"

local log = require "tm.log"
local time = require "tm.time"
local sqlaux = require "tm.sqlaux"

local mconf = require("config_db").mysql


local function test_insert()
	sqlaux.exec("tgame", "delete from user;")
	for i = 1, 42 do
		local userinfo = {
			name = "test"..i,
			age = i,
			record_time = time.nowstr(),
		}
		sqlaux.insert("tgame", "user", userinfo)
	end
	log.info("test insert done")
end


local function test_query()
	-- skynet.timeout(6*100, test_query)
	log.debug("run test query ...")
	local t, e
	t = sqlaux.exec("tgame", "select * from user;")
	if t then
		log.info("query succeed! total rows:%d ", #t)
	end

	t, e = sqlaux.query("tgame", "user", "id,age", "id>5 and id<10", "ORDER BY age DESC")
	if not t then
		log.error(e)
	end
	for k,v in pairs(t) do
		log.info("get row: %s %s", k, v)
	end
	log.info("test query done")
end


local function test_update()
	sqlaux.update("tgame", "user", {age = 99}, {id = 42})
	log.info("test update done")
end


local function test_delete()
	sqlaux.delete("tgame", "user", "id < 10")
	log.info("test delete done")
end


skynet.start(function()
	log.debug("Test of MySQL")

	sqlaux.init(mconf)

	test_insert()
	test_query()
	test_update()
	test_delete()

	log.debug("Test of MySQL done")
end)
