
function string.split(input, delimiter)
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


function string.ltrim(input)
	return string.gsub(input, "^[ \t\n\r]+", "")
end


function string.rtrim(input)
	return string.gsub(input, "[ \t\n\r]+$", "")
end


function string.trim(input)
	input = string.gsub(input, "^[ \t\n\r]+", "")
	return string.gsub(input, "[ \t\n\r]+$", "")
end


function table.nums(t)
	local count = 0
	for k, v in pairs(t) do
		count = count + 1
	end
	return count
end

