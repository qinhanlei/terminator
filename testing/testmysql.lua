local skynet = require "skynet"
local util = require "util"
local dbutil = require "dbutil"
local tlog = require "tlog"


local function test_insert()
	dbutil.execute_sql("tgame", "delete from user;")
	for i = 1, 10 do
		local sql = dbutil.sql_insert("user", {
			username = "test"..i,
			record_time = util.nowstr(),
		})
		dbutil.execute_sql("tgame", sql)
	end
end


local function test_query()
	skynet.timeout(6*100, test_query)
	tlog.debug("run test query ...")
	local t = dbutil.execute_sql("tgame", "select * from user;")
	if t then
		tlog.info("query succeed! row_count:%d ", #t)
	else
		tlog.error("query failed!")
	end
end


skynet.start(function()
	tlog.debug("Test of MySQL.")

	skynet.uniqueservice("tmysql")

	test_insert()
	test_query()
end)
