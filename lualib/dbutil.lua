local skynet = require "skynet"
local mysql = require "mysql"
local tlog = require "tlog"

local dbutil = {}


function dbutil.execute_sql(db, fmt, ...)
	local ok, sql = pcall(string.format, fmt, ...)
	if not ok then
		tlog.error("format sql failed:%s", tostring(sql))
		return nil, tostring(sql)
	end

	local ok, t = pcall(skynet.call, ".tmysql", "lua", "query", db, sql)
	if not ok then
		tlog.error("call failed: %s", tostring(t))
		return nil, tostring(t)
	end

	if t.badresult then
		tlog.error("sql: %s. err: %d %s", sql, t.errno, t.err)
		return nil, t.err
	end

	return t
end


function dbutil.sql_insert(tbl, data)
	local keys = ""
	local vals = ""
	for k, v in pairs(data) do
		if string.len(keys) > 0 then
			keys = keys..","
			vals = vals..","
		end
		keys = keys.."`"..k.."`"
		if type(v) == "string" then
			vals = vals..mysql.quote_sql_str(v)
		else
			vals = vals..v
		end
	end
	return "insert into "..tbl.."("..keys..") value("..vals..");"
end


return dbutil
