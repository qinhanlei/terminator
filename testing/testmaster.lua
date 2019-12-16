local skynet = require "skynet"
local log = require "tm.log"

local xmaster = require "tm.utils.xmaster"
local conf = require("config_db").redis

local redismaster = xmaster.unique("redislogic")


local function test_strings()
	log.info("Redis test strings ...")
	local cli = redismaster.client()
	cli.set("hello1", "world")
	log.debug(cli.get("hello1"))

	cli = redismaster.client()
	cli.append("hello1", 42)
	log.debug(cli.get("hello1"))

	cli = redismaster.client()
	cli.set("ans1", 41)
	cli.incrby("ans1", 1)
	log.debug(cli.get("ans1"))
end


skynet.start(function()
	log.debug("Test of Master.")

	redismaster.init(conf.connects, conf)
	test_strings()

	log.debug("Test of Master done.")
end)
