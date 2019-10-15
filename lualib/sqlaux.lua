-- SQL auxiliary
local skynet = require "skynet"
local mysql = require "skynet.db.mysql"
local log = require "log"

local sqlaux = {}


--NOTE: use `mysql.quote_sql_str(s)` to avoid SQL injection
function sqlaux.exec(db, fmt, ...)
	local ok, sql, t

	if select('#', ...) ~= 0 then
		ok, sql = pcall(string.format, fmt, ...)
		if not ok then
			log.error("format sql failed:%s", tostring(sql))
			return nil, tostring(sql)
		end
	end

	ok, t = pcall(skynet.call, ".tmysql", "lua", "query", db, sql or fmt)
	if not ok then
		log.error("call failed: %s", tostring(t))
		return nil, tostring(t)
	end

	if t.badresult then
		log.error("sql: %s. err: %d %s", sql, t.errno, t.err)
		return nil, t.err
	end
	return t
end

-- -----------------------------------------------------------------------------

function sqlaux.insert(db, tbl, kvmap)
	local keys, vals = "", ""
	for k, v in pairs(kvmap) do
		if string.len(keys) > 0 then
			keys = keys .. ','
			vals = vals .. ','
		end
		keys = keys .. '`' .. k .. '`'
		if type(v) == "string" then
			v = mysql.quote_sql_str(v)
		end
		vals = vals .. v
	end
	local q = "INSERT INTO "..tbl.."("..keys..") VALUE("..vals..");"
	return sqlaux.exec(db, q)
end


-- colums: array
-- conditions: {key = value}/string, can be {}/""
function sqlaux.query(db, tbl, columns, conditions, others)
	columns = columns or "*"
	local typ = type(columns)
	local columnstr = ""
	if typ == "table" then
		for _, v in ipairs(columns) do
			if type(v) == "string" and #v > 0 then
				if #columnstr > 0 then
					columnstr = columnstr .. ','
				end
				columnstr = columnstr .. '`' .. v .. '`'
			end
		end
	elseif typ == "string" then
		columnstr = columns
	else
		return nil, "query columns type invalid!"
	end
	if #columnstr == 0 then
		columnstr = "*"
	end

	assert(conditions, "`conditions` must explicit!")
	typ = type(conditions)
	local condstr = ""
	if typ == "table" then
		for k, v in pairs(conditions) do
			if #condstr > 0 then
				condstr = condstr .. " AND "
			end
			if type(v) == "string" then
				v = mysql.quote_sql_str(v)
			end
			condstr = condstr .. '`' .. k .. "`=" .. v
		end
	elseif type == "string" then
		condstr = conditions
	else
		return nil, "conditions invalid!"
	end
	if #condstr ~= 0 then
		condstr = " WHERE " .. condstr
	end

	others = others or ""  -- group by, order by, limit ...
	if #others > 0 then others = " "..others end

	local q = "SELECT "..columnstr.." FROM "..tbl..condstr..others..";"
	return sqlaux.exec(db, q)
end


function sqlaux.update(db, tbls, kvmap, conditions)
	if type(tbls) == "table" then
		tbls = table.concat(tbls, ",")
	end
	assert(type(tbls) == "string" and #tbls > 0)

	local kvstr = ""
	for k, v in pairs(kvmap) do
		if #kvstr > 0 then
			kvstr = kvstr .. ","
		end
		if type(v) == "string" then
			v = mysql.quote_sql_str(v)
		end
		kvstr = kvstr .. '`' .. k .. "`=" .. v
	end

	assert(conditions, "`conditions` must explicit!")
	local typ = type(conditions)
	local condstr = ""
	if typ == "table" then
		for k, v in pairs(conditions) do
			if #condstr > 0 then
				condstr = condstr .. " AND "
			end
			if type(v) == "string" then
				v = mysql.quote_sql_str(v)
			end
			condstr = condstr .. '`' .. k .. "`=" .. v
		end
	elseif type == "string" then
		condstr = conditions
	else
		return nil, "conditions invalid!"
	end
	if #condstr ~= 0 then
		condstr = " WHERE " .. condstr
	end

	return sqlaux.exec(db, "UPDATE "..tbls.." SET "..kvstr..condstr..";")
end


function sqlaux.delete(db, tbl, conditions)
	assert(conditions, "`conditions` must explicit!")
	local typ = type(conditions)
	local condstr = ""
	if typ == "table" then
		for k, v in pairs(conditions) do
			if #condstr > 0 then
				condstr = condstr .. " AND "
			end
			if type(v) == "string" then
				v = mysql.quote_sql_str(v)
			end
			condstr = condstr .. '`' .. k .. "`=" .. v
		end
	elseif type == "string" then
		condstr = conditions
	else
		return nil, "conditions invalid!"
	end
	if #condstr ~= 0 then
		condstr = " WHERE " .. condstr
	end
	return sqlaux.exec(db, "DELETE FROM "..tbl..condstr..";")
end


return sqlaux
