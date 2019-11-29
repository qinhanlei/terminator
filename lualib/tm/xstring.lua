local table = table
local string = string

local xstring = setmetatable({}, {__index = string})


function xstring.split(input, delimiter)
	input = tostring(input)
	delimiter = tostring(delimiter)
	if delimiter == '' then
		return false
	end
	local pos, arr = 0, {}
	for st, sp in function() return string.find(input, delimiter, pos, true) end do
		table.insert(arr, string.sub(input, pos, st - 1))
		pos = sp + 1
	end
	table.insert(arr, string.sub(input, pos))
	return arr
end


function xstring.ltrim(input)
	return string.gsub(input, "^[ \t\n\r]+", "")
end


function xstring.rtrim(input)
	return string.gsub(input, "[ \t\n\r]+$", "")
end


function xstring.trim(input)
	return xstring.rtrim(xstring.ltrim(input))
end


return xstring
