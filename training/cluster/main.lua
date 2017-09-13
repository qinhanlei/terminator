local skynet = require "skynet"
local cluster = require "cluster"

local logger = require "simple-logger"
local util = require "util"

local nodename = skynet.getenv("nodename")

local svr_list = nil

local function hello()
	for node, v in pairs(svr_list) do
		if node ~= nodename then
			logger("say hi to svr:"..node)
			local msg = {
				from = nodename,
				to = node,
				content = "Hi, "..node.."! here is "..nodename..".",
			}
			local addr = cluster.query(node, "greeting")
			local ok = pcall(cluster.call, node, addr, "hi", msg)
			if not ok then
				logger("send hi to "..k.." failed!")
			end
		end
	end
end

local function tick_tock()
	local ok, ret = pcall(hello)
	if not ok then
		logger("tick_tock hello failed!", tostring(ret))
		skynet.timeout(100 * 1, tick_tock)
	end
end

skynet.start(function()
	logger("server node:"..nodename.."started !")
	
	local greeting = skynet.uniqueservice("greeting")
	cluster.register("greeting", greeting)
	cluster.open(nodename)
	
	svr_list = util.load_clusters(skynet.getenv "cluster")
	util.dump(svr_list)
	
	skynet.fork(tick_tock)
	
end)
