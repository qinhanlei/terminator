local skynet = require "skynet"
local cluster = require "skynet.cluster"

local logger = require "simple-logger"
local util = require "util"

local nodename = skynet.getenv("nodename")
local dbgc_port = skynet.getenv("debug_console_port")

local svr_list = nil

local function hello()
	for node, _ in pairs(svr_list) do
		if node ~= nodename then
			-- node = node .. '-not-exist'
			logger("say hi to svr:"..node)
			local msg = {
				from = nodename,
				to = node,
				content = "Hi, "..node.."! here is "..nodename..".",
			}
			local addr = cluster.query(node, "greeting")
			local ok = pcall(cluster.call, node, addr, "hi", msg)
			if not ok then
				logger("send hi to "..node.." failed!")
			end
		end
	end
end

local function tick_tock()
	local f = tick_tock
	skynet.timeout(100 * 1, function()
		if f then
			f()
		end
	end)

	local ok, ret = pcall(hello)
	if not ok then
		logger("tick_tock hello failed!", tostring(ret))
		-- skynet.timeout(100 * 1, tick_tock)
	else
		f = nil
	end
end

skynet.start(function()
	logger("server node:"..nodename.."started !")

	local greeting = skynet.uniqueservice("greeting")
	cluster.register("greeting", greeting)
	cluster.open(nodename)

	svr_list = util.load_clusters(skynet.getenv "cluster")
	util.dump(svr_list)

	skynet.newservice("debug_console", dbgc_port)
	skynet.newservice("console")

	skynet.fork(tick_tock)
end)
