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
	local vlst = {}
	local tabs = string.rep(" ", (dep or 1) * 2)
	for k, v in pairs(t) do
		xtable.dump(t)
	end
	if xtable.size(vlst) > 1 then
		return "" .. table.concat(vlst, "\n"..sep, i, j)
	end
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
