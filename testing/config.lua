
nodename = "$NODE_NAME"
thread = "$SKYNET_THREAD"
harbor = 0

start = "main"
bootstrap = "snlua bootstrap"

logpath = "./logs"
logger = "tm/logger"
logservice = "snlua"
lualoader = "./skynet/lualib/loader.lua"

cpath = "./skynet/cservice/?.so;"..
		"./cservice/?.so"
lua_cpath = "./skynet/luaclib/?.so;"..
			"./luaclib/?.so"..
			"./testing/?.so"

luaservice = "./skynet/service/?.lua;"..
			"./service/?.lua;"..
			"./testing/?.lua"
lua_path = "./skynet/lualib/?.lua;"..
			"./service/?.lua;"..
			"./lualib/?.lua;"..
			"./testing/?.lua"
