local table = table
local string = string

local xtable = setmetatable({}, {__index = table})

function xtable.size(t)
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

function xtable.dump(t, dep)
	if not t then return "nil" end
	if type(t) == "string" then return '"'..t..'"' end
	if type(t) ~= "table" then return tostring(t) end
	if xtable.size(t) == 0 then return "{}" end
	dep = dep or 1
	if dep > 5 then return "{ ** MAX DEPTH ** }" end
	local vlst = {}
	local tabs0 = string.rep(" ", (dep-1) * 2)
	local tabs1 = string.rep(" ", dep * 2)
	for k, v in pairs(t) do
		if type(k) == "number" then
			k = "["..k.."]"
		end
		if type(v) == "table" then
			v = xtable.dump(v, dep+1)
		elseif type(v) == "string" then
			v = '"'..v..'"'
		end
		table.insert(vlst, tostring(k).." = "..tostring(v)..',')
	end
	return "{\n"..tabs1..
			table.concat(vlst, "\n"..tabs1)..
			"\n"..tabs0.."}"
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
