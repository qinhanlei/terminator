-- https://www.cheatography.com/tasjaevan/cheat-sheets/redis/
local skynet = require "skynet"

local log = require "tm.log"
local xredis = require "tm.db.xredis"

local conf = require("config_db").redis
local test_mode = ...


local function test_strings()
	log.info("Redis test strings ...")
	local cli = xredis.client()
	cli.set("hello", "world")
	log.debug(cli.get("hello"))

	cli = xredis.client()
	cli.append("hello", 42)
	log.debug(cli.get("hello"))

	cli = xredis.client()
	cli.set("ans", 41)
	cli.incrby("ans", 1)
	log.debug(cli.get("ans"))
end


local function test_lists()
	log.info("Redis test strings ...")
	--TODO: ...
end


local function test_sets()
	log.info("Redis test sets ...")
	--TODO: ...
end


local function test_hashes()
	log.info("Redis test hashes ...")
	--TODO: ...
end


local function test_sorted_sets()
	log.info("Redis test sorted sets ...")
	--TODO: ...
end


local function test_hyperloglogs()
	log.info("Redis test hyperloglogs ...")
	--TODO: ...
end


skynet.start(function()
	log.debug("Test of Redis")

	xredis.init(conf, test_mode)

	test_strings()
	test_lists()
	test_sets()
	test_hashes()
	test_sorted_sets()
	test_hyperloglogs()

	xredis.clear()

	log.debug("Test of Redis done")
end)
