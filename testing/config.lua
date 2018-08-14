-- -------------------- Variables --------------------
local root = "./skynet/" -- root of skynet
local proj_name = "testing"
local proj_path = "./" .. proj_name .. "/"
local common_lib = "./lualib/"
local common_svr = "./service/"

nodename = proj_name

-- --------------------  Boostrap --------------------
thread = 4
bootstrap = "snlua bootstrap"	-- The service for bootstrap
start = "main"	-- main script
preload = "./lualib/preload.lua"	-- run preload.lua before every lua service run


-- --------------------  Connection --------------------
harbor = 0


-- --------------------  Logger --------------------
logpath = "./logs"
logger = "tlogger"
logservice = "snlua"


-- -------------------- Path --------------------
cpath = root.."cservice/?.so"
lua_cpath = root.."luaclib/?.so;"..proj_path.."?.so"

lualoader = root.."lualib/loader.lua"

luaservice = root.."service/?.lua;"..
			common_svr.."?.lua;"..
			proj_path..'?.lua'

lua_path = root.."lualib/?.lua;"..
			common_svr.."?.lua;"..
			common_lib.."?.lua;"..
			proj_path..'?.lua'
lua_path = root.."lualib/compat10/?.lua;"..lua_path --TODO: remove me
