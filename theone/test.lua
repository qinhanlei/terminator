local skynet = require "skynet"
local log = require "log"

skynet.start(function()
	for i = 1, 2 do
		skynet.newservice("client", i)
	end
end)
