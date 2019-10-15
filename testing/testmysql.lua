local skynet = require "skynet"
local log = require "log"
local time = require "time"
local sqlaux = require "sqlaux"
local mconf = require("config_db").mysql


local function test_insert()
	sqlaux.exec("tgame", "delete from user;")
	for i = 1, 42 do
		local userinfo = {
			username = "test"..i,
			record_time = time.nowstr(),
		}
		sqlaux.insert("tgame", "user", userinfo)
	end
end


local function test_query()
	skynet.timeout(6*100, test_query)
	log.debug("run test query ...")
	local t = sqlaux.exec("tgame", "select * from user;")
	if t then
		log.info("query succeed! row_count:%d ", #t)
	else
		log.error("query failed!")
	end
end


skynet.start(function()
	log.debug("Test of MySQL")

	local tmysql, e = skynet.uniqueservice("tmysql")
	if not tmysql then
		log.error("failed:%s", e)
	end
	skynet.call(tmysql, "lua", "start", mconf)

	test_insert()
	test_query()
	log.debug("Test of MySQL done")
end)
