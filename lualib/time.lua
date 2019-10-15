local time = {}


function time.nowstr()
	local t = os.date("*t")
	return string.format("%04d-%02d-%02d %02d:%02d:%02d", t.year, t.month, t.day, t.hour, t.min, t.sec)
end


return time
