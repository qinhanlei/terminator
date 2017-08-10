
-- -------------------- Variables --------------------
local root = "./skynet/" -- root of skynet
-- the project path
local proj_name = 'hello-world'
local proj_path = './training/'..proj_name..'/'


-- --------------------  Boostrap --------------------
thread = 4

-- simpler way
bootstrap = "snlua main"

-- the normal way
--bootstrap = "snlua bootstrap"	-- The service for bootstrap
-- skynet/service/bootstrap.lua will run this lastly.
--start = "main"	-- main script


-- --------------------  Connection --------------------
harbor = 0
-- if harbor is 0, address,master,standalone are useless.
--address = "127.0.0.1:2526"
--master = "127.0.0.1:2013"
--standalone = "0.0.0.0:2013"
--cluster = nil


-- --------------------  Logger --------------------
logger = nil -- output log to console.
--logservice = "mylogger" -- customer log service as service_logger.c iml
--logpath = "./training/hello-world/"


-- -------------------- Path --------------------
cpath = root.."cservice/?.so"
lua_cpath = root.."luaclib/?.so;"..proj_path.."?.so"

lualoader = root.."lualib/loader.lua"
luaservice = root.."service/?.lua;"..proj_path..'?.lua'
lua_path = root.."lualib/?.lua;"..proj_path..'?.lua'
lua_path = root.."lualib/compat10/?.lua;"..lua_path --TODO: remove me

-- run preload.lua before every lua service run
--preload = "./examples/preload.lua"


-- -------------------- Snax --------------------
--snax = root.."examples/?.lua;"..root.."test/?.lua"
--snax_interface_g = "snax_g"


-- -------------------- Others --------------------
-- backgroud mode, need config 'logger'
--daemon = "./skynet.pid"
