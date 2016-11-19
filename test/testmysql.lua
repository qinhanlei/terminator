local skynet = require "skynet"
local util = require "util"
local dbutil = require "dbutil"

local _cmd = table.pack(...)

local CMD = {}


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
    local t = dbutil.execute_sql("tm_game", "select * from user;")
    dump(t)
end


skynet.start(function()
    tlog.debug("Test of MySQL.")
    
    skynet.newservice("tm_mysql")
    skynet.call(".db_mysql", "lua", "start")
    
    test_insert()
    test_query()
    
    util.process(CMD, table.unpack(_cmd))
    
    skynet.exit()
end)
