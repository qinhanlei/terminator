local skynet = require "skynet"
local log = require "tm.log"

local _cmd = table.pack(...)

local ms = 1/1000
local us = ms/1000
local ns = us/1000

local CMD = {}


function CMD.number(n)
	local begin_time = skynet.hpc()

	for i = 1, n do
		log.debug("here is logging:%d", i)
	end

	local end_time = skynet.hpc()
	local cost = (end_time - begin_time)*ns
	log.debug("writed %d logs, cost time:%fs", n, cost)
end


function CMD.time(sec)
	local cnt = 0
	local is_time_up = false
	local begin_time = skynet.hpc()

	skynet.fork(function()
		while not is_time_up do
			cnt = cnt + 1
			log.debug("here is logging:%d", cnt)
			skynet.yield()
		end
		local end_time = skynet.hpc()
		local cost = (end_time - begin_time)*ns
		log.debug("writed %d logs, cost time:%fs", cnt, cost)
	end)

	skynet.timeout(sec*100, function()
		is_time_up = true
	end)
end


function process(cmd, ...)
	if not cmd then
		return
	end
	local f = CMD[cmd]
	if not f then
		log.error("cmd %s not found", tostring(cmd))
		return
	end
	f(...)
end


skynet.start(function()
	log.debug("Test of logger.")

	for k, logger in pairs(log) do
		logger("this is logging of `%s`", k)
	end

	log.debug("single string log")
	log.debug("single string log has valid option %s")
	log.debug("log with two string parameters,", "will concat by whitespace.")

	-- has format option will treat as string.format
	log.debug("log has %d valid format %s", 2, "options")
	log.debug("log has invalid option %z,", "will concat by whitespace.")
	log.debug("log has valid and invalid %s %z", "option") -- will cause error!

	process(table.unpack(_cmd))

	-- skynet.exit()
end)
