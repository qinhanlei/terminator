-- https://www.cheatography.com/tasjaevan/cheat-sheets/redis/
local skynet = require "skynet"

local log = require "tm.log"
local redisutil = require "tm.db.redisutil"

local conf = require("config_db").redis


local function test_strings()
	log.info("Redis test strings ...")
	local cli = redisutil.client()
	cli.set("hello", "world")
	log.debug(cli.get("hello"))
	cli.append("hello", 42)
	log.debug(cli.get("hello"))
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

	redisutil.init(conf)
	test_strings()
	test_lists()
	test_sets()
	test_hashes()
	test_sorted_sets()
	test_hyperloglogs()

	log.debug("Test of Redis done")
end)
