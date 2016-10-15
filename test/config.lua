-- -------------------- Variables --------------------
local root = "./skynet/" -- root of skynet
local proj_name = "test"
local proj_path = "./" .. proj_name .. "/"
local common_lib = "./lualib/"
local common_svr = "./service/"

-- --------------------  Boostrap --------------------
thread = 4
bootstrap = "snlua bootstrap"	-- The service for bootstrap
start = "main"	-- main script


-- --------------------  Connection --------------------
harbor = 0


-- --------------------  Logger --------------------
logpath = "./logs"
-- logger = "tm_logger"
-- logservice = "snlua"


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
