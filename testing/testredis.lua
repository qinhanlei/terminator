-- https://www.cheatography.com/tasjaevan/cheat-sheets/redis/
local skynet = require "skynet"

local log = require "tm.log"
local xdump = require "tm.xtable".dump
local xredis = require "tm.db.xredis"

local conf = require("config_db").redis
local test_mode = ...


local function test_strings()
	log.info("Redis test strings ...")
	local cli = xredis.client()
	cli.set("hello", "world")
	log.debug("get hello :%s", xdump(cli.get("hello")))

	cli = xredis.client()
	cli.append("hello", 42)
	log.debug("GET hello :%s", xdump(cli.GET("hello")))

	cli = xredis.client()
	cli.set("ans", 41)
	cli.incrby("ans", 1)
	log.debug(cli.get("hello"))
	log.debug("get ans :%s", xdump(cli.get("ans")))
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
	local cli = xredis.client()
	cli.hset("h1", "id", 1)
	log.debug("hget h1 id :%s", xdump(cli.hget("h1", "id")))
	cli.hset("h1", "name", "hello1")
	log.debug("HGET h1 name :%s", xdump(cli.HGET("h1", "name")))
	log.debug("hgetall h1 :%s", xdump(cli.hgetall("h1")))

	cli = xredis.client()
	cli.hset("h2", "id", 2)
	cli.hset("h2", "name", "hello2")
	log.debug("HGETall h2 :%s", xdump(cli.HGETall("h2")))
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

	assert(xredis.init(conf, test_mode), "init failed!")

	test_strings()
	test_lists()
	test_sets()
	test_hashes()
	test_sorted_sets()
	test_hyperloglogs()

	xredis.clear()

	log.debug("Test of Redis done")
end)
