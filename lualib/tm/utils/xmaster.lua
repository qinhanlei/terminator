-- wrapper of master and slave, see testmaster for usage
local skynet = require "skynet"
local log = require "tm.log"

local string = string

local xmaster = {}


function xmaster.unique(filepath, mastername)
	if not mastername then
		mastername = ".xmaster_"..string.match(filepath, "[^/%.]+")
	end

	local m = {}

	function m.init(num, conf)
		local s = skynet.uniqueservice("tm/utils/master", mastername)
		skynet.call(s, "lua", "start", filepath, num, conf)
	end

	function m.clear()
		local s = skynet.localname(mastername)
		if s then
			skynet.call(s, "lua", "stop")
		end
	end

	function m.client()
		return setmetatable({}, {
			__index = function(_, key)
				return function(...)
					local c = skynet.call(mastername, "lua", "getslave")
					if not c then
						log.error("have no slave!")
						return
					end
					local ok, t = pcall(skynet.call, c, "lua", "exec", key, ...)
					if not ok then
						log.error("call failed: %s", t)
						return
					end
					return t
				end
			end
		})
	end

	return m
end

return xmaster
