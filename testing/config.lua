
nodename = "test"

thread = 4
harbor = 0

start = "main"
bootstrap = "snlua bootstrap"
preload = "./lualib/preload.lua"

logpath = "./logs"
logger = "tlogger"
logservice = "snlua"

cpath = "./skynet/cservice/?.so"
lua_cpath = "./skynet/luaclib/?.so;./testing/?.so"
lualoader = "./skynet/lualib/loader.lua"
luaservice = "./skynet/service/?.lua;./service/?.lua;./testing/?.lua"
lua_path = "./skynet/lualib/?.lua;"..
			"./service/?.lua;"..
			"./lualib/?.lua;"..
			"./testing/?.lua"
