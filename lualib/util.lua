local log = require "log"

local util = {}


function util.concat(t)
	if #t == 0 then return "nil" end
	local ret = ""
	for _, v in pairs(t) do
		if string.len(ret) == 0 then
			ret = tostring(v)
		else
			ret = ret .. " " .. tostring(v)
		end
	end
	return ret
end


local function _v(v)
	if type(v) == "string" then
		v = "\"" .. v .. "\""
	end
	return tostring(v)
end

function util.dump(value, desciption, nesting, logger)
	local print = logger or log.debug
	if type(nesting) ~= "number" then nesting = 3 end

	local lookupTable = {}
	local result = {}
	local traceback = string.split(debug.traceback("", 2), "\n")
	print("dump from: " .. string.trim(traceback[3]))

	local function _dump(value, desciption, indent, nest, keylen)
		desciption = desciption or "<var>"
		local spc = ""
		if type(keylen) == "number" then
			spc = string.rep(" ", keylen - string.len(_v(desciption)))
		end
		if type(value) ~= "table" then
			result[#result +1 ] = string.format("%s%s%s = %s", indent, _v(desciption), spc, _v(value))
		elseif lookupTable[value] then
			result[#result +1 ] = string.format("%s%s%s = *REF*", indent, desciption, spc)
		else
			lookupTable[value] = true
			if nest > nesting then
				result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, desciption)
			else
				result[#result +1 ] = string.format("%s%s = {", indent, _v(desciption))
				local indent2 = indent.."    "
				local keys = {}
				local keylen = 0
				local values = {}
				for k, v in pairs(value) do
					keys[#keys + 1] = k
					local vk = _v(k)
					local vkl = string.len(vk)
					if vkl > keylen then keylen = vkl end
					values[k] = v
				end
				table.sort(keys, function(a, b)
					if type(a) == "number" and type(b) == "number" then
						return a < b
					else
						return tostring(a) < tostring(b)
					end
				end)
				for _, k in ipairs(keys) do
					_dump(values[k], k, indent2, nest + 1, keylen)
				end
				result[#result +1] = string.format("%s}", indent)
			end
		end
	end
	_dump(value, desciption, "- ", 1)

	for _, line in ipairs(result) do
		print(line)
	end
end


return util
