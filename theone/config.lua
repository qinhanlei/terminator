-- this is all in one node, could be cluster

nodename = "$NODE_NAME"
thread = "$SKYNET_THREAD"
harbor = 0

start = "main"
bootstrap = "snlua bootstrap"
preload = "./lualib/preload.lua"

logpath = "./logs"
logger = "tlogger"
logservice = "snlua"
lualoader = "./skynet/lualib/loader.lua"

cpath = "./skynet/cservice/?.so;"..
		"./cservice/?.so"
lua_cpath = "./skynet/luaclib/?.so;"..
			"./luaclib/?.so"..
			"./theone/?.so"

luaservice = "./skynet/service/?.lua;"..
			"./service/?.lua;"..
			"./theone/?.lua"
lua_path = "./skynet/lualib/?.lua;"..
			"./service/?.lua;"..
			"./lualib/?.lua;"..
			"./theone/?.lua"
