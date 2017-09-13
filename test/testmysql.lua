local skynet = require "skynet"
local util = require "util"
local dbutil = require "dbutil"


local function test_insert()
	local t = dbutil.execute_sql("tm_game", "delete from user;")
	for i = 1, 10 do
		local sql = dbutil.sql_insert("user", {
			username = "test"..i,
			record_time = util.nowstr(),
		})
		local t = dbutil.execute_sql("tm_game", sql)
	end
end


local function test_query()
	skynet.timeout(6*100, test_query)
	tlog.debug("run test query ...")
	local t = dbutil.execute_sql("tm_game", "select * from user;")
	if t then
		tlog.info("query succeed! row_count:%d ", #t)
	else
		tlog.error("query failed!")
	end
end


skynet.start(function()
	tlog.debug("Test of MySQL.")
	
	skynet.uniqueservice("tm_mysql")
	
	test_insert()
	test_query()
	
end)
