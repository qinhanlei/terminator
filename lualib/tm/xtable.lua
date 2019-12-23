local table = table
local string = string
local tostring = tostring

local xtable = {}
local INDENT = string.rep(" ", 2)


function xtable.concat(list, sep)
	local result, v
	sep = sep or ""
	for i = 1, #list do
		v = tostring(list[i])
		if result then
			result = result .. sep .. v
		else
			result = v
		end
	end
	return result
end


function xtable.size(t)
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end


function xtable.dump(t)
	if not t then return "nil" end
	if type(t) == "string" then return '"'..t..'"' end
	if type(t) ~= "table" then return tostring(t) end
	local cache = { [t] = "." }
	local function dump(tbl, dep, tag)
		if xtable.size(tbl) == 0 then return "{}" end
		if dep > 8 then return "{ * MAX DEPTH * }" end
		local vlst = { "{" }
		for k, v in pairs(tbl) do
			if type(k) ~= "string" then
				k = "["..tostring(k).."]"
			end
			if type(v) == "table" then
				if cache[v] then
					v = "{ "..cache[v].." }"
				else
					cache[v] = tag..'.'..k
					v = dump(v, dep+1, tag..'.'..k)
				end
			elseif type(v) == "string" then
				v = '"'..v..'"'
			end
			table.insert(vlst, tostring(k).." = "..tostring(v)..',')
		end
		return table.concat(vlst, "\n"..string.rep(INDENT, dep))..
				"\n"..string.rep(INDENT, dep-1).."}"
	end
	return dump(t, 1, "")
end


-- https://blog.codingnow.com/cloud/LuaSerializeTable
function xtable.serialize(t)
	local mark = {}
	local assign = {}
	local function ser_table(tbl, parent)
		mark[tbl] = parent
		local tmp = {}
		for k, v in pairs(tbl) do
			local key = type(k) == "number" and "[" .. k .. "]" or k
			if type(v) == "table" then
				local dotkey = parent .. (type(k) == "number" and key or "." .. key)
				if mark[v] then
					table.insert(assign, dotkey .. "=" .. mark[v])
				else
					table.insert(tmp, key .. "=" .. ser_table(v, dotkey))
				end
			else
				table.insert(tmp, key .. "=" .. v)
			end
		end
		return "{" .. table.concat(tmp, ",") .. "}"
	end
	return "do local ret=" .. ser_table(t, "ret") .. table.concat(assign, " ") .. " return ret end"
end


return xtable
